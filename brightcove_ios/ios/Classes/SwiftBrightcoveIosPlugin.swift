import Flutter
import UIKit
import BrightcovePlayerSDK

public class SwiftBrightcoveIosPlugin: NSObject, FlutterPlugin, BrightcoveVideoPlayerApi {
    
    var registrar: FlutterPluginRegistrar?;
    private var players: [String:BCovePlayer] = [:]
    
    public init(with registrar: FlutterPluginRegistrar) {
        super.init()
        self.registrar = registrar
        BrightcoveVideoPlayerApiSetup.setUp(binaryMessenger: registrar.messenger(), api: self)
    }
    
  public static func register(with registrar: FlutterPluginRegistrar) {
      registrar.addApplicationDelegate(SwiftBrightcoveIosPlugin(with: registrar))
  }

    func initialize() {
        disposeAll()
    }
    
    private func disposeAll() {
        for p in players {
            p.value.dispose()
        }
        players.removeAll()
    }
    
    func create(msg: PlayMessage) -> TextureMessage {
        let id = String(Date().timeIntervalSince1970)
        let player = BCovePlayer()
        let channel = FlutterEventChannel(name: "brightcove_videoplayer/videoEvents\(id)", binaryMessenger: registrar!.messenger())
        channel.setStreamHandler(player)
        
        let factory = PlayerFactory(player: player, msg: msg)
        registrar?.register(factory, withId: "brightcove_videoplayer#\(id)")
        players[id] = player
        return TextureMessage.init(playerId: id)
    }
    
    func dispose(msg: TextureMessage) {
        players[msg.playerId]?.dispose()
    }
    
    func setVolume(msg: VolumeMessage) {
        
    }
    
    func enterPictureInPictureMode(msg: TextureMessage) {
        
    }
    
    func play(msg: TextureMessage) {
        players[msg.playerId]?.play()
    }
    
    func pause(msg: TextureMessage) {
        players[msg.playerId]?.pause()
    }
    
    func seekTo(msg: PositionMessage) {
        players[msg.playerId]?.seekTo(position: CMTimeMake(value: Int64(msg.position), timescale: 1))
    }
    

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
  }
}


public class PlayerFactory: NSObject, FlutterPlatformViewFactory {
    
    var player: BCovePlayer?
    var msg: PlayMessage?
    init(player: BCovePlayer, msg: PlayMessage) {
        self.player = player
        self.msg = msg
    }

    public func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        player!.initialize(message: msg!)
        return player!
    }
}

public class VideoView: NSObject, FlutterPlatformView {
    
    public func view() -> UIView {
        return BCOVPUIPlayerView()
    }
}

public class BCovePlayer: FlutterEventChannel, FlutterPlatformView, FlutterStreamHandler {

    private var eventSink: FlutterEventSink?
    private var controller: BCOVPlaybackController?
    private var playbackService: BCOVPlaybackService!

    lazy private var manager: BCOVPlayerSDKManager = {
         let _manager = BCOVPlayerSDKManager.shared()!
         return _manager
     }()
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }
    
    public override init() {
        super.init()
    }
    
    public func view() -> UIView {
        if let controller = controller {
            self.controller = controller
        } else {
            self.controller = self.manager.createPlaybackController()
        }
        return BCOVPUIPlayerView(playbackController: controller)
    }
    
    func play() {
        controller?.play()
    }
    
    func pause() {
        controller?.pause()
    }
    
    func dispose() {
        controller?.pause()
        playbackService = nil
        controller = nil
    }
    
    func seekTo(position: CMTime) {
        if #available(iOS 13.0, *) {
            Task {
                await self.controller?.seek(to: position)
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    func initialize(message: PlayMessage) {
        if let controller = controller {
            self.controller = controller
        } else {
            self.controller = self.manager.createPlaybackController()
        }
        
        self.playbackService = BCOVPlaybackService(accountId: message.account, policyKey: message.policy)
      
        switch message.dataSourceType {
            case .playlistById:
            self.playbackService.findPlaylist(withPlaylistID: message.dataSource, parameters: nil, completion: {
                (list: BCOVPlaylist?, jsonResponse: [AnyHashable:Any]?, error: Error?) in
                if let list = list {
                    self.controller?.isAutoPlay = true
                    self.controller?.setVideos([list.allPlayableVideos.first] as NSFastEnumeration)
                }
            })
            case .videoById:
            self.playbackService.findVideo(withVideoID: message.dataSource, parameters: nil, completion: {
                (video: BCOVVideo?, jsonResponse: [AnyHashable:Any]?, error: Error?) in
                if let video = video {
                    self.controller?.isAutoPlay = true
                    self.controller!.setVideos([video] as NSFastEnumeration)
                    self.eventSink?([
                        "event": "initialized",
                        "duration": 30
                    ])
                }
            })
        }
    }
    
    
    
}

import Flutter
import UIKit
import BrightcovePlayerSDK

public class SwiftBrightcoveIosPlugin: NSObject, FlutterPlugin, BrightcoveVideoPlayerApi {
    
    var registrar: FlutterPluginRegistrar?
    private var players: [String:BCovePlayer] = [:]
    
    public init(with registrar: FlutterPluginRegistrar) {
        super.init()
        self.registrar = registrar
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
          let plugin = SwiftBrightcoveIosPlugin(with: registrar)
          registrar.addApplicationDelegate(plugin)
          BrightcoveVideoPlayerApiSetup.setUp(binaryMessenger: registrar.messenger(),
                                              api: plugin)
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
        debugPrint("[swiftPlugin] playerView id \(id)")
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

public class BCovePlayer: FlutterEventChannel, FlutterPlatformView, FlutterStreamHandler {

    private var eventSink: FlutterEventSink?
    private var controller: BCOVPlaybackController?
    {
        didSet {
            controller?.delegate = self
        }
    }
    private var playbackService: BCOVPlaybackService!
    private var currentVideo: BCOVVideo?
    private var isInitted = false
    private var didComplete = false

    lazy private var manager: BCOVPlayerSDKManager = {
         let _manager = BCOVPlayerSDKManager.shared()!
         return _manager
     }()
    
    lazy private var playerView: UIView = {
        if let controller = controller {
            self.controller = controller
        } else {
            self.controller = self.manager.createPlaybackController()
        }
        guard let playerView = BCOVPUIPlayerView(playbackController: controller) else { return BCOVPUIPlayerView(playbackController: controller) }
        playerView.controlsContainerView.alpha = 0
        return playerView
    }()
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        // if the video loaded before the onListen is called, then send the initialized event on the stream
//        if let _ = self.currentVideo, !isInitted {
//            sendInitializedEvent(duration: 30000)
//            self.isInitted = true
//        }
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
        return self.playerView
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

        // Optimize buffering by keeping them at low values
        // so the multiple players don't use up too much memory
        // https://github.com/brightcove/brightcove-player-sdk-ios#BufferOptimization
        if var options = self.controller?.options {
            options[kBCOVBufferOptimizerMethodKey] = NSNumber(value: BCOVBufferOptimizerMethod.default.rawValue)
            options[kBCOVBufferOptimizerMinimumDurationKey] = 1
            options[kBCOVBufferOptimizerMaximumDurationKey] = 5
            self.controller?.options = options
        }

        // Caching the thumbnail images for multiple videos
        // will use up a lot of memory so we'll disable this feature
        self.controller?.thumbnailSeekingEnabled = false
        
        self.playbackService = BCOVPlaybackService(accountId: message.account, policyKey: message.policy)
        let queryParams = [ "rendition": "video2000" ]
        switch message.dataSourceType {
            case .playlistById:
            self.playbackService.findPlaylist(withPlaylistID: message.dataSource, parameters: queryParams, completion: {
                (list: BCOVPlaylist?, jsonResponse: [AnyHashable:Any]?, error: Error?) in
                if let list = list {
                    self.controller?.isAutoPlay = false
                    self.controller?.setVideos([list.allPlayableVideos.first] as NSFastEnumeration)
                }
            })
            case .videoById:
            self.playbackService.findVideo(withVideoID: message.dataSource, parameters: queryParams, completion: {
                (video: BCOVVideo?, jsonResponse: [AnyHashable:Any]?, error: Error?) in
                if let video = video {
                    self.currentVideo = video
                    self.controller?.isAutoPlay = false
                    self.controller?.setVideos([video] as NSFastEnumeration)
                }
            })
        }
    }
    
    /// duration in millisecond
    func sendInitializedEvent(duration: Int) {
        if (!isInitted) {
            self.isInitted = true
            self.eventSink?([
                "event": "initialized",
                "videoHeight": 0, // self.playerView.frame.height,
                "videoWidth": 0, // self.playerView.frame.width,
                "duration": duration
            ])
        }
    }
}

extension BCovePlayer: BCOVPlaybackControllerDelegate {
    public func playbackController(_ controller: BCOVPlaybackController!, playbackSession session: BCOVPlaybackSession!, didProgressTo progress: TimeInterval) {
         guard let currentItem = session.player.currentItem else { return }
        
        if !isInitted && (!currentItem.duration.seconds.isZero && !currentItem.duration.seconds.isNaN) {
            self.sendInitializedEvent(duration: Int(currentItem.duration.seconds * 1000))
        }
        
        self.eventSink?(["event": "playProgress", "position": progress])
        
        debugPrint("[swift][\(currentItem.duration.seconds)][\(progress)]")
        
        if  (progress.isInfinite && progress > 0 && !didComplete) {
            self.didComplete = true
            self.eventSink?(["event": "completed"])
            
        }
    }
}

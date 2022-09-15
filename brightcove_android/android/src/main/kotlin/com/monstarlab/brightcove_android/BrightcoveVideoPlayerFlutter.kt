package com.monstarlab.brightcove_android

import android.content.Context
import android.view.View
import com.brightcove.player.edge.Catalog
import com.brightcove.player.edge.CatalogError
import com.brightcove.player.edge.PlaylistListener
import com.brightcove.player.edge.VideoListener
import com.brightcove.player.event.Event
import com.brightcove.player.event.EventType
import com.brightcove.player.mediacontroller.BrightcoveMediaController
import com.brightcove.player.model.Playlist
import com.brightcove.player.model.Video
import com.brightcove.player.view.BrightcoveExoPlayerVideoView
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.platform.PlatformView


class BrightcoveVideoPlayerFlutter : PlatformView, EventChannel.StreamHandler {

    private lateinit var videoView: BrightcoveExoPlayerVideoView
    private lateinit var videoViewCatalog: Catalog
    private lateinit var mediaController: BrightcoveMediaController
    private var isInitialized = false
    private var autoplay = false
    private var eventSink: EventChannel.EventSink? = null


    fun isPlaying() = videoView.isPlaying

    fun initialize(context: Context, msg: Messages.PlayMessage) {
        videoView = BrightcoveExoPlayerVideoView(context)
        videoView.finishInitialization()

        mediaController = BrightcoveMediaController(videoView)
        mediaController.isShowControllerEnable = false // hide default controller actions
        videoView.setMediaController(mediaController)
        videoView.analytics.account = msg.account

        val baseUrl =
            if (msg.catalogBaseUrl == null) Catalog.DEFAULT_EDGE_BASE_URL else msg.catalogBaseUrl
        videoViewCatalog = Catalog.Builder(this.videoView.eventEmitter, msg.account)
            .setPolicy(msg.policy)
            .setBaseURL(baseUrl!!)
            .build()

        subscribeToEvents()

        val dataSource = msg.dataSource
        when (msg.dataSourceType) {
            Messages.DataSourceType.VIDEO_BY_ID -> {
                videoViewCatalog.findVideoByID(dataSource, object : VideoListener() {
                    override fun onVideo(p0: Video) {
                        videoView.add(p0)
                        isInitialized = true
                        if (autoplay) {
                            videoView.start()
                        }
                        val event: MutableMap<String, Any> = HashMap()
                        event["event"] = "initialized"
                        event["duration"] = p0.durationLong
                        eventSink?.success(event)
                    }

                    override fun onError(errors: MutableList<CatalogError>) {
                        super.onError(errors)
                        eventSink?.error("BrightcoveVideoPlayerError",
                            "Brightcove had a error: ${errors.first()}", null)
                    }
                })
            }
            Messages.DataSourceType.PLAYLIST_BY_ID -> {
                videoViewCatalog.findPlaylistByID(dataSource, object : PlaylistListener() {
                    override fun onPlaylist(p0: Playlist?) {
                        if (p0 != null) {
                            videoView.addAll(p0.videos)
                            isInitialized = true
                            if (autoplay) {
                                videoView.start()
                            }
                            val event: MutableMap<String, Any> = HashMap()
                            event["event"] = "initialized"
                            event["duration"] = p0.videos.first().durationLong
                            eventSink?.success(event)
                        }
                    }

                    override fun onError(errors: MutableList<CatalogError>) {
                        super.onError(errors)
                        eventSink?.error("BrightcoveVideoPlayerError",
                            "Brightcove had a error: ${errors.first()}", null)
                    }
                })
            }
        }
    }

    private fun subscribeToEvents() {
        videoView.eventEmitter.on(EventType.BUFFERING_STARTED) {
            val event: MutableMap<String, Any> = HashMap()
            event["event"] = "bufferingStart"
            eventSink?.success(event)
        }
        videoView.eventEmitter.on(EventType.BUFFERING_COMPLETED) {
            val event: MutableMap<String, Any> = HashMap()
            event["event"] = "bufferingCompleted"
            eventSink?.success(event)
        }
        videoView.eventEmitter.on(EventType.BUFFERED_UPDATE) {
            val event: MutableMap<String, Any> = HashMap()
            event["event"] = "bufferedUpdate"
            eventSink?.success(event)
        }
        videoView.eventEmitter.on(EventType.PROGRESS) {
            val event: MutableMap<String, Any> = HashMap()
            event["event"] = "playProgress"
            // TODO: fix progress not being delivered to Flutter
            event["position"] = videoView.videoDisplay.playerCurrentPosition
            eventSink!!.success(event)
        }
        videoView.eventEmitter.on(EventType.COMPLETED) {
            val event: MutableMap<String, Any> = HashMap()
            event["event"] = "completed"
            eventSink?.success(event)
        }
    }

    fun play() {
        if (!isInitialized) {
            autoplay = true
            return
        }
        videoView.start()
    }

    fun pause() = videoView.pause()

    fun seekTo(position: Long) {
        videoView.seekTo(position)
    }

    fun enablePiP() {
        val pipManager = videoView.pictureInPictureManager
        if (pipManager.isInPictureInPictureMode) {
            pipManager.enterPictureInPictureMode()
            // TODO: implement Picture-in-Picture mode.
        }
    }

    fun setVolume(volume: Long) {
        val properties: MutableMap<String, Any> = HashMap()
        properties[Event.VOLUME] = volume.toFloat()
        videoView.eventEmitter.emit(EventType.SET_VOLUME, properties)
    }

    override fun getView(): View {
        return videoView
    }

    // Dispose view
    override fun dispose() {
        videoView.clear()
        eventSink?.endOfStream()
        eventSink = null
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink?.endOfStream()
        eventSink = null
    }
}

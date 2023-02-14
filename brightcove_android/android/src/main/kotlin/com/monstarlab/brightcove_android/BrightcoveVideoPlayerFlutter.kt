package com.monstarlab.brightcove_android

import android.app.Activity
import android.content.Context
import android.net.Uri
import android.view.View
import com.brightcove.player.captioning.BrightcoveCaptionFormat
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

    fun initialize(context: Context, msg: Messages.PlayMessage) {
        videoView = BrightcoveExoPlayerVideoView(context)
        videoView.finishInitialization()

        mediaController = BrightcoveMediaController(videoView)
        mediaController.isShowControllerEnable = false // hide default controller actions
        videoView.setMediaController(mediaController)
        videoView.analytics.account = msg.account
        val options = mapOf("rendition" to "video2000")
        val baseUrl =
            if (msg.catalogBaseUrl == null) Catalog.DEFAULT_EDGE_BASE_URL else msg.catalogBaseUrl
        videoViewCatalog = Catalog.Builder(this.videoView.eventEmitter, msg.account)
            .setPolicy(msg.policy)
            .setBaseURL(baseUrl!!)
            .setProperties(options)
            .build()

        subscribeToEvents()

        val dataSource = msg.dataSource
        when (msg.dataSourceType) {
            Messages.DataSourceType.VIDEO_BY_ID -> {
                videoViewCatalog.findVideoByID(dataSource, object : VideoListener() {
                    override fun onVideo(p0: Video) {
                        videoView.add(p0)
                        isInitialized = true
                        sendInitializedEvent(p0)
                        if (autoplay) {
                            videoView.start()
                        }
                    }

                    override fun onError(errors: MutableList<CatalogError>) {
                        super.onError(errors)
                        eventSink?.error(
                            "BrightcoveVideoPlayerError",
                            "Brightcove had a error: ${errors.first()}", null
                        )
                    }
                })
            }
            Messages.DataSourceType.PLAYLIST_BY_ID -> {
                videoViewCatalog.findPlaylistByID(dataSource, object : PlaylistListener() {
                    override fun onPlaylist(p0: Playlist?) {
                        if (p0 != null) {
                            videoView.addAll(p0.videos)
                            isInitialized = true
                            sendInitializedEvent(p0.videos.first())
                            if (autoplay) {
                                videoView.start()
                            }
                        }
                    }

                    override fun onError(errors: MutableList<CatalogError>) {
                        super.onError(errors)
                        eventSink?.error(
                            "BrightcoveVideoPlayerError",
                            "Brightcove had a error: ${errors.first()}", null
                        )
                    }
                })
            }
        }
    }

    fun sendInitializedEvent(video: Video) {
        val props = video.properties
        videoView.setClosedCaptioningEnabled(true)

        val event: MutableMap<String, Any> = HashMap()
        event["event"] = "initialized"
        event["duration"] = video.durationLong
        event["videoWidth"] = videoView.videoWidth
        event["videoHeight"] = videoView.videoHeight
        eventSink?.success(event)
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
            event["position"] = videoView.videoDisplay.playerCurrentPosition
            eventSink!!.success(event)
        }
        videoView.eventEmitter.on(EventType.COMPLETED) {
            val event: MutableMap<String, Any> = HashMap()
            event["event"] = "completed"
            eventSink?.success(event)
        }
        videoView.eventEmitter.on(EventType.CAPTIONS_LANGUAGES) {
            // You could find the desired language in the LANGUAGES list.
            // List<String> languages = event.getProperty(Event.LANGUAGES, List.class);
            selectCaption(videoView.currentVideo, "en")

            val event: MutableMap<String, Any> = HashMap()
            event["event"] = "captionsAvailable"

            val languages = it.properties[Event.LANGUAGES]
            if (languages != null) {
                print("CAPTION-LANGUAGES: $languages")
                event["languages"] = languages
            }
            eventSink!!.success(event)
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

    fun enterPiPMode(activity: Activity?) {
        if (activity == null)  return
/*
        val pipManager = videoView.pictureInPictureManager
        pipManager.registerActivity(activity, videoView)
        pipManager.enterPictureInPictureMode()*/
        // TODO: complete PiP support
    }

    @Suppress("UNCHECKED_CAST")
    private fun getCaptionsForLanguageCode(
        video: Video?,
        languageCode: String
    ): Pair<Uri?, BrightcoveCaptionFormat?>? {
        val payload = video?.properties?.get(Video.Fields.CAPTION_SOURCES)
        if (payload is List<*>) {
            val pairs: List<Pair<Uri, BrightcoveCaptionFormat>> =
                payload as List<Pair<Uri, BrightcoveCaptionFormat>>
            for (pair in pairs) {
                if (pair.second.language().equals(languageCode)) {
                    return pair
                }
            }
        }
        return null
    }

    private fun selectCaption(video: Video, language: String) {
        val pair = getCaptionsForLanguageCode(video, language)
        if (pair != null && pair.first!! != Uri.EMPTY) {
            // BrightcoveCaptionFormat.BRIGHTCOVE_SCHEME indicates that is not a URL we need to load with the LoadCaptionsService, but instead we'll be enabled through a different component.
            if (!pair.first.toString().startsWith(BrightcoveCaptionFormat.BRIGHTCOVE_SCHEME)) {
                videoView.closedCaptioningController.loadCaptionsService
                    .loadCaptions(pair.first, pair.second!!.type())
            }
            val properties: MutableMap<String, Any?> = HashMap()
            properties[Event.CAPTION_FORMAT] = pair.second
            properties[Event.CAPTION_URI] = pair.first
            videoView.eventEmitter
                .emit(EventType.SELECT_CLOSED_CAPTION_TRACK, properties)
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

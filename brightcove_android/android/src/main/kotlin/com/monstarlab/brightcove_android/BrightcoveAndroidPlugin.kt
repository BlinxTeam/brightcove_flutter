package com.monstarlab.brightcove_android

import android.content.Context
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import io.flutter.plugin.platform.PlatformViewRegistry
import io.flutter.view.TextureRegistry
import java.util.*

/** BrightcovePlayerFlutterPlugin */
class BrightcoveAndroidPlugin : FlutterPlugin, Messages.BrightcoveVideoPlayerApi {

    companion object {
        const val VIEW_TYPE = "brightcove_videoplayer"
    }

    private var pluginState: PluginState? = null
    private val players = mutableMapOf<String, BrightcoveVideoPlayerFlutter>()

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        Messages.BrightcoveVideoPlayerApi.setup(binding.binaryMessenger, this)
        this.pluginState = PluginState(
            binding.applicationContext,
            binding.binaryMessenger,
            binding.textureRegistry,
            binding.platformViewRegistry,
        )
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        for (p in players.values) {
            p.dispose()
        }
        pluginState = null
    }

    override fun initialize() {
        disposeAllPlayers()
    }

    private fun disposeAllPlayers() {
        for (player in players.values) {
            player.dispose()
        }
        players.clear()
    }

    override fun create(msg: Messages.PlayMessage): Messages.TextureMessage {
        val id = Calendar.getInstance().timeInMillis.toString()
        val videoPlayer = BrightcoveVideoPlayerFlutter()
        val instanceChannel = EventChannel(pluginState!!.binaryMessenger,"brightcove_videoplayer/videoEvents$id")
        instanceChannel.setStreamHandler(videoPlayer)

        pluginState!!.platformViewRegistry.registerViewFactory(
            "$VIEW_TYPE#$id",
            object : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
                override fun create(context: Context?, viewId: Int, args: Any?): PlatformView {
                    videoPlayer.initialize(context!!, msg)
                    return videoPlayer
                }
            },
        )
        players[id] = videoPlayer
        return Messages.TextureMessage.Builder()
            .setPlayerId(id)
            .build()
    }

    override fun dispose(msg: Messages.TextureMessage) {
        players[msg.playerId]?.dispose()
    }

    override fun setVolume(msg: Messages.VolumeMessage) {
        players[msg.playerId]?.setVolume(msg.volume.toLong())
    }

    override fun play(msg: Messages.TextureMessage) = players[msg.playerId]!!.play()

    override fun pause(msg: Messages.TextureMessage) = players[msg.playerId]!!.pause()

    override fun seekTo(msg: Messages.PositionMessage) {
        players[msg.playerId]?.seekTo(msg.position)
    }
}

data class PluginState(
    val context: Context,
    val binaryMessenger: BinaryMessenger,
    val textureRegistry: TextureRegistry,
    val platformViewRegistry: PlatformViewRegistry,
)

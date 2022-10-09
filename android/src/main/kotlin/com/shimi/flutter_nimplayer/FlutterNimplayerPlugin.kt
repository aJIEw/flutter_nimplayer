package com.shimi.flutter_nimplayer

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.os.Message
import androidx.annotation.NonNull
import com.shimi.flutter_nimplayer.FlutterNimplayerPlugin.Instance.NIM_PLAYER_CURRENT_POS
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import java.lang.ref.WeakReference

/** FlutterNimplayerPlugin */
class FlutterNimplayerPlugin : FlutterPlugin,
    MethodCallHandler, EventChannel.StreamHandler,
    FlutterNimplayerView.FlutterNimPlayerViewListener,
    PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    private lateinit var methodChannel: MethodChannel
    private lateinit var flutterPluginBinding: FlutterPluginBinding
    private lateinit var eventChannel: EventChannel
    private var eventSink: EventSink? = null
    private var handler: MyHandler? = null
    private val playerType = -1

    private val mFlutterNimplayerMap: HashMap<String, FlutterNimplayer> = HashMap()
    private val mFlutterNimplayerViewMap: HashMap<Int, FlutterNimplayerView> = HashMap()

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPluginBinding) {
        this.flutterPluginBinding = flutterPluginBinding;
        flutterPluginBinding.platformViewRegistry.registerViewFactory(
            "flutter_nimplayer_render_view",
            this
        )

        methodChannel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_nimplayer")
        methodChannel.setMethodCallHandler(this)

        eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "flutter_nimplayer_event")
        eventChannel.setStreamHandler(this)
    }

    override fun create(context: Context?, viewId: Int, args: Any?): PlatformView {
        val flutterNimPlayerView = FlutterNimplayerView(context, viewId)
        flutterNimPlayerView.setFlutterNimPlayerViewListener(this)
        mFlutterNimplayerViewMap[viewId] = flutterNimPlayerView;
        return flutterNimPlayerView
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "createPlayer" -> {
                val playerId: String = call.argument<String>("playerId")!!
                val player = FlutterNimplayer(flutterPluginBinding, playerId)
                initListener(player)
                mFlutterNimplayerMap[playerId] = player
            }
            "setPlayerView" -> {
                val viewId = call.argument<Any>("arg") as Int?
                val flutterNimPlayerView: FlutterNimplayerView? = mFlutterNimplayerViewMap[viewId]
                val playerId = call.argument<String>("playerId")
                val currentPlayer: FlutterNimplayer? = mFlutterNimplayerMap[playerId]
                if (flutterNimPlayerView != null && currentPlayer != null) {
                    flutterNimPlayerView.setPlayer(currentPlayer.player)
                }
            }
            "getPlatformVersion" -> {
                result.success("Android ${android.os.Build.VERSION.RELEASE}")
            }
            else -> {
                val playerId = call.argument<String>("playerId")
                val currentPlayer: FlutterNimplayer? = mFlutterNimplayerMap[playerId]
                if (call.method == "destroy") {
                    mFlutterNimplayerMap.remove(playerId)
                }
                currentPlayer?.onMethodCall(call, result)
            }
        }
    }

    private fun initListener(player: FlutterPlayerBase) {
        player.setOnFlutterListener(object :
            FlutterNimplayerListener {
            override fun onPrepared(map: MutableMap<String, Any>?) {
                eventSink?.success(map)
            }

            override fun onVideoSizeChanged(map: MutableMap<String, Any>?) {
                eventSink?.success(map)
            }

            override fun onSeekComplete(map: MutableMap<String, Any>?) {
                eventSink?.success(map)
            }

            override fun onLoadingBegin(map: MutableMap<String, Any>?) {
                eventSink?.success(map)
            }

            override fun onLoadingProgress(map: MutableMap<String, Any>?) {
                eventSink?.success(map)
            }

            override fun onLoadingEnd(map: MutableMap<String, Any>?) {
                eventSink?.success(map)
            }

            override fun onSubtitleShow(map: MutableMap<String, Any>?) {
                eventSink?.success(map)
            }

            override fun onSubtitleHide(map: MutableMap<String, Any>?) {
                eventSink?.success(map)
            }

            override fun onCurrentPosition(map: MutableMap<String, Any>?) {
//                eventSink?.success(map)
                val msg = Message()
                msg.what = NIM_PLAYER_CURRENT_POS;
                msg.obj = map;
                handler?.sendMessage(msg)
            }

            override fun onInfo(map: MutableMap<String, Any>?) {
                eventSink?.success(map)
            }

            override fun onCompletion(map: MutableMap<String, Any>?) {
                eventSink?.success(map)
            }

            override fun onError(map: MutableMap<String, Any>?) {
                eventSink?.success(map)
            }

        })
    }

    override fun onListen(arguments: Any?, events: EventSink?) {
        this.eventSink = events
        if (eventSink != null) {
            this.handler = MyHandler(events!!)
        }
    }

    override fun onCancel(arguments: Any?) {

    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPluginBinding) {
        methodChannel.setMethodCallHandler(null)
    }

    override fun onDispose(viewId: Int) {
        mFlutterNimplayerViewMap.remove(viewId)
    }

    private class MyHandler(eventSink: EventSink) : Handler(Looper.getMainLooper()) {

        private val mWeakReference: WeakReference<EventSink>

        init {
            mWeakReference = WeakReference(eventSink)
        }

        override fun handleMessage(msg: Message) {
            super.handleMessage(msg)
            val eventSink = mWeakReference.get() ?: return
            when (msg.what) {
                NIM_PLAYER_CURRENT_POS -> {
                    eventSink.success(msg.obj)
                }
            }
        }
    }

    object Instance {
        const val NIM_PLAYER_CURRENT_POS = 0x0010
    }
}

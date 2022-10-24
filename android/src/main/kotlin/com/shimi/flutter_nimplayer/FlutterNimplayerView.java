package com.shimi.flutter_nimplayer;


import android.content.Context;
import android.graphics.SurfaceTexture;
import android.os.Handler;
import android.os.Message;
import android.util.Log;
import android.view.Surface;
import android.view.TextureView;
import android.view.View;

import com.netease.neliveplayer.sdk.NELivePlayer;

import java.lang.ref.WeakReference;

import io.flutter.plugin.platform.PlatformView;

public class FlutterNimplayerView implements PlatformView {

    private static final int NIM_PLAYER_SETSURFACE = 0x0001;
    private Context mContext;
    private NELivePlayer mPlayer;
    private int mViewId;
    private MyHandler mHandler = new MyHandler(this);

    private final TextureView mTextureView;
    private Surface mSurface;

    public FlutterNimplayerView(Context context, int viewId) {
        this.mViewId = viewId;
        this.mContext = context;
        mTextureView = new TextureView(mContext);
        initRenderView(mTextureView);
    }

    public void setPlayer(NELivePlayer player) {
        this.mPlayer = player;
        mHandler.sendEmptyMessage(NIM_PLAYER_SETSURFACE);
    }


    @Override
    public View getView() {
        return mTextureView;
    }

    @Override
    public void dispose() {
        if (mFlutterNimPlayerViewListener != null) {
            mPlayer.setSurface(null);
            mFlutterNimPlayerViewListener.onDispose(mViewId);
        }
    }

    private void initRenderView(TextureView mTextureView) {
        if (mTextureView != null) {
            mTextureView.setSurfaceTextureListener(new TextureView.SurfaceTextureListener() {
                @Override
                public void onSurfaceTextureAvailable(SurfaceTexture surface, int width, int height) {
                    Log.d(FlutterNimplayerView.class.getSimpleName(), "onSurfaceTextureAvailable: ");
                    mSurface = new Surface(surface);
                    mHandler.sendEmptyMessage(NIM_PLAYER_SETSURFACE);
                    /*if (mPlayer != null) {
                        mPlayer.setSurface(mSurface);
                    }*/
                }

                @Override
                public void onSurfaceTextureSizeChanged(SurfaceTexture surface, int width, int height) {
                    Log.d(FlutterNimplayerView.class.getSimpleName(), "onSurfaceTextureSizeChanged: ");
                    /*if (mPlayer != null) {
                        mSurface = new Surface(surface);
                        mHandler.sendEmptyMessage(NIM_PLAYER_SETSURFACE);
                    }*/
                }

                @Override
                public boolean onSurfaceTextureDestroyed(SurfaceTexture surface) {
                    Log.d(FlutterNimplayerView.class.getSimpleName(), "onSurfaceTextureDestroyed: ");
                    /*if (mPlayer != null) {
                        mPlayer.setSurface(null);
                    }*/
                    return false;
                }

                @Override
                public void onSurfaceTextureUpdated(SurfaceTexture surface) {

                }
            });
        }
    }

    public interface FlutterNimPlayerViewListener {
        void onDispose(int viewId);
    }

    private FlutterNimPlayerViewListener mFlutterNimPlayerViewListener;

    public void setFlutterNimPlayerViewListener(FlutterNimPlayerViewListener listener) {
        this.mFlutterNimPlayerViewListener = listener;
    }

    private static class MyHandler extends Handler {

        private WeakReference<FlutterNimplayerView> mWeakReference;

        public MyHandler(FlutterNimplayerView playerView) {
            mWeakReference = new WeakReference<>(playerView);
        }

        @Override
        public void handleMessage(Message msg) {
            super.handleMessage(msg);
            FlutterNimplayerView flutterNimPlayerView = mWeakReference.get();
            if (flutterNimPlayerView == null) {
                return;
            }
            switch (msg.what) {
                case NIM_PLAYER_SETSURFACE:
                    if (flutterNimPlayerView.mPlayer != null && flutterNimPlayerView.mSurface != null) {
                        flutterNimPlayerView.mPlayer.setSurface(null);
                        flutterNimPlayerView.mPlayer.setSurface(flutterNimPlayerView.mSurface);
                    }
                    break;
            }
        }
    }
}
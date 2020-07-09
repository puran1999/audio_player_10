package com.example.audio_player_10;

import android.content.Context;
import android.media.AudioAttributes;
import android.media.AudioFocusRequest;
import android.media.AudioManager;
import android.os.Build;
import android.util.Log;

import androidx.annotation.NonNull;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
    public static final String TAG = "NATIVE_MESSAGE_TAG";
    public static final String CHANNEL = "com.example.focus_audio/channel";
    public static final String STREAM = "com.example.focus_audio/stream";

    AudioManager.OnAudioFocusChangeListener audioFocusChangeListener;
    private AudioManager audioManager;
    private Object audioFocusRequest;

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);

        audioManager = (AudioManager) this.getSystemService(Context.AUDIO_SERVICE);

        new MethodChannel(flutterEngine.getDartExecutor(), CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            if (call.method.equals("requestAudioFocus")) {
                                int r = 0;
                                if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
                                    r = audioManager.requestAudioFocus(
                                            audioFocusChangeListener,
                                            AudioManager.STREAM_MUSIC,
                                            AudioManager.AUDIOFOCUS_GAIN
                                    );
                                } else {
                                    AudioAttributes audioAttributes = new AudioAttributes.Builder()
                                            .setUsage(AudioAttributes.USAGE_MEDIA)
                                            .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                                            .build();
                                    audioFocusRequest = new AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN)
                                            .setAudioAttributes(audioAttributes)
                                            .setWillPauseWhenDucked(true)
                                            .setOnAudioFocusChangeListener(audioFocusChangeListener)
                                            .build();
                                    r = audioManager.requestAudioFocus((AudioFocusRequest) audioFocusRequest);
                                }
                                if (r == AudioManager.AUDIOFOCUS_REQUEST_GRANTED) {
                                    result.success("GRANTED");
                                } else {
                                    result.success("FAILED");
                                }
                            } else if (call.method.equals("abandonAudioFocus")) {
                                audioManager.abandonAudioFocus(audioFocusChangeListener);
                            } else {
                                result.notImplemented();
                            }
                        }
                );

        new EventChannel(flutterEngine.getDartExecutor(), STREAM).setStreamHandler(
                new EventChannel.StreamHandler() {
                    @Override
                    public void onListen(Object args, EventChannel.EventSink events) {
                        Log.w(TAG, "adding listener");
                        audioFocusChangeListener = createAudioFocusChangeListener(events);
                    }

                    @Override
                    public void onCancel(Object args) {
                        Log.w(TAG, "cancelling listener");

                    }
                }
        );
    }

    private AudioManager.OnAudioFocusChangeListener createAudioFocusChangeListener(final EventChannel.EventSink events) {
        return new AudioManager.OnAudioFocusChangeListener() {
            @Override
            public void onAudioFocusChange(int focusChange) {
                switch (focusChange) {
                    case AudioManager.AUDIOFOCUS_GAIN:
                        events.success("AUDIOFOCUS_GAIN");
                        break;
                    case AudioManager.AUDIOFOCUS_GAIN_TRANSIENT:
                        events.success("AUDIOFOCUS_GAIN_TRANSIENT");
                        break;
                    case AudioManager.AUDIOFOCUS_GAIN_TRANSIENT_MAY_DUCK:
                        events.success("AUDIOFOCUS_GAIN_TRANSIENT_MAY_DUCK");
                        break;
                    case AudioManager.AUDIOFOCUS_LOSS:
                        events.success("AUDIOFOCUS_LOSS");
                        break;
                    case AudioManager.AUDIOFOCUS_LOSS_TRANSIENT:
                        events.success("AUDIOFOCUS_LOSS_TRANSIENT");
                        break;
                    case AudioManager.AUDIOFOCUS_LOSS_TRANSIENT_CAN_DUCK:
                        events.success("AUDIOFOCUS_LOSS_TRANSIENT_CAN_DUCK");
                        break;
                    case AudioManager.AUDIOFOCUS_REQUEST_FAILED:
                        events.success("AUDIOFOCUS_REQUEST_FAILED");
                        break;
                    default:
                        events.success("AUDIOFOCUS_REQUEST_FAILED");
                        break;
                }
            }
        };
    }
}

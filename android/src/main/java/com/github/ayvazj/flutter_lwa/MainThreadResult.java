package com.github.ayvazj.flutter_lwa;

import android.os.Handler;
import android.os.Looper;

import io.flutter.plugin.common.MethodChannel;

class MainThreadResult implements MethodChannel.Result {
    private final MethodChannel.Result result;
    private final Handler handler;

    private MainThreadResult(MethodChannel.Result result) {
        this.result = result;
        this.handler = new Handler(Looper.getMainLooper());
    }

    static MethodChannel.Result from(MethodChannel.Result result) {
        return new MainThreadResult(result);
    }

    @Override
    public void success(final Object res) {
        handler.post(
                new Runnable() {
                    @Override
                    public void run() {
                        result.success(res);
                    }
                });
    }

    @Override
    public void error(
            final String errorCode, final String errorMessage, final Object errorDetails) {
        handler.post(
                new Runnable() {
                    @Override
                    public void run() {
                        result.error(errorCode, errorMessage, errorDetails);
                    }
                });
    }

    @Override
    public void notImplemented() {
        handler.post(
                new Runnable() {
                    @Override
                    public void run() {
                        result.notImplemented();
                    }
                });
    }
}

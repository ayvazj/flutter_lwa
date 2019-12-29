package com.github.ayvazj.flutter_lwa;

import android.util.Log;

import com.amazon.identity.auth.device.AuthError;
import com.amazon.identity.auth.device.api.authorization.AuthCancellation;
import com.amazon.identity.auth.device.api.authorization.AuthorizeListener;
import com.amazon.identity.auth.device.api.authorization.AuthorizeResult;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.util.Map;

import io.flutter.plugin.common.MethodChannel;

public class LwaAuthorizeListener extends AuthorizeListener {
    private static String TAG = "LwaAuthorizeListener";
    private static final ObjectMapper om = new ObjectMapper();
    private MethodChannel.Result result;

    LwaAuthorizeListener() {
    }

    void setResult(MethodChannel.Result result) {
        this.result = result;
    }

    @Override
    public void onSuccess(AuthorizeResult authorizeResult) {
        Log.i(TAG, "Authorization Success");
        if (result != null) {
            result.success(om.convertValue(authorizeResult, Map.class));
        }
    }

    @Override
    public void onError(AuthError authError) {
        Log.e(TAG, "Authorization Error");
        if (result != null) {
            result.error(
                    authError.getType().name(),
                    authError.getMessage(),
                    om.convertValue(authError, Map.class)
            );
        }
    }

    @Override
    public void onCancel(AuthCancellation authCancellation) {
        Log.w(TAG, "User cancelled authorization");
        if (result != null) {
            result.error(authCancellation.getCause().name(),
                    authCancellation.getDescription(),
                    om.convertValue(authCancellation, Map.class)
            );
        }
    }
}

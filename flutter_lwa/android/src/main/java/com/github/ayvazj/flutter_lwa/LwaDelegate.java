package com.github.ayvazj.flutter_lwa;

import android.content.Context;

import androidx.annotation.NonNull;

import com.amazon.identity.auth.device.AuthError;
import com.amazon.identity.auth.device.api.Listener;
import com.amazon.identity.auth.device.api.authorization.AuthorizationManager;
import com.amazon.identity.auth.device.api.authorization.AuthorizeRequest;
import com.amazon.identity.auth.device.api.authorization.AuthorizeResult;
import com.amazon.identity.auth.device.api.authorization.Scope;
import com.amazon.identity.auth.device.api.authorization.User;
import com.amazon.identity.auth.device.api.workflow.RequestContext;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;

final class LwaDelegate {
    private static final String TAG = "LwaDelegate";
    private static final ObjectMapper om = new ObjectMapper();
    private final LwaAuthorizeListener lwaAuthorizeListener;
    private final RequestContext requestContext;
    @NonNull
    private final Context context;

    LwaDelegate(final RequestContext requestContext, final @NonNull Context context) {
        this.requestContext = requestContext;
        this.context = context;
        this.lwaAuthorizeListener = new LwaAuthorizeListener();
        this.requestContext.registerListener(lwaAuthorizeListener);
    }

    void signIn(final MethodChannel.Result result, List<Scope> scopes) {
        this.lwaAuthorizeListener.setResult(result);
        AuthorizationManager.authorize(
                new AuthorizeRequest.Builder(requestContext)
                        .addScopes(createScopes(scopes))
                        .build()
        );
    }

    void signOut(final MethodChannel.Result result) {
        AuthorizationManager.signOut(context, new Listener<Void, AuthError>() {
            @Override
            public void onSuccess(Void aVoid) {
                result.success(null);
            }

            @Override
            public void onError(AuthError authError) {
                result.error(authError.getType().toString(), authError.getMessage(),
                        om.convertValue(authError, Map.class));
            }
        });
    }

    void getToken(final MethodChannel.Result result,
                  final List<Scope> scopes) {
        AuthorizationManager.getToken(context, createScopes(scopes),
                new Listener<AuthorizeResult, AuthError>() {
                    @Override
                    public void onSuccess(AuthorizeResult authorizeResult) {
                        result.success(om.convertValue(authorizeResult, Map.class));
                    }

                    @Override
                    public void onError(AuthError authError) {
                        result.error(
                                authError.getType().name(),
                                authError.getMessage(),
                                om.convertValue(authError, Map.class)
                        );
                    }
                }
        );
    }

    void getProfile(final MethodChannel.Result result) {
        User.fetch(context, new Listener<User, AuthError>() {
            @Override
            public void onSuccess(User user) {
                result.success(om.convertValue(user, Map.class));
            }

            @Override
            public void onError(AuthError authError) {
                result.error(
                        authError.getType().name(),
                        authError.getMessage(),
                        om.convertValue(authError, Map.class)
                );
            }
        });
    }

    private static Scope[] createScopes(List<Scope> scopes) {
        final Scope[] scopeArray = new Scope[scopes.size()];
        for (int i = 0; i < scopes.size(); i++) {
            scopeArray[i] = scopes.get(i);
        }
        return scopeArray;
    }
}

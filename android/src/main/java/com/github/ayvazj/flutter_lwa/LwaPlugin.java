package com.github.ayvazj.flutter_lwa;

import android.content.Context;

import androidx.annotation.NonNull;

import com.amazon.identity.auth.device.api.workflow.RequestContext;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * LwaPlugin
 */
public class LwaPlugin implements FlutterPlugin, ActivityAware {

    private RequestContext requestContext;

    // This static function is optional and equivalent to onAttachedToEngine. It supports the old
    // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
    // plugin registration via this function while apps migrate to use the new Android APIs
    // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
    //
    // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
    // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
    // depending on the user's project. onAttachedToEngine or registerWith must both be defined
    // in the same class.
    public static void registerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "lwa");
        final Context applicationContext = registrar.activeContext().getApplicationContext();
        final RequestContext requestContext = RequestContext.create(applicationContext);
        channel.setMethodCallHandler(newMethodHandler(requestContext, applicationContext));
    }

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        final MethodChannel channel = new MethodChannel(
                binding.getBinaryMessenger(),
                "com.github.ayvazj/flutter_lwa"
        );
        requestContext = RequestContext.create(binding.getApplicationContext());
        channel.setMethodCallHandler(newMethodHandler(requestContext, binding.getApplicationContext()));
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {

    }

    private static LwaMethodHandler newMethodHandler(final RequestContext requestContext,
                                                     final @NonNull Context context) {
        return new LwaMethodHandler(requestContext, context);
    }

    @Override
    public void onAttachedToActivity(ActivityPluginBinding binding) {
        requestContext = RequestContext.create(binding.getActivity().getApplicationContext());
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {

    }

    @Override
    public void onReattachedToActivityForConfigChanges(ActivityPluginBinding binding) {
        requestContext.onResume();
    }

    @Override
    public void onDetachedFromActivity() {

    }
}

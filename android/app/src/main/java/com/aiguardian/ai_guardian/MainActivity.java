package com.aiguardian.ai_guardian;

import android.view.KeyEvent;
import io.flutter.embedding.android.FlutterFragmentActivity;
import io.flutter.embedding.engine.FlutterEngine;
import dev.fluttercommunity.shake_gesture_android.ShakeGesturePlugin;

public class MainActivity extends FlutterFragmentActivity {

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if (keyCode == KeyEvent.KEYCODE_MENU) {
            FlutterEngine flutterEngine = getFlutterEngine();
            if (flutterEngine != null) {
                Object plugin = flutterEngine.getPlugins().get(ShakeGesturePlugin.class);
                if (plugin instanceof ShakeGesturePlugin) {
                    ((ShakeGesturePlugin) plugin).onShake();
                }
            }
        }
        return super.onKeyDown(keyCode, event);
    }
}

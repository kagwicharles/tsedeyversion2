package com.craftsilicon.tsedeybnkdemo

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import android.view.WindowManager.LayoutParams

class MainActivity : FlutterFragmentActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        //window.addFlags(LayoutParams.FLAG_SECURE)
    }

}

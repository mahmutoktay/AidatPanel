package com.aidatpanel.app



import android.util.Log

import com.baseflow.permissionhandler.PermissionHandlerPlugin

import com.dexterous.flutterlocalnotifications.FlutterLocalNotificationsPlugin

import com.github.dart_lang.jni.JniPlugin

import com.github.dart_lang.jni_flutter.JniFlutterPlugin

import com.it_nomads.fluttersecurestorage.FlutterSecureStoragePlugin

import com.kasem.receive_sharing_intent.ReceiveSharingIntentPlugin

import com.mr.flutter.plugin.filepicker.FilePickerPlugin

import io.scer.pdfx.PdfxPlugin

import io.flutter.embedding.engine.FlutterEngine

import io.flutter.embedding.engine.plugins.FlutterPlugin

import io.flutter.plugins.firebase.core.FlutterFirebaseCorePlugin

import io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingPlugin

import io.flutter.plugins.flutter_plugin_android_lifecycle.FlutterAndroidLifecyclePlugin

import io.flutter.plugins.imagepicker.ImagePickerPlugin



/**

 * GeneratedPluginRegistrant.java Kotlin eklentileri derleyemiyor.

 * Liste [.flutter-plugins-dependencies] ile senkron — bkz. mobile/scripts/check_plugin_registrant.ps1

 */

object PluginRegistrant {

    private const val TAG = "PluginRegistrant"



    fun register(flutterEngine: FlutterEngine) {

        flutterEngine.plugins.add(FilePickerPlugin())

        flutterEngine.plugins.add(FlutterFirebaseCorePlugin())

        flutterEngine.plugins.add(FlutterFirebaseMessagingPlugin())

        flutterEngine.plugins.add(FlutterLocalNotificationsPlugin())

        flutterEngine.plugins.add(FlutterAndroidLifecyclePlugin())

        flutterEngine.plugins.add(FlutterSecureStoragePlugin())

        flutterEngine.plugins.add(ImagePickerPlugin())

        flutterEngine.plugins.add(JniPlugin())

        flutterEngine.plugins.add(JniFlutterPlugin())

        addPluginReflective(

            flutterEngine,

            "dev.fluttercommunity.plus.packageinfo.PackageInfoPlugin",

            "package_info_plus",

        )

        flutterEngine.plugins.add(PermissionHandlerPlugin())

        flutterEngine.plugins.add(PdfxPlugin())

        flutterEngine.plugins.add(ReceiveSharingIntentPlugin())

        addPluginReflective(

            flutterEngine,

            "dev.fluttercommunity.plus.share.SharePlusPlugin",

            "share_plus",

        )

        addPluginReflective(

            flutterEngine,

            "studio.midoridesign.gal.GalPlugin",

            "gal",

        )

        addPluginReflective(

            flutterEngine,

            "vn.hunghd.flutter.plugins.imagecropper.ImageCropperPlugin",

            "image_cropper",

        )

    }



    private fun addPluginReflective(

        flutterEngine: FlutterEngine,

        className: String,

        pluginName: String,

    ) {

        try {

            val clazz = Class.forName(className)

            val plugin = clazz.getDeclaredConstructor().newInstance() as FlutterPlugin

            flutterEngine.plugins.add(plugin)

        } catch (e: ReflectiveOperationException) {

            Log.e(TAG, "Eklenti kaydı başarısız: $pluginName ($className)", e)

        }

    }

}


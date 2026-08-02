package com.gameturbo.x

import io.flutter.embedding.android.FlutterActivity

/**
 * MainActivity dasar. MethodChannel native untuk fitur yang butuh kode Kotlin
 * langsung (mis. UsageStatsManager untuk histori game dengan izin eksplisit,
 * atau overlay window controller untuk FPS HUD) akan didaftarkan di sini pada
 * bagian selanjutnya (Native Bridge), tanpa mengubah fondasi ini.
 */
class MainActivity : FlutterActivity()

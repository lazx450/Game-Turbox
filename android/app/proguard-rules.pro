# Aturan ProGuard/R8 untuk rilis. Tidak menghapus/obfuscate kelas Flutter/Firebase
# yang dibutuhkan reflection agar tidak crash saat rilis.
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-keep class com.google.firebase.** { *; }

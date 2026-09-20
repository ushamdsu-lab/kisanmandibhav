# Flutter Proguard Rules for Optimization
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-dontwarn io.flutter.embedding.**
-ignorewarnings

# Google Play Services & Google Mobile Ads (AdMob)
-keep public class com.google.android.gms.ads.** {
   public *;
}
-keep public class com.google.ads.** {
   public *;
}
-keep class com.google.android.gms.ads.identifier.** { *; }
-dontwarn com.google.android.gms.ads.**

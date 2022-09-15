-dontwarn com.google.**
  -dontwarn android.media.**
  -keep class android.media.** { *; }
  -keep class com.google.** { *; }
  -keep interface com.google.** { *; }
  -keep class com.google.ads.interactivemedia.** { *; }
  -keep interface com.google.ads.interactivemedia.** { *; }

-keep class com.brightcove.player.analytics.Models.** { *; }
-keep class com.brightcove.player.event.EventEmitterImpl.** { *; }


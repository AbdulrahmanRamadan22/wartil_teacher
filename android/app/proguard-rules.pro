# ============================================================
# Flutter - Keep all Flutter engine classes
# ============================================================
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugin.** { *; }
-dontwarn io.flutter.**

# ============================================================
# Kotlin
# ============================================================
-keep class kotlin.** { *; }
-keep class kotlin.Metadata { *; }
-dontwarn kotlin.**
-keepclassmembers class **$WhenMappings {
    <fields>;
}
-keepclassmembers class kotlin.Lazy {
    *;
}

# ============================================================
# Retrofit + OkHttp + Gson/Moshi
# ============================================================
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes Exceptions
-keepattributes InnerClasses
-keepattributes EnclosingMethod
-keepattributes RuntimeVisibleAnnotations
-keepattributes RuntimeInvisibleAnnotations
-keepattributes RuntimeVisibleParameterAnnotations
-keepattributes RuntimeInvisibleParameterAnnotations

-keep class retrofit2.** { *; }
-dontwarn retrofit2.**
-keep interface retrofit2.** { *; }

-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }
-dontwarn okhttp3.**

-keep class okio.** { *; }
-dontwarn okio.**

# Keep all Retrofit service interfaces
-if interface * { @retrofit2.http.* <methods>; }
-keep,allowobfuscation interface <1>

# ============================================================
# Dio (Dart HTTP client - native Android side)
# ============================================================
-keep class com.google.gson.** { *; }
-dontwarn com.google.gson.**

# ============================================================
# Pusher Channels
# ============================================================
-keep class com.pusher.** { *; }
-keep interface com.pusher.** { *; }
-dontwarn com.pusher.**
-keep class com.github.pusher.** { *; }
-dontwarn com.github.pusher.**
-keep class org.java_websocket.** { *; }
-dontwarn org.java_websocket.**

# ============================================================
# Agora RTC Engine
# ============================================================
-keep class io.agora.** { *; }
-keep interface io.agora.** { *; }
-dontwarn io.agora.**
-keepclassmembers class io.agora.** {
    *;
}

# ============================================================
# Flutter Local Notifications
# ============================================================
-keep class com.dexterous.** { *; }
-dontwarn com.dexterous.**

# ============================================================
# Flutter CallKit Incoming
# ============================================================
-keep class com.hiennv.flutter_callkit_incoming.** { *; }
-dontwarn com.hiennv.flutter_callkit_incoming.**

# ============================================================
# Permission Handler
# ============================================================
-keep class com.baseflow.permissionhandler.** { *; }
-dontwarn com.baseflow.permissionhandler.**

# ============================================================
# URL Launcher
# ============================================================
-keep class io.flutter.plugins.urllauncher.** { *; }
-dontwarn io.flutter.plugins.urllauncher.**

# ============================================================
# Shared Preferences
# ============================================================
-keep class io.flutter.plugins.sharedpreferences.** { *; }
-dontwarn io.flutter.plugins.sharedpreferences.**

# ============================================================
# Cached Network Image
# ============================================================
-keep class com.github.bumptech.glide.** { *; }
-dontwarn com.github.bumptech.glide.**

# ============================================================
# Google Fonts
# ============================================================
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# ============================================================
# JSON Serialization (json_annotation / json_serializable)
# ============================================================
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Keep all data models (classes with fromJson/toJson)
-keep class * {
    public ** fromJson(org.json.JSONObject);
    public org.json.JSONObject toJson();
}

# ============================================================
# R8 / ProGuard General Rules
# ============================================================
-dontwarn org.slf4j.**
-dontwarn javax.annotation.**
-dontwarn sun.misc.**

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep Parcelable implementations
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# Keep Serializable implementations
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Keep enums
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# ============================================================
# Suppress common warnings
# ============================================================
-dontwarn java.lang.invoke.**
-dontwarn org.conscrypt.**
-dontwarn org.bouncycastle.**
-dontwarn org.openjsse.**

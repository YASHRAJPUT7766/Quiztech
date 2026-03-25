# ============================================================
# QuizTech ProGuard Rules
# ============================================================

# Firebase
-keep class com.google.firebase.** { *; }
-keep interface com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Google Play Services
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# Google Sign-In
-keep class com.google.android.gms.auth.** { *; }
-keep class com.google.android.gms.auth.api.signin.** { *; }

# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.**

# Kotlin
-keep class kotlin.** { *; }
-keep class kotlin.jvm.** { *; }
-keep class kotlin.reflect.** { *; }
-keepclassmembers class kotlin.** { *; }
-dontwarn kotlin.**

# App package
-keep class com.yashsoftware.quiztech.** { *; }
-keepclassmembers class com.yashsoftware.quiztech.** { *; }

# Keep public constructors
-keepclasseswithmembers public class * {
    public <init>(...);
}

# Native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Enums
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Parcelable
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# Serializable
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Gson / JSON (agar future mein use ho)
-dontwarn com.google.gson.**
-keep class com.google.gson.** { *; }

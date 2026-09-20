# Release Notes - v1.0.6 (Build 7)

**Release Date**: 20 September 2026  
**Status**: In Review on Google Play Console (Production Track)  
**Package Name**: `com.kisanmitra.kisan_mitra`  
**Version Name**: `1.0.6`  
**Version Code**: `7`  
**Bundle File**: `kisan_mandi_bhav_v1.0.6_build7.aab` (55.8 MB)  
**Mapping File**: `mapping.txt` (R8 Deobfuscation mapping)

---

## Play Console Release Notes (Submitted)
```text
<en-US>
Initial official release of Kisan Mandi Bhav app:
- Live daily mandi bhav and commodity market rates
- Accurate weather forecasts and agricultural updates for farmers
- Fast, smooth, and 100% free access without any sign-up or login
- Performance improvements and reliable notifications
</en-US>
```

---

## Technical Changes in this Build
1. **Production Signing Keystore**:
   - Created `android/app/kisan_release_key.jks` with alias `kisan_mandi_key` (RSA 2048-bit, 10,000 days validity).
   - Configured `android/key.properties` and updated `android/app/build.gradle.kts`.
2. **Google Play Photo & Video Compliance**:
   - Removed broad permissions (`READ_EXTERNAL_STORAGE` and `READ_MEDIA_IMAGES`) from `AndroidManifest.xml`.
   - Crop Doctor feature uses modern Android Photo Picker without requiring broad media permissions, ensuring 100% Google Play policy compliance.
3. **R8 Code & Resource Shrinking**:
   - `isMinifyEnabled = true`, `isShrinkResources = true` enabled in release build.
   - APK download size optimized to ~15.9 MB for users.

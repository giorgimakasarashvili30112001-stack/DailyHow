# Build Flutter APK & AAB with GitHub Actions

## ✅ Setup Complete!

Your DailyHow Flutter app is configured to build native Android APK and AAB files automatically using GitHub Actions.

**No local Flutter SDK needed!** Everything is built on GitHub's servers.

---

## 🚀 Quick Start (3 Steps)

### Step 1: Trigger the Workflow
Go to: https://github.com/giorgimakasarashvili30112001-stack/DailyHow/actions

### Step 2: Select and Run
1. Click "Build Flutter APK & AAB" on the left
2. Click "Run workflow" button
3. Confirm to start build

### Step 3: Download
- Wait for workflow to complete (green checkmark) ~5-10 minutes
- Scroll to "Artifacts" section
- Download your files

---

## 📁 Output Files

| File | Purpose | Location |
|------|---------|----------|
| `app-debug.apk` | Testing on device | `build/app/outputs/apk/debug/` |
| `app-release.apk` | Share with friends | `build/app/outputs/apk/release/` |
| `app-release-aab` | Upload to Play Store | `build/app/outputs/bundle/release/` |

---

## 🔄 Build Triggers

### Automatic (On Every Push)
```bash
git push origin main
# Workflow starts automatically
```

### Manual (Anytime)
1. Go to Actions tab
2. Click "Build Flutter APK & AAB"
3. Click "Run workflow"

### On Git Tag (For Releases)
```bash
git tag v1.0.0
git push origin v1.0.0
# Creates GitHub Release with APK/AAB attached
```

---

## 📱 Install and Test

### Download APK
1. Go to Actions tab
2. Click latest successful workflow
3. Download `app-debug.apk` from Artifacts

### Install on Phone
```bash
adb install -r app-debug.apk
```

### Test Offline
1. Disable WiFi on phone
2. Restart the app
3. Verify it works without internet

---

## 📤 Upload to Google Play Store

### Step 1: Download AAB
Get `app-release-aab` from workflow artifacts

### Step 2: Create Google Play Account
- Go to https://play.google.com/console
- Developer account ($25 one-time fee)

### Step 3: Create App
1. Click "Create app"
2. Fill in app details
3. Add descriptions, screenshots, icons

### Step 4: Upload
1. Go to Release → Production
2. Click "Create new release"
3. Upload the AAB file
4. Fill release notes
5. Review and publish

---

## ⚙️ Workflow Details

### What Happens (Automatically)
1. ✅ Checkout code
2. ✅ Setup Flutter SDK (3.47.2)
3. ✅ Get dependencies (flutter pub get)
4. ✅ Analyze code (flutter analyze)
5. ✅ Build debug APK
6. ✅ Build release APK
7. ✅ Build AAB for Play Store
8. ✅ Upload artifacts

### Build Time
- **First build:** ~8-10 minutes (downloads Flutter SDK and dependencies)
- **Subsequent builds:** ~5-7 minutes (cached)

### Environment
- **OS:** Ubuntu latest
- **Flutter:** 3.47.2 stable
- **Dart:** Included with Flutter

---

## 📊 Flutter vs React Comparison

| Aspect | Flutter | React (daily-curiosity) |
|--------|---------|------------------------|
| Build Time | 5-10 min | 10-15 min |
| First Build | 8-10 min | 15-20 min |
| APK Size | ~80-120MB | ~80-120MB |
| Platforms | 6+ (Android, iOS, Web, Desktop) | Android only |
| Performance | Very fast (native) | Good (SSR) |
| Language | Dart | TypeScript |

---

## 🔐 Security Notes

✅ **Artifacts are private** - Only you can download them
✅ **Builds are ephemeral** - No code stored permanently
✅ **No secrets needed** - Flutter builds are straightforward
✅ **GitHub Secrets available** - For sensitive data if needed

---

## 📅 Artifacts Retention

- Artifacts stored for **30 days**
- After 30 days, automatically deleted
- You can re-run workflow to rebuild anytime

---

## 🚀 Example: Build and Test

```bash
# 1. Make a change
echo "// Update" >> lib/main.dart
git add .
git commit -m "Test build"
git push origin main

# 2. Go to Actions tab and watch the build

# 3. When complete, download app-debug.apk

# 4. Install and test
adb install -r app-debug.apk

# 5. Test offline - disable WiFi and verify app works
```

---

## ✨ Next Steps

✅ **Build your first APK:**
1. Go to Actions tab
2. Run workflow manually
3. Download APK when complete

✅ **Test on your phone:**
1. Install debug APK
2. Test features (facts, save, profile, etc)
3. Test offline
4. Test notifications

✅ **Publish to Play Store (when ready):**
1. Download AAB from workflow
2. Create Google Play account
3. Upload AAB to Play Console
4. Fill app details and publish

---

## 📝 Workflow File

Location: `.github/workflows/build-flutter.yml`

The workflow is fully configured and ready to use. You can modify it if needed:
- Change Flutter version: update `flutter-version`
- Add more build targets: iOS, Web, Desktop
- Add signing: for production releases

---

## 🐛 Troubleshooting

### Build Fails
Check the workflow logs:
1. Go to Actions tab
2. Click failed workflow
3. Click job that failed
4. Scroll to see error messages

### Common Errors

**"Flutter not found"**
- Setup Flutter action failed
- Check internet connection
- Run workflow again

**"pub get failed"**
- Dependency issue
- Check pubspec.yaml
- Run locally: `flutter pub get`

**"Build failed"**
- Code issue
- Check flutter analyze logs
- Fix errors and push again

---

## 📞 Support

For issues:
1. Check workflow logs in Actions tab
2. Read error messages carefully
3. Try running workflow again
4. Check Flutter documentation: https://flutter.dev/docs

---

## 💡 Flutter-Specific Tips

### Local Development
```bash
# Install Flutter SDK from flutter.dev
flutter --version              # Check version
flutter pub get               # Get dependencies
flutter run                   # Run on device/emulator
flutter build apk             # Build APK locally
```

### Flutter Platforms
```bash
flutter build apk             # Android APK
flutter build aab             # Google Play Store
flutter build ios             # iOS app
flutter build web             # Web version
flutter build windows         # Windows desktop
flutter build macos           # macOS desktop
flutter build linux           # Linux desktop
```

---

**Everything is set up and ready! Go build your Flutter app! 🎉**

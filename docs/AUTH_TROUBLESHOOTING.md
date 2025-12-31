# Authentication Troubleshooting Guide

## Network Error: "Network error has occurred"

This is the most common issue when testing Firebase Authentication.

### Quick Fixes (Try in Order):

### 1. **Check Firebase Console - Enable Email/Password Auth**

**This is the most likely cause!**

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: `naija-food-finder-uk`
3. Click **Authentication** in left sidebar
4. Click **Sign-in method** tab
5. Find **Email/Password** in the list
6. Click on it
7. **Enable** the toggle
8. Click **Save**

**Screenshot locations:**
- Authentication > Sign-in method > Email/Password > Enable

---

### 2. **Restart iOS Simulator**

The simulator network might be stuck:

```bash
# Stop the app
# In Simulator: Device > Erase All Content and Settings
# Or just restart simulator:
# Simulator > File > Close Window
# Then relaunch from Xcode/VS Code
```

---

### 3. **Check Simulator Network**

In iOS Simulator:
1. Open **Settings** app
2. Go to **Wi-Fi**
3. Make sure Wi-Fi is ON
4. Try opening Safari and loading google.com
5. If Safari works, Firebase should work

---

### 4. **Verify Firebase Configuration**

Check if Firebase is initialized:

```bash
# Look for this in console when app starts:
flutter: === AUTH STATE ===
flutter: User signed in: false
flutter: ==================
```

If you don't see this, Firebase might not be initialized.

---

### 5. **Test with a Real Device**

Sometimes simulators have network issues:

```bash
# Connect your iPhone via USB
flutter run
# Select your physical device
```

---

## Other Common Errors

### "No user found with this email"

**Solution:** The user doesn't exist yet.
- Try **Sign Up** instead of Sign In
- Or create the user in Firebase Console

### "Wrong password provided"

**Solution:** Password is incorrect
- Double-check the password
- Use password reset if needed

### "Email/Password sign-in is not enabled"

**Solution:** Enable Email/Password in Firebase Console
- See Fix #1 above

### "Operation not allowed"

**Solution:** Sign-in method not enabled in Firebase
- Check Firebase Console > Authentication > Sign-in method
- Enable the method you're trying to use

---

## Verify Firebase Setup

### Check firebase_options.dart

```bash
cat lib/firebase_options.dart
```

Should show your project configuration with:
- `apiKey`
- `appId`
- `messagingSenderId`
- `projectId`

### Check Firebase Initialization

In `lib/main.dart`, you should have:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: MyApp()));
}
```

---

## Test Without Network Issues

### Option 1: Create User in Firebase Console

1. Go to Firebase Console
2. Authentication > Users
3. Click "Add user"
4. Enter email and password
5. Now try to log in with those credentials

### Option 2: Use Google Sign-In

Google Sign-In sometimes works better:
- Tap "Continue with Google"
- Select your Google account
- Should work without network issues

---

## Still Not Working?

### Enable Debug Mode

The app now logs detailed errors. Look for:

```
=== AUTH REPOSITORY: Attempting sign in ===
Email: test@naijafoodfinder.com
FirebaseAuthException: network-request-failed - ...
```

### Copy Full Error and Share

Run this and send the output:

```bash
flutter run
# Try to log in
# Copy everything from console
# Send to developer
```

---

## Success Indicators

When auth is working, you'll see:

```
=== AUTH REPOSITORY: Attempting sign in ===
Email: test@naijafoodfinder.com
Sign in successful, user: test@naijafoodfinder.com
=== AUTH STATE ===
User signed in: true
User ID: xyz123...
Email: test@naijafoodfinder.com
==================
```

---

## Quick Test Checklist

- [ ] Firebase Email/Password auth enabled in console?
- [ ] Simulator has internet? (test in Safari)
- [ ] Firebase initialized in console logs?
- [ ] User exists in Firebase Console > Users?
- [ ] Tried Google Sign-In instead?
- [ ] Tried on real device?

---

Generated: December 30, 2025

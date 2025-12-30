# How to Create Test User in Firebase

## Option 1: Via Firebase Console (Recommended - 2 minutes)

1. **Open Firebase Console:**
   - Go to https://console.firebase.google.com/
   - Select project: `naija-food-finder-uk`

2. **Navigate to Authentication:**
   - Click "Authentication" in left sidebar
   - Click "Users" tab

3. **Add Test User:**
   - Click "Add user" button
   - Enter email: `test@naijafoodfinder.com`
   - Enter password: `TestUser123!`
   - Click "Add user"

4. **Done!** ✅
   - You can now sign in with these credentials in your app

---

## Option 2: Via Your App (3 minutes)

1. **Open your app**
2. **Go to Profile tab** (4th icon in bottom nav)
3. **Tap "Sign In"** button
4. **Tap "Don't have an account? Sign Up"** at bottom
5. **Enter details:**
   - Name: `Test User`
   - Email: `test@naijafoodfinder.com`
   - Password: `TestUser123!`
   - Confirm Password: `TestUser123!`
6. **Tap "Sign Up"**
7. **Done!** ✅

---

## Option 3: Use Google Sign-In (Fastest - 30 seconds)

1. **Open your app**
2. **Go to Profile tab**
3. **Tap "Sign In"**
4. **Tap "Continue with Google"** button
5. **Select your Google account**
6. **Done!** ✅ - Automatically creates user profile

---

## Verify Test User

After creating the user, verify in Firebase Console:

1. Go to Authentication > Users
2. You should see your test user listed
3. Check the UID, email, and creation date

---

## Test the User

### Test Authentication:
- ✅ Sign in with email/password
- ✅ Sign out
- ✅ Sign in again
- ✅ Check profile shows user info

### Test Reviews:
- ✅ Go to any restaurant details
- ✅ Tap "Write Review" button (should be visible)
- ✅ Rate and write a comment
- ✅ Submit review
- ✅ See your review appear instantly
- ✅ Edit your review
- ✅ Delete your review

### Test Favorites:
- ✅ Browse restaurants
- ✅ Tap heart icon on restaurant cards
- ✅ Go to Profile > Favorites
- ✅ See favorited restaurants
- ✅ Unfavorite restaurants

---

## Troubleshooting

### Can't sign in?
- Check if email/password authentication is enabled in Firebase Console
- Verify the email and password are correct
- Try resetting the password

### "Write Review" button not showing?
- Make sure you're signed in (check Profile tab)
- Only signed-in users can write reviews
- Sign out and sign in again

### Google Sign-In not working?
- Check if Google auth is enabled in Firebase Console
- Verify SHA-1 certificate is configured
- Check google-services.json is up to date

---

## Quick Start

**Fastest way to test right now:**

```bash
# Just use the app's sign-up screen!
1. Open app
2. Profile tab → Sign In → Sign Up
3. Enter: test@naijafoodfinder.com / TestUser123!
4. Start testing! 🎉
```

---

Generated: December 30, 2025

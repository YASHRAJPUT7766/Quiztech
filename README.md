# 🎯 QuizTech — Flutter App

---

## 📱 App Features

| Feature | Status |
|---------|--------|
| Splash Screen | ✅ |
| Intro / Onboarding | ✅ |
| Email Login & Register | ✅ |
| Google Sign In | ✅ |
| Home Screen with Categories | ✅ |
| 12 Quiz Categories | ✅ |
| 3200+ Questions | ✅ |
| 5-Second Timer per Question | ✅ |
| Quiz with Animations | ✅ |
| Result Screen + Confetti 🎉 | ✅ |
| Answer Review | ✅ |
| Credits System | ✅ |
| Real ₹ Earnings | ✅ |
| Daily Streak Bonus | ✅ |
| Rewards / Withdrawal | ✅ |
| UPI / PayTM / GPay / Amazon / Flipkart / Bank | ✅ |
| Profile Screen | ✅ |
| Edit Name | ✅ |
| Referral Code System | ✅ |
| Promo Code Redemption | ✅ |
| Dark Mode | ✅ |
| Admin Panel | ✅ |
| Quiz History | ✅ |


## 📁 Project Structure

```
quiztech_flutter/
├── lib/
│   ├── main.dart              # App entry point
│   ├── firebase_options.dart  # Firebase config (same as website)
│   ├── theme/
│   │   └── app_theme.dart    # Colors & theme (same purple #4F46E5)
│   ├── models/
│   │   ├── user_model.dart   # User data
│   │   └── question_model.dart # Questions & Categories
│   ├── data/
│   │   └── questions_db.dart # 3200+ questions (same as qdb.js)
│   ├── services/
│   │   ├── auth_service.dart    # Login/Register/Google
│   │   └── firestore_service.dart # Database (same as website)
│   └── screens/
│       ├── splash_screen.dart
│       ├── intro_screen.dart
│       ├── login_screen.dart
│       ├── home_screen.dart    # Main hub
│       ├── category_screen.dart
│       ├── quiz_screen.dart    # Quiz with timer
│       ├── result_screen.dart  # Results + confetti
│       ├── profile_screen.dart
│       ├── rewards_screen.dart # Withdrawals
│       ├── settings_screen.dart
│       └── admin_screen.dart   # Admin panel
├── android/
├── ios/
└── pubspec.yaml
```

---


LifeLog Offline Android

Android-first Flutter app, no WebView, no server requirement.
Package: com.yasin.lifelog

Current implemented application layer:
- Glass UI
- Today dashboard
- task add/complete
- focus timer
- calendar
- daily review
- journal
- sleep tracking
- inbox
- basic analytics
- local persistence

Build is automated by .github/workflows/build-apk.yml.

Not yet safe to call security-final:
- encrypted SQLite vault
- Android Keystore key wrapping
- PIN/biometric lock
- encrypted backup/restore
- exact alarm/notification action native configuration
- home widget
- full habits/goals UI
- Jalali/English runtime UI
- complete analytics

These must be completed and device-tested before storing sensitive production data.

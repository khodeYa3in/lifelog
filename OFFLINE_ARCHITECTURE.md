# LifeLog Offline

This Android build has no server dependency and no WebView.

Data model:
- Tasks / timeline
- Daily reviews
- Journal
- Sleep
- Habits
- Goals
- Focus sessions
- Settings

Production security target:
- encrypted SQLite database
- database key protected by Android Keystore
- biometric/PIN app lock
- encrypted export/import backup
- no INTERNET permission in the final Android manifest

Android native target:
- scheduled notifications
- exact alarms when permission is granted
- boot rescheduling
- notification actions
- home-screen widget

Important: exact alarms on recent Android versions require the applicable Android permission/user grant.

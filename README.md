# Stamp Rally

Offline-first Flutter app for collecting digital convention stamps.

Stamp Rally is built for conference booth games, passport challenges, and sponsor trails. The hackathon demo focuses on a complete local QR handoff:

1. A participant joins a demo event and shows a passport QR.
2. A booth operator scans the passport QR.
3. The operator issues a signed stamp token as a QR.
4. The participant scans the stamp token.
5. The passport updates locally and unlocks the prize when the required stamps are collected.

The project is MIT licensed and designed for a jPrime 2026 hackathon submission in Sofia.

## Repository Layout

```text
.
├── app/                  # Flutter application
├── docs/                 # Planning and design notes
├── LICENSE
├── THIRD_PARTY_NOTICES.md
└── README.md
```

## Current Scope

The current implementation targets the hackathon MVP:

- Seeded demo event with event-bound checkpoint keys
- Participant passport QR
- Operator PIN flow
- Signed stamp token QR
- Local stamp verification and duplicate prevention
- Prize unlock screen

Organizer event creation, PDF sheets, manual-code fallback, and backend sync are planned for later phases.

## Local Setup

Install Flutter, then generate the native project folders:

```sh
cd app
flutter create --platforms=android,ios,web .
flutter pub get
flutter test
flutter run
```

This repository keeps generated native folders out of version control until the mobile build settings are intentional.

## Demo Script

- Participant: open the app, join the demo event, and show the passport QR.
- Operator: enter demo PIN `1001`, `1002`, or `1003`, then scan the participant QR.
- Operator: compare the 4-digit confirmation code, issue the stamp QR, and show it to the participant.
- Participant: scan the signed stamp QR from the import screen.

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE).

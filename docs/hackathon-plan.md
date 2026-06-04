# Hackathon Plan

## Goal

Build a demoable offline-first Flutter stamp rally app for jPrime 2026.

## MVP Flow

1. Participant joins the demo event.
2. Participant shows a passport QR containing `eventId`, `passportId`, and `displayNonce`.
3. Operator enters a checkpoint PIN.
4. Operator scans the participant QR and validates the matching `eventId`.
5. Both devices show the same 4-digit visual confirmation code.
6. Operator issues a signed stamp token QR.
7. Participant scans the stamp token.
8. Participant app verifies signature, `eventId`, `passportId`, and duplicate status.
9. Passport progress updates and prize unlocks when enough stamps are collected.

## Out of Scope for Hackathon MVP

- Organizer event builder
- PDF QR sheets
- Manual-code fallback
- Backend sync
- Live organizer dashboard
- Production-grade key provisioning

## Security Model

The visual confirmation code is a UX check, not proof. The signed stamp token is the proof. The participant app trusts public keys from the event config and accepts only stamp tokens signed by the matching checkpoint/operator key.

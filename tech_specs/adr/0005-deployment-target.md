# ADR-0005 — Deployment target iOS 17

**Status:** accepted (M0)

## Context
Developed on Xcode 26.6 (iOS 26 SDK). The Xcode template defaulted to a 26.5 deployment target,
which would exclude most of a real fitness app's install base. A mass-market app like Runkeeper
supports several OS majors back; the modern-observation APIs we build on (`@Observable`) need 17.

## Decision
Deployment target **iOS 17** — the current OS plus the two prior majors (26, 18, 17), the newest
floor that still provides Observation and modern SwiftUI. Swift 6 language mode with strict
concurrency stays on regardless of target.

## Consequences
Realistic device coverage story for the interview; `@Observable` ViewModels without back-ports;
builds with Xcode 16+ so any reviewer's toolchain opens it. Cost: none for this scope — no
17-unavailable API is needed.

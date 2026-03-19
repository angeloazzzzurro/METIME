---

## Comandi rapidi VS Code

Per lavorare in modo più produttivo con METIME:

| Azione                        | Shortcut                |
|-------------------------------|-------------------------|
| Apri terminale integrato      | Ctrl + `                |
| Crea nuovo file               | Ctrl + N                |
| Salva file                    | Ctrl + S                |
| Apri palette comandi          | Ctrl + Shift + P        |
| Split editor (HTML + CSS)     | Ctrl + \                |
| Live Server                   | Ctrl + Shift + P → "Open with Live Server" |
| Formatta codice               | Shift + Alt + F         |
| Multi-cursore                 | Ctrl + D                |
| Trova e sostituisci           | Ctrl + H                |

---
<div align="center">

# METIME

**A mindful companion that grows with you**

*iOS 17+ · SwiftUI · SpriteKit · SwiftData*

![METIME Hero Mockup](Assets/Mockups/mockup_hero.png)

</div>

---

## Overview

METIME is an iOS wellness app built around a virtual pet that reflects the user's actual wellbeing state. When you meditate, your pet becomes calmer. When you neglect yourself, it shows. The emotional feedback loop creates genuine engagement without gamification dark patterns.

The pet's mood is not manually set — it is computed by `derivedMood()` from four real statistics (hunger, happiness, calm, energy), creating an honest mirror of the user's daily habits.

---

## Screenshots

![METIME Screens](Assets/Mockups/mockup_screens.png)

| Screen | Description |
| :--- | :--- |
| **Garden Home** | Isometric kawaii garden with the pet, mood HUD, and action bar |
| **Care Ritual** | Guided breathing session with circular timer and session metrics |
| **Journal & Insights** | Diary entries, 7-day streak, and mood average |
| **Mockup Gallery** | Navigation hub for all app sections |

---

## Architecture

![METIME Architecture](Assets/Mockups/mockup_architecture.png)

The codebase is organized in five layers with zero circular dependencies:

| Layer | Responsibility | Key Files |
| :--- | :--- | :--- |
| **Presentation** | SwiftUI views, SpriteKit scenes | `MainPetView`, `GardenScene`, `PetNode` |
| **State Management** | App-wide state, game logic | `AppState`, `GameStore` |
| **Domain** | Data models, mood derivation | `Pet @Model`, `PetNeeds @Model`, `derivedMood()` |
| **Infrastructure** | Persistence, security, logging | `ModelContainer`, Data Protection, `OSLog` |
| **Audio/Graphics** | Ambient audio, particles | `SoundscapeManager`, `ParticleFactory` |

---

## Tech Stack

- **SwiftUI** — Declarative UI with `@EnvironmentObject` and `@Observable`
- **SpriteKit** — Isometric garden scene with depth sorting, particles, and mood-reactive colors
- **SwiftData** — Persistent pet state with `FileProtectionType.completeUnlessOpen` (AES-256)
- **AVFoundation** — Dynamic ambient audio that changes with the pet's mood
- **XcodeGen** — Reproducible project generation from `project.yml`

---

## Security

METIME implements the full iOS security stack from day one:

- **Data at rest** — SwiftData encrypted with `FileProtectionType.completeUnlessOpen`
- **Input validation** — `Pet.setName()` allowlist with `didSet` sanitization
- **Privacy manifest** — `PrivacyInfo.xcprivacy` with full data taxonomy (iOS 17+ App Store requirement)
- **Concurrency** — `SWIFT_STRICT_CONCURRENCY = complete` (Swift 6 ready)
- **Code quality** — SwiftLint with `force_try`, `force_cast`, `force_unwrapping` rules
- **Crash resilience** — All `fatalError` replaced with graceful fallbacks + `OSLog`

---

## Getting Started

### Requirements

- Xcode 15+
- iOS 17+ deployment target
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`)
- [SwiftLint](https://github.com/realm/SwiftLint) (`brew install swiftlint`)

### Setup

```bash
# Clone the repository
git clone https://github.com/angeloazzzzurro/METIME.git
cd METIME

# Generate the Xcode project
make setup

# Open in Xcode
open METIME.xcodeproj
```

### Available Commands

```bash
make setup      # Generate Xcode project with XcodeGen
make test       # Run all tests (unit + UI)
make test-unit  # Run unit tests only
make test-ui    # Run UI tests only
make lint       # Run SwiftLint
make lint-fix   # Auto-fix SwiftLint violations
```

---

## Project Structure

```
METIME/
├── App/
│   ├── METIMEApp.swift       # Entry point, SwiftData container
│   ├── AppState.swift        # Pet model, PetMood enum
│   └── Resources.swift       # AudioResource, ColorResource enums
├── UI/
│   ├── MainPetView.swift     # Homepage (kawaii, isometric)
│   └── Mockups/              # Xcode Preview mockups
├── Garden/
│   ├── GardenScene.swift     # SpriteKit isometric scene
│   └── BedNode.swift         # Bed decoration node
├── Creature/
│   ├── PetNode.swift         # Kawaii pet with face and animations
│   └── ParticleFactory.swift # Rain and sparkle effects
├── Data/Persistence/
│   └── GameStore.swift       # Game logic, derivedMood(), SwiftData
├── Audio/
│   └── SoundscapeManager.swift # Mood-reactive ambient audio
├── Tests/
│   ├── METIMETests/          # Unit tests (GameStore, SwiftData in-memory)
│   └── METIMEUITests/        # UI tests (flows, buttons, sheet navigation)
└── Assets/
    └── Mockups/              # Professional App Store mockups
```

---

## SwiftUI Mockups

Open `UI/Mockups/MockupGalleryView.swift` in Xcode and use Canvas Preview to inspect all screens: `GardenHomeMockupView`, `CareRitualMockupView`, and `JournalInsightsMockupView`.

---

## Roadmap

| Milestone | Description | Status |
| :--- | :--- | :--- |
| **iCloud Sync** | CloudKit Private Database for cross-device state | Planned |
| **Apple Watch** | WKExtension with mood display and breathing session | Planned |
| **Widgets** | WidgetKit lock screen widget showing pet mood | Planned |

---

<div align="center">

Made with care · iOS 17+ · Swift 5.9+

</div>

<- Tech Stack, Security, Getting Started, Project Structure, auto-commit test Tue Mar 17 07:18:17 EDT 2026 -->

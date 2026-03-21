<div align="center">

# METIME

**A mindful companion that grows with you**

*iOS 17+ · SwiftUI · SpriteKit · SwiftData*

![METIME Hero Mockup](Assets/Mockups/mockup_hero.png)

</div>

## Overview

METIME is an iOS wellness app built around a virtual pet that reflects the user's wellbeing state. Meditation, care rituals, mood, inventory, and room interactions all feed the same pet state instead of living in disconnected flows.

The pet mood is derived from real stats through `derivedMood()` in [GameStore.swift](Data/Persistence/GameStore.swift), so UI state follows gameplay state instead of hardcoded mood transitions.

## Current Product Areas

- Main pet home with mood HUD, actions, and color cycling
- Garden and island navigation built with SpriteKit
- Meditation and care ritual flows with SwiftData history
- House/store systems with wallet, inventory, and placement
- Web preview prototypes for screen exploration outside Xcode

## Tech Stack

- SwiftUI for app UI and navigation
- SpriteKit for the interactive pet and island scenes
- SwiftData for persistent pet, wallet, inventory, and session data
- AVFoundation for ambient soundscapes
- XcodeGen for reproducible project generation
- SwiftLint for basic static checks

## Getting Started

### Requirements

- Xcode 15+
- iOS 17+ deployment target
- [XcodeGen](https://github.com/yonaskolb/XcodeGen)
- [SwiftLint](https://github.com/realm/SwiftLint)

### Setup

```bash
git clone https://github.com/angeloazzzzurro/METIME.git
cd METIME
make setup
open METIME.xcodeproj
```

### Common Commands

```bash
make setup
make test
make test-unit
make test-ui
make lint
make lint-fix
```

## Repository Structure

```text
METIME/
├── App/                 App entry point, app state, models, app resources
├── Audio/               Soundscape and audio helpers
├── Creature/            Pet rendering and animation
├── Data/                Persistence and game-state logic
├── Garden/              SpriteKit garden and island scenes
├── House/               House scene and room presentation
├── Store/               Wallet, inventory, and item purchase logic
├── UI/                  SwiftUI screens and reusable section views
├── WebPreview/          HTML/CSS previews and prototype flows
├── Resources/           App assets and bundled resources
├── Tests/               Unit and UI tests
├── docs/
│   ├── images/          Static assets for docs site
│   ├── presentations/   Deck content and exported mockups
│   ├── previews/        Screenshot exports
│   └── reviews/         Audit and analysis notes
├── .github/workflows/   CI and Pages workflows
└── project.yml          XcodeGen project definition
```

## Documentation

- Product and repo notes live under [docs](docs)
- Review and audit material lives under [docs/reviews](docs/reviews)
- Presentation assets live under [docs/presentations](docs/presentations)
- Preview exports live under [docs/previews](docs/previews)

## Screenshots

![METIME Screens](Assets/Mockups/mockup_screens.png)

![METIME Architecture](Assets/Mockups/mockup_architecture.png)

## GitHub Hygiene

- iOS CI is defined in [.github/workflows/ios-build.yml](.github/workflows/ios-build.yml)
- GitHub Pages deployment is defined in [.github/workflows/pages.yml](.github/workflows/pages.yml)
- Issue templates live in [.github/ISSUE_TEMPLATE](.github/ISSUE_TEMPLATE)
- Pull request guidance lives in [.github/pull_request_template.md](.github/pull_request_template.md)

## Roadmap

- iCloud sync for cross-device state
- Apple Watch companion
- Widgets for lock screen / home screen pet status

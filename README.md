# METIME

iOS 17+ Tamagotchi-style mindful farming pet app (SwiftUI + SpriteKit + SwiftData).

## Setup

1. `make setup`
2. `make open`
3. Build and run target `METIME` in Xcode.

## Bundle ID

- `com.metime.app`

## Running Tests

```bash
make test        # run all tests (unit + UI)
make test-unit   # run only unit tests
make test-ui     # run only UI tests
```

## Architecture

| Module | Responsibility |
| :--- | :--- |
| `App` | Entry point, global state (`AppState`), type-safe resource enums (`Resources.swift`) |
| `UI` | SwiftUI views: `MainPetView`, mockup gallery |
| `Garden` | SpriteKit scene with dynamic weather effects |
| `Creature` | Pet node with mood-driven animations |
| `Data` | `GameStore` — game logic + SwiftData persistence |
| `Audio` | `SoundscapeManager` — mood-driven ambient audio |
| `Tests` | Unit tests (`METIMETests`) and UI tests (`METIMEUITests`) |

## SwiftUI Mockups

- Open `UI/Mockups/MockupGalleryView.swift` in Xcode.
- Use Canvas Preview to inspect `MockupGalleryView`, `GardenHomeMockupView`, `CareRitualMockupView`, and `JournalInsightsMockupView`.
- If the file is not visible in the project navigator yet, run `xcodegen generate` from the project root and reopen the project.

## Persistence

Pet state is persisted automatically via **SwiftData** (`Pet` and `PetNeeds` models). The data survives app restarts and is stored in the app's default container on-device.

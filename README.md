# METIME

iOS 17+ kawaii-cottagecore pet & restaurant game (SwiftUI + SpriteKit + SwiftData).

METIME combina due mondi: un **pet virtuale mindful** che cresce con la tua cura quotidiana e un **ristorante/fattoria** con cucina, concorsi, mercato e mappa di esplorazione sociale.

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
| `UI` | SwiftUI views: `MainPetView`, mockup gallery, section views |
| `Garden` | SpriteKit scene with dynamic weather effects |
| `Creature` | Pet node with mood-driven animations, particle factory |
| `Data` | `GameStore` — game logic + SwiftData persistence |
| `Audio` | `SoundscapeManager` — mood-driven ambient audio (WAV) |
| `Resources` | Asset catalogs (sprites, colors, app icon), audio files |
| `Tests` | Unit tests (`METIMETests`) and UI tests (`METIMEUITests`) |
| `WebPreview` | Interactive HTML/CSS/JS mockups for all game screens |

## WebPreview (HTML Mockups)

The `WebPreview/` directory contains a fully interactive prototype of the game UI, viewable in any browser. Open `WebPreview/index.html` (Pet Home) or `WebPreview/gallery.html` (Gallery) to navigate all screens.

### Game Screens

| Screen | File | Description |
| :--- | :--- | :--- |
| Casa Pet | `index.html` | Mimi's home — mood, stats, self-care actions |
| Hub Ristorante | `pages/hub.html` | Isometric restaurant with orders, NPC, cooking |
| Scegli Piatto | `pages/choose-food.html` | Recipe catalog, chef selection, cooking progress |
| Fattoria | `pages/farm.html` | 4 farm types with live timers, harvest, chef assignment |
| Negozio | `pages/shop.html` | Item shop with categories, buy logic, coin tracking |
| Concorso | `pages/contest.html` | Leaderboard, voting system, reward claims |
| Personale | `pages/staff.html` | Chef roster, stats, shift simulation |
| Magazzino | `pages/storage.html` | Place/remove farms, stations, decorations |
| Mercato | `pages/market.html` | NPC vendor, live restock timers, slot purchase |
| Mappa | `pages/map.html` | World map with pan/zoom, 8 regions, mini-map |
| Matchmaking | `pages/matchmaking.html` | Battle accept modal with countdown |

### Design Systems

- **`assets/game.css`** — Cottagecore palette (sage/cream/paper), used by restaurant/farming pages
- **`assets/kawaii.css`** — Pastel blue/purple palette, used by pet/wellness pages

Navigation bridges connect both worlds: pet pages link to Ristorante, game pages have a Pet tab.

## SwiftUI Mockups

- Open `UI/Mockups/MockupGalleryView.swift` in Xcode.
- Use Canvas Preview to inspect `MockupGalleryView`, `GardenHomeMockupView`, `CareRitualMockupView`, and `JournalInsightsMockupView`.
- If the file is not visible in the project navigator yet, run `xcodegen generate` from the project root and reopen the project.

## Persistence

Pet state is persisted automatically via **SwiftData** (`Pet` and `PetNeeds` models). The data survives app restarts and is stored in the app's default container on-device.

## Landing Page

GitHub Pages landing page: `docs/index.html` — showcases the project story, features, island tour, and tech stack.

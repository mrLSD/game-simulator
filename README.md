# game-simulator

An educational airline-tycoon game for macOS built with **Swift + SpriteKit**: run an airline with a route map, a fleet and per-aircraft detail screens. The UI is inspired by classic airline-manager games and is built with a hybrid approach: procedural "chrome" (gradients, gloss, ribbons) plus raster art slots in the asset catalog.

The window is fixed: **1000×780 pt** (5:4), non-resizable.

## Screens

| Screen | Class | Contents |
|---|---|---|
| Main | `MainScreen` | NASA day/night photo map of Earth with routes out of KBP, resource bar, side rails, bottom dock, clock |
| "Aircraft" menu | `AircraftMenuScreen` | ribbon header, hero zone, 4 section cards |
| Aircraft list | `AircraftListScreen` | drag-scrollable fleet table, filter toolbar |
| Aircraft details | `AircraftDetailScreen` | 5 panels: identity, schedule, flights, maintenance, capacity |

Navigation: click buttons/cards/arrows; `Esc` goes one level up (details → list → menu → main). Screen transitions use a cross-blur (the outgoing screen blurs out and fades while the new one resolves from blur into focus).

## Build & run

Requirements: **Xcode 16+**, macOS 15.7+ (deployment target).

```bash
open game-simulator.xcodeproj    # then ⌘R
# or from the terminal:
xcodebuild -project game-simulator.xcodeproj -scheme game-simulator -configuration Debug build
```

Tests: `game-simulatorTests` (the `GameState` model).

## Architecture

Principle: **a screen is a type**. `GameScene` draws nothing itself — it hosts screens, runs the blur transition and forwards input.

```
GameScene                  — game state, presentScreen()/transition(), mouse/keyboard forwarding
└── ScreenNode             — screen base: scene proxies (size/canvas/gameState/transition),
    │                        build()/mouseDown(at:)…/handleEscape() hooks,
    │                        layout metrics, shared HUD (resource bar, timers), static texture caches
    ├── MainScreen
    └── AircraftScreen     — chrome shared by the aircraft screens: ribbon, hero, ?/X/back buttons,
        │                    press/hover state machine, activate(_:) router
        ├── AircraftMenuScreen
        ├── AircraftListScreen
        └── AircraftDetailScreen
```

| File | Responsibility |
|---|---|
| `GameScene.swift` | screen host, blur transition, dev flags |
| `ScreenNode.swift` | screen base + top HUD + layout metrics |
| `AircraftScreen.swift` | shared chrome and input of the three aircraft screens |
| `MainScreen.swift`, `AircraftMenuScreen.swift`, `AircraftListScreen.swift`, `AircraftDetailScreen.swift` | concrete screens |
| `ScreenNode+Rendering.swift` | primitives: art slots, gradient textures, glossy buttons, ribbon banner, labels |
| `ScreenNode+Icons.swift` | procedural vector icons (slot fallbacks) |
| `Nodes/ProgressBarNode.swift` | "live" progress-bar component (`percent`, `setPercent(animated:)`) |
| `Nodes/ClampedBlurFilter.swift` | CIFilter for blur without the transparent edge halo |
| `UI/Theme.swift` | `SKColor` palette + the UI font |
| `Extensions/SKLabelNode+Fitting.swift` | themed label factory + font fitting to a max width |
| `GameModels.swift`, `GameState.swift` | screen/action models and data (incl. the demo fleet) |

Component rule of thumb: **a function for one-shot construction, a class (`SKNode`) for a live element with state** (see `ProgressBarNode`).

## Art pipeline (hybrid)

The code checks the asset catalog first and falls back to procedural drawing when a slot is empty — the app always builds and looks coherent, while art can be added incrementally.

Adding an image: Xcode → `Assets.xcassets` → pick a slot → drag the PNG into the **2x** well (not into "Unassigned") → rebuild.

| Slot | Purpose | Status |
|---|---|---|
| `map.earth.day` / `map.earth.night` | Earth photo map | ✅ NASA (public domain) |
| `icon.header.aircraft` | left icon in the "Aircraft" menu ribbon | ✅ |
| `icon.resource.tickets/credits/cash/science` | resource icons in the top bar | empty |
| `icon.menu.routeMap … icon.menu.settings` (14) | rail/dock/settings button icons | empty |
| `icon.offer.shop/cashBonus/cargoBonus` | timed-offer icons | empty |
| `avatar.player` | player portrait | empty |
| `photo.hero.aircraft` | hero photo behind the aircraft-screen headers (cover-crop built in) | empty |

The day/night map is composed at load time: the day and night textures are blended with a soft terminator (`earthMapTexture()`).

Earth imagery — NASA Visible Earth (Blue Marble / Black Marble), public domain; crediting NASA is appreciated.

## Dev tooling

Boot straight into any screen and take a pixel-exact scene snapshot **without Screen Recording permission** (rendered via `SKView.texture(from:)` at Retina scale):

```bash
APP=~/Library/Developer/Xcode/DerivedData/game-simulator-*/Build/Products/Debug/game-simulator.app

# open a specific screen
open "$APP" --args -screen list          # main | aircraft | list | detail

# render a screen to PNG and quit (for visual diffing)
"$APP/Contents/MacOS/game-simulator" -screen detail -snapshot /tmp/detail.png
```

UI iteration loop: edit → build → snapshot all 4 screens → compare against the reference (`cmp` to prove "not a single pixel changed" during refactors).

## Asset notes

The only binary assets in the repository are NASA public-domain textures. All other slots are filled with your own or freely licensed art (CC0 packs, your own generations); no third-party game art is used.

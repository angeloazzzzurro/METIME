# METIME — Portfolio Presentation for Bending Spoons
## iOS Developer & UI/UX Designer

---

## SLIDE 1 — COVER
**Title:** METIME
**Subtitle:** A mindful companion that grows with you
**Author:** [Nome Candidato]
**Role:** iOS Developer & UI/UX Designer
**Date:** March 2026
**Visual:** Hero mockup con tre iPhone 15 Pro su sfondo nero premium (mockup_hero.png)

---

## SLIDE 2 — Who I Am
**Heading:** A developer who thinks in systems and designs in experiences

I am an iOS developer and UI/UX designer with a focus on building products that are technically rigorous and emotionally resonant. My work sits at the intersection of Swift engineering and product design — I write production-ready code and own the full design process from concept to pixel.

**Key facts:**
- iOS development with SwiftUI, SpriteKit, SwiftData (iOS 17+)
- UI/UX design: information architecture, interaction design, visual design
- Security-first mindset: Data Protection, input validation, OSLog, Strict Concurrency
- Tooling: XcodeGen, SwiftLint, Git, Makefile-based CI
- Fluent in the Bending Spoons product philosophy: acquire, improve, ship at scale

---

## SLIDE 3 — The Problem METIME Solves
**Heading:** Wellness apps fail users because they treat wellbeing as a checklist, not a relationship

The global mental wellness app market is worth $6.2 billion (2024) and growing at 16% CAGR. Yet user retention in wellness apps drops below 4% after 30 days — because most apps are transactional: they ask users to log data without giving anything back.

METIME takes a different approach: a virtual pet that reflects the user's actual wellbeing state. When you meditate, your pet becomes calmer. When you neglect yourself, it shows. The emotional feedback loop creates genuine engagement without gamification dark patterns.

**The insight:** Attachment to a character is a more powerful retention mechanism than streaks or notifications.

---

## SLIDE 4 — Product Overview
**Heading:** Three screens, one coherent experience: garden, ritual, reflection

METIME is structured around three core moments in a user's day:

| Screen | Moment | Core mechanic |
|:---|:---|:---|
| **Garden Home** | Morning check-in | Pet mood reflects derived wellness state |
| **Care Ritual** | Midday practice | Guided breathing with session metrics |
| **Journal & Insights** | Evening reflection | Diary entries + 7-day mood trend |

The pet's mood is not manually set — it is computed by `derivedMood()` from four real statistics (hunger, happiness, calm, energy), creating an honest mirror of the user's habits.

**Visual:** Four iPhone screens mockup (mockup_screens.png)

---

## SLIDE 5 — UI/UX Design Process
**Heading:** From isometric grid math to kawaii pixel polish — design decisions that are also engineering decisions

Every visual choice in METIME has a technical rationale:

**Isometric garden (45° projection):** The SpriteKit scene uses a custom `isoPoint()` function that maps a 7×5 tile grid to screen coordinates with `zPosition` depth sorting. This is not a static image — it is a live, interactive SpriteKit scene embedded in SwiftUI via `SceneView`, with mood-reactive tile colors and particle effects.

**Kawaii aesthetic:** SF Rounded typography at `.black` weight, pastel palette (`#FFE8F0 → #EAD9FF`), and a `PetNode` built entirely in SpriteKit code (no image assets) — a blob with elliptical body, dot eyes, pink cheek circles, and a smile arc. This keeps the binary small and the pet fully animatable.

**Action bar design:** Four circular pill buttons with haptic feedback (`UIImpactFeedbackGenerator`) and a shake animation on blocked actions — designed to feel alive, not just functional.

---

## SLIDE 6 — Technical Architecture
**Heading:** A layered architecture that separates concerns cleanly across five domains

**Visual:** Architecture diagram (mockup_architecture.png)

The codebase is organized in five layers with zero circular dependencies:

1. **Presentation** — SwiftUI views with `@EnvironmentObject` injection; SpriteKit scenes initialized once in `@State` to prevent re-creation on re-render
2. **State Management** — `GameStore` uses `@Observable` (not `ObservableObject`) for compatibility with SwiftData `@Model` classes; `objectWillChange.send()` called explicitly before mutations
3. **Domain** — `Pet` and `PetNeeds` are SwiftData `@Model` classes; `derivedMood()` is a pure function with no side effects
4. **Infrastructure** — `ModelContainer` with `FileProtectionType.completeUnlessOpen`; `fatalError` replaced with in-memory fallback; all errors logged via `OSLog`
5. **Audio/Graphics** — `SoundscapeManager` uses `AudioResource` enum (no hardcoded strings); `GardenScene` uses `ColorResource` enum; `ParticleFactory` generates rain and sparkle effects per mood

---

## SLIDE 7 — Security & Code Quality
**Heading:** Production-grade security implemented from day one, not bolted on later

Security is not a feature — it is a constraint that shapes every architectural decision. METIME implements the full iOS security stack:

| Layer | Implementation | Standard |
|:---|:---|:---|
| **Data at rest** | SwiftData + `FileProtectionType.completeUnlessOpen` | Apple Data Protection |
| **Input validation** | `Pet.setName()` allowlist + `didSet` sanitization | OWASP Mobile Top 10 |
| **Privacy manifest** | `PrivacyInfo.xcprivacy` with full data taxonomy | App Store requirement (iOS 17+) |
| **Concurrency** | `SWIFT_STRICT_CONCURRENCY = complete` | Swift 6 readiness |
| **Code quality** | SwiftLint with `force_try`, `force_cast`, `force_unwrapping` rules | Zero force unwrap in production paths |
| **Crash resilience** | All `fatalError` replaced with graceful fallbacks + `OSLog` | Zero unrecoverable crashes |

Audit results: **5 critical/high bugs identified and resolved** in a single audit pass, including 2 retain cycles, 1 force unwrap crash, and 1 unhandled `try!`.

---

## SLIDE 8 — Why Bending Spoons
**Heading:** The Bending Spoons model is exactly the environment where I want to build

Bending Spoons acquires products with existing user bases and improves them through engineering excellence and design precision. This is the most demanding and most rewarding environment for a developer-designer hybrid: every decision has immediate impact on millions of users.

**What I bring to your products:**
- I can own a feature end-to-end: from UX research to Swift implementation to App Store screenshot
- I understand the full iOS stack — UIKit, SwiftUI, SpriteKit, AVFoundation, SwiftData, CloudKit
- I ship with security and quality built in, not added as a post-launch patch
- I work with the same tools your team uses: XcodeGen, SwiftLint, Git, CI pipelines

**What I want to learn from Bending Spoons:**
- How to scale UX patterns across products with different audiences (Matrix technology)
- How to make data-driven design decisions at the Minerva/Xina level
- How to operate with the velocity and quality bar of Europe's #1 iOS team

---

## SLIDE 9 — METIME: What's Next
**Heading:** A clear product roadmap that shows I think beyond the current sprint

The current METIME codebase is a solid foundation. The next three milestones are already designed:

**Milestone 1 — iCloud Sync (CloudKit Private Database)**
User data follows them across devices. Architecture already supports it: `ModelContainer` needs only a `cloudKitDatabase: .private("iCloud.com.metime.app")` configuration change.

**Milestone 2 — Apple Watch companion**
A `WKExtension` target that shows the pet's current mood and a one-tap breathing session. The `GameStore` state is already serializable for Watch connectivity.

**Milestone 3 — Widgets (WidgetKit)**
A lock screen widget showing the pet's face and current mood. The `PetMood` enum and `derivedMood()` logic are already decoupled from the UI and ready for extraction into a shared framework.

---

## SLIDE 10 — Call to Action
**Title:** Let's build something iconic together
**Subtitle:** iOS Developer & UI/UX Designer — Available for Bending Spoons

**Links:**
- GitHub: github.com/angeloazzzzurro/METIME
- The full codebase is public, documented, and ready for code review

**What I am asking for:**
A conversation. Not a job offer — a conversation about what problems Bending Spoons is solving right now, and whether my skills are the right fit to help solve them.

**Visual:** Clean dark slide with name, role, GitHub link, and a small version of the hero mockup

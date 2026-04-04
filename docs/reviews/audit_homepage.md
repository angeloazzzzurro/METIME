# Audit: Homepage Kawaii — METIME
**Data:** 17 Marzo 2026 | **Autore:** angeloazzzzurro | **Scope:** `MainPetView`, `GameStore`, `AppState`, `PetNode`, `GardenScene`

---

## 1. Analisi Rischi di Injection

### 1.1 Contesto

METIME è un'app iOS **completamente offline**, senza backend, senza chiamate di rete e senza input testuali liberi da parte dell'utente nella homepage. Non esistono superfici di attacco per **prompt injection** nel senso classico (LLM), né per **SQL injection** (nessun database relazionale raw). L'analisi si concentra quindi sui vettori realistici per questa architettura: **data injection via SwiftData**, **state injection via EnvironmentObject** e **input injection via `pet.name`**.

---

### 1.2 Vettori Identificati

| ID | Vettore | File | Riga | Gravità | Stato |
| :--- | :--- | :--- | :--- | :--- | :--- |
| INJ-01 | `pet.name` renderizzato senza sanitizzazione in `Text()` | `MainPetView.swift` | 72 | **Media** | Aperto |
| INJ-02 | `moodRaw: String` scritto direttamente nel DB SwiftData senza validazione | `AppState.swift` | 40 | **Bassa** | Parzialmente mitigato |
| INJ-03 | `fatalError` nel `ModelContainer` init espone crash in produzione | `METIMEApp.swift` | 15 | **Media** | Aperto |
| INJ-04 | `try?` silenzioso su `modelContext.save()` nasconde errori di persistenza | `GameStore.swift` | 67 | **Bassa** | Aperto |
| INJ-05 | `UIScreen.main.bounds` deprecato in iOS 16+ causa comportamento imprevedibile | `MainPetView.swift` | 14 | **Bassa** | Aperto |
| INJ-06 | `--uitesting` launch argument non gestito nel codice app | `METIMEApp.swift` | — | **Bassa** | Aperto |

---

### 1.3 Dettaglio per Vettore

#### INJ-01 — `pet.name` non sanitizzato (Media)

```swift
// MainPetView.swift:72
Text(store.pet.name)
```

`pet.name` è un campo `String` libero persistito su SwiftData. Se in futuro viene aggiunto un campo di input per rinominare il pet, un nome contenente caratteri di controllo Unicode (es. sequenze RTL, zero-width joiners, caratteri di override) potrebbe alterare visivamente l'interfaccia o causare comportamenti inattesi nell'accessibilità (VoiceOver). SwiftUI non esegue alcuna sanitizzazione automatica su `Text()`.

**Fix consigliato:** aggiungere una proprietà computed `sanitizedName` su `Pet` che tronchi a 20 caratteri e rimuova i caratteri di controllo Unicode.

---

#### INJ-02 — `moodRaw` scritto senza validazione (Bassa)

```swift
// AppState.swift:40
var moodRaw: String
```

Il campo `moodRaw` è una stringa grezza nel modello SwiftData. Il getter `mood` ha un fallback sicuro (`?? .calm`), ma se il database venisse corrotto o modificato esternamente (es. tramite backup/restore o strumenti di debug), un valore non valido verrebbe silenziosamente ignorato senza log. Il rischio è basso perché `moodRaw` è scritto esclusivamente tramite `PetMood.rawValue` (enum chiuso), ma la mancanza di validazione in lettura è una debolezza difensiva.

**Fix consigliato:** aggiungere un log di warning quando il fallback `.calm` viene attivato.

---

#### INJ-03 — `fatalError` nel container SwiftData (Media)

```swift
// METIMEApp.swift:15
fatalError("Failed to create ModelContainer: \(error)")
```

Un `fatalError` in produzione causa un crash immediato e non recuperabile. Se il container SwiftData fallisce (es. schema migration fallita dopo un aggiornamento dell'app), l'utente non può aprire l'app. Questo è un vettore di **Denial of Service** auto-inflitto.

**Fix consigliato:** sostituire con un fallback in-memory + alert all'utente, permettendo all'app di avviarsi in modalità degradata.

---

#### INJ-04 — `try?` silenzioso su `save()` (Bassa)

```swift
// GameStore.swift:67
try? modelContext.save()
```

Gli errori di salvataggio vengono inghiottiti silenziosamente. Se il disco è pieno o il container è in uno stato inconsistente, le azioni dell'utente (nutrire, giocare, meditare) sembrano avere successo ma i dati non vengono persistiti.

**Fix consigliato:** loggare l'errore con `os_log` o propagarlo all'UI con un banner non invasivo.

---

#### INJ-05 — `UIScreen.main.bounds` deprecato (Bassa)

```swift
// MainPetView.swift:14
GardenScene(size: UIScreen.main.bounds.size)
```

`UIScreen.main` è deprecato da iOS 16 e rimosso in iOS 17+ per le app multi-window/multi-scene. Su iPad o in Split View, restituisce dimensioni errate, causando una scena SpriteKit mal dimensionata.

**Fix consigliato:** usare `GeometryReader` o `.onGeometryChange` per leggere le dimensioni reali della view.

---

#### INJ-06 — `--uitesting` non gestito (Bassa)

```swift
// METIMEUITests.swift:17
app.launchArguments = ["--uitesting"]
```

L'argomento `--uitesting` viene passato all'app durante i test UI, ma il codice app non lo intercetta. L'intenzione era usare un container in-memory durante i test, ma senza gestione esplicita i test UI scrivono sul database reale del simulatore.

**Fix consigliato:** in `METIMEApp`, controllare `CommandLine.arguments.contains("--uitesting")` e usare `isStoredInMemoryOnly: true` nel `ModelConfiguration`.

---

## 2. Analisi Interazioni Pulsanti

### 2.1 Mappa delle Azioni

| Pulsante | Handler | Effetti su stato | Effetti UI | Effetti audio |
| :--- | :--- | :--- | :--- | :--- |
| **Medita** | `appState.mood = .happy` + `store.meditate()` | `calm +0.25`, `happiness +0.1`, `moodRaw = "happy"` | Emoji badge → ✨, barra Calma aumenta, scena SpriteKit → sparkle | `SoundscapeManager` → `ambient_happy` |
| **Cibo** | `store.feed()` | `food -1`, `hunger +0.3`, `happiness +0.1` (se `food > 0`) | Barre Fame e Felicità aumentano | Nessuno |
| **Gioca** | `store.play()` | `happiness +0.2`, `energy -0.1` | Barra Felicità aumenta, Energia diminuisce | Nessuno |
| **Diario** | `showJournal.toggle()` | Nessuno su `GameStore` | Toggle sheet (non ancora implementato) | Nessuno |

---

### 2.2 Bug e Anomalie Funzionali

| ID | Pulsante | Problema | Gravità | Fix |
| :--- | :--- | :--- | :--- | :--- |
| BUG-01 | **Medita** | Imposta `appState.mood = .happy` direttamente, bypassando qualsiasi logica di progressione del mood. Il mood diventa sempre `.happy` indipendentemente dallo stato del pet. | **Media** | Il mood dovrebbe essere derivato dalle statistiche del pet, non impostato manualmente. |
| BUG-02 | **Cibo** | Nessun feedback visivo/sonoro quando `food == 0` e il tap non ha effetto. L'utente non capisce perché il pulsante non risponde. | **Media** | Aggiungere un'animazione di shake sul pulsante e/o un badge "0" sul cibo. |
| BUG-03 | **Gioca** | `energy` può scendere a 0 senza conseguenze sul pet (nessun cambio di mood, nessun avviso). Un pet con energia 0 dovrebbe diventare `.sleepy`. | **Media** | Aggiungere logica in `play()` o in un observer che triggeri `appState.mood = .sleepy` quando `energy < 0.2`. |
| BUG-04 | **Diario** | `showJournal.toggle()` non apre nessuna view reale (nessun `.sheet` collegato in `MainPetView`). Il pulsante è visivamente presente ma non funzionale. | **Alta** | Aggiungere `.sheet(isPresented: $showJournal) { JournalInsightsMockupView() }` al body. |
| BUG-05 | **Tutti** | `KawaiiActionButton` usa `.buttonStyle(.plain)` senza feedback aptico (`UIImpactFeedbackGenerator`). Su iOS, i pulsanti senza feedback tattile sembrano non rispondere. | **Bassa** | Aggiungere `UIImpactFeedbackGenerator(style: .light).impactOccurred()` in ogni action. |
| BUG-06 | **Medita** | Chiama sia `appState.mood = .happy` che `store.meditate()`. Il primo aggiorna la scena SpriteKit e l'audio; il secondo aggiorna le statistiche. Ma `store.meditate()` non aggiorna `pet.mood` nel database, creando una discrepanza tra `appState.mood` (`.happy`) e `pet.moodRaw` (rimane il valore precedente). | **Media** | Sincronizzare `pet.mood` in `meditate()` oppure rimuovere `appState.mood` come stato separato. |

---

### 2.3 Test UI Esistenti — Copertura e Gap

| Test | Copre | Gap identificato |
| :--- | :--- | :--- |
| `test_gardenHome_petNameIsVisible` | Presenza del nome | Non verifica che il nome sia quello persistito nel DB |
| `test_gardenHome_moodLabelIsVisible` | Presenza del label mood | Non verifica il valore iniziale |
| `test_gardenHome_allActionButtonsExist` | Esistenza dei 4 pulsanti | Non verifica accessibilityLabel né hitArea |
| `test_feed_buttonTapDoesNotCrash` | Crash su tap | Non verifica che la barra Fame aumenti |
| `test_play_buttonTapDoesNotCrash` | Crash su tap | Non verifica che la barra Energia diminuisca |
| `test_meditate_changesMoodLabel` | Cambio mood label | Non verifica le barre Calma/Felicità |
| `test_journal_sheetOpensOnTap` | Esistenza app dopo tap | **BUG-04**: il sheet non si apre, il test passa falsamente perché controlla solo `app.exists` |

---

## 3. Riepilogo e Priorità

| Priorità | ID | Descrizione |
| :--- | :--- | :--- |
| 🔴 Alta | BUG-04 | Pulsante Diario non apre nessuna view |
| 🟠 Media | BUG-01 | Mood sempre `.happy` dopo Medita |
| 🟠 Media | BUG-03 | Energia a 0 senza conseguenze sul mood |
| 🟠 Media | BUG-06 | Discrepanza `appState.mood` vs `pet.moodRaw` |
| 🟠 Media | INJ-01 | `pet.name` non sanitizzato |
| 🟠 Media | INJ-03 | `fatalError` nel container SwiftData |
| 🟡 Bassa | BUG-02 | Nessun feedback quando cibo = 0 |
| 🟡 Bassa | BUG-05 | Nessun feedback aptico sui pulsanti |
| 🟡 Bassa | INJ-02 | `moodRaw` senza validazione in lettura |
| 🟡 Bassa | INJ-04 | `try?` silenzioso su `save()` |
| 🟡 Bassa | INJ-05 | `UIScreen.main.bounds` deprecato |
| 🟡 Bassa | INJ-06 | `--uitesting` non gestito nel codice app |

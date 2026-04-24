import SwiftUI

// MARK: - Activity Category

enum ActivityCategory: String, CaseIterable, Identifiable {
    case all        = "Tutte"
    case breathing  = "Respirazione"
    case meditation = "Meditazione"
    case focus      = "Focus"
    case journaling = "Journaling"
    case shortBreak = "Pausa breve"
    case evening    = "Routine serale"

    var id: String { rawValue }

    var sfSymbol: String {
        switch self {
        case .all:        return "square.grid.2x2"
        case .breathing:  return "wind"
        case .meditation: return "sparkles"
        case .focus:      return "scope"
        case .journaling: return "book.closed"
        case .shortBreak: return "clock"
        case .evening:    return "moon"
        }
    }
}

// MARK: - Session Step

struct SessionStep: Identifiable {
    let id = UUID()
    let number: Int
    let title: String
    let description: String
    let durationSeconds: Int
}

// MARK: - Meditation Activity

struct MeditationActivity: Identifiable {
    let id = UUID()
    let title: String
    let category: ActivityCategory
    let durationMinutes: Int
    let level: String
    let description: String
    let objective: String
    let steps: [SessionStep]
    let benefits: [String]
    let benefitIcons: [String]
    var isFavorite: Bool = false

    var totalSessionSeconds: Int { steps.reduce(0) { $0 + $1.durationSeconds } }
}

// MARK: - Catalog

extension MeditationActivity {
    // swiftlint:disable function_body_length
    static let catalog: [MeditationActivity] = [
        MeditationActivity(
            title: "Respiro del Mattino",
            category: .breathing,
            durationMinutes: 5,
            level: "Principiante",
            description: "Risveglia corpo e mente con 5 minuti di respirazione consapevole guidata.",
            objective: "Energizzarsi con una respirazione ritmica che porta freschezza mentale e prepara il corpo alla giornata.",
            steps: [
                SessionStep(number: 1, title: "Preparazione",   description: "Siediti comodo, schiena dritta. Chiudi gli occhi.", durationSeconds: 40),
                SessionStep(number: 2, title: "Respiro 4-4-4",  description: "Inspira 4 sec, trattieni 4, espira 4.",             durationSeconds: 120),
                SessionStep(number: 3, title: "Respiro libero", description: "Lascia fluire il respiro naturalmente.",             durationSeconds: 90),
                SessionStep(number: 4, title: "Chiusura",       description: "Ritorna gradualmente al presente.",                 durationSeconds: 50),
            ],
            benefits: ["Riduzione stress", "Energia mattutina", "Chiarezza"],
            benefitIcons: ["leaf", "bolt", "brain"]
        ),
        MeditationActivity(
            title: "Respiro Consapevole",
            category: .meditation,
            durationMinutes: 15,
            level: "Intermedio",
            description: "Questa sessione guidata ti accompagna in un viaggio di consapevolezza attraverso il respiro. Imparerai a riconoscere le tensioni accumulate nel corpo e a lasciarle andare con tecniche di respirazione profonda e ritmica.",
            objective: "Ridurre lo stress accumulato e ristabilire un ritmo respiratorio naturale, favorendo centratura e presenza nel momento.",
            steps: [
                SessionStep(number: 1, title: "Preparazione",           description: "Trova una posizione comoda e chiudi gli occhi. 2 min", durationSeconds: 120),
                SessionStep(number: 2, title: "Scansione Corporea",     description: "Porta attenzione a ogni parte del corpo. 4 min",       durationSeconds: 240),
                SessionStep(number: 3, title: "Respirazione Guidata",   description: "Segui il ritmo di inspirazione ed espirazione. 6 min", durationSeconds: 360),
                SessionStep(number: 4, title: "Chiusura e Gratitudine", description: "Ritorna gradualmente al presente. 3 min",              durationSeconds: 180),
            ],
            benefits: ["Riduzione stress", "Chiarezza mentale", "Calma interiore", "Sonno migliore"],
            benefitIcons: ["leaf", "brain", "heart", "moon"],
            isFavorite: true
        ),
        MeditationActivity(
            title: "Meditazione Profonda",
            category: .meditation,
            durationMinutes: 15,
            level: "Intermedio",
            description: "Lascia andare lo stress con una sessione guidata di 15 minuti.",
            objective: "Raggiungere uno stato di profondo rilassamento e chiarezza interiore.",
            steps: [
                SessionStep(number: 1, title: "Grounding",       description: "Radica il tuo corpo nel presente. 3 min",      durationSeconds: 180),
                SessionStep(number: 2, title: "Visualizzazione", description: "Immagina un luogo sereno e sicuro. 7 min",      durationSeconds: 420),
                SessionStep(number: 3, title: "Mantras",         description: "Ripeti affermazioni di pace interiore. 3 min", durationSeconds: 180),
                SessionStep(number: 4, title: "Ritorno",         description: "Ritorna dolcemente al presente. 2 min",        durationSeconds: 120),
            ],
            benefits: ["Relax profondo", "Chiarezza", "Benessere"],
            benefitIcons: ["sparkles", "brain", "heart"]
        ),
        MeditationActivity(
            title: "Diario della Gratitudine",
            category: .journaling,
            durationMinutes: 10,
            level: "Principiante",
            description: "Scrivi 3 cose per cui sei grato oggi e trasforma la tua prospettiva.",
            objective: "Coltivare gratitudine e positività attraverso la scrittura riflessiva.",
            steps: [
                SessionStep(number: 1, title: "Respira",     description: "3 respiri profondi per centrarsi.",    durationSeconds: 60),
                SessionStep(number: 2, title: "Scrivi",      description: "3 cose positive di oggi.",             durationSeconds: 300),
                SessionStep(number: 3, title: "Riflessione", description: "Leggi quello che hai scritto.",        durationSeconds: 120),
                SessionStep(number: 4, title: "Intenzione",  description: "Scegli un'intenzione per domani.",     durationSeconds: 120),
            ],
            benefits: ["Positività", "Focus", "Autostima"],
            benefitIcons: ["sun.max", "scope", "heart"]
        ),
        MeditationActivity(
            title: "Routine della Buonanotte",
            category: .evening,
            durationMinutes: 20,
            level: "Tutti i livelli",
            description: "Prepara il corpo al sonno con stretching dolce e visualizzazione guidata.",
            objective: "Favorire il rilassamento profondo per un sonno rigenerante.",
            steps: [
                SessionStep(number: 1, title: "Stretching dolce",   description: "Allenta le tensioni del corpo. 5 min",  durationSeconds: 300),
                SessionStep(number: 2, title: "Respirazione 4-7-8", description: "Rallenta il sistema nervoso. 4 min",    durationSeconds: 240),
                SessionStep(number: 3, title: "Visualizzazione",    description: "Immagina un luogo di pace. 5 min",      durationSeconds: 300),
                SessionStep(number: 4, title: "Rilascio finale",    description: "Lascia andare la giornata. 6 min",      durationSeconds: 360),
            ],
            benefits: ["Sonno migliore", "Relax", "Recupero"],
            benefitIcons: ["moon", "leaf", "bolt"]
        ),
        MeditationActivity(
            title: "Focus Intenso",
            category: .focus,
            durationMinutes: 12,
            level: "Intermedio",
            description: "Aumenta la concentrazione con tecniche di mindfulness e suoni binaurali.",
            objective: "Potenziare la capacità di concentrazione e ridurre le distrazioni mentali.",
            steps: [
                SessionStep(number: 1, title: "Centratura",     description: "Porta attenzione al respiro. 2 min",        durationSeconds: 120),
                SessionStep(number: 2, title: "Focus Point",    description: "Scegli un punto di concentrazione. 5 min",  durationSeconds: 300),
                SessionStep(number: 3, title: "Flow",           description: "Mantieni l'attenzione fluente. 4 min",      durationSeconds: 240),
                SessionStep(number: 4, title: "Consolidamento", description: "Fissa l'intento nel presente. 1 min",       durationSeconds: 60),
            ],
            benefits: ["Produttività", "Concentrazione", "Calma"],
            benefitIcons: ["brain", "scope", "sparkles"]
        ),
        MeditationActivity(
            title: "Pausa Tè",
            category: .shortBreak,
            durationMinutes: 5,
            level: "Principiante",
            description: "Una micro-pausa consapevole per ricaricarsi durante la giornata.",
            objective: "Interrompere il ciclo di stress con 5 minuti di presenza piena.",
            steps: [
                SessionStep(number: 1, title: "Sosta",      description: "Metti giù tutto quello che stai facendo.", durationSeconds: 30),
                SessionStep(number: 2, title: "Respira",    description: "5 respiri lenti e profondi.",              durationSeconds: 90),
                SessionStep(number: 3, title: "Presenza",   description: "Osserva 5 cose intorno a te.",             durationSeconds: 120),
                SessionStep(number: 4, title: "Intenzione", description: "Torna alle attività con intenzione.",      durationSeconds: 60),
            ],
            benefits: ["Calma immediata", "Reset mentale", "Energia"],
            benefitIcons: ["clock", "arrow.counterclockwise", "bolt"]
        ),
    ]
    // swiftlint:enable function_body_length
}

// MARK: - Design tokens

private enum MT {
    static let bg         = Color(hex: "F7F4EF")
    static let accent     = Color(hex: "C78F65")
    static let accentDark = Color(hex: "845430")
    static let text       = Color(hex: "2C1C10")
    static let textSub    = Color(hex: "737373")
    static let tag        = Color(hex: "F4E9E0")
    static let border     = Color(hex: "E5E5E5")
    static let borderWarm = Color(hex: "DDBCA3")
    static let sessionBg  = Color(hex: "141210")
    static let sessionFg  = Color(hex: "F4E9E0")
    static let sessionSub = Color(hex: "DDBCA3")

    static let heroGradient = LinearGradient(
        colors: [Color(hex: "C78F65"), Color(hex: "6B3A20")],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    static let arcGradient = LinearGradient(
        colors: [Color(hex: "C78F65"), Color(hex: "E8B080")],
        startPoint: .leading, endPoint: .trailing
    )
}

// MARK: - MeditationLibraryView

struct MeditationLibraryView: View {
    @EnvironmentObject private var store: GameStore
    @State private var selectedCategory: ActivityCategory = .all
    @State private var searchText = ""

    private var filtered: [MeditationActivity] {
        MeditationActivity.catalog.filter { activity in
            let catOK    = selectedCategory == .all || activity.category == selectedCategory
            let searchOK = searchText.isEmpty ||
                activity.title.localizedCaseInsensitiveContains(searchText) ||
                activity.category.rawValue.localizedCaseInsensitiveContains(searchText)
            return catOK && searchOK
        }
    }

    var body: some View {
        ZStack {
            MT.bg.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    libraryHero
                        .padding(.bottom, 4)

                    searchBar
                        .padding(.horizontal, 16)
                        .padding(.top, 16)

                    categoryChips
                        .padding(.top, 12)

                    if filtered.isEmpty {
                        emptyState
                            .padding(.top, 40)
                    } else {
                        Text("Attività consigliate")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(MT.text)
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                            .padding(.bottom, 4)

                        LazyVStack(spacing: 10) {
                            ForEach(filtered) { activity in
                                NavigationLink(destination:
                                    MeditationActivityDetailView(activity: activity)
                                        .environmentObject(store)
                                ) {
                                    ActivityCardView(activity: activity)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 16)
                    }

                    Spacer(minLength: 40)
                }
            }
        }
        .navigationBarHidden(true)
    }

    private var libraryHero: some View {
        ZStack(alignment: .bottomLeading) {
            MT.heroGradient
                .frame(height: 200)

            // ambient orb
            Circle()
                .fill(Color.white.opacity(0.08))
                .frame(width: 220, height: 220)
                .blur(radius: 40)
                .offset(x: 160, y: -20)

            VStack(alignment: .leading, spacing: 6) {
                Text("ME TIME")
                    .font(.system(size: 11, weight: .black))
                    .foregroundStyle(Color.white.opacity(0.6))
                    .kerning(2)

                Text("Libreria\nAttività")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(.white)
                    .lineSpacing(2)

                HStack(spacing: 16) {
                    heroStat(icon: "sparkles", label: "\(MeditationActivity.catalog.count) sessioni")
                    heroStat(icon: "clock", label: "5–20 min")
                    heroStat(icon: "heart", label: "Mindful")
                }
                .padding(.top, 4)
            }
            .padding(24)
            .padding(.bottom, 8)
        }
    }

    private func heroStat(icon: String, label: String) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .semibold))
            Text(label)
                .font(.system(size: 12, weight: .semibold))
        }
        .foregroundStyle(Color.white.opacity(0.85))
    }

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Color(hex: "A3A3A3"))
                .font(.system(size: 14))
            TextField("Cerca attività...", text: $searchText)
                .font(.system(size: 14))
                .foregroundStyle(MT.text)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .mtSectionCard(cornerRadius: 14)
    }

    private var categoryChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(ActivityCategory.allCases) { cat in
                    MTFilterChip(title: cat.rawValue, iconText: nil, selected: selectedCategory == cat, tint: MT.accentDark) {
                        withAnimation(.snappy(duration: 0.2)) { selectedCategory = cat }
                    }
                    .animation(.easeInOut(duration: 0.15), value: selectedCategory)
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 32))
                .foregroundStyle(MT.accent.opacity(0.5))
            Text("Nessuna attività trovata")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(MT.textSub)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Activity Card

private struct ActivityCardView: View {
    let activity: MeditationActivity

    var body: some View {
        HStack(spacing: 0) {
            // Thumbnail
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(MT.tag)
                .frame(width: 110, height: 120)
                .overlay {
                    Image(systemName: activity.category.sfSymbol)
                        .font(.system(size: 30))
                        .foregroundStyle(MT.accent)
                }

            // Info
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .top) {
                    Text(activity.title)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(MT.text)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer(minLength: 4)
                    Image(systemName: activity.isFavorite ? "heart.fill" : "heart")
                        .font(.system(size: 13))
                        .foregroundStyle(activity.isFavorite ? MT.accent : Color(hex: "D4D4D4"))
                }

                HStack(spacing: 6) {
                    Text(activity.category.rawValue)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(MT.accentDark)
                    Text(activity.level)
                        .font(.system(size: 10))
                        .foregroundStyle(Color(hex: "B07040"))
                }

                Text(activity.description)
                    .font(.system(size: 11))
                    .foregroundStyle(MT.textSub)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 12) {
                    Label("\(activity.durationMinutes) min", systemImage: "clock")
                        .font(.system(size: 10))
                        .foregroundStyle(MT.textSub)
                        .labelStyle(CompactLabelStyle())

                    if let firstBenefit = activity.benefits.first,
                       let firstIcon   = activity.benefitIcons.first {
                        Label(firstBenefit, systemImage: firstIcon)
                            .font(.system(size: 10))
                            .foregroundStyle(MT.textSub)
                            .labelStyle(CompactLabelStyle())
                    }
                }
            }
            .padding(.leading, 12)
            .padding(.trailing, 12)
            .padding(.vertical, 12)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .mtSectionCard(cornerRadius: 18)
    }
}

private struct CompactLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 4) {
            configuration.icon.foregroundStyle(Color(hex: "C78F65"))
            configuration.title
        }
    }
}

// MARK: - MeditationActivityDetailView

struct MeditationActivityDetailView: View {
    @EnvironmentObject private var store: GameStore
    let activity: MeditationActivity

    var body: some View {
        ZStack {
            MT.bg.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Hero
                    heroSection
                        .padding(.bottom, 20)

                    VStack(alignment: .leading, spacing: 20) {
                        // Tags + title
                        tagsAndTitle

                        // Meta row
                        metaRow

                        // Description
                        sectionBlock(title: "Descrizione") {
                            Text(activity.description)
                                .font(.system(size: 14))
                                .foregroundStyle(Color(hex: "404040"))
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        // Objective
                        objectiveBlock

                        // Steps
                        sectionBlock(title: "Step della Sessione") {
                            VStack(spacing: 10) {
                                ForEach(activity.steps) { step in
                                    stepRow(step)
                                }
                            }
                        }

                        // Benefits
                        sectionBlock(title: "Benefici Attesi") {
                            benefitsGrid
                        }

                        // Audio preview
                        audioPreviewBlock

                        // CTA
                        NavigationLink(destination:
                            ActiveSessionView(activity: activity)
                                .environmentObject(store)
                        ) {
                            Text("Inizia la Sessione")
                                .font(.system(size: 16, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 17)
                                .background(MT.accent)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        }
                        .buttonStyle(.plain)

                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Image(systemName: "leaf.fill")
                    .foregroundStyle(MT.accent)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Image(systemName: activity.isFavorite ? "heart.fill" : "heart")
                    .foregroundStyle(MT.borderWarm)
            }
        }
    }

    // MARK: Sub-views

    private var heroSection: some View {
        RoundedRectangle(cornerRadius: 0)
            .fill(
                LinearGradient(
                    colors: [MT.tag, MT.accent.opacity(0.35)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(height: 220)
            .overlay {
                Image(systemName: activity.category.sfSymbol)
                    .font(.system(size: 64))
                    .foregroundStyle(MT.accent.opacity(0.6))
            }
    }

    private var tagsAndTitle: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 10) {
                tagLabel(activity.category.rawValue, color: MT.accentDark)
                tagLabel(activity.level, color: Color(hex: "B07040"))
            }
            Text(activity.title)
                .font(.system(size: 24, weight: .bold, design: .serif))
                .foregroundStyle(MT.text)
        }
    }

    private var metaRow: some View {
        HStack(spacing: 18) {
            metaItem(icon: "clock",     label: "\(activity.durationMinutes) min")
            metaItem(icon: "signal",    label: activity.level)
            metaItem(icon: "star.fill", label: "4.8")
            metaItem(icon: "headphones",label: "Audio")
        }
        .font(.system(size: 14))
        .foregroundStyle(Color(hex: "525252"))
    }

    private var objectiveBlock: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "scope")
                    .foregroundStyle(MT.accent)
                Text("Obiettivo")
                    .font(.system(size: 16, weight: .semibold, design: .serif))
                    .foregroundStyle(MT.text)
            }
            Text(activity.objective)
                .font(.system(size: 14))
                .foregroundStyle(Color(hex: "583820"))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(MT.tag)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(MT.borderWarm, lineWidth: 1)
        )
    }

    private var benefitsGrid: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                ForEach(Array(zip(activity.benefits, activity.benefitIcons)).prefix(2), id: \.0) { benefit, icon in
                    benefitChip(icon: icon, text: benefit)
                }
            }
            if activity.benefits.count > 2 {
                HStack(spacing: 10) {
                    ForEach(Array(zip(activity.benefits, activity.benefitIcons)).dropFirst(2), id: \.0) { benefit, icon in
                        benefitChip(icon: icon, text: benefit)
                    }
                }
            }
        }
    }

    private var audioPreviewBlock: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(MT.tag)
                        .frame(width: 44, height: 44)
                    Image(systemName: "play.circle.fill")
                        .foregroundStyle(MT.accent)
                        .font(.system(size: 18))
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("Anteprima Audio")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(MT.text)
                    Text("Ascolta 30 secondi di preview")
                        .font(.system(size: 12))
                        .foregroundStyle(MT.textSub)
                }
                Spacer()
                Text("0:30")
                    .font(.system(size: 12))
                    .foregroundStyle(MT.textSub)
            }

            // Progress bar (static preview)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(MT.tag).frame(height: 6)
                    Capsule().fill(MT.accent).frame(width: geo.size.width * 0.3, height: 6)
                }
            }
            .frame(height: 6)
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(MT.border, lineWidth: 1)
        )
    }

    // MARK: Helpers

    @ViewBuilder
    private func sectionBlock<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 16, weight: .semibold, design: .serif))
                .foregroundStyle(MT.text)
            content()
        }
    }

    private func stepRow(_ step: SessionStep) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(MT.accent)
                .frame(width: 28, height: 28)
                .overlay {
                    Text("\(step.number)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                }

            VStack(alignment: .leading, spacing: 4) {
                Text(step.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(MT.text)
                Text(step.description)
                    .font(.system(size: 12))
                    .foregroundStyle(Color(hex: "525252"))
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(MT.border, lineWidth: 1)
        )
    }

    private func benefitChip(icon: String, text: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(MT.accent)
            Text(text)
                .font(.system(size: 14))
                .foregroundStyle(Color(hex: "404040"))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(Color.white)
        .clipShape(Capsule())
        .overlay(Capsule().stroke(MT.border, lineWidth: 1))
    }

    private func tagLabel(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(color)
    }

    private func metaItem(icon: String, label: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundStyle(MT.accent)
                .font(.system(size: 13))
            Text(label)
        }
    }
}

// MARK: - BreathingPhase

private enum BreathingPhase {
    case inhale, hold, exhale

    var label: String {
        switch self {
        case .inhale:  "Inspira"
        case .hold:    "Trattieni"
        case .exhale:  "Espira"
        }
    }

    var duration: Double {
        switch self {
        case .inhale:  4
        case .hold:    4
        case .exhale:  6
        }
    }

    var targetScale: CGFloat {
        switch self {
        case .inhale, .hold:  1.0
        case .exhale:         0.82
        }
    }

    var next: BreathingPhase {
        switch self {
        case .inhale:  .hold
        case .hold:    .exhale
        case .exhale:  .inhale
        }
    }
}

// MARK: - ActiveSessionView

struct ActiveSessionView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: GameStore

    let activity: MeditationActivity

    @State private var elapsedSeconds   = 0
    @State private var isPaused         = false
    @State private var isAudioPlaying   = true
    @State private var currentStepIdx   = 0
    @State private var showCheckin      = false
    @State private var timerTask: Task<Void, Never>?

    @State private var breathingPhase: BreathingPhase = .inhale
    @State private var breathScale: CGFloat            = 0.82
    @State private var breathingTask: Task<Void, Never>?

    private var totalSeconds: Int { max(activity.totalSessionSeconds, 1) }

    private var currentStep: SessionStep {
        activity.steps[min(currentStepIdx, activity.steps.count - 1)]
    }

    private var remainingSeconds: Int { max(0, totalSeconds - elapsedSeconds) }

    var body: some View {
        ZStack {
            MT.sessionBg.ignoresSafeArea()

            VStack(spacing: 0) {
                topBar
                    .padding(.top, 8)
                    .padding(.horizontal, 24)

                Spacer()

                timerCircle

                Spacer()

                stepCard(currentStep)
                    .padding(.horizontal, 24)

                stepDots
                    .padding(.top, 16)

                Spacer(minLength: 20)

                audioPlayerRow
                    .padding(.horizontal, 24)

                sessionProgressBar
                    .padding(.horizontal, 24)
                    .padding(.top, 14)

                sessionControls
                    .padding(.top, 20)
                    .padding(.bottom, 40)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            startTimer()
            startBreathingCycle()
        }
        .onDisappear {
            stopTimer()
            stopBreathingCycle()
        }
        .onChange(of: isPaused) { _, paused in
            if paused { stopBreathingCycle() } else { startBreathingCycle() }
        }
        .sheet(isPresented: $showCheckin) {
            NavigationStack {
                SessionCheckinView(activity: activity)
                    .environmentObject(store)
            }
        }
    }

    // MARK: Sub-views

    private var topBar: some View {
        HStack {
            Button { dismiss() } label: {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 40, height: 40)
                    Image(systemName: "xmark")
                        .foregroundStyle(MT.sessionFg)
                        .font(.system(size: 13))
                }
            }
            Spacer()
            Text(activity.category.rawValue)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(MT.sessionSub)
            Spacer()
            Color.clear.frame(width: 40, height: 40)
        }
    }

    private var timerCircle: some View {
        ZStack {
            Circle()
                .stroke(MT.accent.opacity(0.2), lineWidth: 4)
                .frame(width: 184, height: 184)

            Circle()
                .trim(from: 0, to: CGFloat(elapsedSeconds) / CGFloat(totalSeconds))
                .stroke(MT.accent, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .frame(width: 184, height: 184)
                .animation(.linear(duration: 1), value: elapsedSeconds)

            Circle()
                .stroke(MT.sessionSub.opacity(0.25), lineWidth: 1)
                .frame(width: 170, height: 170)

            Circle()
                .fill(MT.accent.opacity(0.12))
                .frame(width: 158, height: 158)
                .scaleEffect(breathScale)
                .animation(
                    .easeInOut(duration: breathingPhase.duration),
                    value: breathScale
                )

            VStack(spacing: 6) {
                Text(formatTimeString(remainingSeconds))
                    .font(.system(size: 36, weight: .bold, design: .serif))
                    .foregroundStyle(MT.sessionFg)
                Text(isPaused ? "In pausa" : breathingPhase.label)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(MT.sessionSub)
                    .animation(.easeInOut(duration: 0.3), value: breathingPhase.label)
                Text("di \(formatTimeString(totalSeconds))")
                    .font(.system(size: 11))
                    .foregroundStyle(MT.sessionSub.opacity(0.6))
            }
        }
    }

    private func stepCard(_ step: SessionStep) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Circle()
                    .fill(MT.accent)
                    .frame(width: 24, height: 24)
                    .overlay {
                        Text("\(step.number)")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.white)
                    }
                Text(step.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color(hex: "E9D2C1"))
                Spacer()
            }
            Text(step.description)
                .font(.system(size: 14))
                .foregroundStyle(MT.sessionSub)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(MT.sessionSub.opacity(0.15), lineWidth: 1)
        )
        .id(currentStepIdx)
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }

    private var stepDots: some View {
        HStack(spacing: 8) {
            ForEach(0..<activity.steps.count, id: \.self) { i in
                Circle()
                    .fill(i == currentStepIdx
                          ? MT.accent
                          : MT.accent.opacity(0.3))
                    .frame(width: 8, height: 8)
                    .animation(.easeInOut(duration: 0.2), value: currentStepIdx)
            }
        }
    }

    private var audioPlayerRow: some View {
        HStack(spacing: 12) {
            Image(systemName: "music.note")
                .foregroundStyle(MT.accent)
                .font(.system(size: 16))

            VStack(alignment: .leading, spacing: 2) {
                Text("Onde del mattino")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color(hex: "E9D2C1"))
                Text("Suoni della natura")
                    .font(.system(size: 12))
                    .foregroundStyle(MT.sessionSub)
            }

            Spacer()

            HStack(spacing: 16) {
                Button { } label: {
                    Image(systemName: "backward.fill")
                        .foregroundStyle(MT.sessionSub)
                        .font(.system(size: 14))
                }
                Button {
                    withAnimation(.easeInOut(duration: 0.15)) { isAudioPlaying.toggle() }
                } label: {
                    ZStack {
                        Circle()
                            .fill(MT.accent)
                            .frame(width: 32, height: 32)
                        Image(systemName: isAudioPlaying ? "pause.fill" : "play.fill")
                            .foregroundStyle(.white)
                            .font(.system(size: 11))
                    }
                }
                Button { } label: {
                    Image(systemName: "forward.fill")
                        .foregroundStyle(MT.sessionSub)
                        .font(.system(size: 14))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(MT.sessionSub.opacity(0.12), lineWidth: 1)
        )
    }

    private var sessionProgressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.08))
                    .frame(height: 8)
                Capsule()
                    .fill(MT.accent)
                    .frame(
                        width: geo.size.width * CGFloat(elapsedSeconds) / CGFloat(totalSeconds),
                        height: 8
                    )
                    .animation(.linear(duration: 1), value: elapsedSeconds)
            }
        }
        .frame(height: 8)
    }

    private var sessionControls: some View {
        HStack(alignment: .center, spacing: 28) {
            // Stop
            Button { dismiss() } label: {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.08))
                        .overlay(Circle().stroke(MT.sessionSub.opacity(0.2), lineWidth: 1))
                        .frame(width: 50, height: 50)
                    Image(systemName: "stop.fill")
                        .foregroundStyle(MT.sessionSub)
                        .font(.system(size: 16))
                }
            }

            // Pause / Resume (large)
            Button {
                withAnimation(.easeInOut(duration: 0.15)) { isPaused.toggle() }
            } label: {
                ZStack {
                    Circle()
                        .fill(MT.accent)
                        .frame(width: 68, height: 68)
                    Image(systemName: isPaused ? "play.fill" : "pause.fill")
                        .foregroundStyle(.white)
                        .font(.system(size: 22))
                }
            }

            // Complete
            Button {
                stopTimer()
                store.completeRelaxRitual(durationSeconds: elapsedSeconds, gratitudeText: "")
                showCheckin = true
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.08))
                        .overlay(Circle().stroke(MT.sessionSub.opacity(0.2), lineWidth: 1))
                        .frame(width: 50, height: 50)
                    Image(systemName: "checkmark")
                        .foregroundStyle(MT.sessionSub)
                        .font(.system(size: 18, weight: .semibold))
                }
            }
        }
    }

    // MARK: Timer

    private func startTimer() {
        timerTask = Task { @MainActor in
            while !Task.isCancelled && elapsedSeconds < totalSeconds {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                guard !Task.isCancelled else { break }
                if !isPaused {
                    elapsedSeconds = min(elapsedSeconds + 1, totalSeconds)
                    advanceStep()
                }
            }
        }
    }

    private func stopTimer() {
        timerTask?.cancel()
        timerTask = nil
    }

    private func advanceStep() {
        var cumulative = 0
        for (i, step) in activity.steps.enumerated() {
            cumulative += step.durationSeconds
            if elapsedSeconds <= cumulative {
                if currentStepIdx != i {
                    withAnimation(.easeInOut(duration: 0.3)) { currentStepIdx = i }
                }
                return
            }
        }
        currentStepIdx = activity.steps.count - 1
    }

    // MARK: Breathing cycle

    private func startBreathingCycle() {
        breathingTask = Task { @MainActor in
            while !Task.isCancelled {
                let phase = breathingPhase
                withAnimation(.easeInOut(duration: phase.duration)) {
                    breathScale = phase.targetScale
                }
                let nanos = UInt64(phase.duration * 1_000_000_000)
                try? await Task.sleep(nanoseconds: nanos)
                guard !Task.isCancelled else { break }
                breathingPhase = phase.next
            }
        }
    }

    private func stopBreathingCycle() {
        breathingTask?.cancel()
        breathingTask = nil
    }
}

// MARK: - SessionCheckinView

struct SessionCheckinView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: GameStore

    let activity: MeditationActivity

    @State private var selectedMood   = 2    // 0…4
    @State private var energyLevel    = 0.70
    @State private var focusLevel     = 0.50
    @State private var stressLevel    = 0.25
    @State private var thoughtText    = ""
    @State private var nextGoalText   = ""
    @State private var personalNotes  = ""
    @State private var isSaved        = false

    private let moods: [(emoji: String, label: String)] = [
        ("😔", "Giù"), ("😐", "Neutro"), ("🙂", "Bene"), ("😊", "Molto"), ("🤩", "Ottimo")
    ]

    var body: some View {
        ZStack {
            MT.bg.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    // Mood picker
                    moodPickerCard

                    // Indicators
                    indicatorsCard

                    // Guided questions
                    guidedQuestionsCard

                    // Personal notes
                    personalNotesCard

                    // Insight suggestion
                    insightCard

                    // Save button
                    Button { save() } label: {
                        HStack {
                            if isSaved {
                                Image(systemName: "checkmark.circle.fill")
                            }
                            Text(isSaved ? "Salvato nel diario" : "Salva nel diario")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(isSaved ? MT.accentDark : MT.accent)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .disabled(isSaved)
                    .padding(.horizontal, 20)
                    .animation(.easeInOut(duration: 0.2), value: isSaved)

                    if isSaved {
                        Button { dismiss() } label: {
                            Text("Torna alla Home")
                                .font(.system(size: 14))
                                .foregroundStyle(MT.accentDark)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                        }
                        .padding(.horizontal, 20)
                    }

                    Spacer(minLength: 40)
                }
                .padding(.top, 16)
            }
        }
        .navigationTitle("Diario e Check-in")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Chiudi") { dismiss() }
                    .foregroundStyle(MT.accentDark)
            }
        }
    }

    // MARK: Cards

    private var moodPickerCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Come ti senti in questo momento?")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color(hex: "404040"))

            HStack(spacing: 0) {
                ForEach(moods.indices, id: \.self) { i in
                    VStack(spacing: 4) {
                        ZStack {
                            Circle()
                                .fill(i == selectedMood ? MT.tag : Color(hex: "F9F4F0"))
                                .overlay(
                                    Circle()
                                        .stroke(i == selectedMood ? MT.accent : MT.border,
                                                lineWidth: i == selectedMood ? 2 : 1)
                                )
                                .frame(width: 44, height: 44)

                            Text(moods[i].emoji)
                                .font(.system(size: 22))
                        }
                        Text(moods[i].label)
                            .font(.system(size: 10, weight: i == selectedMood ? .semibold : .regular))
                            .foregroundStyle(i == selectedMood ? MT.accent : MT.textSub)
                    }
                    .frame(maxWidth: .infinity)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.15)) { selectedMood = i }
                    }
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(MT.border, lineWidth: 1)
        )
        .padding(.horizontal, 20)
    }

    private var indicatorsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Indicatori")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color(hex: "404040"))

            indicatorRow(emoji: "⚡", label: "Energia",        value: energyLevelLabel,  color: MT.accent,     binding: $energyLevel)
            indicatorRow(emoji: "🧠", label: "Concentrazione", value: focusLevelLabel,   color: Color(hex: "D2A584"), binding: $focusLevel)
            indicatorRow(emoji: "😤", label: "Stress",         value: stressLevelLabel,  color: MT.accentDark, binding: $stressLevel)
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(MT.border, lineWidth: 1)
        )
        .padding(.horizontal, 20)
    }

    private var guidedQuestionsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Domande guidate")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color(hex: "404040"))

            questionField(
                prompt: "Qual è il pensiero principale che hai in mente ora?",
                placeholder: "Scrivi qui il tuo pensiero...",
                text: $thoughtText
            )
            questionField(
                prompt: "Cosa vorresti ottenere dalla prossima sessione?",
                placeholder: "Es. rilassarmi, concentrarmi meglio...",
                text: $nextGoalText
            )
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(MT.border, lineWidth: 1)
        )
        .padding(.horizontal, 20)
    }

    private var personalNotesCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Note personali")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color(hex: "404040"))
            TextField("Aggiungi le tue riflessioni libere...", text: $personalNotes, axis: .vertical)
                .font(.system(size: 12))
                .lineLimit(4...6)
                .padding(12)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color(hex: "D4D4D4"), lineWidth: 1)
                )
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(MT.border, lineWidth: 1)
        )
        .padding(.horizontal, 20)
    }

    private var insightCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "lightbulb.fill")
                    .foregroundStyle(MT.accent)
                    .font(.system(size: 12))
                Text("Suggerimento per te")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(MT.text)
            }
            Text(insightText)
                .font(.system(size: 12))
                .foregroundStyle(Color(hex: "583820"))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(MT.tag)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(MT.borderWarm, lineWidth: 1)
        )
        .padding(.horizontal, 20)
    }

    // MARK: Helper views

    private func indicatorRow(
        emoji: String,
        label: String,
        value: String,
        color: Color,
        binding: Binding<Double>
    ) -> some View {
        VStack(spacing: 6) {
            HStack {
                Text("\(emoji) \(label)")
                    .font(.system(size: 12))
                    .foregroundStyle(Color(hex: "525252"))
                Spacer()
                Text(value)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(color)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color(hex: "E5E5E5")).frame(height: 8)
                    Capsule().fill(color)
                        .frame(width: geo.size.width * binding.wrappedValue, height: 8)
                        .animation(.easeInOut(duration: 0.2), value: binding.wrappedValue)
                }
            }
            .frame(height: 8)
        }
    }

    private func questionField(
        prompt: String,
        placeholder: String,
        text: Binding<String>
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(prompt)
                .font(.system(size: 12))
                .foregroundStyle(Color(hex: "525252"))
            TextField(placeholder, text: text, axis: .vertical)
                .font(.system(size: 12))
                .lineLimit(2...4)
                .padding(12)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color(hex: "D4D4D4"), lineWidth: 1)
                )
        }
    }

    // MARK: Logic

    private var energyLevelLabel: String {
        energyLevel > 0.65 ? "Alta" : energyLevel > 0.35 ? "Media" : "Bassa"
    }
    private var focusLevelLabel: String {
        focusLevel > 0.65 ? "Alta" : focusLevel > 0.35 ? "Media" : "Bassa"
    }
    private var stressLevelLabel: String {
        stressLevel < 0.35 ? "Basso" : stressLevel < 0.65 ? "Medio" : "Alto"
    }

    private var insightText: String {
        if energyLevel > 0.6 && stressLevel < 0.4 {
            return "Il tuo livello di energia è alto e lo stress è basso: è il momento ideale per una sessione di meditazione focalizzata o un'attività creativa. Prova \"\(activity.title)\" dalla libreria!"
        } else if stressLevel > 0.6 {
            return "Noto un livello di stress elevato. Le sessioni di respirazione profonda hanno ridotto lo stress fino al 30% nei tuoi ultimi check-in. Considera una pausa breve."
        } else {
            return "Ottimo lavoro completando la sessione di \"\(activity.title)\"! Continuare con sessioni regolari rafforza i benefici nel tempo."
        }
    }

    private func save() {
        let notes = [thoughtText, nextGoalText, personalNotes]
            .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .joined(separator: " | ")
        store.writeDiaryEntry(notes.isEmpty ? "Sessione completata: \(activity.title)" : notes)
        withAnimation(.easeInOut(duration: 0.2)) { isSaved = true }
    }
}

// MARK: - Previews

#Preview("Libreria") {
    let schema    = Schema([Pet.self, PetNeeds.self, MeditationSession.self, GratitudeEntry.self, GardenState.self])
    let config    = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [config])
    let store     = GameStore(modelContext: container.mainContext)

    return NavigationStack {
        MeditationLibraryView()
            .environmentObject(store)
    }
}

import Foundation

struct HomeDerivedState {
    let currentExercises: [FaceExercise]
    let todayCompletedExercises: Set<Int>
    let currentChapter: Chapter
    let displayMessage: String
    let primaryAction: HomePrimaryAction

    var completedExercisesCount: Int {
        todayCompletedExercises.count
    }

    var isTodayComplete: Bool {
        completedExercisesCount >= currentExercises.count
    }

    var nextExercise: FaceExercise? {
        currentExercises.first { !todayCompletedExercises.contains($0.rawValue) }
    }

    init(
        selectedDifficulty: String,
        totalGrowthPoints: Double,
        todayCompletedExercisesData: String,
        lastExerciseDate: String,
        pendingFlowerPick: Bool,
        dailyQuote: String,
        completionQuote: String,
        todayString: String = AppStorageKeys.todayString()
    ) {
        let difficulty = Difficulty(rawValue: selectedDifficulty) ?? .basic
        let exercises = FaceExercise.exercises(for: difficulty)
        let completedExercises = HomeDerivedState.completedExercises(
            from: todayCompletedExercisesData,
            lastExerciseDate: lastExerciseDate,
            todayString: todayString
        )
        let chapter = HomeDerivedState.chapter(for: totalGrowthPoints)
        let isTodayComplete = completedExercises.count >= exercises.count
        let nextExercise = exercises.first { !completedExercises.contains($0.rawValue) }

        currentExercises = exercises
        todayCompletedExercises = completedExercises
        currentChapter = chapter
        displayMessage = isTodayComplete
            ? HomeDerivedState.completionMessage(from: completionQuote)
            : dailyQuote
        primaryAction = HomePrimaryAction(
            pendingFlowerPick: pendingFlowerPick,
            isTodayComplete: isTodayComplete,
            nextExercise: nextExercise,
            completedExercisesCount: completedExercises.count,
            difficulty: difficulty
        )
    }

    private static func completedExercises(
        from encodedExercises: String,
        lastExerciseDate: String,
        todayString: String
    ) -> Set<Int> {
        guard lastExerciseDate == todayString else { return [] }
        return AppStorageKeys.parseCompletedExercises(encodedExercises)
    }

    private static func chapter(for totalGrowthPoints: Double) -> Chapter {
        switch totalGrowthPoints {
        case 0..<20: return .seed
        case 20..<50: return .sprout
        case 50..<100: return .bloom
        default: return .breeze
        }
    }

    private static func completionMessage(from quote: String) -> String {
        quote.isEmpty ? String(localized: "You did it!\nSee you tomorrow.") : quote
    }
}

enum HomePrimaryAction {
    case pickFlower
    case bonusPractice
    case startNextExercise(exercise: FaceExercise, title: String)
    case none

    init(
        pendingFlowerPick: Bool,
        isTodayComplete: Bool,
        nextExercise: FaceExercise?,
        completedExercisesCount: Int,
        difficulty: Difficulty
    ) {
        if pendingFlowerPick {
            self = .pickFlower
        } else if isTodayComplete {
            self = .bonusPractice
        } else if let nextExercise {
            self = .startNextExercise(
                exercise: nextExercise,
                title: HomePrimaryAction.startTitle(
                    for: difficulty,
                    completedExercisesCount: completedExercisesCount
                )
            )
        } else {
            self = .none
        }
    }

    private static func startTitle(
        for difficulty: Difficulty,
        completedExercisesCount: Int
    ) -> String {
        if difficulty == .basic {
            switch completedExercisesCount {
            case 0: return String(localized: "Wake Up Your Smile")
            case 1: return String(localized: "Keep the Flow")
            default: return String(localized: "Complete Your Day")
            }
        } else {
            switch completedExercisesCount {
            case 0: return String(localized: "Start Your Training")
            case 1: return String(localized: "Build the Momentum")
            case 2: return String(localized: "You're Warming Up")
            case 3: return String(localized: "Almost There")
            default: return String(localized: "One More to Go!")
            }
        }
    }
}

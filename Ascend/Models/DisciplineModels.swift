import Foundation
import SwiftData

public enum SupplementTiming: String, Codable, CaseIterable, Identifiable {
    case morning = "Morning with Breakfast"
    case preWorkout = "30-45 Min Pre-Workout"
    case postWorkout = "Immediately Post-Workout"
    case bedtime = "30 Min Before Bed"
    case anytime = "Anytime with Meal"
    
    public var id: String { rawValue }
    
    public var icon: String {
        switch self {
        case .morning: return "sun.max.fill"
        case .preWorkout: return "bolt.fill"
        case .postWorkout: return "cup.and.saucer.fill"
        case .bedtime: return "moon.stars.fill"
        case .anytime: return "clock.fill"
        }
    }
}

@Model
public final class DailyDisciplineEntry {
    public var id: UUID
    public var date: Date
    public var workoutCompleted: Bool
    public var proteinHit: Bool
    public var supplementsTaken: Bool
    public var hydrationHit: Bool
    public var sleepHit: Bool
    public var notes: String
    
    public init(
        id: UUID = UUID(),
        date: Date = Date(),
        workoutCompleted: Bool = false,
        proteinHit: Bool = false,
        supplementsTaken: Bool = false,
        hydrationHit: Bool = false,
        sleepHit: Bool = false,
        notes: String = ""
    ) {
        self.id = id
        self.date = date
        self.workoutCompleted = workoutCompleted
        self.proteinHit = proteinHit
        self.supplementsTaken = supplementsTaken
        self.hydrationHit = hydrationHit
        self.sleepHit = sleepHit
        self.notes = notes
    }
    
    public var completedCount: Int {
        var count = 0
        if workoutCompleted { count += 1 }
        if proteinHit { count += 1 }
        if supplementsTaken { count += 1 }
        if hydrationHit { count += 1 }
        if sleepHit { count += 1 }
        return count
    }
    
    public var completionPercentage: Double {
        Double(completedCount) / 5.0
    }
    
    public var isPerfectDay: Bool {
        completedCount == 5
    }
}

@Model
public final class SupplementItem {
    public var id: UUID
    public var name: String
    public var dosage: String
    public var timingRaw: String
    public var purpose: String
    public var whyItMatters: String
    public var isEssential: Bool
    public var isTakenToday: Bool
    public var lastTakenDate: Date?
    
    public init(
        id: UUID = UUID(),
        name: String,
        dosage: String,
        timing: SupplementTiming,
        purpose: String,
        whyItMatters: String,
        isEssential: Bool = true,
        isTakenToday: Bool = false,
        lastTakenDate: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.dosage = dosage
        self.timingRaw = timing.rawValue
        self.purpose = purpose
        self.whyItMatters = whyItMatters
        self.isEssential = isEssential
        self.isTakenToday = isTakenToday
        self.lastTakenDate = lastTakenDate
    }
    
    public var timing: SupplementTiming {
        get { SupplementTiming(rawValue: timingRaw) ?? .morning }
        set { timingRaw = newValue.rawValue }
    }
}

public struct MindsetQuote: Identifiable {
    public var id = UUID()
    public let quote: String
    public let author: String
    public let theme: String
    
    public static let library: [MindsetQuote] = [
        MindsetQuote(quote: "We don't rise to the level of our expectations, we fall to the level of our training.", author: "Archilochus", theme: "Discipline"),
        MindsetQuote(quote: "Small disciplines repeated with consistency every day lead to great achievements gained slowly over time.", author: "John C. Maxwell", theme: "Consistency"),
        MindsetQuote(quote: "No man has the right to be an amateur in the matter of physical training. It is a shame for a man to grow old without seeing the beauty and strength of which his body is capable.", author: "Socrates", theme: "Physicality"),
        MindsetQuote(quote: "The pain of discipline is far less than the pain of regret.", author: "Jim Rohn", theme: "Focus"),
        MindsetQuote(quote: "You do not need motivation when you have built non-negotiable standards.", author: "Marcus Aurelius", theme: "Stoicism"),
        MindsetQuote(quote: "Progress isn't about being heroic every day. It's about showing up on the days you don't feel like it.", author: "Ascend Philosophy", theme: "Habit")
    ]
    
    public static var todayQuote: MindsetQuote {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
        return library[dayOfYear % library.count]
    }
}

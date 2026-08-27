import Foundation
import SwiftUI

let studyMaterialBasePath = "/Users/guy/Documents/אוניברסיטה/חדוא 2/חומר למבחן"

let examDate: Date = {
    var c = DateComponents()
    c.year = 2026; c.month = 9; c.day = 3; c.hour = 8; c.minute = 30
    return Calendar.current.date(from: c)!
}()

enum SubTaskType: String, Codable {
    case lecture, exercise, extraExercise, reminder, computerExercise

    var hebrewName: String {
        switch self {
        case .lecture: "שיעור"
        case .exercise: "תרגיל"
        case .extraExercise: "תרגיל נוסף"
        case .reminder: "תזכורת"
        case .computerExercise: "תרגול ממוחשב"
        }
    }

    var sfSymbol: String {
        switch self {
        case .lecture: "book.fill"
        case .exercise: "pencil.and.list.clipboard"
        case .extraExercise: "list.bullet.clipboard.fill"
        case .reminder: "lightbulb.fill"
        case .computerExercise: "desktopcomputer"
        }
    }

    var color: Color {
        switch self {
        case .lecture: .blue
        case .exercise: .orange
        case .extraExercise: Color(red: 1.0, green: 0.38, blue: 0.0)
        case .reminder: Color(red: 1.0, green: 0.82, blue: 0.0)
        case .computerExercise: .green
        }
    }

    var openIcon: String {
        self == .computerExercise ? "globe" : "arrow.up.forward.app.fill"
    }
}

struct SubTask: Identifiable, Codable {
    let id: String
    var displayName: String
    var type: SubTaskType
    var fileName: String?
    var urlString: String?
    var isCompleted: Bool = false

    var openURL: URL? {
        if let s = urlString { return URL(string: s) }
        if let f = fileName { return URL(fileURLWithPath: "\(studyMaterialBasePath)/\(f)") }
        return nil
    }
}

struct StudyUnit: Identifiable, Codable {
    let id: String
    var unitNumber: String
    var topic: String
    var subTasks: [SubTask]
    var isExpanded: Bool = false

    var completedCount: Int { subTasks.filter(\.isCompleted).count }
    var totalCount: Int { subTasks.count }
    var progress: Double { totalCount > 0 ? Double(completedCount) / Double(totalCount) : 0.0 }
}

struct ExamFile: Identifiable, Codable {
    let id: String
    var displayName: String
    var fileName: String
    var isCompleted: Bool = false

    var openURL: URL { URL(fileURLWithPath: "\(studyMaterialBasePath)/\(fileName)") }
}

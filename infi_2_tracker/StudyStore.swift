import Foundation
import Observation

@Observable
final class StudyStore {
    var units: [StudyUnit] = []
    var exams: [ExamFile] = []

    private let unitsKey = "studyUnits_v3"
    private let examsKey = "studyExams_v3"

    var totalSubTasks: Int { units.reduce(0) { $0 + $1.totalCount } }
    var completedSubTasks: Int { units.reduce(0) { $0 + $1.completedCount } }
    var overallProgress: Double {
        totalSubTasks > 0 ? Double(completedSubTasks) / Double(totalSubTasks) : 0.0
    }
    var completedExams: Int { exams.filter(\.isCompleted).count }

    init() { loadData() }

    func toggleSubTask(unitId: String, subTaskId: String) {
        guard let ui = units.firstIndex(where: { $0.id == unitId }),
              let ti = units[ui].subTasks.firstIndex(where: { $0.id == subTaskId }) else { return }
        units[ui].subTasks[ti].isCompleted.toggle()
        save()
    }

    func toggleExam(_ id: String) {
        guard let i = exams.firstIndex(where: { $0.id == id }) else { return }
        exams[i].isCompleted.toggle()
        save()
    }

    func toggleExpanded(_ unitId: String) {
        guard let i = units.firstIndex(where: { $0.id == unitId }) else { return }
        units[i].isExpanded.toggle()
        save()
    }

    private func save() {
        if let d = try? JSONEncoder().encode(units) { UserDefaults.standard.set(d, forKey: unitsKey) }
        if let d = try? JSONEncoder().encode(exams) { UserDefaults.standard.set(d, forKey: examsKey) }
    }

    private func loadData() {
        let defUnits = Self.makeDefaultUnits()
        let defExams = Self.makeDefaultExams()

        if let data = UserDefaults.standard.data(forKey: unitsKey),
           let saved = try? JSONDecoder().decode([StudyUnit].self, from: data) {
            units = Self.mergeUnits(saved: saved, defaults: defUnits)
        } else {
            units = defUnits
        }

        if let data = UserDefaults.standard.data(forKey: examsKey),
           let saved = try? JSONDecoder().decode([ExamFile].self, from: data) {
            exams = Self.mergeExams(saved: saved, defaults: defExams)
        } else {
            exams = defExams
        }
    }

    private static func mergeUnits(saved: [StudyUnit], defaults: [StudyUnit]) -> [StudyUnit] {
        var result = defaults
        for i in result.indices {
            guard let s = saved.first(where: { $0.id == result[i].id }) else { continue }
            result[i].isExpanded = s.isExpanded
            for j in result[i].subTasks.indices {
                if let st = s.subTasks.first(where: { $0.id == result[i].subTasks[j].id }) {
                    result[i].subTasks[j].isCompleted = st.isCompleted
                }
            }
        }
        return result
    }

    private static func mergeExams(saved: [ExamFile], defaults: [ExamFile]) -> [ExamFile] {
        var result = defaults
        for i in result.indices {
            if let s = saved.first(where: { $0.id == result[i].id }) {
                result[i].isCompleted = s.isCompleted
            }
        }
        return result
    }

    // MARK: - Default Data

    static func makeDefaultUnits() -> [StudyUnit] {
        func s(_ id: String, _ name: String, _ type: SubTaskType,
               file: String? = nil, url: String? = nil) -> SubTask {
            SubTask(id: id, displayName: name, type: type, fileName: file, urlString: url)
        }

        func makeUnit(_ num: String, _ topic: String, lecture: String, exercise: String,
                      reminder: String? = nil, extra: (String, String)? = nil,
                      computer: String) -> StudyUnit {
            var tasks: [SubTask] = [
                s("\(num)_l", "שיעור \(num)", .lecture, file: lecture),
                s("\(num)_e", "תרגיל \(num)", .exercise, file: exercise),
            ]
            if let (exName, exFile) = extra {
                tasks.append(s("\(num)_e2", exName, .extraExercise, file: exFile))
            }
            if let rem = reminder {
                tasks.append(s("\(num)_r", "תזכורת \(num)", .reminder, file: rem))
            }
            tasks.append(s("\(num)_c", "תרגול ממוחשב \(num)", .computerExercise, url: computer))
            return StudyUnit(id: num, unitNumber: num, topic: topic, subTasks: tasks)
        }

        return [
            makeUnit("1", "אינטגרל מסוים",
                lecture: "שיעור 1 - אינטגרל מסוים_260712_132722.pdf",
                exercise: "תרגיל 1 - אינטגרל מסוים.pdf",
                computer: "https://iakaria.my.canva.site/cdhpk970tr5j5c1s"),
            makeUnit("2", "אינטגרל מסוים (המשך)",
                lecture: "שיעור 2 - אינטגרל מסוים_260714_114301.pdf",
                exercise: "תרגיל 2 - אינטגרל מסוים.pdf",
                computer: "https://iakaria.my.canva.site/cdssr7kwbxv5k58e"),
            makeUnit("3", "אינטגרל לא מסוים",
                lecture: "שיעור 3 - אינטגרל לא מסוים_260719_133653.pdf",
                exercise: "תרגיל 3 - אינטגרל לא מסוים.pdf",
                reminder: "תזכורת 3.pdf",
                computer: "https://iakaria.my.canva.site/math-quiz-indefinite-integrals"),
            makeUnit("4", "אינטגרלים רציונליים",
                lecture: "שיעור 4 - אינטגרל לא מסוים_260721_120133.pdf",
                exercise: "תרגיל 4  - אינטגרלים של פונקציות רציונליות ויישומי האינטגרל המסוים.pdf",
                reminder: "תזכורת 4.pdf",
                computer: "https://iakaria.my.canva.site/cebqsq9fre6z9626"),
            makeUnit("5", "אינטגרל מוכלל",
                lecture: "שיעור 5 - אינטגרל מוכלל_260726_134628.pdf",
                exercise: "תרגיל 5  - אינטגרל מוכלל.pdf",
                reminder: "תזכורת 5.pdf",
                computer: "https://iakaria.my.canva.site/cergd6nkks6g5yhy"),
            makeUnit("6", "טורים",
                lecture: "שיעור 6 - טורים_260728_114626.pdf",
                exercise: "תרגיל 6  - טורים.pdf",
                reminder: "תזכורת 6.pdf",
                computer: "https://iakaria.my.canva.site/cey2fm7rq9w5qt59"),
            makeUnit("7", "טורים (המשך)",
                lecture: "שיעור 7 - טורים_260802_132812.pdf",
                exercise: "תרגיל 7  - טורים.pdf",
                computer: "https://iakaria.my.canva.site/cfaq9wx92r6zvns0"),
            makeUnit("8", "פונקציות כמה משתנים",
                lecture: "שיעור 8 - פונקציות של כמה משתנים_260804_114514.pdf",
                exercise: "תרגיל 8 - פונקציות של כמה משתנים.pdf",
                reminder: "תזכורת 8.pdf",
                computer: "https://iakaria.my.canva.site/cfjrcyzzazxdf21q"),
            makeUnit("9", "גבולות ורציפות",
                lecture: "שיעור 9 - גבולות, רציפות ודיפרנציאביליות_260811_114831.pdf",
                exercise: "תרגיל 9 - גבולות ורציפות.pdf",
                computer: "https://iakaria.my.canva.site/cg70fbv5ca1ks41h"),
            makeUnit("10", "דיפרנציאביליות",
                lecture: "שיעור 10 - דיפרנציאביליות_260816_134557.pdf",
                exercise: "תרגיל 10 - דיפרנציאביליות.pdf",
                computer: "https://iakaria.my.canva.site/cgeycgjp4qggc151"),
            makeUnit("11", "דיפרנציאביליות מתקדמת",
                lecture: "שיעור 11 - דיפרנציאביליות מתקדמת_260818_114858.pdf",
                exercise: "תרגיל 11 - דיפרנציאביליות מתקדמת.pdf",
                computer: "https://iakaria.my.canva.site/cghevdf2z4fnxggs"),
            makeUnit("12", "דיפרנציאל גבוה ואקסטרמום",
                lecture: "שיעור 12 - דיפרנציאל מסדר גבוה ונקודות אקסטרמום_260823_134250.pdf",
                exercise: "תרגיל 12 - דיפרנציאל גבוה ונקודות אקסטרמום.pdf",
                extra: ("תרגיל 12.5", "תרגיל 12.5 - דיפרנציאל גבוה ונקודות אקסטרמום.pdf"),
                computer: "https://iakaria.my.canva.site/cgy83n0x8va5wwj2"),
            makeUnit("13", "לגרנז ואינטגרל כפול",
                lecture: "שיעור 13 - כופלי לגרנז ואינטגרל כפול_260825_115341.pdf",
                exercise: "תרגיל 13 - כופלי לגרנז ואינטגרל כפול.pdf",
                extra: ("תרגיל 13.5", "תרגיל 13.5 - כופלי לגרנז ואינטגרל כפול.pdf"),
                computer: "https://iakaria.my.canva.site/dahtvcm-clk"),
        ]
    }

    static func makeDefaultExams() -> [ExamFile] {
        [
            ExamFile(id: "mid1",      displayName: "מבחן אמצע 1",     fileName: "מבחן אמצע 1.pdf"),
            ExamFile(id: "mid2",      displayName: "מבחן אמצע 2",     fileName: "מבחן אמצע 2.pdf"),
            ExamFile(id: "tashpd_a",  displayName: "תשפ״ד מועד א׳",   fileName: "מבחן תשפ״ד א׳.pdf"),
            ExamFile(id: "tashpd_b",  displayName: "תשפ״ד מועד ב׳",   fileName: "מבחן תשפ״ד ב׳.pdf"),
            ExamFile(id: "tashpd_c",  displayName: "תשפ״ד מועד ג׳",   fileName: "מבחן תשפ״ד ג׳.pdf"),
            ExamFile(id: "tashph_a",  displayName: "תשפ״ה מועד א׳",   fileName: "מבחן תשפ״ה א׳.pdf"),
            ExamFile(id: "tashph_b",  displayName: "תשפ״ה מועד ב׳",   fileName: "מבחן תשפ״ה ב׳.pdf"),
            ExamFile(id: "tashph_c",  displayName: "תשפ״ה מועד ג׳",   fileName: "מבחן תשפ״ה ג׳.pdf"),
            ExamFile(id: "tashpv_a",  displayName: "תשפ״ו מועד א׳",   fileName: "מבחן תשפ״ו א׳.pdf"),
            ExamFile(id: "tashpv_b",  displayName: "תשפ״ו מועד ב׳",   fileName: "מבחן תשפ״ו ב׳.pdf"),
            ExamFile(id: "tashpv_c",  displayName: "תשפ״ו מועד ג׳",   fileName: "מבחן תשפ״ו ג׳.pdf"),
        ]
    }
}

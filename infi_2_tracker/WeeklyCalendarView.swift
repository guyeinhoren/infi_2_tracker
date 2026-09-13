import SwiftUI

struct WeeklyCalendarView: View {
    var store: StudyStore
    @Environment(\.colorScheme) private var colorScheme
    
    private let daysOfWeek = ["ב׳", "ג׳", "ד׳", "ה׳", "ו׳", "ש׳", "א׳"]
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader("תכנון שבועי")
                .padding(.horizontal)
            
            VStack(spacing: 0) {
                // Days of week header
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(0..<7, id: \.self) { index in
                        Text(daysOfWeek[6 - index]) // Reverse for RTL
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                
                Divider()
                    .padding(.horizontal, 16)
                
                // Calendar grid with 2 weeks
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(Array(store.dayPlans.prefix(14).enumerated()), id: \.element.id) { index, plan in
                        DayCell(
                            store: store,
                            plan: plan,
                            isToday: Calendar.current.isDateInToday(plan.date)
                        )
                    }
                }
                .padding(16)
            }
            .background(
                colorScheme == .dark
                    ? AnyShapeStyle(.regularMaterial)
                    : AnyShapeStyle(Color.white),
                in: RoundedRectangle(cornerRadius: 24)
            )
            .shadow(
                color: colorScheme == .dark ? .clear : Color.black.opacity(0.04),
                radius: 8,
                x: 0,
                y: 4
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(
                        colorScheme == .dark ? Color.white.opacity(0.15) : Color.black.opacity(0.06),
                        lineWidth: 1
                    )
            )
            .padding(.horizontal)
        }
    }
}

struct DayCell: View {
    var store: StudyStore
    var plan: DayPlan
    var isToday: Bool
    @Environment(\.colorScheme) private var colorScheme
    @State private var isTargeted = false
    
    private var dayNumber: String {
        let calendar = Calendar.current
        let day = calendar.component(.day, from: plan.date)
        return "\(day)"
    }
    
    private var tasks: [CalendarTask] {
        store.tasksForDay(plan.id)
    }
    
    var body: some View {
        VStack(spacing: 6) {
            // Day number
            Text(dayNumber)
                .font(.system(size: 18, weight: isToday ? .bold : .semibold, design: .rounded))
                .foregroundStyle(isToday ? Color.blue : .primary)
                .frame(height: 24)
            
            // Tasks
            VStack(spacing: 4) {
                ForEach(tasks) { task in
                    TaskChip(task: task)
                        .draggable(task)
                        .onTapGesture {
                            store.removeTask(task.subTaskId, from: plan.id)
                        }
                }
            }
            
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, minHeight: 120)
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isToday ? Color.blue.opacity(0.08) : Color.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    isTargeted ? Color.blue.opacity(0.6) :
                    isToday ? Color.blue.opacity(0.3) :
                    colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.06),
                    lineWidth: isTargeted ? 2 : 1
                )
        )
        .dropDestination(for: CalendarTask.self) { droppedTasks, _ in
            for task in droppedTasks {
                // Remove from all other days first
                for otherPlan in store.dayPlans {
                    store.removeTask(task.subTaskId, from: otherPlan.id)
                }
                // Add to this day
                store.assignTask(task.subTaskId, to: plan.id)
            }
            return true
        } isTargeted: { targeted in
            withAnimation(.spring(response: 0.3)) {
                isTargeted = targeted
            }
        }
    }
}

struct TaskChip: View {
    var task: CalendarTask
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: task.type.sfSymbol)
                .font(.system(size: 8))
            Text("תר׳ \(task.unitNumber)")
                .font(.system(size: 10, weight: .semibold))
                .lineLimit(1)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(task.type.color)
        )
        .shadow(color: task.type.color.opacity(0.3), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Floating Countdown Badge

struct FloatingCountdownBadge: View {
    let targetDate: Date
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        TimelineView(.periodic(from: .now, by: 3600)) { ctx in
            let remaining = max(0, targetDate.timeIntervalSince(ctx.date))
            let days = Int(remaining) / 86400
            let hours = (Int(remaining) % 86400) / 3600
            
            VStack(spacing: 2) {
                Text("\(days)")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .contentTransition(.numericText(countsDown: true))
                
                Text("ימים")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.9))
                
                if hours > 0 {
                    Text("\(hours)ש׳")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
            .frame(width: 72, height: 72)
            .background(
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.red, Color.orange],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 2)
                        .padding(4)
                }
            )
            .shadow(color: Color.red.opacity(0.4), radius: 12, x: 0, y: 4)
        }
    }
}

#Preview {
    WeeklyCalendarView(store: StudyStore())
        .preferredColorScheme(.light)
}

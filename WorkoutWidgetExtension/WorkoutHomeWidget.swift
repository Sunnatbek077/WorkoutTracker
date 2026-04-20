//
//  WorkoutHomeWidget.swift
//  WorkoutWidgetExtension
//
//  Home Screen widget: Small, Medium va Large o'lchamlar.
//  Ma'lumot App Groups UserDefaults orqali keladi.
//
//  SETUP: Xcode → Targets → WorkoutWidgetExtension →
//  Signing & Capabilities → + Capability → App Groups →
//  group.com.sunnatbek.WorkoutTracker ni qo'shing.
//

import WidgetKit
import SwiftUI

// MARK: - App Group constants (main app dagi bilan mos bo'lishi kerak)
private let kAppGroupID    = "group.com.sunnatbek.WorkoutTracker"
private let kWidgetDataKey = "workout_widget_data"

// MARK: - Shared Data Model (widget extension copy)
// NOTE: WorkoutSharedData.swift dagi struct bilan bir xil bo'lishi kerak
private struct WorkoutWidgetData: Codable {
    var lastWorkoutType: String     = ""
    var lastWorkoutDate: Date       = .distantPast
    var lastCalories: Double        = 0
    var lastDurationSeconds: Int    = 0
    var lastDistanceKM: Double      = 0
    var lastSteps: Int              = 0
    var lastHeartRate: Int          = 0
    var todayCalories: Double       = 0
    var todaySteps: Int             = 0
    var todayActiveMinutes: Int     = 0
    var weeklyWorkoutCount: Int     = 0
    var dailyCalorieGoal: Int       = 500
    var dailyGoalType: String       = "calories"

    // MARK: - Computed
    var hasData: Bool { !lastWorkoutType.isEmpty }

    var calorieProgress: Double {
        guard dailyCalorieGoal > 0 else { return 0 }
        return min(todayCalories / Double(dailyCalorieGoal), 1.0)
    }

    var workoutIcon: String {
        switch lastWorkoutType {
        case "Running": return "figure.run"
        case "Cycling": return "figure.outdoor.cycle"
        case "Walking": return "figure.walk"
        default:        return "figure.highintensity.intervaltraining"
        }
    }

    var accentColor: Color {
        switch lastWorkoutType {
        case "Running": return .orange
        case "Cycling": return .blue
        case "Walking": return .green
        default:        return Color(red: 1, green: 0.25, blue: 0.3)
        }
    }

    var formattedDuration: String {
        let m = lastDurationSeconds / 60
        let s = lastDurationSeconds % 60
        return String(format: "%02d:%02d", m, s)
    }

    var relativeDate: String {
        guard lastWorkoutDate != .distantPast else { return "Hali yo'q" }
        let f = RelativeDateTimeFormatter()
        f.unitsStyle = .abbreviated
        return f.localizedString(for: lastWorkoutDate, relativeTo: Date())
    }

    // MARK: - Preview data
    static var preview: WorkoutWidgetData {
        WorkoutWidgetData(
            lastWorkoutType: "Running",
            lastWorkoutDate: Date().addingTimeInterval(-3600),
            lastCalories: 287,
            lastDurationSeconds: 1847,
            lastDistanceKM: 4.2,
            lastSteps: 5200,
            lastHeartRate: 148,
            todayCalories: 287,
            todaySteps: 5200,
            todayActiveMinutes: 31,
            weeklyWorkoutCount: 3,
            dailyCalorieGoal: 500
        )
    }
}

// MARK: - Data Store (read-only, widget side)
private struct WorkoutDataStore {
    static func load() -> WorkoutWidgetData {
        guard let defaults = UserDefaults(suiteName: kAppGroupID),
              let raw      = defaults.data(forKey: kWidgetDataKey),
              let decoded  = try? JSONDecoder().decode(WorkoutWidgetData.self, from: raw)
        else { return WorkoutWidgetData() }
        return decoded
    }
}

// MARK: - Timeline Entry
struct WorkoutWidgetEntry: TimelineEntry {
    let date: Date
    fileprivate let data: WorkoutWidgetData
}

// MARK: - Timeline Provider
struct WorkoutWidgetProvider: TimelineProvider {

    func placeholder(in context: Context) -> WorkoutWidgetEntry {
        WorkoutWidgetEntry(date: .now, data: .preview)
    }

    func getSnapshot(in context: Context, completion: @escaping (WorkoutWidgetEntry) -> Void) {
        let data = context.isPreview ? .preview : WorkoutDataStore.load()
        completion(WorkoutWidgetEntry(date: .now, data: data))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WorkoutWidgetEntry>) -> Void) {
        let data  = WorkoutDataStore.load()
        let entry = WorkoutWidgetEntry(date: .now, data: data)
        let next  = Calendar.current.date(byAdding: .minute, value: 15, to: .now) ?? .now
        completion(Timeline(entries: [entry], policy: .after(next)))
    }
}

// MARK: - Widget Configuration
struct WorkoutHomeWidget: Widget {
    let kind = "WorkoutHomeWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WorkoutWidgetProvider()) { entry in
            WorkoutWidgetEntryView(entry: entry)
                .containerBackground(.black, for: .widget)
        }
        .configurationDisplayName("Workout Tracker")
        .description("Bugungi mashq ko'rsatkichlaringizni kuzating.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - Entry View (router)
struct WorkoutWidgetEntryView: View {
    @Environment(\.widgetFamily) private var family
    let entry: WorkoutWidgetEntry

    var body: some View {
        switch family {
        case .systemSmall:  SmallWorkoutWidgetView(data: entry.data)
        case .systemMedium: MediumWorkoutWidgetView(data: entry.data)
        case .systemLarge:  LargeWorkoutWidgetView(data: entry.data)
        default:            SmallWorkoutWidgetView(data: entry.data)
        }
    }
}

// MARK: - Small Widget
private struct SmallWorkoutWidgetView: View {
    let data: WorkoutWidgetData

    var body: some View {
        ZStack {
            darkBackground

            VStack(spacing: 6) {
                // Yuqori qator: icon + tur nomi
                HStack(spacing: 4) {
                    Image(systemName: data.hasData ? data.workoutIcon : "figure.run")
                        .font(.caption2)
                        .foregroundStyle(data.hasData ? data.accentColor : .gray)
                    Text(data.hasData ? data.lastWorkoutType : "Mashq")
                        .font(.system(.caption2, design: .rounded, weight: .semibold))
                        .foregroundStyle(.white.opacity(data.hasData ? 0.75 : 0.4))
                        .lineLimit(1)
                    Spacer()
                }

                Spacer()

                // Progress ring — kaloriya
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.08), lineWidth: 10)

                    if data.calorieProgress > 0 {
                        Circle()
                            .trim(from: 0, to: data.calorieProgress)
                            .stroke(data.accentColor,
                                    style: StrokeStyle(lineWidth: 10, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                    }

                    VStack(spacing: 1) {
                        Text(String(format: "%.0f", data.todayCalories))
                            .font(.system(.title3, design: .rounded, weight: .bold))
                            .foregroundStyle(data.hasData ? .white : .white.opacity(0.3))
                        Text("kcal")
                            .font(.system(size: 9))
                            .foregroundStyle(.white.opacity(0.45))
                    }
                }
                .frame(width: 86, height: 86)

                Spacer()

                // Pastki qator: foiz
                HStack(spacing: 3) {
                    Text("\(Int(data.calorieProgress * 100))%")
                        .font(.system(.caption2, design: .rounded, weight: .semibold))
                        .foregroundStyle(data.hasData ? data.accentColor : .gray)
                    Text("maqsad")
                        .font(.system(size: 9))
                        .foregroundStyle(.white.opacity(0.4))
                    Spacer()
                }
            }
            .padding(12)
        }
    }
}

// MARK: - Medium Widget
private struct MediumWorkoutWidgetView: View {
    let data: WorkoutWidgetData

    var body: some View {
        ZStack {
            darkBackground

            VStack(spacing: 10) {
                // Header: mashq turi + haftalik
                HStack {
                    HStack(spacing: 7) {
                        Image(systemName: data.hasData ? data.workoutIcon : "figure.run")
                            .font(.subheadline)
                            .foregroundStyle(data.hasData ? data.accentColor : .gray)

                        VStack(alignment: .leading, spacing: 1) {
                            Text(data.hasData ? data.lastWorkoutType : "Mashq yo'q")
                                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                                .foregroundStyle(.white)
                            Text(data.relativeDate)
                                .font(.caption2)
                                .foregroundStyle(.white.opacity(0.45))
                        }
                    }

                    Spacer()

                    // Haftalik badge
                    HStack(spacing: 3) {
                        Image(systemName: "flame.fill")
                            .font(.caption2)
                            .foregroundStyle(.orange)
                        Text("\(data.weeklyWorkoutCount) hafta")
                            .font(.system(.caption2, design: .rounded))
                            .foregroundStyle(.white.opacity(0.7))
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.08))
                    .clipShape(Capsule())
                }

                // 4 ta metrika
                HStack(spacing: 0) {
                    WidgetStatCell(icon: "flame.fill",
                                  value: String(format: "%.0f", data.lastCalories),
                                  unit: "kcal", color: .orange)
                    widgetDivider
                    WidgetStatCell(icon: "timer",
                                  value: data.formattedDuration,
                                  unit: "vaqt", color: .white)
                    widgetDivider
                    WidgetStatCell(icon: "figure.walk",
                                  value: compactSteps(data.lastSteps),
                                  unit: "qadam", color: .green)
                    widgetDivider
                    WidgetStatCell(icon: "heart.fill",
                                  value: "\(data.lastHeartRate)",
                                  unit: "bpm", color: .red)
                }

                // Kunlik progress bar
                VStack(spacing: 4) {
                    HStack {
                        Text("Kunlik maqsad")
                            .font(.system(size: 9))
                            .foregroundStyle(.white.opacity(0.4))
                        Spacer()
                        Text("\(Int(data.todayCalories)) / \(data.dailyCalorieGoal) kcal")
                            .font(.system(size: 9))
                            .foregroundStyle(.white.opacity(0.4))
                    }
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color.white.opacity(0.08))
                                .frame(height: 5)
                            RoundedRectangle(cornerRadius: 3)
                                .fill(data.hasData ? data.accentColor : Color.gray.opacity(0.4))
                                .frame(width: geo.size.width * data.calorieProgress, height: 5)
                        }
                    }
                    .frame(height: 5)
                }
            }
            .padding(14)
        }
    }

    private var widgetDivider: some View {
        Rectangle()
            .fill(Color.white.opacity(0.1))
            .frame(width: 1, height: 30)
    }
}

// MARK: - Large Widget
private struct LargeWorkoutWidgetView: View {
    let data: WorkoutWidgetData

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(white: 0.07), Color(white: 0.12)],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(spacing: 0) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Bugungi Faollik")
                            .font(.system(.headline, design: .rounded, weight: .bold))
                            .foregroundStyle(.white)
                        Text(data.relativeDate)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.45))
                    }
                    Spacer()
                    VStack(spacing: 2) {
                        Text("\(data.weeklyWorkoutCount)")
                            .font(.system(.title3, design: .rounded, weight: .bold))
                            .foregroundStyle(.orange)
                        Text("hafta")
                            .font(.system(size: 9))
                            .foregroundStyle(.white.opacity(0.45))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(Color.white.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding(.bottom, 14)

                // Katta progress ring
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.07), lineWidth: 18)

                    if data.calorieProgress > 0 {
                        Circle()
                            .trim(from: 0, to: data.calorieProgress)
                            .stroke(
                                LinearGradient(
                                    colors: [data.accentColor, data.accentColor.opacity(0.5)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                style: StrokeStyle(lineWidth: 18, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                    }

                    VStack(spacing: 4) {
                        Image(systemName: data.hasData ? data.workoutIcon : "figure.run")
                            .font(.title2)
                            .foregroundStyle(data.hasData ? data.accentColor : .gray)
                        Text(String(format: "%.0f", data.todayCalories))
                            .font(.system(.title, design: .rounded, weight: .bold))
                            .foregroundStyle(data.hasData ? .white : .white.opacity(0.3))
                        Text("/ \(data.dailyCalorieGoal) kcal")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.4))
                    }
                }
                .frame(width: 145, height: 145)
                .padding(.bottom, 14)

                // Ajratgich
                Rectangle()
                    .fill(Color.white.opacity(0.08))
                    .frame(height: 1)
                    .padding(.bottom, 12)

                // 2×2 statistika
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    LargeWidgetStatCard(icon: "timer",       label: "Davomiyligi",   value: data.formattedDuration,                            color: .white)
                    LargeWidgetStatCard(icon: "figure.walk", label: "Qadam",         value: fullSteps(data.lastSteps),                         color: .green)
                    LargeWidgetStatCard(icon: "location.fill", label: "Masofa",      value: String(format: "%.1f km", data.lastDistanceKM),    color: .blue)
                    LargeWidgetStatCard(icon: "heart.fill",  label: "Yurak urishi",  value: "\(data.lastHeartRate) bpm",                       color: .red)
                }
                .padding(.bottom, 12)

                // Motivatsion xabar
                Text(motivationalMessage)
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(.white.opacity(0.4))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .padding(16)
        }
    }

    private var motivationalMessage: String {
        guard data.hasData else { return "Mashqni boshlang va natijalaringizni kuzating!" }
        let pct = Int(data.calorieProgress * 100)
        if pct >= 100 { return "Ajoyib! Bugungi maqsadga erishdingiz!" }
        if pct >= 75  { return "Zo'r! Ozgina qoldi, davom eting!" }
        if pct >= 50  { return "Yaxshi! Maqsadning \(pct)% ini bajardingiz." }
        return "Davom eting! Maqsadga yaqinlashyapsiz."
    }

    private func fullSteps(_ n: Int) -> String {
        let f = NumberFormatter(); f.numberStyle = .decimal
        return f.string(from: NSNumber(value: n)) ?? "\(n)"
    }
}

// MARK: - Shared UI Components

private struct WidgetStatCell: View {
    let icon: String
    let value: String
    let unit: String
    let color: Color

    var body: some View {
        VStack(spacing: 3) {
            Image(systemName: icon)
                .font(.caption2)
                .foregroundStyle(color)
            Text(value)
                .font(.system(.caption, design: .rounded, weight: .bold))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(unit)
                .font(.system(size: 9))
                .foregroundStyle(.white.opacity(0.45))
        }
        .frame(maxWidth: .infinity)
    }
}

private struct LargeWidgetStatCard: View {
    let icon: String
    let label: String
    let value: String
    let color: Color

    var body: some View {
        HStack(spacing: 9) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundStyle(color)
                .frame(width: 22)
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Text(label)
                    .font(.system(size: 10))
                    .foregroundStyle(.white.opacity(0.45))
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

// MARK: - Helpers
private var darkBackground: some View {
    LinearGradient(
        colors: [Color(white: 0.08), Color(white: 0.13)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

private func compactSteps(_ n: Int) -> String {
    n >= 1000 ? String(format: "%.1fk", Double(n) / 1000.0) : "\(n)"
}

// MARK: - Preview
#Preview(as: .systemSmall) {
    WorkoutHomeWidget()
} timeline: {
    WorkoutWidgetEntry(date: .now, data: .preview)
}

#Preview(as: .systemMedium) {
    WorkoutHomeWidget()
} timeline: {
    WorkoutWidgetEntry(date: .now, data: .preview)
}

#Preview(as: .systemLarge) {
    WorkoutHomeWidget()
} timeline: {
    WorkoutWidgetEntry(date: .now, data: .preview)
}

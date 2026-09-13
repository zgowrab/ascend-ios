import SwiftUI
import SwiftData

public struct MainTabView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @State private var appState = AppState()
    
    private var profile: UserProfile {
        if let existing = profiles.first {
            return existing
        } else {
            let newProfile = UserProfile()
            modelContext.insert(newProfile)
            try? modelContext.save()
            return newProfile
        }
    }
    
    public init() {}
    
    public var body: some View {
        Group {
            if !profile.isOnboarded {
                OnboardingFlowView(profile: profile)
            } else {
                TabView(selection: $appState.selectedTab) {
                    DashboardView()
                        .tabItem {
                            Label("Dashboard", systemImage: "house.fill")
                        }
                        .tag(0)
                    
                    WorkoutListView()
                        .tabItem {
                            Label("Workouts", systemImage: "dumbbell.fill")
                        }
                        .tag(1)
                    
                    DietAndPortionView()
                        .tabItem {
                            Label("Nutrition", systemImage: "leaf.fill")
                        }
                        .tag(2)
                    
                    SupplementHubView()
                        .tabItem {
                            Label("Supplements", systemImage: "pills.fill")
                        }
                        .tag(3)
                    
                    AnalyticsView()
                        .tabItem {
                            Label("Analytics", systemImage: "chart.bar.xaxis")
                        }
                        .tag(4)
                }
                .tint(AscendTheme.emerald)
                .fullScreenCover(isPresented: $appState.isWorkoutInProgress) {
                    ActiveWorkoutPlayerView()
                }
            }
        }
        .environment(appState)
        .preferredColorScheme(.dark)
    }
}

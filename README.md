# Ascend — Personal Workout, Nutrition & Betterment Guide

Ascend is a native iOS application engineered for physical transformation, nutrition precision, and daily discipline. Built targeting iOS 26+ and Swift 6.3 following modern Apple architecture patterns.

## Features

- **Personalized Onboarding & Directive**: Intake for biometrics, goals (Hypertrophy, Strength, Cut, Recomp), equipment access, and diet staples with automatic Mifflin-St Jeor TDEE and macro calculation.
- **Dynamic Routine Generation**: Algorithmic training splits matching your equipment (Commercial Gym, Home Gym, Dumbbells only, Calisthenics, Bands) and schedule (3-6 days/week).
- **Interactive Workout Guide**: Step-by-step exercise guides with form cues, execution tips, common mistakes, and an automated rest countdown timer with tactile haptics.
- **Hand-Based Portion Visualizer**: Practical no-scale visual guides (Palm, Fist, Cupped Hand, Thumb) and staple food suggestions index.
- **Targeted Supplement Protocol**: Tiered science-backed stacks (Creatine, Whey, Vitamin D3+K2, Electrolytes, Omega-3, Magnesium) with time-of-day schedules.
- **The Daily 5 Non-Negotiables**: Accountability checklist tracking workouts, protein, supplements, hydration, and sleep with daily discipline scoring.
- **Swift Charts Analytics**: Progressive overload volume tracking, weekly discipline score heatmaps, and milestone badges.

## Technology Stack

- **Platform**: iOS 26+
- **Language**: Swift 6.3
- **UI Framework**: SwiftUI with Liquid Glass (`.ultraThinMaterial`) and SF Symbols
- **State Management**: Observation framework (`@Observable`, `@State`, `@Environment`)
- **Persistence**: SwiftData (`@Model`, `ModelContainer`)
- **Data Visualization**: Swift Charts (`Chart`, `BarMark`, `LineMark`, `RuleMark`)

## Running in Xcode

1. Open `Ascend.xcodeproj` in Xcode:
   ```bash
   open Ascend.xcodeproj
   ```
2. Select an iPhone Simulator (e.g. iPhone 16 Pro) or your connected physical iPhone.
3. Press `Cmd + R` to build and run.

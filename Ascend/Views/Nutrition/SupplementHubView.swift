import SwiftUI
import SwiftData

public struct SupplementHubView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var supplements: [SupplementItem]
    
    @State private var showingAddSheet = false
    @State private var newName = ""
    @State private var newDosage = ""
    @State private var newTiming: SupplementTiming = .morning
    @State private var newPurpose = ""
    @State private var newWhy = ""
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            GeometryReader { geo in
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Header Guidance Card
                        GlassCard(cornerRadius: 20, padding: 18) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("SCIENCE-BACKED PROTOCOL")
                                    .font(.caption2.bold())
                                    .foregroundStyle(AscendTheme.amber)
                                    .tracking(1)
                                
                                Text("Supplement Optimization")
                                    .font(.title3.bold())
                                    .foregroundStyle(AscendTheme.textPrimary)
                                
                                Text("Supplements yield the final 5-10% edge when whole nutrition and heavy resistance training are locked in. Timing maximizes bioavailability.")
                                    .font(.caption)
                                    .foregroundStyle(AscendTheme.textSecondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        // Daily Timing Checklist
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Daily Timing Schedule", systemImage: "clock.fill")
                                .font(.headline)
                                .foregroundStyle(AscendTheme.emerald)
                            
                            ForEach(SupplementTiming.allCases) { timing in
                                let items = supplements.filter { $0.timing == timing }
                                if !items.isEmpty {
                                    timingSection(timing: timing, items: items)
                                }
                            }
                        }
                        
                        // In-depth Rationale / Science Section
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Biochemical Rationale", systemImage: "atom")
                                .font(.headline)
                                .foregroundStyle(AscendTheme.cyan)
                            
                            ForEach(supplements) { supp in
                                GlassCard(cornerRadius: 16, padding: 14) {
                                    VStack(alignment: .leading, spacing: 6) {
                                        HStack {
                                            Text(supp.name)
                                                .font(.subheadline.bold())
                                                .foregroundStyle(AscendTheme.textPrimary)
                                                .lineLimit(1)
                                            
                                            Spacer()
                                            
                                            Text(supp.dosage)
                                                .font(.caption2.bold())
                                                .foregroundStyle(AscendTheme.emerald)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 3)
                                                .background(AscendTheme.emerald.opacity(0.15))
                                                .clipShape(Capsule())
                                                .lineLimit(1)
                                        }
                                        
                                        Text("Purpose: \(supp.purpose)")
                                            .font(.caption.bold())
                                            .foregroundStyle(AscendTheme.cyan)
                                            .lineLimit(2)
                                        
                                        Text(supp.whyItMatters)
                                            .font(.caption)
                                            .foregroundStyle(AscendTheme.textSecondary)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .frame(width: geo.size.width)
                }
                .scrollBounceBehavior(.basedOnSize, axes: .horizontal)
            }
            .ascendBackground()
            .navigationTitle("Supplements")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.headline)
                            .foregroundStyle(AscendTheme.emerald)
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                addSupplementSheet
            }
        }
    }
    
    private func timingSection(timing: SupplementTiming, items: [SupplementItem]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: timing.icon)
                    .foregroundStyle(AscendTheme.amber)
                    .font(.caption)
                Text(timing.rawValue)
                    .font(.caption.bold())
                    .foregroundStyle(AscendTheme.textSecondary)
                    .textCase(.uppercase)
            }
            
            VStack(spacing: 8) {
                ForEach(items) { supp in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(supp.name)
                                .font(.subheadline.bold())
                                .foregroundStyle(AscendTheme.textPrimary)
                                .lineLimit(1)
                            Text("\(supp.dosage) • \(supp.purpose)")
                                .font(.caption2)
                                .foregroundStyle(AscendTheme.textSecondary)
                                .lineLimit(2)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Spacer()
                        
                        Button {
                            supp.isTakenToday.toggle()
                            supp.lastTakenDate = Date()
                            try? modelContext.save()
                        } label: {
                            Image(systemName: supp.isTakenToday ? "checkmark.circle.fill" : "circle")
                                .font(.title3)
                                .foregroundStyle(supp.isTakenToday ? AscendTheme.emerald : AscendTheme.textMuted)
                        }
                    }
                    .padding(12)
                    .background(AscendTheme.bgSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }
    
    private var addSupplementSheet: some View {
        NavigationStack {
            VStack(spacing: 16) {
                TextField("Supplement Name (e.g. Zinc)", text: $newName)
                    .padding()
                    .background(AscendTheme.bgElevated)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .foregroundStyle(AscendTheme.textPrimary)
                
                TextField("Dosage (e.g. 15mg)", text: $newDosage)
                    .padding()
                    .background(AscendTheme.bgElevated)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .foregroundStyle(AscendTheme.textPrimary)
                
                Picker("Timing", selection: $newTiming) {
                    ForEach(SupplementTiming.allCases) { t in
                        Text(t.rawValue).tag(t)
                    }
                }
                .pickerStyle(.menu)
                .padding()
                .background(AscendTheme.bgElevated)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                TextField("Primary Purpose (e.g. Immune Recovery)", text: $newPurpose)
                    .padding()
                    .background(AscendTheme.bgElevated)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .foregroundStyle(AscendTheme.textPrimary)
                
                TextField("Why it matters", text: $newWhy)
                    .padding()
                    .background(AscendTheme.bgElevated)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .foregroundStyle(AscendTheme.textPrimary)
                
                Spacer()
                
                Button {
                    guard !newName.isEmpty else { return }
                    let item = SupplementItem(
                        name: newName,
                        dosage: newDosage,
                        timing: newTiming,
                        purpose: newPurpose,
                        whyItMatters: newWhy,
                        isEssential: false
                    )
                    modelContext.insert(item)
                    try? modelContext.save()
                    showingAddSheet = false
                    newName = ""
                    newDosage = ""
                } label: {
                    Text("Add to Protocol")
                        .font(.headline.bold())
                        .foregroundStyle(AscendTheme.bgPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(AscendTheme.primaryGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
            .padding(24)
            .ascendBackground()
            .navigationTitle("Add Supplement")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        showingAddSheet = false
                    }
                    .foregroundStyle(AscendTheme.textSecondary)
                }
            }
        }
    }
}

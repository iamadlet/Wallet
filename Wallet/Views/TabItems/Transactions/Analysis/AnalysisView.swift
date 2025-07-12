import SwiftUI

struct AnalysisView: View {
    let direction: Direction
    @State private var showStartPicker = false
    @State private var showEndPicker = false
    @State private var startDate: Date = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
    @State private var endDate: Date = Date()
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Color(.systemGroupedBackground)
//                    .frame(height: 120)
                    .edgesIgnoringSafeArea(.top)
                AnalysisViewControllerRepresentable(
                    isIncome: direction == .income,
                    showStartPicker: $showStartPicker,
                    showEndPicker: $showEndPicker,
                    startDate: $startDate,
                    endDate: $endDate
                )
                .navigationTitle("Анализ")
                .navigationBarTitleDisplayMode(.automatic)
                .onAppear {
                    let appearance = UINavigationBarAppearance()
                    appearance.configureWithOpaqueBackground()
                    appearance.backgroundColor = UIColor.systemGroupedBackground
                    appearance.shadowColor = .clear
                    appearance.shadowImage = UIImage()
                    UINavigationBar.appearance().standardAppearance = appearance
                    UINavigationBar.appearance().scrollEdgeAppearance = appearance
                }
            }
        }
        .sheet(isPresented: $showStartPicker) {
            VStack {
                DatePicker(
                    "Начало",
                    selection: Binding(
                        get: { startDate },
                        set: { newValue in
                            startDate = newValue
                            if startDate > endDate {
                                endDate = startDate
                            }
                        }
                    ),
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .accentColor(.green)
                .padding()
                Button("Готово") { showStartPicker = false }
                    .padding(.bottom)
            }
            .presentationDetents([.medium])
        }
        .sheet(isPresented: $showEndPicker) {
            VStack {
                DatePicker(
                    "Конец",
                    selection: Binding(
                        get: { endDate },
                        set: { newValue in
                            endDate = newValue
                            if endDate < startDate {
                                startDate = endDate
                            }
                        }
                    ),
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .accentColor(.green)
                .padding()
                Button("Готово") { showEndPicker = false }
                    .padding(.bottom)
            }
            .presentationDetents([.medium])
        }
    }
}

#Preview {
    AnalysisView(direction: .outcome)
}

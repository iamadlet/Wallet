import SwiftUI
import Charts

struct BankAccountView: View {
    @EnvironmentObject var model: BankAccountViewModel
    @EnvironmentObject var transactionModel: TransactionsViewModel
    @Environment(\.editMode) private var editMode
    @State private var isShowingPicker = false
    @State private var editModeState: EditMode = .inactive
    @State private var startDate = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
    var body: some View {
        NavigationStack {
            Form {
                //MARK: - Balance Subview
                BalanceRow(model: model)
                
                //MARK: - Currency Subview
                CurrencyRow(model: model, isShowingPicker: $isShowingPicker)
                
                let startOfToday = Calendar.current.startOfDay(for: Date())
                let startDate = Calendar.current
                    .date(byAdding: .day, value: -29, to: startOfToday)!
                // загружаем транзакции с 00:00 startDate до 00:00 завтрашнего дня
                let endDate = Calendar.current
                    .date(byAdding: .day, value: 1, to: startOfToday)!
                
                // Предполагаем, что вы уже вызвали txModel.loadLast30Days(...)
                let rawSums = transactionModel.getSumsForOneMonth(from: startDate)
                
                // Преобразуем в массив DaySum и сортируем
                let data: [DaySum] = rawSums
                    .map { (day, total) in
                        DaySum(id: day, date: day,
                               sum: Decimal(NSDecimalNumber(decimal: total).doubleValue))
                    }
                    .sorted { $0.date < $1.date }
                ChartView(transactions: data)
            }
            .onAppear {
                Task {
                    if let id = model.accountId {
                        await transactionModel.loadTransactions(accountId: id, from: startDate, until: Date())
                    }
                }
            }
            .refreshable {
                do {
                    try await model.loadAccountInfo()
                    if let id = model.accountId {
                        await transactionModel.loadTransactions(accountId: id, from: startDate, until: Date())
                    }
                } catch {
                    print("Refresh failed: ", error)
                }
            }
            .listSectionSpacing(16)
            .navigationTitle("Мой счет")
            .environment(\.editMode, $editModeState)
            .onChange(of: editMode?.wrappedValue) { newMode, oldMode in
                switch newMode {
                case .active:
                    model.editedBalance = model.balance
                    model.editedCurrency = model.currency
                case .inactive, .transient, .none, .some:
                    isShowingPicker = false
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if editModeState == .active {
                            model.currency = model.editedCurrency ?? model.currency
                            model.balance = model.editedBalance ?? model.balance
                            Task {
                                do {
                                    try await
                                    model.loadAccountInfo()
                                } catch {
                                    print("Refresh failed: ", error)
                                }
                            }
                        }
                        // Toggle between .active and .inactive
                        editModeState = (editModeState == .active) ? .inactive : .active
                    } label: {
                        Text(editModeState == .active ? "Сохранить" : "Редактировать")
                            .tint(.purple)
                    }
                }
            }
            //MARK: - Кнопки меняющие валюту
            .actionSheet(isPresented: $isShowingPicker) {
                ActionSheet(title: Text("Валюта"),
                            buttons: [
                                .default(Text("Российский рубль ₽")) {
                                    model.editedCurrency = "RUB"
                                },
                                .default(Text("Доллар США $")) {
                                    model.editedCurrency = "USD"
                                },
                                .default(Text("Евро €")) {
                                    model.editedCurrency = "EUR"
                                }
                            ])
            }
        }
    }
}

#Preview {
    let deps = AppDependencies(token: "DHlsXvPvrVcHuK5T0u5LzH0x")
    
    let viewModel = BankAccountViewModel(service: deps.bankService)
    let transactionViewModel = TransactionsViewModel(service: deps.transactionService)
    BankAccountView()
        .environmentObject(viewModel)
        .environmentObject(transactionViewModel)
}




struct ChartView: View {
    let transactions: [DaySum]
    var body: some View {
        if transactions.isEmpty {
            Text("Нет данных за период")
                .foregroundStyle(.secondary)
                .padding()
        } else {
            Chart {
                ForEach(transactions) { entry in
                    BarMark(
                        x: .value("Day", entry.date, unit: .day),
                        y: .value("Sum", abs(entry.sum)),
                        width: .fixed(6)
                    )
                    .foregroundStyle(entry.sum < 0
                                     ? Color.red
                                     : Color.green)
                }
            }
            .frame(height: 220)
        }
    }
}

struct DaySum: Identifiable {
    var id: Date
    var date: Date
    var sum: Decimal
}

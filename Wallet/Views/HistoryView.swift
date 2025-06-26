import SwiftUI

struct HistoryView: View {
    let direction: Direction
    @StateObject var model = TransactionsViewModel(transactionsService: TransactionsService())
    @State private var startDate: Date = {
        Calendar.current.date(
            byAdding: .month, value: -1, to: Date()
        )!
    }()
    
    @State private var endDate = Calendar.current.startOfDay(for: Date())
    var body: some View {
        NavigationView {
            List {
                Section{
                    HStack {
                        Text("Начало")
                        
                        Spacer()
                        
                        CustomDatePickerView(date: $startDate)
                            .onChange(of: startDate) { oldDate, newDate in
                                if newDate > endDate {
                                    startDate = endDate
                                }
                            }
                    }
                    
                    HStack {
                        Text("Конец")
                        
                        Spacer()
                        
                        CustomDatePickerView(date: $endDate)
                            .onChange(of: endDate) { oldDate, newDate in
                                if newDate < startDate {
                                    endDate = startDate
                                }
                            }
                    }
                    
                    HStack {
                        Text("Сумма")
                        
                        Spacer()
                        
                        let sum = model.sumTransactionsAmount(by: direction, from: startDate, until: endDate)
                        Text(model.formatAmount(sum))
                    }
                    
                    //MARK: - Выбор сортировки
                    Picker("Сортировка", selection: $model.sortType) {
                        ForEach(SortType.allCases, id: \.self) { type in
                            Text(type.rawValue)
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .tag(type)
                        }
                    }
                }
                
                Section("Операции"){
                    TransactionsListSectionView(
                        transactions: model.getTransactions(
                            by: direction,
                            from: startDate,
                            until: endDate,
                            sortedBy: model.sortType
                        ),
                        isShowingTransactionTime: true
                    )
                }
                
            }
            .navigationTitle("Моя история")
            .task {
                await model.loadTransactions(
                    accountId: 0,
                    from: model.today,
                    until: model.today
                )
            }
        }
    }
}

#Preview {
    HistoryView(direction: .outcome)
}

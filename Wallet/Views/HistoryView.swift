import SwiftUI

struct HistoryView: View {
    let direction: Direction
    @StateObject var model = TransactionsService()
    @State private var startDate: Date = {
        Calendar.current.date(
            byAdding: .month, value: -1, to: Date()
        )!
    }()
    
    @State private var endDate = Calendar.current.startOfDay(for: Date())
    @State var sortType: SortType = .dateDescending
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
                    Picker("Сортировка", selection: $sortType) {
                        ForEach(SortType.allCases, id: \.self) { type in
                            Text(type.rawValue)
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .tag(type)
                        }
                    }
                    .onChange(of: sortType) { newType, oldType in
                        sortType = newType
                    }
                }
                
                Section("Операции"){
                    TransactionsListSectionView(
                        transactions: model.getTransactions(
                            by: direction,
                            from: startDate,
                            until: endDate,
                            sortedBy: sortType
                        ),
                        isShowingTransactionTime: true
                    )
                }
                
            }
            .navigationTitle("Моя история")
        }
    }
}

#Preview {
    HistoryView(direction: .outcome)
}

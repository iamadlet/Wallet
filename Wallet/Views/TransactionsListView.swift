import SwiftUI

struct TransactionsListView: View {
    @StateObject var model = TransactionsService()
    @State var sortType: SortType = .dateDescending
    let today = Date()
    var direction: Direction
    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Text("Всего")
                        Spacer()
                        let sum = model.sumTransactionsAmount(by: direction, from: Date(), until: Date())
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
                
                Section("Операции") {
                    TransactionsListSectionView(
                        transactions: model.getTransactions(
                            by: direction,
                            from: today,
                            until: today,
                            sortedBy: sortType
                        ),
                        isShowingTransactionTime: false
                    )
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle(direction == .income ? "Доходы сегодня": "Расходы сегодня")
            
        }
    }
}

#Preview {
    TransactionsListView(direction: .outcome)
}





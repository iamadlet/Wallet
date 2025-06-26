import SwiftUI

struct TransactionsListView: View {
    @StateObject var model = TransactionsViewModel(transactionsService: TransactionsService())
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
                    Picker("Сортировка", selection: $model.sortType) {
                        ForEach(SortType.allCases, id: \.self) { type in
                            Text(type.rawValue)
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .tag(type)
                        }
                    }
                }
                
                Section("Операции") {
                    TransactionsListSectionView(
                        transactions: model.getTransactions(
                            by: direction,
                            from: model.today,
                            until: model.today,
                            sortedBy: model.sortType
                        ),
                        isShowingTransactionTime: false
                    )
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle(direction == .income ? "Доходы сегодня": "Расходы сегодня")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        HistoryView(direction: direction)
                    } label: {
                        Image("History")
                    }
                }
            }
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
    TransactionsListView(direction: .outcome)
}





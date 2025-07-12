import SwiftUI

struct TransactionsListView: View {
    @EnvironmentObject var model: TransactionsViewModel
    var direction: Direction
    @State private var isShowingAddTransactionView: Bool = false
    @State private var popoverState: TransactionSheetState?
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
                        isShowingTransactionTime: false,
                        popoverState: $popoverState)
                }
            }
            .refreshable {
                await model.loadTransactions(accountId: 0, from: model.today, until: model.today)
            }
            .listStyle(.insetGrouped)
            .overlay(
                Button {
//                    isShowingAddTransactionView.toggle()
                    popoverState = .create
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 56, height: 56)
                        .background(Color.accentColor)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                }
                .padding(.trailing, 16)
                .padding(.bottom, 20)
                , alignment: .bottomTrailing
            )
            .popover(item: $popoverState) { state in
                let transactionToEdit: Transaction? = {
                    switch state {
                    case .create: return nil
                    case .edit(let transaction): return transaction
                    }
                }()
                let childVM = CreateTransactionViewModel(
                    accountService: BankAccountsService(),
                    transactionService: model.transactionsService,
                    categoriesService: CategoriesService(),
                    existing: transactionToEdit
                )
                CreateTransactionView(
                    direction: direction,
                    viewModel: childVM
                )
                .onDisappear {
                    Task {
                        await model.loadTransactions(accountId: 0, from: model.today, until: model.today)
                    }
                }
            }
            .navigationTitle(direction == .income ? "Доходы сегодня": "Расходы сегодня")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        HistoryView(direction: direction)
                            .environmentObject(model)
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





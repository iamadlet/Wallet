import SwiftUI

struct TransactionsListView: View {
    @EnvironmentObject var model: TransactionsViewModel
    @EnvironmentObject var bankVM: BankAccountViewModel
    @EnvironmentObject var deps: AppDependencies
    
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
                        let sum = model.sumTransactionsAmount(by: direction, from: model.today, until: model.today)
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
                if let accountId = bankVM.accountId {
                    await model.loadTransactions(
                        accountId: accountId,
                        from: model.today,
                        until: model.today
                    )
                }
            }
            .listStyle(.insetGrouped)
            .overlay(
                Button {
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
                if let accountId = bankVM.accountId {
                    let childVM = CreateTransactionViewModel(
                        accountId: accountId,
                        accountService: deps.bankService,
                        transactionService: deps.transactionService,
                        categoriesService: deps.categoriesService,
                        existing: transactionToEdit
                    )

                    CreateTransactionView(direction: direction)
                        .environmentObject(childVM)
                    .onDisappear {
                        Task {
                            if let accountId = bankVM.accountId {
                                await model.loadTransactions(
                                    accountId: accountId,
                                    from: model.today,
                                    until: model.today
                                )
                            }
                        }
                    }
                }
            }
            .navigationTitle(direction == .income ? "Доходы сегодня": "Расходы сегодня")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        HistoryView(direction: direction)
                            .environmentObject(model)
                            .environmentObject(bankVM)
                            .environmentObject(deps)
                    } label: {
                        Image("History")
                    }
                }
            }
            .onChange(of: bankVM.accountId) { newId in
                guard let id = newId else { return }
                Task {
                    await model.loadTransactions(accountId: id,
                                                 from: model.today,
                                                 until: model.today)
                }
            }
            .task {
                if let accountId = bankVM.accountId {
                    await model.loadTransactions(
                        accountId: accountId,
                        from: model.today,
                        until: model.today
                    )
                }
            }
        }
    }
}

#Preview {
    let deps = AppDependencies(token: "тест")
    let model = TransactionsViewModel(service: deps.transactionService)
    let bankVM = BankAccountViewModel(service: deps.bankService)
    
    TransactionsListView(direction: .outcome)
        .environmentObject(model)
        .environmentObject(bankVM)
        .environmentObject(deps)
}





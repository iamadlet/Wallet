import SwiftUI

struct TransactionsListView: View {
    @EnvironmentObject var model: TransactionsViewModel
    @EnvironmentObject var bankVM: BankAccountViewModel
    @EnvironmentObject var deps: AppDependencies
    
    var direction: Direction
    @State private var isShowingAddTransactionView: Bool = false
    @State private var popoverState: TransactionSheetState?
    @StateObject private var createTxVMHolder = CreateTxVMHolder()
    
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
            .onAppear {
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
                    popoverState = .create(UUID())
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
            .navigationTitle(direction == .income ? "Доходы сегодня": "Расходы сегодня")
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
        .onChange(of: popoverState) { state in
               guard let state = state,
                     createTxVMHolder.vm == nil,
                     let accountId = bankVM.accountId
               else { return }
    
               let txToEdit: Transaction? = {
                   switch state {
                   case .create(_): return nil
                   case .edit(let tx): return tx
                   }
               }()
               createTxVMHolder.vm = CreateTransactionViewModel(
                   accountId: accountId,
                   accountService: deps.bankService,
                   transactionService: deps.transactionService,
                   categoriesService: deps.categoriesService,
                   existing: txToEdit
               )
           }
        .popover(item: $popoverState) { state in
            if let vm = createTxVMHolder.vm {
                CreateTransactionView(
                    direction: direction,
                    popoverState: $popoverState
                )
                .environmentObject(vm)
                .onDisappear {
                    createTxVMHolder.vm = nil
                    Task {
                        await model.loadTransactions(
                                accountId: bankVM.accountId!,
                                from: model.today,
                                until: model.today
                            )
                    }
                }
            }
        }
    }
}

@MainActor
private class CreateTxVMHolder: ObservableObject {
    @Published var vm: CreateTransactionViewModel?
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





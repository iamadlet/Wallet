import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var model: TransactionsViewModel
    let direction: Direction
    @State private var startDate: Date = {
        Calendar.current.date(
            byAdding: .month, value: -1, to: Date()
        )!
    }()
    @State private var endDate: Date = {
        Calendar.current.date(byAdding: .second, value: -1, to: Date()
        )!
    }()
    @State private var showAnalysis = false
    @State private var showEditTransaction: Bool = false
    @State private var selectedTx: Transaction?
    @State private var popoverState: TransactionSheetState?
    
    var body: some View {
            List {
                Section{
                    HStack {
                        Text("Начало")
                        
                        Spacer()
                        
                        CustomDatePickerView(date: $startDate)
                            .onChange(of: startDate) { oldDate, newDate in
                                if newDate > endDate {
                                    endDate = newDate
                                }
                            }
                    }
                    
                    HStack {
                        Text("Конец")
                        
                        Spacer()
                        
                        CustomDatePickerView(date: $endDate)
                            .onChange(of: endDate) { oldDate, newDate in
                                if newDate < startDate {
                                    startDate = newDate
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
                        isShowingTransactionTime: true,
                        popoverState: $popoverState)
                }
                
            }
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
                        await model.loadTransactions(
                            accountId: 0,
                            from: startDate,
                            until: endDate
                        )
                    }
                }
            }
            .navigationTitle("Моя история")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAnalysis = true }) {
                        Image(systemName: "chart.pie")
                    }
                }
            }
            .task {
                await model.loadTransactions(
                    accountId: 0,
                    from: startDate,
                    until: endDate
                )
            }
            .onChange(of: startDate) { _, _ in
              Task { await model.loadTransactions(accountId: 0,
                                                  from: startDate,
                                                  until: endDate) }
            }
            .onChange(of: endDate)   { _, _ in
              Task { await model.loadTransactions(accountId: 0,
                                                  from: startDate,
                                                  until: endDate) }
            }
            .background(
                NavigationLink(destination: AnalysisView(direction: direction), isActive: $showAnalysis) {
                    EmptyView()
                }
                .hidden()
            )
    }
}

#Preview {
    HistoryView(direction: .outcome)
}

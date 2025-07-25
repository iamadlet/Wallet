import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var model: TransactionsViewModel
    @EnvironmentObject var bankVM: BankAccountViewModel
    @EnvironmentObject var deps: AppDependencies
    
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
                startSection
                
                endSection
                
                HStack {
                    Text("Сумма")
                    
                    Spacer()
                    
                    let total = model.sumTransactionsAmount(by: direction, from: startDate, until: endDate)
                    let formatted = model.formatAmount(total)
                    
                    Text(formatted)
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
            
            if model.isLoading {
                ProgressView()
            } else {
                transactionSection
            }
            
        }
        .popover(item: $popoverState) { state in
            let transactionToEdit: Transaction? = {
                switch state {
                case .create(_): return nil
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
                
                CreateTransactionView(
                    direction: direction,
                    popoverState: $popoverState
                )
                    .environmentObject(childVM)
                    .onDisappear {
                        Task {
                            if let accountId = bankVM.accountId {
                                await model.loadTransactions(
                                    accountId: accountId,
                                    from: startDate,
                                    until: endDate
                                )
                            }
                        }
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
        .task(id: "\(startDate)-\(endDate)-\(bankVM.accountId ?? -1)") {
            if let accountId = bankVM.accountId {
                await model.loadTransactions(
                    accountId: accountId,
                    from: startDate,
                    until: endDate
                )
            }
        }
        .background(
            NavigationLink(destination: AnalysisView(direction: direction), isActive: $showAnalysis) {
                EmptyView()
            }
                .hidden()
        )
    }
    
    var transactionSection: some View {
        Section("Операции") {
            TransactionsListSectionView(
                transactions: model.getTransactions(
                    by: direction,
                    from: startDate,
                    until: endDate,
                    sortedBy: model.sortType
                ),
                isShowingTransactionTime: false,
                popoverState: $popoverState
            )
//            .task {
//                if let accountId = bankVM.accountId {
//                    await model.loadTransactions(accountId: accountId,
//                                                 from: startDate,
//                                                 until: endDate)
//                }
//            }
        }
    }
    
    private var startSection: some View {
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
    }
    
    private var endSection: some View {
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
    }
}

#Preview {
    let deps = AppDependencies(token: "тест")
    let model = TransactionsViewModel(service: deps.transactionService)
    let bankVM = BankAccountViewModel(service: deps.bankService)
    
    
    HistoryView(direction: .outcome)
        .environmentObject(model)
        .environmentObject(bankVM)
        .environmentObject(deps)
}

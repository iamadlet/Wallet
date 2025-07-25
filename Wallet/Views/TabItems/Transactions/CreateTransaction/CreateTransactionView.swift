import SwiftUI

struct CreateTransactionView: View {
    let direction: Direction
    @EnvironmentObject var viewModel: CreateTransactionViewModel
    
    @State private var showAlert: Bool = false
    @Binding var popoverState: TransactionSheetState?
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Статья", selection: $viewModel.category) {
                        ForEach(viewModel.categories) { category in
                            Text(category.name)
                                .tag(category as Category?)
                        }
                    }
                    HStack {
                        Text("Сумма")
                        TextField("", text: $viewModel.amount)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Дата")
                        Spacer()
                        CustomDatePickerView(date: $viewModel.date)
                            .onChange(of: viewModel.date) { oldDate, newDate in
                                viewModel.date = min(newDate, Date())
                            }
                    }
                    HStack {
                        Text("Время")
                        Spacer()
                        CustomTimePickerView(time: $viewModel.time)
                    }
                    HStack {
                        TextField("Комментарий", text: $viewModel.comment)
                    }
                }
                
                if viewModel.isEditing() {
                    Button {
                        popoverState = nil
                        Task {
                            if let transaction = viewModel.existingTransaction {
                                try await viewModel.deleteTransaction(transaction)
                            }
                        }
                    } label: {
                        Text("Удалить расход")
                            .foregroundStyle(Color.red)
                    }
                }

            }
            .task {
                await viewModel.loadCategories(of: direction)
            }
            .navigationTitle(direction == .outcome ? "Мои расходы" : "Мои доходы")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отменить") {
                        popoverState = nil
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button((viewModel.existingTransaction != nil) ? "Сохранить" : "Создать") {
                        showAlert = false
                        Task {
                            let success = await viewModel.saveTransaction()
                            if success {
                                popoverState = nil
                            } else {
                                showAlert = true
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            showAlert = false
            viewModel.error = nil
        }
        .alert("Ошибка", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Заполните все поля")
        }
    }
}

#Preview {
    let deps = AppDependencies(token: "токен")
    
    let account = AccountBrief(id: 1, name: "Основной счёт", balance: 1000, currency: "RUB")
    let category = Category(id: 1, name: "Еда", emoji: "🍎", isIncome: false)

    let transaction = Transaction(
        id: 1,
        account: account,
        category: category,
        amount: 100,
        transactionDate: Date(),
        comment: "Пример",
        createdAt: Date(),
        updatedAt: Date()
    )

    let viewModel = CreateTransactionViewModel(
        accountId: 1,
        accountService: deps.bankService,
        transactionService: deps.transactionService,
        categoriesService: deps.categoriesService,
        existing: transaction
    )
    
    CreateTransactionView(direction: .outcome, popoverState: .constant(.create(UUID())))
        .environmentObject(viewModel)
}

#Preview {
    TransactionsListView(direction: .outcome)
}

import SwiftUI

struct CreateTransactionView: View {
    let direction: Direction
    @StateObject var viewModel: CreateTransactionViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showAlert: Bool = false
    
    var body: some View {
        NavigationStack {
            Form {
                
                Section {
                    Picker("Статья", selection: $viewModel.category) {
                        ForEach(viewModel.categories) { category in
                            Text(category.name)
                                .tag(category)
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
                        dismiss()
                        Task {
                            try await viewModel.deleteTransaction(viewModel.getTransaction())
                        }
                    } label: {
                        Text("Удалить расход")
                            .foregroundStyle(Color.red)
                    }
                }

            }
            .navigationTitle(direction == .outcome ? "Мои расходы" : "Мои доходы")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отменить") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button((viewModel.existingTransaction != nil) ? "Сохранить" : "Создать") {
                        Task {
                            do {
                                let validated = try await viewModel.saveTransaction()
                                if validated {
                                    dismiss()
                                } else {
                                    showAlert = true
                                }
                            } catch {
                                print("не удалось сохранить транзакцию:", viewModel.error)
                                showAlert = true
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            Task {
                try await viewModel.loadCategories(of: direction)
            }
        }
        .alert("Ошибка", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Заполните все поля")
        }
    }
}

#Preview {
    CreateTransactionView(
        direction: .outcome,
        viewModel: CreateTransactionViewModel(
            accountService: BankAccountsService(),
            transactionService: TransactionsService(),
            categoriesService: CategoriesService(),
            existing: nil
        )
    )
}

#Preview {
    TransactionsListView(direction: .outcome)
}

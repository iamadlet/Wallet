import SwiftUI

struct BankAccountView: View {
    @StateObject var model = AccountViewModel(service: BankAccountsService())
    @Environment(\.editMode) private var editMode
    @State private var isShowingPicker = false
    @State private var editModeState: EditMode = .inactive
    var body: some View {
        NavigationStack {
            Form {
                //MARK: - Balance Subview
                BalanceRow(model: model)
                
                //MARK: - Currency Subview
                CurrencyRow(model: model, isShowingPicker: $isShowingPicker)
            }
            .refreshable {
                do {
                    try await model.loadBalance()
                    try await model.loadCurrency()
                } catch {
                    print("Refresh failed: ", error)
                }
            }
            .listSectionSpacing(16)
            .navigationTitle("Мой счет")
            .environment(\.editMode, $editModeState)
            .onChange(of: editMode?.wrappedValue) { newMode, oldMode in
                switch newMode {
                case .active:
                    model.editedBalance = model.balance
                    model.editedCurrency = model.currency
                case .inactive, .transient, .none, .some:
                    isShowingPicker = false
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if editModeState == .active {
                            model.currency = model.editedCurrency ?? model.currency
                            model.balance = model.editedBalance ?? model.balance
                            Task {
                                try await model.updateCurrency(new: model.currency)
                                try await model.updateBalance(new: model.balance)
                            }
                        }
                        // Toggle between .active and .inactive
                        editModeState = (editModeState == .active) ? .inactive : .active
                    } label: {
                        Text(editModeState == .active ? "Сохранить" : "Редактировать")
                            .tint(.purple)
                    }
                }
            }
            //MARK: - Кнопки меняющие валюту
            .actionSheet(isPresented: $isShowingPicker) {
                ActionSheet(title: Text("Валюта"),
                            buttons: [
                                .default(Text("Российский рубль ₽")) {
                                    model.editedCurrency = "RUB"
                                },
                                .default(Text("Доллар США $")) {
                                    model.editedCurrency = "USD"
                                },
                                .default(Text("Евро €")) {
                                    model.editedCurrency = "EUR"
                                }
                            ])
            }
        }
    }
}

#Preview {
    BankAccountView()
}




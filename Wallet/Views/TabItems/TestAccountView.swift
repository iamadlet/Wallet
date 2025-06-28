import SwiftUI

struct TestAccountView: View {
    @StateObject var model = AccountViewModel(service: BankAccountsService())
    @Environment(\.editMode) private var editMode
    @State private var isShowingPicker: Bool = false
    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        
                    }
                }
                Section {
                    HStack {
                        Text("Валюта:")
                        Spacer()
                        Button(model.currency) {
                            isShowingPicker = true
                        }
                    }
                }
                .listRowBackground(editMode?.wrappedValue == .active ? .white : Color.backgroundGreen)
            }
            .navigationTitle("Мой счет")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
        }
        .confirmationDialog("Выберите валюту",
                            isPresented: $isShowingPicker,
                            titleVisibility: .visible) {
            ForEach(model.allCurrencies, id: \.self) { cur in
                Button(cur) { model.currency = cur }
            }
//            Button("Отмена", role: .cancel) { }
        }
    }
}

#Preview {
    TestAccountView()
}

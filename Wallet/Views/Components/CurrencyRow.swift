import SwiftUI

struct CurrencyRow: View {
    @Environment(\.editMode) private var editMode
    @ObservedObject var model: AccountViewModel
    @Binding var isShowingPicker: Bool
    
    var body: some View {
        Section {
            HStack {
                if editMode?.wrappedValue == .active {
                    Button {
                        isShowingPicker.toggle()
                    } label: {
                        HStack {
                            Text("Валюта")
                            Spacer()
                            Text(model.editedCurrency ?? model.currency)
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                        .foregroundStyle(Color.black)
                    }
                }
                if editMode?.wrappedValue == .inactive {
                    Text("Валюта")
                    Spacer()
                    Text(model.currency)
                }
            }
        }
        .onAppear() {
            model.editedCurrency = model.currency
        }
        .listRowBackground(editMode?.wrappedValue == .active ? Color.white : Color.backgroundGreen)
    }
}


#Preview {
    CurrencyRow(model: AccountViewModel(service: BankAccountsService()), isShowingPicker: .constant(true))
}

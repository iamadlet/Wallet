import SwiftUI

struct BalanceRow: View {
    @Environment(\.editMode) private var editMode
    @ObservedObject var model: AccountViewModel
    @State var spoilerIsOn = true
    @State private var balanceText: String = ""
    
    var body: some View {
        Section {
            HStack {
                Text("💰")
                Text("Баланс")
                Spacer()
                if editMode?.wrappedValue == .inactive {
                    Text("\(model.formatBalance())")
                        .spoiler(isOn: $spoilerIsOn)
                        .onShake {
                            spoilerIsOn.toggle()
                        }
                } else {
                    TextField(
                        "Баланс",
                        text: $balanceText
                    )
                    .onAppear {
                        balanceText = model.formatBalance()
                    }
                    .onChange(of: balanceText) { new, old in
                        let filtered = new
                        // разрешить цифры, точки и запятые
                            .filter { $0.isWholeNumber || $0 == "." || $0 == "," }
                        // превратить запятые в точки
                        let parts = filtered
                            .replacingOccurrences(of: ",", with: ".")
                            .split(separator: ".")
                        // соединять макс. только 2 точки
                        let sanitized = parts
                            .prefix(2)                            // только целые числа + фракшены
                            .joined(separator: ".")
                        if sanitized != new {
                            balanceText = sanitized
                        }
                        if let dec = Decimal(string: sanitized) {
                            model.editedBalance = dec
                        } else {
                            // invalid or empty → you could choose to set nil or 0
                            model.editedBalance = nil
                        }
                    }
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                }
            }
        }
        .listRowBackground((editMode?.wrappedValue == .inactive) ? Color.accentColor : Color.white)
    }
}

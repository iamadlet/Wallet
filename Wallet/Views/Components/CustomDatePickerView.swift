import SwiftUI

struct CustomDatePickerView: View {
    @Binding var date: Date
    var body: some View {
        Text(dateFormatter(date))
            .font(.body)
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .background(Color.backgroundGreen)
            .cornerRadius(8)
            .overlay(
                DatePicker(
                    "",
                    selection: $date,
                    displayedComponents: [.date]
                )
                .labelsHidden()
                .blendMode(.destinationOver)
            )
    }
}

func dateFormatter(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "ru_RU")
    formatter.dateFormat = "dd MMMM yyyy"
    let text = formatter.string(from: date)
    
    var parts = text
           .split(separator: " ", maxSplits: 3, omittingEmptySubsequences: false)
           .map(String.init)
    
    parts[1] = parts[1].capitalized(with: formatter.locale)
    
    return parts.joined(separator: " ")
}

#Preview {
    CustomDatePickerView(date: .constant(Date()))
}

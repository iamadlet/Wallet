import SwiftUI

struct CustomTimePickerView: View {
    @Binding var time: Date
    var body: some View {
        Text(timeFormatter(time))
            .font(.body)
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .background(Color.backgroundGreen)
            .cornerRadius(8)
            .overlay(
                DatePicker(
                    "",
                    selection: $time,
                    displayedComponents: [.hourAndMinute]
                )
                .labelsHidden()
                .blendMode(.destinationOver)
            )
    }
}

func timeFormatter(_ time: Date) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "ru_RU")
    formatter.dateFormat = "HH:mm"
    let text = formatter.string(from: time)
    
    var parts = text.split(separator: " ", maxSplits: 2, omittingEmptySubsequences: false).map(String.init)
    
    return parts.joined(separator: " ")
}

#Preview {
    CustomTimePickerView(time: .constant(Date()))
}

import SwiftUI

struct TransactionsListSectionView: View {
    var transactions: [Transaction]
    var isShowingTransactionTime: Bool
    @Binding var popoverState: TransactionSheetState?
    var body: some View {
        ForEach(transactions) { transaction in
            Button(action: {
                popoverState = .edit(transaction)
            }) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(Color.backgroundGreen)
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 22)
                        Text("\(transaction.category.emoji)")
                            .font(.system(size: 11.5))
                    }
                    VStack(alignment: .leading, spacing: 0) {
                        Text(transaction.category.name)
                        if !transaction.comment.isEmpty {
                            Text(transaction.comment)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("\(transaction.amount) ₽")
                        if isShowingTransactionTime {
                            Text("\(transaction.transactionDate, style: .time)")
                        }
                    }
                    Image(systemName: "chevron.right")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 6)
                }
                .foregroundStyle(Color.black)
            }
        }
    }
}

#Preview {
    TransactionsListView(direction: .outcome)
}

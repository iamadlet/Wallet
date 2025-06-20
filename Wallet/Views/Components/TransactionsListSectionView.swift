import SwiftUI

struct TransactionsListSectionView: View {
    var transactions: [Transaction]
    var isShowingTransactionTime: Bool
    var body: some View {
        ForEach(transactions) { transaction in
            NavigationLink(destination: TransactionDetailView()) {
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
                        if let comment = transaction.comment, !comment.isEmpty{
                            Text(transaction.comment!)
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
                }
            }
        }
    }
}

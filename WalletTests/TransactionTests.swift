import XCTest
@testable import Wallet

final class TransactionTests: XCTestCase {

    func testParseReturnsValidTransaction() throws {
        let date = Date()
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        let account = AccountBrief(id: 2, name: "Personal", balance: 10000.00, currency: "RUB")
        let category = Category(id: 3, name: "Housing", emoji: "🏠", isIncome: false)
        
        let originalTransaction = Transaction(
            id: 1,
            account: account,
            category: category,
            amount: Decimal(string: "1000.00")!,
            transactionDate: date,
            comment: "Salary",
            createdAt: date,
            updatedAt: date
        )
        let json = originalTransaction.jsonObject
        let parsed = Transaction.parse(jsonObject: json)
        
        XCTAssertNotNil(parsed)
        XCTAssertEqual(parsed?.id, originalTransaction.id)
        XCTAssertEqual(parsed?.account.id, originalTransaction.account.id)
        XCTAssertEqual(parsed?.category.id, originalTransaction.category.id)
        XCTAssertEqual(parsed?.amount, originalTransaction.amount)
        XCTAssertEqual(parsed?.comment, originalTransaction.comment)
        if let parsed = parsed {
            XCTAssertEqual(parsed.transactionDate.timeIntervalSinceReferenceDate,
                           originalTransaction.transactionDate.timeIntervalSinceReferenceDate,
                           accuracy: 0.001)
        }
    }
    
    func testJsonObjectReturnsValidDictionary() throws {
        let date = Date()
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        let account = AccountBrief(id: 2, name: "Personal", balance: 10000.00, currency: "RUB")
        let category = Category(id: 3, name: "Housing", emoji: "🏠", isIncome: false)

        let transaction = Transaction(
            id: 1,
            account: account,
            category: category,
            amount: Decimal(string: "1000.00")!,
            transactionDate: date,
            comment: "Salary",
            createdAt: date,
            updatedAt: date
        )
        let json = transaction.jsonObject as? [String: Any]
        XCTAssertNotNil(json)

        XCTAssertEqual(json?["id"] as? Int, 1)
        XCTAssertEqual(json?["amount"] as? String, "1000.00")
        XCTAssertEqual(json?["comment"] as? String, "Salary")
        XCTAssertEqual(json?["transactionDate"] as? String, formatter.string(from: date))
        XCTAssertEqual(json?["createdAt"] as? String, formatter.string(from: date))
        XCTAssertEqual(json?["updatedAt"] as? String, formatter.string(from: date))


        XCTAssertEqual(json?["account"] as? AccountBrief, account)
        XCTAssertEqual(json?["category"] as? Wallet.Category, category)
    }

}

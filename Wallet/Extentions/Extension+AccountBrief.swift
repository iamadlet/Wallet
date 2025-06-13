import Foundation

extension AccountBrief {
    //из AccountBrief в BankAccount
    init(from bankAccount: BankAccount) {
        self.id = bankAccount.id
        self.name = bankAccount.name
        self.balance = bankAccount.balance
        self.currency = bankAccount.currency
    }
}

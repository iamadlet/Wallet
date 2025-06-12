import Foundation

final class BankAccountsService {
    
    var bankAccounts: [BankAccount] = [BankAccount(
        id: 1,
        userId: 1,
        name: "Personal",
        balance: 10000,
        currency: "RUB",
        createdAt: Date.now,
        updatedAt: Date.now
    )]
    
    func getInfo() async throws -> BankAccount {
        return bankAccounts[0]
    }
    
    //TODO: точно ли 1 счёт в массиве ???? 
    func changeAccount(name: String, balance: Decimal, currency: String) async throws {
        let newAccount = BankAccount(
            id: bankAccounts[0].id,
            userId: bankAccounts[0].id,
            name: name,
            balance: balance,
            currency: currency,
            createdAt: bankAccounts[0].createdAt,
            updatedAt: bankAccounts[0].updatedAt
        )
        
        bankAccounts[0] = newAccount
    }
}

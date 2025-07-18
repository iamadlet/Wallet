import Foundation
import SwiftUI

@MainActor
final class BankAccountViewModel: ObservableObject {
    @Published var accountId: Int? = nil
    @Published var balance: Decimal = 0
    @Published var currency: String = ""
    @Published var editedBalance: Decimal?
    @Published var editedCurrency: String?
    @Published var error: Error?
    
    let allCurrencies: [String] = ["RUB", "USD", "EUR"]
    
    private let service: BankAccountsService
    
    init(service: BankAccountsService) {
        self.service = service
        Task {
            await loadAccountInfo()
        }
    }
    
    func loadAccountInfo() async {
        do {
            let account = try await service.getInfo()
            print("Загружен аккаунт: \(account.id), \(account.balance) \(account.currency)")
            self.accountId = account.id
            self.balance = account.balance
            self.currency = account.currency
        } catch {
            print("Ошибка загрузки аккаунта: \(error)")
            self.error = error
        }
    }
    
    func updateBalance(to newBalance: Decimal) async throws {
        do {
            editedBalance = newBalance
            let info = try await service.getInfo()
            try await service.changeAccount(name: info.name, balance: newBalance, currency: info.currency)
            self.balance = newBalance
        } catch {
            self.error = error
        }
    }
    
    func updateCurrency(to newCurrency: String) async {
        do {
            editedCurrency = newCurrency
            let info = try await service.getInfo()
            try await service.changeAccount(name: info.name, balance: info.balance, currency: newCurrency)
            self.currency = newCurrency
        } catch {
            self.error = error
        }
    }
    
    func formatCurrency() -> String {
        switch self.currency {
        case "RUB":
            return "₽"
        case "USD":
            return "$"
        case "EUR":
            return "€"
        default:
            return ""
        }
    }
    
    func formatBalance() -> String {
        let currencySymbol = formatCurrency()
        let amount = self.balance.formatted(.number.precision(.fractionLength(0...2)))
        return "\(amount) \(currencySymbol)"
    }
    
    func balanceToString() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        
        return formatter.string(from: self.balance as NSDecimalNumber) ?? ""
    }
}

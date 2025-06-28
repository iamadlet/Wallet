import Foundation
import SwiftUI

final class AccountViewModel: ObservableObject {
    @Published var balance: Decimal
    @Published var currency: String
    @Published var editedBalance: Decimal?
    @Published var editedCurrency: String?
    
    let allCurrencies: [String] = ["RUB", "USD", "EUR"]
    
    private let service: BankAccountsService
    
    init(service: BankAccountsService) {
        self.service = service
        self.balance = service.bankAccounts[0].balance
        self.currency = service.bankAccounts[0].currency
    }
    
    func getService() async throws -> BankAccountsService {
        self.service
    }
    
    func loadBalance() async throws {
        self.balance = try await service.getInfo().balance
    }
    
    func loadCurrency() async throws {
        self.currency = try await service.getInfo().currency
    }
    
    @MainActor
    func updateBalance(new balance: Decimal) async throws {
        editedBalance = balance
        
        let info = try await service.getInfo()
        
        try await service.changeAccount(
            name: info.name,
            balance: balance,
            currency: info.currency
        )
    }
    
    @MainActor
    func updateCurrency(new currency: String) async throws {
        editedCurrency = currency
        
        let info = try await service.getInfo()
        
        try await service.changeAccount(
            name: info.name,
            balance: info.balance,
            currency: currency
        )
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

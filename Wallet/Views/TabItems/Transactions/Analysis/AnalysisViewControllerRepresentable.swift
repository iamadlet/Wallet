import SwiftUI
import UIKit

struct AnalysisViewControllerRepresentable: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = AnalysisViewController
    
    let isIncome: Bool
    @Binding var showStartPicker: Bool
    @Binding var showEndPicker: Bool
    @Binding var startDate: Date
    @Binding var endDate: Date
    
    func makeUIViewController(context: Context) -> AnalysisViewController {
        let vc = AnalysisViewController(isIncome: isIncome)
        vc.onStartDateTap = { self.showStartPicker = true }
        vc.onEndDateTap = { self.showEndPicker = true }
        return vc
    }
    
    func updateUIViewController(_ uiViewController: AnalysisViewController, context: Context) {
        // Sync dates from SwiftUI to UIKit
        uiViewController.startDate = startDate
        uiViewController.endDate = endDate
        uiViewController.periodStartBtn.setTitle(uiViewController.dateString(startDate), for: .normal)
        uiViewController.periodEndBtn.setTitle(uiViewController.dateString(endDate), for: .normal)
        uiViewController.loadTransactions()
    }
    
}

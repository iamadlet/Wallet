// The Swift Programming Language
// https://docs.swift.org/swift-book
import Foundation
import UIKit

public struct Entity {
    public let value: Decimal
    public let label: String
    
    public init(value: Decimal, label: String) {
        self.value = value
        self.label = label
    }
}

public final class PieChartView: UIView {
    public var entities: [Entity] = [] {
        didSet { setNeedsDisplay() }
    }
    
    public static let segmentColors: [UIColor] = [
        .systemRed, .systemOrange, .systemYellow,
        .systemGreen, .systemBlue, .systemGray
    ]
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext(), !entities.isEmpty else { return }
        
        // 1. Build up to 6 slices: first 5 entities + “Others”
        let firstFive = entities.prefix(5)
        let restValue = entities.dropFirst(5)
            .reduce(Decimal(0)) { $0 + $1.value }
        var slices: [(value: Decimal, label: String)] = firstFive.map { ($0.value, $0.label) }
        if restValue > 0 {
            slices.append((restValue, "Others"))
        }
        
        // 2. Compute total as Double
        let total = slices
            .map { NSDecimalNumber(decimal: $0.value).doubleValue }
            .reduce(0, +)
        guard total > 0 else { return }
        
        // 3. Draw each wedge
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) * 0.4
        var startAngle = -CGFloat.pi / 2
        
        for (i, slice) in slices.enumerated() {
            let value = NSDecimalNumber(decimal: slice.value).doubleValue
            let angle = CGFloat(value / total) * 2 * .pi
            let endAngle = startAngle + angle
            
            ctx.setFillColor(PieChartView.segmentColors[i].cgColor)
            let path = UIBezierPath()
            path.move(to: center)
            path.addArc(withCenter: center,
                        radius: radius,
                        startAngle: startAngle,
                        endAngle: endAngle,
                        clockwise: true)
            path.close()
            path.fill()
            
            startAngle = endAngle
        }
        
        // 4. Draw in-circle legend
        let swatchSize = CGSize(width: 12, height: 12)
        let spacing: CGFloat = 8
        let font = UIFont.systemFont(ofSize: 12)
        let textColor = UIColor.label
        var legendX = center.x - radius + spacing
        var legendY = center.y - radius + spacing
        
        for (i, slice) in slices.enumerated() {
            // Color swatch
            let swatchRect = CGRect(origin: CGPoint(x: legendX, y: legendY),
                                    size: swatchSize)
            ctx.setFillColor(PieChartView.segmentColors[i].cgColor)
            ctx.fill(swatchRect)
            
            // Label + value
            let valueString = String(format: "%.0f", NSDecimalNumber(decimal: slice.value).doubleValue)
            let text = "\(slice.label) \(valueString)"
            let attrs: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: textColor
            ]
            let textOrigin = CGPoint(x: legendX + swatchSize.width + 4,
                                     y: legendY - 1)
            (text as NSString).draw(at: textOrigin, withAttributes: attrs)
            
            legendY += swatchSize.height + spacing
        }
    }
    
}

//
//  GlucoseCurrentInfoView.swift
//  xDrip
//
//  Created by Dmitry on 6/16/20.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit
@IBDesignable
class GlucoseCurrentInfoView: UIView, NibLoadable {
    @IBOutlet private weak var glucoseIntValueLabel: UILabel!
    @IBOutlet private weak var glucoseDecimalValueLablel: UILabel!
    @IBOutlet private weak var slopeArrowLabel: UILabel!
    @IBOutlet private weak var lastScanTitleLabel: UILabel!
    @IBOutlet private weak var lastScanValueLabel: UILabel!
    @IBOutlet private weak var difTitleLabel: UILabel!
    @IBOutlet private weak var difValueLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupFromNib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupFromNib()
    }
    
    func setup(glucoseValue: Double?, slopeValue: Double?, lastScanDate: Date?, difValue: Double?) {
        let components = getComponentsForGlucoseValue(glucoseValue ?? 0.0)
        glucoseIntValueLabel.text = components.first ?? ""
        glucoseDecimalValueLablel.text = ". " + (components.last ?? "")
        slopeArrowLabel.text = slopeToArrowSymbol(slope: slopeValue ?? 0.0)
        lastScanTitleLabel.text = "Last Scan"
        if let date = lastScanDate {
            lastScanValueLabel.text = getLastScanDateStringFrom(date: date)
        } else {
            lastScanValueLabel.text = ""
        }
        difTitleLabel.text = "DIF"
        difValueLabel.text = getDeltaString(difValue)
    }
    
    fileprivate func getComponentsForGlucoseValue(_ glucoseValue: Double) -> [String] {
        let roundedGlucoseValueString = getRoundedStringFrom(glucoseValue, place: 1)
        return roundedGlucoseValueString.components(separatedBy: ".")
    }
    
    fileprivate func getRoundedStringFrom(_ value: Double, place: Int) -> String {
        return String(format: "%.\(place)f", value.rounded(toPlaces: place))
    }
    
    fileprivate func getDeltaString(_ value: Double?) -> String {
        guard let value = value else { return "" }
        let unit = User.current.settings.unit
        var valueString: String
        if abs(value) < 0.1 {
            valueString = getRoundedStringFrom(value, place: 2)
        } else {
            valueString = getRoundedStringFrom(value, place: 1)
        }
        let signString = value > 0 ? "+" : ""
        let unitString = unit.label
        return signString + valueString + " " + unitString
    }
    
    fileprivate func  slopeToArrowSymbol(slope: Double) -> String {
        if slope <= -3.5 {
            return "\u{21ca}"// ⇊
        } else if slope <= -2 {
            return "\u{2193}" // ↓
        } else if slope <= -1 {
            return "\u{2198}" // ↘
        } else if slope <= 1 {
            return "\u{2192}" // →
        } else if slope <= 2 {
            return "\u{2197}" // ↗
        } else if slope <= 3.5 {
            return "\u{2191}" // ↑
        } else {
            return "\u{21c8}" // ⇈
        }
    }
    
    fileprivate func getLastScanDateStringFrom(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Calendar.current.isDateInToday(date) ? "HH:mm" : "MMM d HH:mm"
        return dateFormatter.string(from: date)
    }
}

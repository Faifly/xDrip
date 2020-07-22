//
//  BasalRatesPicker.swift
//  xDrip
//
//  Created by Ivan Skoryk on 07.07.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

final class BasalRatesPicker: UIPickerView, PickerView, UIPickerViewDelegate {
    private enum Component: Int, CaseIterable {
        case time
        case value
        case units
    }
    
    init() {
        super.init(frame: .zero)
        
        delegate = self
        dataSource = self
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not permitted")
    }
    
    var onValueChanged: ((String?) -> Void)?
    var handleChanges: ((TimeInterval, String) -> Void)?
    
    var minimumTimeInterval: TimeInterval = BasalRate.minimumTimeIntervalBetweenRates
    var minimumStartTime: TimeInterval = 0.0 {
        didSet {
            reloadTimes()
            updateStartTimeSelection()
        }
    }
    var maximumStartTime: TimeInterval = BasalRate.lastValidStartTime {
        didSet {
            reloadTimes()
        }
    }
    private lazy var startOfDay = Calendar.current.startOfDay(for: Date())

    var startTime: TimeInterval = 0 {
        didSet {
            updateStartTimeSelection()
        }
    }
    var selectedStartTime: TimeInterval {
        let row = selectedRow(inComponent: Component.time.rawValue)
        return startTimeForTimeComponent(row: row)
    }
    
    var value: Float = 0.0 {
        didSet {
            if let index = valueComponentRows.firstIndex(of: String(format: "%.2f", value)) {
                selectRow(index, inComponent: Component.value.rawValue, animated: true)
            }
        }
    }
    private var valueComponentRows: [String] {
        let minMax = BasalRate.minMax
        let step = BasalRate.unitStep
        let unitsArray = Array(stride(from: minMax.lowerBound, to: minMax.upperBound + step, by: step))
        let unitsStrings = unitsArray.map { String(format: "%.2f", $0) }
        return unitsStrings
    }
    private var timeComponentRows = [String]()
    
    private func reloadTimes() {
        let rowsCount = Int(round((maximumStartTime - minimumStartTime) / minimumTimeInterval) + 1)
        guard rowsCount > 0 else { return }
        
        timeComponentRows.removeAll()
        for row in 0 ..< rowsCount {
            let time = startTimeForTimeComponent(row: row)
            timeComponentRows.append(stringForStartTime(time))
        }
        reloadComponent(Component.time.rawValue)
    }
    
    private func startTimeForTimeComponent(row: Int) -> TimeInterval {
        return minimumStartTime + minimumTimeInterval * TimeInterval(row)
    }

    private func stringForStartTime(_ time: TimeInterval) -> String {
        let date = startOfDay.addingTimeInterval(time)
        return DateFormatter.localizedString(from: date, dateStyle: .none, timeStyle: .short)
    }
    
    private func updateStartTimeSelection() {
        let row = Int(round((startTime - minimumStartTime) / minimumTimeInterval))
        if row >= 0 && row < pickerView(self, numberOfRowsInComponent: Component.time.rawValue) {
            selectRow(row, inComponent: Component.time.rawValue, animated: true)
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let component = Component(rawValue: component) else { return }
        switch component {
        case .time:
            startTime = selectedStartTime
        default:
            break
        }
        
        let selectedValueRow = selectedRow(inComponent: Component.value.rawValue)
        let value = valueComponentRows[selectedValueRow]
        
        onValueChanged?(stringForStartTime(startTime) + "/\(value)" + "settings_pen_user_units".localized)
        handleChanges?(startTime, value)
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard let component = Component(rawValue: component) else { return nil }
        switch component {
        case .time:
            return timeComponentRows[row]
        case .value:
            return valueComponentRows[row]
        case .units:
            return "settings_pen_user_units".localized
        }
    }
}

extension BasalRatesPicker: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return Component.allCases.count
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard let component = Component(rawValue: component) else { return 0 }
        switch component {
        case .time:
            return timeComponentRows.count
        case .value:
            return valueComponentRows.count
        case .units:
            return 1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        var data = [String]()
        
        guard let component = Component(rawValue: component) else { return 0.0 }
        switch component {
        case .time:
            data = timeComponentRows
        case .value:
            data = [valueComponentRows.last ?? ""]
        case .units:
            data = ["settings_pen_user_units".localized]
        }
        
        let font = UIFont.systemFont(ofSize: 24)
        var maxWidth: CGFloat = 0.0
        
        for value in data {
            let val = value as NSString
            let width = val.size(withAttributes: [NSAttributedString.Key.font: font]).width
            
            if width > maxWidth {
                maxWidth = width
            }
        }
        
        return maxWidth + 16.0
    }
}

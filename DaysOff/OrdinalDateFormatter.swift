import Foundation

class OrdinalDateFormatter: Formatter {
    private let dateFormatter: DateFormatter

    override init() {
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE d MMM YY"
        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func string(for obj: Any?) -> String {
        guard let date = obj as? Date else { return "" }

        let day = Calendar.current.component(.day, from: date)
        let suffix = daySuffix(for: day)

        var formattedString = dateFormatter.string(from: date)
        let dayString = String(format: "%d", day)

        if let range = formattedString.range(of: dayString) {
            formattedString.replaceSubrange(range, with: "\(day)\(suffix)")
        }

        return formattedString
    }

    private func daySuffix(for day: Int) -> String {
        switch day {
        case 1, 21, 31: return "st"
        case 2, 22: return "nd"
        case 3, 23: return "rd"
        default: return "th"
        }
    }
}


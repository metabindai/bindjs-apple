import Foundation

extension ChartAxisOption {
    init(from directive: Directive) {
        let rawValue: String? = directive.rawValue()
        let hiddenFlag: Bool = directive["hidden"] ?? false
        let visibility: String? = directive["visibility"]
        let hidden = hiddenFlag || rawValue == "hidden" || visibility == "hidden"
        let values = ChartAxisValues(from: directive.props["values"] ?? rawValue)
        self.init(
            hidden: hidden,
            values: values,
            position: directive["position"],
            label: directive["label"],
            labelsHidden: directive["labelsHidden"] ?? false,
            ticksHidden: directive["ticksHidden"] ?? false,
            gridHidden: directive["gridHidden"] ?? false,
            formatter: ChartValueFormatter(from: directive.props["formatter"])
        )
    }
}

extension ChartAxisValues {
    init?(`from` raw: Any?) {
        if let string = raw as? String {
            guard string == "automatic" else { return nil }
            self = .automatic
            return
        }
        if let values = raw as? [Any] {
            self = .values(values.compactMap { ChartValue($0) }.filter(\.isAxisValue))
            return
        }
        return nil
    }
}

extension ChartValueFormatter {
    init?(`from` raw: Any?) {
        guard let dict = raw as? [String: Any], let style = dict["style"] as? String else { return nil }
        let minimum: Int? = dict["minimumFractionDigits"] as? Int
        let maximum: Int? = dict["maximumFractionDigits"] as? Int
        switch style {
        case "number":
            self = .number(minimumFractionDigits: minimum, maximumFractionDigits: maximum)
        case "percent":
            self = .percent(minimumFractionDigits: minimum, maximumFractionDigits: maximum)
        case "currency":
            guard let currency = dict["currency"] as? String else { return nil }
            self = .currency(currency: currency, minimumFractionDigits: minimum, maximumFractionDigits: maximum)
        case "date":
            self = .date(dateStyle: dict["dateStyle"] as? String, timeStyle: dict["timeStyle"] as? String)
        default:
            return nil
        }
    }
}

extension ChartScaleOption {
    init(from directive: Directive) {
        let rawDomain = directive.props["domain"] as? [Any]
        self.init(
            type: directive["type"],
            domain: rawDomain?.compactMap { ChartValue($0) }.filter(\.isAxisValue)
        )
    }
}

extension Array where Element == ChartValue {
    var numericRange: ClosedRange<Double>? {
        guard count == 2 else { return nil }
        guard case .number(let lower) = self[0], case .number(let upper) = self[1] else { return nil }
        guard lower <= upper else { return nil }
        return lower...upper
    }

    var hasInvalidNumericRange: Bool {
        guard count == 2 else { return false }
        guard case .number(let lower) = self[0], case .number(let upper) = self[1] else { return false }
        return lower > upper
    }

    var stringDomain: [String]? {
        let strings = compactMap { value -> String? in
            guard case .string(let string) = value else { return nil }
            return string
        }
        return strings.count == count && !strings.isEmpty ? strings : nil
    }
}

extension ChartValue {
    var isAxisValue: Bool {
        switch self {
        case .number, .string:
            return true
        case .bool:
            return false
        }
    }
}

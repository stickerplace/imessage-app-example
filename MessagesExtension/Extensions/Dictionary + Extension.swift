import Foundation

extension Dictionary {
    func stringFromHttpParameters() -> String {
        var parametersString = ""
        for (key, value) in self {
            if let key = key as? String,
                let value = value as? String {
                parametersString = parametersString + key + "=" + value + "&"
            }
        }
        parametersString = parametersString.substring(to: parametersString.index(before: parametersString.endIndex))
        return parametersString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
    }
}

import Foundation

enum AppType: String {
    case hostApp, keyboardExtension, iMessageExtension
}

struct AppTypeService {
    
    var appType: AppType {
        let infoPlist = Bundle.main.infoDictionary
        let type = AppType(rawValue: infoPlist?["SCAppType"] as! String) ?? .hostApp
        return type
    }
    
}

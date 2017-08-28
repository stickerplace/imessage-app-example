import Foundation
import UIKit



class SPSettingsManager: NSObject {
    static let sharedInstance = SPSettingsManager()
    
    private var settings:[String: Any] = [String: Any]()
    
    var kCompanyAppStoreId: String?
    var kProductHTTPSUrl: String?
    var kPackId:String = ""
    var kShowAuthorFooter:Bool = false
    var kApiKey = ""
    
    var logoImageName = ""
    var logoHeight: CGFloat = 0
    var logoWidth: CGFloat = 0
    
    var appName: String {
        var bundle = Bundle.main
        if bundle.bundleURL.pathExtension == "appex" {
            // Peel off two directory levels - MY_APP.app/PlugIns/MY_APP_EXTENSION.appex
            let url = bundle.bundleURL.deletingLastPathComponent().deletingLastPathComponent()
            if let otherBundle = Bundle(url: url) {
                bundle = otherBundle
            }
        }
        
        let appDisplayName = bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
        return appDisplayName ?? ""
    }
    
    override init() {
        super.init()
        
        self.initializeInfo()
    }
    
    func initializeInfo() {
        if let fileUrl = Bundle.main.url(forResource: "settings", withExtension: "plist"),
            let data = try? Data(contentsOf: fileUrl) {
            if let propertyList = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil), let result = propertyList as? [String: Any]  {
                settings = result
            }
        }
        
        // Common settings
        kCompanyAppStoreId = settings["kCompanyAppStoreId"] as? String
        kProductHTTPSUrl = settings["kProductHTTPSUrl"] as? String
        kPackId = settings["kPackId"] as? String ?? ""
        kShowAuthorFooter = settings["kShowAuthorFooter"] as? Bool ?? false
        kApiKey = settings["kApiKey"] as? String ?? ""
        
        logoImageName = settings["kLogoImageName"] as? String ?? ""
        logoHeight = CGFloat(settings["kLogoHeight"] as? NSNumber ?? 0)
        logoWidth = CGFloat(settings["kLogoWidth"] as? NSNumber ?? 0)
    }
    
}

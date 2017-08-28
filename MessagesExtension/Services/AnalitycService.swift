import UIKit

fileprivate let kAppIdKey = "appId" //boundleId
fileprivate let kUuidKey = "uuid"
fileprivate let kEventTypeKey = "eventType"
fileprivate let kStickerIdKey = "stickerId"

enum EventType: String {
    case tap = "TAP", longPress = "LONG_PRESS"
}


class AnalitycService {
    
    private let networkService = NetworkService()
    
    private let uuid = UIDevice.current.identifierForVendor?.uuidString ?? ""
    private let bundleIdentifier = Bundle.main.bundleIdentifier ?? ""
    
    
    func sendEvent(type: EventType, stickerId: String) {
        let body = [kUuidKey : uuid,
                    kEventTypeKey : type.rawValue,
                    kStickerIdKey: stickerId,
                    kAppIdKey: bundleIdentifier]
        
        
        networkService.postRequest(urlStr: APIEndpoint.analititycEvent.path, body: body) { result in
            print(result)
        }
    }
}

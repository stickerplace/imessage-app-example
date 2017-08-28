import Foundation

fileprivate let kIdKey = "id"
fileprivate let kIndexKey = "index"
fileprivate let kPathKey = "path"
fileprivate let kThumbPathKey = "thumbPath"
fileprivate let kUrlKey = "url"
fileprivate let kThumbnailUrlKey = "thumbnailUrl"
fileprivate let kAnimatedKey = "animated"
fileprivate let kExtensionKey = "imageExtension"


class Sticker: NSObject, NSCoding {
    
    let id: String
    
    var url: String { return "\(baseUrl)/v2/images/\(id)?variant=TINIFIED" }
    var thumbnailUrl: String { return "\(baseUrl)/v2/images/\(id)?variant=PNG_400" }
    var imageExtension: String { return isAnimated == true ? "apng" : "png" }
    
    let isAnimated: Bool?
    var imageName: String?
    var thumbImageName: String?
    
    let index: Int
    
    init(json: [String : Any], index: Int) {
        id = (json[kIdKey] as? String) ?? ""
        isAnimated = json[kAnimatedKey] as? Bool
        self.index = index
    }
    
    
    init(id: String, url: String, thumbnailUrl: String, isAnimated: Bool?, index: Int, path: String? = nil, thumbPath: String? = nil) {
        self.id = id
        self.index = index
        self.isAnimated = isAnimated
    }
    
    required init(coder decoder: NSCoder) {
        self.id = decoder.decodeObject(forKey: kIdKey) as! String
        self.index = decoder.decodeInteger(forKey: kIndexKey)
        self.isAnimated = decoder.decodeObject(forKey: kAnimatedKey) as? Bool
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(id, forKey: kIdKey)
        coder.encode(index, forKey: kIndexKey)
        coder.encode(isAnimated, forKey: kAnimatedKey)
    }
    
    func imagePath() -> URL? {
        guard let _imageName = imageName else { return nil }
        let documents = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let imagePath = documents?.appendingPathComponent(_imageName)
        if let path = imagePath?.path, FileManager.default.fileExists(atPath: path) {
            return imagePath
        }
        return nil
    }
    
    func thumbImagePath() -> URL? {
        guard let _imageName = thumbImageName else { return nil }
        let documents = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let imagePath = documents?.appendingPathComponent(_imageName)
        if let path = imagePath?.path, FileManager.default.fileExists(atPath: path) {
            return imagePath
        }
        return nil
    }
}


//Hashable Equtible
extension Sticker {
    
    override var hashValue: Int {
        return "\(id)\(index)".hash
    }
    
    static func ==(lhs: Sticker, rhs: Sticker) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

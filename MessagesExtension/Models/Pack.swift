import Foundation

fileprivate let kIdKey = "id"
fileprivate let kIconIdKey = "icon"
fileprivate let kNameKey = "name"
fileprivate let kUrlKey = "url"
fileprivate let kFirstStickerIdKey = "firstSticker"
fileprivate let kRatingKey = "rating"
fileprivate let kAuthorKey = "author"



class Pack: NSObject, NSCoding {
    
    let id: String
    let url: String
    let name: String
    let iconId: String
    let firstStickerId: String
    let rating: Int
    let author: String
    
    var iconUrl: String {
        return "\(baseUrl)/v2/images/\(iconId)?variant=PNG_200"
    }
    
    init(id: String, url: String, name: String, iconUrl: String, firstStickerId: String, author: String, rating: Int) {
        self.id = id
        self.url = url
        self.name = name
        self.iconId = iconUrl
        self.rating = rating
        self.firstStickerId = firstStickerId
        self.author = author
    }
    
    
    init(json: [String:Any]) {
        id = json[kIdKey] as? String ?? ""
        url = json[kUrlKey] as? String ?? ""
        name = json[kNameKey] as? String ?? ""
        iconId = json[kIconIdKey] as? String ?? ""
        rating = json[kRatingKey] as? Int ?? 0
        firstStickerId = json[kFirstStickerIdKey] as? String ?? ""
        author = json[kAuthorKey] as? String ?? ""
    }
    
    required init(coder decoder: NSCoder) {
        self.id = decoder.decodeObject(forKey: kIdKey) as! String
        self.name = decoder.decodeObject(forKey: kNameKey) as! String
        self.iconId = decoder.decodeObject(forKey: kIconIdKey) as! String
        self.url = decoder.decodeObject(forKey: kUrlKey) as! String
        self.rating = decoder.decodeInteger(forKey: kRatingKey)
        self.firstStickerId = decoder.decodeObject(forKey: kFirstStickerIdKey) as! String
        self.author = decoder.decodeObject(forKey: kAuthorKey) as! String
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(id, forKey: kIdKey)
        coder.encode(name, forKey: kNameKey)
        coder.encode(iconId, forKey: kIconIdKey)
        coder.encode(url, forKey: kUrlKey)
        coder.encode(rating, forKey: kRatingKey)
        coder.encode(firstStickerId, forKey: kFirstStickerIdKey)
        coder.encode(author, forKey: kAuthorKey)
    }
}


//Hashable Equtible
extension Pack {
    
    override var hashValue: Int {
        return "\(id)".hash
    }
    
    static func ==(lhs: Pack, rhs: Pack) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}


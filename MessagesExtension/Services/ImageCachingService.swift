import Foundation

enum StickerImageType: String {
    case original, thumbnail
    
    func endpoit() -> String {
        return "\(self.rawValue).png"
    }
}

struct ImageCachingService {
    
    func saveLocaly(imageData: Data, imageId: String, imageType: StickerImageType) -> URL? {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        
        let imageName = "\(imageId).\(imageType.endpoit())"
        
        let fileURL = documentsURL?.appendingPathComponent(imageName)
        if let _fileURL = fileURL {
            do {
                try imageData.write(to: _fileURL, options: .atomic)
                return fileURL
            } catch _ as NSError {
                return nil
            }
        }
        return nil
    }
    
    func pathOf(imageId: String, imageType: StickerImageType) -> URL? {
        let imageName = imageId
        
        let fm = FileManager.default
        guard let docsurl = try? fm.url(for:.documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) else { return nil }
        let myurl = docsurl.appendingPathComponent("\(imageName).\(imageType.endpoit())")
        
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        var path = paths[0] as String
        path = path + "/" + "\(imageName).\(imageType.endpoit())"
        if FileManager.default.fileExists(atPath: path) {
            return myurl
        }
        
        return nil
    }
    
    func imageDataFor(imageId: String, imageType: StickerImageType) -> Data? {
        if let path = pathOf(imageId: imageId, imageType: imageType) {
            let data = try? Data(contentsOf: path)
            return data
        }

        return nil
    }
}

extension URL {
    var creationDate: Date? {
        return (try? resourceValues(forKeys: [.creationDateKey]))?.creationDate
    }
}


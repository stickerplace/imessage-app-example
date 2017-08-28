import Foundation
import UIKit


protocol StickerServiceDelegate: class {
    func updateData()
    func reloadStickers(index: [IndexPath])
}

class StickerStore {
    
    fileprivate lazy var httpService = NetworkService()
    fileprivate lazy var imageCachingService = ImageCachingService()
    weak var delegate: StickerServiceDelegate?
    
    var pack: Pack?
    fileprivate var stickers = [Sticker]()
    var stickersCount: Int { return stickers.count }
    
    
    
    
    func fetchDataSource(completion: @escaping (_ success: Bool)->()) {
        let dispatchGroup = DispatchGroup()
        var isSuccess = true
        
        dispatchGroup.enter()
        loadPackInfo { success in
            dispatchGroup.leave()
            
            if !success {
                isSuccess = false
            }
        }
        
        dispatchGroup.enter()
        loadStickers { success in
            dispatchGroup.leave()

            if !success {
                isSuccess = false
            }
        }
        
        dispatchGroup.notify(queue: DispatchQueue.main) {
            completion(isSuccess)
        }
    }
    
    
    func loadPackInfo(completion: @escaping (_ success: Bool)->()) {
        if let _pack = loadPackFromFile() {
            self.pack = _pack
            completion(true)
            
        } else {
            getPackInfo(completion: { (pack, error) in
                guard let _pack = pack else {
                    completion(false)
                    return
                }
                
                self.pack = _pack
                self.savePackToFile(pack: _pack)
                completion(true)
            })
        }
    }
    
    func loadStickers(completion: @escaping (_ success: Bool)->()) {
        DispatchQueue.global().async {
            if let stickersFromUserDefaults = self.loadStickersFromFile() {
                self.stickers = stickersFromUserDefaults
                completion(true)
                
                self.getStickersFromServer(completion: { [weak self] (stickers, error) in
                    guard let wSelf = self, let _stickers = stickers else { return }
                    
                    if !_stickers.compareStickersArrays(wSelf.stickers) {
                        wSelf.updateStickers(newStickers: _stickers)
                        wSelf.saveStickersToFile()
                    }
                })
                
            } else {
                self.getStickersFromServer(completion: { [weak self] stickers, error in
                    guard let wSelf = self, let _stickers = stickers else {
                        completion(false)
                        return
                    }
                    
                    wSelf.stickers = _stickers
                    wSelf.delegate?.updateData()
                    
                    wSelf.saveStickersToFile()
                    completion(true)
                })
            }
        }
    }
    
    func stickerForCell(index: Int) -> Sticker? {
        guard stickers.contains(where: { sticker -> Bool in
            if sticker.index == index {
                return true
            }
            return false
            
        }) else { return nil }
        
        return stickers[index]
    }
    
    
    func updateStickers(newStickers: [Sticker]) {
        var stickersToSave: [Sticker] = []
        var stickersToRemove: [Sticker] = []
        
        for (index, element) in newStickers.enumerated() {
            
            if stickers.contains(where: { $0.index == index }) {
                if element == stickers[index] {
                    continue
                    
                } else {
                    stickersToSave.append(element)
                    stickersToRemove.append(stickers[index])
                    stickers[index] = element
                }
            } else {
                stickersToSave.append(element)
                stickers.insert(element, at: index)
            }
        }
        
        if stickers.count > newStickers.count {
            for i in newStickers.count ..< stickers.count {
                stickersToRemove.append(stickers[i])
            }
            stickersToRemove.forEach { stickers.remove(object: $0) }
        }
        
        delegate?.updateData()
    }
}

//MARK:- FileManager
extension StickerStore {
    
    fileprivate func loadPackFromFile() -> Pack? {
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let path = dir.appendingPathComponent("packInfo")
            do {
                let data = try Data(contentsOf: path)
                return NSKeyedUnarchiver.unarchiveObject(with: data) as? Pack
            }
            catch {
                return nil
            }
        }
        return nil
    }
    
    fileprivate func savePackToFile(pack: Pack) {
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: pack)
        
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("pack.info")
        
        do {
            try encodedData.write(to: fileURL, options: .atomic)
        } catch {
            print(error)
        }
    }
    
    fileprivate func loadStickersFromFile() -> [Sticker]? {
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let path = dir.appendingPathComponent("stickers.info")
            do {
                let data = try Data(contentsOf: path)
                return NSKeyedUnarchiver.unarchiveObject(with: data) as? [Sticker]
            }
            catch {
                return nil
            }
        }
        return nil
    }
    
    fileprivate func saveStickersToFile() {
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: stickers)
        
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("stickers.info")
        
        do {
            try encodedData.write(to: fileURL, options: .atomic)
        } catch {
            print(error)
        }
    }
}

//MARK:- network request
extension StickerStore {
    
    func getStickersFromServer(completion: @escaping (_ stickers: [Sticker]?, _ error: String?)->()) {
        let url = APIEndpoint.stickersPath.path
        
        httpService.getRequest(urlStr: url) { result in
            switch result {
                
            case .success(let data):
                guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .allowFragments), let json = jsonObject as? [[String : Any]] else { return }
                
                var stickers = [Sticker]()
                for object in json.enumerated() {
                    let sticker = Sticker(json: object.element, index: object.offset)
                    stickers.append(sticker)
                }
                completion(stickers, nil)
                
            case .failure(let error):
                completion(nil, error?.localizedDescription)
            }
        }
    }
    
    func getPackInfo(completion: @escaping (_ pack: Pack?, _ error: String?)->()) {
        let body = [SPSettingsManager.sharedInstance.kPackId]
        
        httpService.postRequest(urlStr: APIEndpoint.packInfo.path, body: body) { result in
            switch result {
                
            case .success(let data):
                guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .allowFragments), let json = jsonObject as? [[String : Any]],
                    let packJson = json.first
                else { return }
                let pack = Pack(json: packJson)
                completion(pack, nil)
                
            case .failure(let error):
                completion(nil, error?.localizedDescription)
            }
        }
    }
}

protocol ImageHendlerProtocol {
    func getImagePathFor(sticker: Sticker, type: StickerImageType, completion: @escaping (_ path: URL?)->())
}

//MARK: - Image
extension StickerStore: ImageHendlerProtocol {
    
    func getImagePathFor(sticker: Sticker, type: StickerImageType, completion: @escaping (_ path: URL?)->()) {
        if let data = imageCachingService.pathOf(imageId: sticker.id, imageType: type) {
            completion(data)
            
        } else {
            var url: String
            switch type {
            case .original:    url = sticker.url
            case .thumbnail: url = sticker.thumbnailUrl
            }
            
            httpService.getDataFromServerURL(urlString: url, completion: { imageData in
                guard let _imageData = imageData else { return }
                let url = self.imageCachingService.saveLocaly(imageData: _imageData, imageId: sticker.id, imageType: type)
                completion(url)
            })
        }
    }
}

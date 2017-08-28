import UIKit
import Messages


struct StickerCollectionCellData {
    let sticker: Sticker
    let imageHendler: ImageHendlerProtocol
}


class StickerCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var spinerView: UIActivityIndicatorView!
    @IBOutlet weak var stickerView: InstrumentedStickerView!
    
    static let cellId = "StickerCollectionViewCell"
    
    
    var generation: Int = 0
    var index = 0
    
    override func prepareForReuse() {
        super.prepareForReuse()
        generation += 1
        data = nil
    }
    
    var data: StickerCollectionCellData? {
        didSet {
            spinerView.startAnimating()
            stickerView.sticker = nil
            
            guard let _cellData = data else { return }
            let generation = self.generation
            stickerView.alpha = 0
            
            
            let dispatchGroup = DispatchGroup()
            
            dispatchGroup.enter()
            _cellData.imageHendler.getImagePathFor(sticker: _cellData.sticker, type: .original) { [weak self] url in
                guard let wSelf = self, wSelf.generation == generation, let _url = url else { return }
                
                wSelf.stickerView.path = _url
                dispatchGroup.leave()
            }
            
            dispatchGroup.enter()
            _cellData.imageHendler.getImagePathFor(sticker: _cellData.sticker, type: .thumbnail) { [weak self] url in
                guard let wSelf = self, wSelf.generation == generation, let _url = url else { return }
                
                wSelf.stickerView.thumbnailPath = _url
                dispatchGroup.leave()
            }
            
            dispatchGroup.notify(queue: DispatchQueue.main) { [weak self] in
                guard let wSelf = self, wSelf.generation == generation else { return }
                
                wSelf.stickerView.stickerId = _cellData.sticker.id
                
                if let _thumbnailPath = wSelf.stickerView.thumbnailPath {
                    wSelf.stickerView.sticker = try? MSSticker(contentsOfFileURL: _thumbnailPath, localizedDescription: _cellData.sticker.id)
                    wSelf.stickerView.startAnimating()
                    wSelf.spinerView.stopAnimating()
                    wSelf.stickerView.alpha = 1
                }
            }
        }
    }
    
}

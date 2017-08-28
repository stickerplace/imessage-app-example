import UIKit
import Messages

class InstrumentedStickerView: MSStickerView {
    
    lazy var analitycService = AnalitycService()
    var emptyView: UIView?
    var stickerId: String?
    var packId: String?
    var path: URL?
    var thumbnailPath: URL?
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        emptyView = UIView(frame: bounds)
        configureGestureRecognizer()
    }
    
    private func configureGestureRecognizer() {
        for gestureRecognizer in gestureRecognizers ?? [] {
            if let tapGestureRecognizer = gestureRecognizer as? UITapGestureRecognizer {
                tapGestureRecognizer.addTarget(self, action: #selector(didTap))
                tapGestureRecognizer.cancelsTouchesInView = false
                tapGestureRecognizer.delegate = self
                
            } else if let longPressGestureRecognizer = gestureRecognizer as? UILongPressGestureRecognizer {
                longPressGestureRecognizer.addTarget(self, action: #selector(didLongPress))
                longPressGestureRecognizer.delegate = self
                longPressGestureRecognizer.cancelsTouchesInView = false
            }
        }
    }
    
    func didTap(tapGestureRecognizer: UITapGestureRecognizer) {
        if tapGestureRecognizer.state == .recognized {
            self.sendEvent(type: .tap)
        }
    }
    
    func didLongPress(longPressGestureRecognizer: UILongPressGestureRecognizer) {
        if longPressGestureRecognizer.state == .began {
            self.sendEvent(type: .longPress)
        }
    }
    
    private func sendEvent(type: EventType) {
        guard let _stickerId = stickerId else { return }
        analitycService.sendEvent(type: type, stickerId: _stickerId)
    }
    
    //MARK: - replace sticker from full size to thumbnailPath
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        if let _thumbnailPath = thumbnailPath {
            sticker = try? MSSticker(contentsOfFileURL: _thumbnailPath, localizedDescription: "")
        }
    }
    
}

extension InstrumentedStickerView: UIGestureRecognizerDelegate {
    
    //MARK: - replace sticker from thumbnailPath to full size
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let _ = gestureRecognizer as? UIPanGestureRecognizer { return true }
        
        if let _path = path {
            sticker = try? MSSticker(contentsOfFileURL: _path, localizedDescription: "")
        }
        
        return true
    }
}


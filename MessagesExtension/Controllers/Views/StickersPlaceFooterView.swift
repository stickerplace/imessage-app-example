import UIKit

fileprivate let grayColor = UIColor(red: 171/255, green: 171/255, blue: 171/255, alpha: 1)
fileprivate let font = UIFont.systemFont(ofSize: 14.0)


class StickersPlaceFooterView: UICollectionReusableView {
    
    @IBOutlet weak var stickerImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var logoImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var logoImageViewWidthConstraint: NSLayoutConstraint!
    
    
    static let footerId = "StickersPlaceFooterView"
    static let nibName = "StickersPlaceFooterView"
    
    var authorName: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        updateInfo()
    }
    
    func updateInfo() {
        
        if let _authorName = self.authorName {
            let attribute = [NSFontAttributeName: font, NSForegroundColorAttributeName: grayColor]
            let text = NSMutableAttributedString(string: "in collaboration with \(_authorName)", attributes: attribute)
            descriptionLabel.attributedText = text
            
        } else {
            descriptionLabel.text = nil
        }
        
        let imageName = SPSettingsManager.sharedInstance.logoImageName
        let imageWidth = SPSettingsManager.sharedInstance.logoWidth
        let imageHeight = SPSettingsManager.sharedInstance.logoHeight
        
        
        let image = UIImage(named: imageName)
        
        if let _image = image {
            stickerImageView.image = _image
            logoImageViewHeightConstraint.constant = imageHeight
            logoImageViewWidthConstraint.constant = imageWidth
        }
    }
}

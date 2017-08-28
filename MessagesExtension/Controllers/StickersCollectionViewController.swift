import UIKit
import StoreKit
import Messages

protocol StickersCollectionViewControllerDelegate: class {
    func requestPresentation(style: MSMessagesAppPresentationStyle)
}

fileprivate let kShowWebContentSegue = "showWebContentSegue"

fileprivate let kHeaderNib = "FreeStickersHeaderView"
fileprivate let kHeaderReuseIdentifier = "EmptyHeader"

fileprivate let kFooterHeight: CGFloat = 150



class StickersCollectionViewController: UIViewController {

    //MARK: - IBOutlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var errorView: UIView!
    
    //MARK: - Properties
    var stickersStore = StickerStore()
    weak var delegate: StickersCollectionViewControllerDelegate?
    
    
    
    // MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stickersStore.delegate = self
        configureXibViews()
        
        fetchDataSource()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.scrollRectToVisible(CGRect.zero, animated: false)
        
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        configureCollectionLayout(layout: layout)
    }
    
    
    //MARK: - Private Methods
    private func configureXibViews() {
        let footerNib = UINib(nibName: StickersPlaceFooterView.nibName, bundle:nil)
        self.collectionView?.register(footerNib, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: StickersPlaceFooterView.footerId)
    }
    
    private func configureCollectionLayout(layout: UICollectionViewFlowLayout) {
        var itemNumber: CGFloat
        if view.bounds.size.width < 414 {
            itemNumber = 3
        } else if view.bounds.width >= 768 {
            itemNumber = 8
        } else {
            itemNumber = 4
        }
        layout.itemSize.width = floor(view.bounds.size.width / itemNumber)
    }
    
    private func fetchDataSource() {
        collectionView.showProgress()
        errorView.isHidden = true
        
        stickersStore.fetchDataSource { [weak self] isSuccess in
            guard let wSelf = self else { return }
            
            wSelf.collectionView.hideProgress()
            
            wSelf.errorView.isHidden = isSuccess
            wSelf.collectionView.isHidden = !isSuccess
        }

    }
    
    private func showSKStoreProductViewController(identifier: String) {
        let storeController: SKStoreProductViewController = SKStoreProductViewController()
        storeController.delegate = self
        
        let params: [String : Any] = [SKStoreProductParameterITunesItemIdentifier: identifier,
                                      SKStoreProductParameterCampaignToken :  SPSettingsManager.sharedInstance.kPackId]
        
        storeController.loadProduct(withParameters: params) { success, error in
            if success {
                storeController.modalPresentationStyle = .currentContext
                self.delegate?.requestPresentation(style: .expanded)
                self.present(storeController, animated: true)
            }
        }
    }
    
    func showWebViewController(url: URL) {
        self.delegate?.requestPresentation(style: .expanded)
        performSegue(withIdentifier: kShowWebContentSegue, sender: url)
    }
    
    //MARK: - IBActions
    @IBAction func didTapFetchDataSource(_ sender: UIButton) {
        fetchDataSource()
    }
    
    //MARK: - Target-Action methods
    func didTapShowCompanyAppStore(sender: UIButton) {
        if let storeIdentifier = SPSettingsManager.sharedInstance.kCompanyAppStoreId, !storeIdentifier.isEmpty {
            showSKStoreProductViewController(identifier: storeIdentifier)
            
        } else if let productStrUrl = SPSettingsManager.sharedInstance.kProductHTTPSUrl, let url = URL(string: productStrUrl) {
            showWebViewController(url: url)
        }
    }
    
    //MARK: - Navigation
    override open func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == kShowWebContentSegue , let navigationViewController = segue.destination as? UINavigationController, let webViewController = navigationViewController.topViewController as? WebViewController {
            webViewController.url = sender as? URL
        }
    }
}


// MARK: UICollectionViewDataSource
extension StickersCollectionViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stickersStore.stickersCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StickerCollectionViewCell.cellId, for: indexPath) as! StickerCollectionViewCell
        
        if let sticker = stickersStore.stickerForCell(index: indexPath.row) {
            cell.data = StickerCollectionCellData(sticker: sticker, imageHendler: stickersStore)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            if indexPath.section == 0 {
                return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: kHeaderReuseIdentifier, for: indexPath)
            }
            
        case UICollectionElementKindSectionFooter:
            if SPSettingsManager.sharedInstance.kShowAuthorFooter {
                let footerView:StickersPlaceFooterView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: StickersPlaceFooterView.footerId, for: indexPath) as! StickersPlaceFooterView
                footerView.authorName = stickersStore.pack?.author
                footerView.updateInfo()
                let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapShowCompanyAppStore(sender:)))
                footerView.addGestureRecognizer(gesture)
                return footerView
            }
        default: ()
        }
        return UICollectionReusableView()
    }
}


extension StickersCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if SPSettingsManager.sharedInstance.kShowAuthorFooter {
            let height: CGFloat = kFooterHeight + SPSettingsManager.sharedInstance.logoHeight
            return CGSize(width: collectionView.bounds.size.width, height: height)
        }
        return CGSize.zero
    }
}

extension StickersCollectionViewController: StickerServiceDelegate {
    
    func reloadStickers(index: [IndexPath]) {
        DispatchQueue.main.async { self.collectionView?.reloadItems(at: index) }
    }
    
    func updateData() {
        DispatchQueue.main.async { self.collectionView?.reloadData() }
    }
}

extension StickersCollectionViewController : SKStoreProductViewControllerDelegate {
    
    public func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
}


import UIKit


private var loaderViewKey: UInt8 = 7
private var loaderActivityViewKey: UInt8 = 8

extension UICollectionView {
    
    var loaderView: UIView? {
        get {
            return objc_getAssociatedObject(self, &loaderViewKey) as? UIView
        }
        set(newValue) {
            objc_setAssociatedObject(self, &loaderViewKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    var loaderActivityView: UIActivityIndicatorView! {
        get {
            return objc_getAssociatedObject(self, &loaderActivityViewKey) as? UIActivityIndicatorView
        }
        set(newValue) {
            objc_setAssociatedObject(self, &loaderActivityViewKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    func showProgress() {
        showProgress(withTopPadding: 40)
    }
    
    func showProgress(withTopPadding padding:Float) {
        guard loaderView?.superview == nil else { return }
        loaderView = UIView(frame: bounds)
        loaderView?.backgroundColor = UIColor.white
        loaderView?.alpha = 0
        addSubview(loaderView!)
        
        loaderActivityView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        loaderActivityView.startAnimating()
        loaderActivityView.center = CGPoint(x: loaderView!.center.x, y: CGFloat(padding))
        loaderView?.addSubview(loaderActivityView)
        
        UIView.animate(withDuration: 0.15) {
            self.loaderView?.alpha = 1
        }
    }
    
    func hideProgress() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.15, animations: {
                self.loaderView?.alpha = 0
            }) { (completion) in
                self.loaderView?.removeFromSuperview()
                self.loaderActivityView.removeFromSuperview()
            }
        }
    }
}

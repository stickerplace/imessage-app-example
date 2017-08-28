import UIKit

fileprivate let segueStickersCollection = "StickersCollectionSegue"


open class ContainerViewController: UIViewController {
    
    weak var rootDelegate: StickersCollectionViewControllerDelegate?
    
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        performSegue(withIdentifier: segueStickersCollection, sender: nil)
    }
    
    override open func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueStickersCollection {
            let navigationViewController = segue.destination as! UINavigationController
            addChildViewController(navigationViewController)
            view.addSubview(navigationViewController.view)
            navigationViewController.view.frame = view.bounds
            
            if let _stickersViewController = navigationViewController.topViewController as? StickersCollectionViewController {
                _stickersViewController.delegate = rootDelegate
            }
        }
    }
}

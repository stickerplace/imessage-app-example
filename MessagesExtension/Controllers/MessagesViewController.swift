import UIKit
import Messages

fileprivate let kEmbedSegue = "embedControllerSegue"

class MessagesViewController: MSMessagesAppViewController {
    
    var containerViewController: ContainerViewController!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Conversation Handling
    override func willBecomeActive(with conversation: MSConversation) {}
    
    override func didResignActive(with conversation: MSConversation) {}

    override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {}
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == kEmbedSegue {
            containerViewController = segue.destination as! ContainerViewController
            containerViewController.rootDelegate = self
        }
    }
}

extension MessagesViewController: StickersCollectionViewControllerDelegate {
    
    func requestPresentation(style: MSMessagesAppPresentationStyle) {
        requestPresentationStyle(style)
    }
}

import UIKit

class WebViewController: UIViewController, UIWebViewDelegate {
    
    @IBOutlet weak var webView: UIWebView!
    var url: URL?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let _url = url {
            webView.loadRequest(URLRequest(url: _url))
        }
    }
    
    @IBAction func didTapDismiss(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
}

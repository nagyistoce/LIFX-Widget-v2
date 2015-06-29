//
//  OAuthTokenPickerViewController.swift
//  LiFX Widget
//
//  Created by Maxime de Chalendar on 29/06/2015.
//  Copyright (c) 2015 Maxime de Chalendar. All rights reserved.
//

import UIKit

class OAuthTokenPickerViewController: UIViewController {

    var onValidation: ((String?)->())?
    
    @IBOutlet weak var webView: UIWebView!

    @IBAction func pressedConfirmButton(sender: UIBarButtonItem) {
        if hasValidOAuthToken {
            dismissView()
        } else {
            presentConfirmAlertView()
        }
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loadLIFXCloudPage()
    }
}

// Navigation
extension OAuthTokenPickerViewController {

    private func dismissView() {
        dismissViewControllerAnimated(true) {
            onValidation?(OAuthToken)
        }
    }

    private func loadLIFXCloudPage() {
        let URL = NSURL(string: "https://cloud.lifx.com/settings")
        if let unwrappedURL = URL {
            webView.loadRequest(NSURLRequest(URL:unwrappedURL))
        }
    }

}

// Token parsing
extension OAuthTokenPickerViewController {

    private var OAuthToken: String? {
        return UIPasteboard.generalPasteboard().string
    }

    private var hasValidOAuthToken: Bool {
        if let unwrapperOAuthToken = OAuthToken {
            let numberOfCharacters = count(unwrapperOAuthToken)
            let invalidCharactersSet = NSCharacterSet(charactersInString: "0123456789ABCDEFabcdef").invertedSet
            let invalidCharactersRange = unwrapperOAuthToken.rangeOfCharacterFromSet(invalidCharactersSet)

            return numberOfCharacters == 64 && invalidCharactersRange == nil
        } else {
            return false
        }
    }

}

extension OAuthTokenPickerViewController: UIAlertViewDelegate {

    func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        if buttonIndex != alertView.cancelButtonIndex {
            dismissView()
        }
    }

    private func presentConfirmAlertView() {
        let alertView = UIAlertView(title: "Warning", message: "You didn't seem to have copied your token. Without it, you won't be able to use LIFX Widget",
            delegate: nil, cancelButtonTitle: "Go back & copy it", otherButtonTitles: "I did copy it")
        alertView.delegate = self
        alertView.show()
    }

}

extension OAuthTokenPickerViewController: UIBarPositioningDelegate {

    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return .TopAttached
    }

}



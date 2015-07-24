//
//  AlertInterfaceController.swift
//  LiFX Widget
//
//  Created by Maxime de Chalendar on 19/03/2015.
//  Copyright (c) 2015 Maxime de Chalendar. All rights reserved.
//

import WatchKit
import Foundation

class AlertInterfaceOptions {
    let title: String
    let content: String
    let cancelTitle: String
    let onCancellation: (()->())?

    init(title: String, content: String, cancelTitle: String, onCancellation: (()->())?) {
        self.title = title
        self.content = content
        self.cancelTitle = cancelTitle
        self.onCancellation = onCancellation
    }
}

class AlertInterfaceController: WKInterfaceController {

    @IBOutlet private weak var contentLabel: WKInterfaceLabel!
    @IBOutlet private weak var cancelButton: WKInterfaceButton!
    private var onCancellation: (()->Void)?

    @IBAction func tappedCancelButton() {
        self.dismissController()
        onCancellation?()
    }

    override func awakeWithContext(context: AnyObject?) {
        if let options = context as? AlertInterfaceOptions {
            setTitle(options.title)
            contentLabel.setText(options.content)
            cancelButton.setTitle(options.cancelTitle)
            onCancellation = options.onCancellation
        }
    }
    
    class func presentOnController(controller: WKInterfaceController, title: String, content: String, cancelTitle: String, onCancellation: (()->Void)?) {
        let context = AlertInterfaceOptions(title: title, content: content, cancelTitle: cancelTitle, onCancellation: onCancellation)
        controller.presentControllerWithName("AlertInterfaceController", context: context)
    }
}
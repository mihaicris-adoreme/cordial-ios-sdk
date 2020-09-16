//
//  InboxMessageViewController.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 16.09.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import UIKit

class InboxMessageViewController: UIViewController {

    @IBOutlet weak var inboxMessageSegmentedControl: UISegmentedControl!
    @IBOutlet weak var inboxMessageHTMLView: UIView!
    @IBOutlet weak var inboxMessageKeyValuePairsView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Message"
        
        self.prepareInboxMessageSegmentedControl()
    }
    
    func prepareInboxMessageSegmentedControl() {
        if let font = UIFont(name: "Copperplate", size: 16) {
            let underlineStyleNumber = NSNumber(integerLiteral: 1)
            let notUnderlineStyleNumber = NSNumber(integerLiteral: 0)
            let normalTextAttributes = [NSAttributedString.Key.foregroundColor.rawValue: UIColor.black, NSAttributedString.Key.font: font, NSAttributedString.Key.underlineStyle: notUnderlineStyleNumber] as! [NSAttributedString.Key: Any]
            let selectedTextAttributes = [NSAttributedString.Key.foregroundColor.rawValue: UIColor.black, NSAttributedString.Key.font: font, NSAttributedString.Key.underlineStyle: underlineStyleNumber] as! [NSAttributedString.Key: Any]
            
            self.inboxMessageSegmentedControl.setTitleTextAttributes(normalTextAttributes, for: .normal)
            self.inboxMessageSegmentedControl.setTitleTextAttributes(selectedTextAttributes, for: .selected)
            self.inboxMessageSegmentedControl.backgroundColor = UIColor.white
            self.inboxMessageSegmentedControl.tintColor = UIColor.white
        }
    }
    
    @IBAction func inboxMessageSegmentedControlAction(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            self.inboxMessageHTMLView.isHidden = false
            self.inboxMessageKeyValuePairsView.isHidden = true
            break
        case 1:
            self.inboxMessageHTMLView.isHidden = true
            self.inboxMessageKeyValuePairsView.isHidden = false
            break
        default:
            break
        }
    }
    
}

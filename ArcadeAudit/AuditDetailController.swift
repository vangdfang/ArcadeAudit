//
//  AuditDetailController.swift
//  ArcadeAudit
//
//  Created by Doug Kelly on 1/21/16.
//  Copyright © 2016 Doug Kelly. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright notice,
//     this list of conditions and the following disclaimer.
//
//  2. Redistributions in binary form must reproduce the above copyright notice,
//     this list of conditions and the following disclaimer in the documentation
//     and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
//  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.
//

import UIKit

class AuditDetailController: UIViewController, UITextFieldDelegate {
    
    // MARK: Properties
    @IBOutlet weak var games: UITextField!
    @IBOutlet weak var tokens: UITextField!
    @IBOutlet weak var tickets: UITextField!
    @IBOutlet weak var tokensOne: UITextField!
    @IBOutlet weak var tokensTwo: UITextField!
    @IBOutlet weak var tokensThree: UITextField!
    @IBOutlet weak var tokensFour: UITextField!
    @IBOutlet weak var ticketsOne: UITextField!
    @IBOutlet weak var ticketsTwo: UITextField!
    @IBOutlet weak var ticketsThree: UITextField!
    @IBOutlet weak var ticketsFour: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!

    var currentTag: Int = -1
    var originalBottomConstraint: CGFloat = 0
    
    var detailItem: AnyObject? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }
    
    private func addButtonBarTo(textField: UITextField) {
        let previousBarButton = UIBarButtonItem(title: "Prev", style: UIBarButtonItemStyle.Plain, target: self, action: "didTapPrevious:")
        let nextBarButton = UIBarButtonItem(title: "Next", style: UIBarButtonItemStyle.Plain, target: self, action: "didTapNext:")
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "didTapDone:")
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.sizeToFit()
        keyboardToolbar.items = [previousBarButton, nextBarButton, flexBarButton, doneBarButton]
        textField.inputAccessoryView = keyboardToolbar
    }
    
    func didTapPrevious(sender: AnyObject?) {
        var tag = currentTag
        while let nextView = self.view.viewWithTag(--tag) {
            if (nextView.canBecomeFirstResponder()) {
                nextView.becomeFirstResponder()
                return
            }
        }
        self.view.endEditing(true)
    }
    
    func didTapNext(sender: AnyObject?) {
        var tag = currentTag
        while let nextView = self.view.viewWithTag(++tag) {
            if (nextView.canBecomeFirstResponder()) {
                nextView.becomeFirstResponder()
                return
            }
        }
        self.view.endEditing(true)
    }
    
    func didTapDone(sender: AnyObject?) {
        self.view.endEditing(true)
    }
    
    func configureView() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWasShown:", name:UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillBeHidden:", name:UIKeyboardWillHideNotification, object: nil)
        // Update the user interface for the detail item.
        if let detail = self.detailItem as! Audit? {
            if let gamesField = self.games {
                gamesField.text = (detail.games! != 0) ? detail.games?.stringValue : ""
                gamesField.delegate = self
                addButtonBarTo(gamesField)
            }
            if let tokensField = self.tokens {
                tokensField.text = (detail.tokens! != 0) ? detail.tokens?.stringValue : ""
                tokensField.delegate = self
                addButtonBarTo(tokensField)
            }
            if let ticketsField = self.tickets {
                ticketsField.text = (detail.tickets! != 0) ? detail.tickets?.stringValue : ""
                ticketsField.delegate = self
                addButtonBarTo(ticketsField)
            }
            if let tokensOneField = self.tokensOne {
                tokensOneField.text = (detail.tokenOne! != 0) ? detail.tokenOne?.stringValue : ""
                tokensOneField.delegate = self
                tokensOneField.enabled = detail.machine!.coinSlots >= 1
                addButtonBarTo(tokensOneField)
            }
            if let tokensTwoField = self.tokensTwo {
                tokensTwoField.text = (detail.tokenTwo! != 0) ? detail.tokenTwo?.stringValue : ""
                tokensTwoField.delegate = self
                tokensTwoField.enabled = detail.machine!.coinSlots >= 2
                addButtonBarTo(tokensTwoField)
            }
            if let tokensThreeField = self.tokensThree {
                tokensThreeField.text = (detail.tokenThree! != 0) ? detail.tokenThree?.stringValue : ""
                tokensThreeField.delegate = self
                tokensThreeField.enabled = detail.machine!.coinSlots >= 3
                addButtonBarTo(tokensThreeField)
            }
            if let tokensFourField = self.tokensFour {
                tokensFourField.text = (detail.tokenFour! != 0) ? detail.tokenFour?.stringValue : ""
                tokensFourField.delegate = self
                tokensFourField.enabled = detail.machine!.coinSlots >= 4
                addButtonBarTo(tokensFourField)
            }
            if let ticketsOneField = self.ticketsOne {
                ticketsOneField.text = (detail.ticketOne! != 0) ? detail.ticketOne?.stringValue : ""
                ticketsOneField.delegate = self
                ticketsOneField.enabled = detail.machine!.ticketMechs >= 1
                addButtonBarTo(ticketsOneField)
            }
            if let ticketsTwoField = self.ticketsTwo {
                ticketsTwoField.text = (detail.ticketTwo! != 0) ? detail.ticketTwo?.stringValue : ""
                ticketsTwoField.delegate = self
                ticketsTwoField.enabled = detail.machine!.ticketMechs >= 2
                addButtonBarTo(ticketsTwoField)
            }
            if let ticketsThreeField = self.ticketsThree {
                ticketsThreeField.text = (detail.ticketThree! != 0) ? detail.ticketThree?.stringValue : ""
                ticketsThreeField.delegate = self
                ticketsThreeField.enabled = detail.machine!.ticketMechs >= 3
                addButtonBarTo(ticketsThreeField)
            }
            if let ticketsFourField = self.ticketsFour {
                ticketsFourField.text = (detail.ticketFour! != 0) ? detail.ticketFour?.stringValue : ""
                ticketsFourField.delegate = self
                ticketsFourField.enabled = detail.machine!.ticketMechs >= 4
                addButtonBarTo(ticketsFourField)
            }
        }
    }
    
    func keyboardWasShown(notification: NSNotification) {
        /*let keyboardFrame: CGRect = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()

        var aRect = self.view.frame;
        aRect.size.height -= keyboardFrame.height;
        if let activeField = self.view.viewWithTag(currentTag) {
            if !CGRectContainsPoint(aRect, activeField.frame.origin) {
                self.scrollView.scrollRectToVisible(activeField.frame, animated: true)
            }
        }*/
    }
    
    func keyboardWillBeHidden(notification: NSNotification) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        updateFields()
    }
    
    override func viewWillDisappear(animated: Bool) {
        updateFields()
        super.viewWillDisappear(animated)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        currentTag = textField.tag
    }
    
    func updateFields() {
        if let detail = self.detailItem as! Audit? {
            detail.games = Int(games.text!)
            detail.tokens = Int(tokens.text!)
            detail.tickets = Int(tickets.text!)
            detail.tokenOne = Int(tokensOne.text!)
            detail.tokenTwo = Int(tokensTwo.text!)
            detail.tokenThree = Int(tokensThree.text!)
            detail.tokenFour = Int(tokensFour.text!)
            detail.ticketOne = Int(ticketsOne.text!)
            detail.ticketTwo = Int(ticketsTwo.text!)
            detail.ticketThree = Int(ticketsThree.text!)
            detail.ticketFour = Int(ticketsFour.text!)
            do {
                try detail.managedObjectContext!.save()
            } catch {
                abort()
            }
        }
    }
}


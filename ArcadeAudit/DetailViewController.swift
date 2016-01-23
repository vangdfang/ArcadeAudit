//
//  DetailViewController.swift
//  ArcadeAudit
//
//  Created by Doug Kelly on 1/19/16.
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

class DetailViewController: UIViewController, UITextFieldDelegate {

    // MARK: Properties
    @IBOutlet weak var machineName: UITextField!
    @IBOutlet weak var numTicketsStepper: UIStepper!
    @IBOutlet weak var numTokensLabel: UILabel!
    @IBOutlet weak var counterReadsGames: UISwitch!
    @IBOutlet weak var numTicketsLabel: UILabel!
    @IBOutlet weak var numTokensStepper: UIStepper!

    var detailItem: AnyObject? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let detail = self.detailItem as! Machine? {
            if let machineNameField = self.machineName {
                machineNameField.text = detail.machineName
                machineNameField.delegate = self
            }
            if let numTokensField = self.numTokensLabel {
                numTokensField.text = String(detail.coinSlots)
            }
            if let numTicketsField = self.numTicketsLabel {
                numTicketsField.text = String(detail.ticketMechs)
            }
            if let numTokensStepperField = self.numTokensStepper {
                numTokensStepperField.value = Double(detail.coinSlots)
            }
            if let numTicketsStepperField = self.numTicketsStepper {
                numTicketsStepperField.value = Double(detail.ticketMechs)
            }
            if let counterReadsGamesField = self.counterReadsGames {
                counterReadsGamesField.on = detail.countsGames
            }
        }
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
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func stepperValueChanged(sender: UIStepper) {
        updateFields()
    }
    
    @IBAction func switchValueChanged(sender: UISwitch) {
        updateFields()
    }

    func updateFields() {
        if let detail = self.detailItem as! Machine? {
            detail.machineName = machineName.text
            detail.countsGames = counterReadsGames.on
            detail.coinSlots = Int32(numTokensStepper.value)
            detail.ticketMechs = Int32(numTicketsStepper.value)
            do {
                try detail.managedObjectContext!.save()
            } catch {
                abort()
            }
        }
        numTokensLabel.text = String(Int(numTokensStepper.value))
        numTicketsLabel.text = String(Int(numTicketsStepper.value))
    }

    // MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "viewAudits" {
                let controller = segue.destinationViewController as! AuditViewController
                controller.parentItem = self.detailItem as! Machine?
                controller.managedObjectContext = (self.detailItem as! Machine?)?.managedObjectContext
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
        }
    }
}


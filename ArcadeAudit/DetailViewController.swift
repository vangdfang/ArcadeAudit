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
import CoreData

class DetailViewController: UIViewController, UITextFieldDelegate {

    // MARK: Properties
    @IBOutlet weak var machineName: UITextField!
    @IBOutlet weak var machineIdentifier: UITextField!
    @IBOutlet weak var costPerGame: UITextField!
    @IBOutlet weak var numTicketsStepper: UIStepper!
    @IBOutlet weak var numTokensLabel: UILabel!
    @IBOutlet weak var counterReadsGames: UISwitch!
    @IBOutlet weak var numTicketsLabel: UILabel!
    @IBOutlet weak var numTokensStepper: UIStepper!
    @IBOutlet weak var revenueSevenDays: UILabel!
    @IBOutlet weak var ticketsSevenDays: UILabel!

    var detailItem: AnyObject? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }
    
    var managedObjectContext: NSManagedObjectContext?

    func configureView() {
        // Update the user interface for the detail item.
        if let detail = self.detailItem as! Machine? {
            if let machineNameField = self.machineName {
                machineNameField.text = detail.machineName
                machineNameField.delegate = self
            }
            if let machineIdentifierField = self.machineIdentifier {
                machineIdentifierField.text = detail.machineIdentifier
                machineIdentifierField.delegate = self
            }
            if let costPerGameField = self.costPerGame {
                costPerGameField.text = (detail.costPerGame ?? 0 != 0) ? String(format: "%0.02f", detail.costPerGame) : ""
                costPerGameField.delegate = self
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
            updateEarnings()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.updateEarnings()
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
            detail.machineIdentifier = machineIdentifier.text
            detail.costPerGame = Double(costPerGame.text!) ?? 0.0
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
        updateEarnings()
    }
    
    func updateEarnings() {
        if let detail = self.detailItem as! Machine? {
            if let context = managedObjectContext {
                do {
                    let fetchRequest = NSFetchRequest(entityName: "Audit")
                    let machinePredicate = NSPredicate(format: "machine == %@", argumentArray: [detail])
                    let date = NSCalendar.currentCalendar().dateByAddingUnit(NSCalendarUnit.Day, value: -7, toDate: NSDate(), options: NSCalendarOptions(rawValue: 0))
                    let datePredicate = NSPredicate(format: "dateTime >= %@", argumentArray: [date!])
                    fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [machinePredicate, datePredicate])
                    let audits = try context.executeFetchRequest(fetchRequest) as! [Audit]
                    var totalRevenue = 0
                    var totalTickets = 0
                    for audit in audits {
                        if detail.countsGames {
                            totalRevenue += Int(audit.games ?? 0)
                        } else {
                            totalRevenue += Int(audit.tokens ?? 0)
                        }
                        totalTickets += Int(audit.tickets ?? 0)
                    }
                    if let revenueSevenDaysLabel = self.revenueSevenDays {
                        revenueSevenDaysLabel.text = String(format: "%0.02f", Double(totalRevenue) * detail.costPerGame)
                    }
                    if let ticketsSevenDaysLabel = self.ticketsSevenDays {
                        ticketsSevenDaysLabel.text = String(totalTickets)
                    }
                } catch {
                    print("Error while fetching recent audits: \(error)")
                }
            }
        }
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


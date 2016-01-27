//
//  HistoryViewController.swift
//  ArcadeAudit
//
//  Created by Doug Kelly on 1/25/16.
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

class HistoryViewController: UIViewController {

    @IBOutlet weak var revenueSevenDays: UILabel!
    @IBOutlet weak var ticketsSevenDays: UILabel!
    @IBOutlet weak var revenueThirtyDays: UILabel!
    @IBOutlet weak var ticketsThirtyDays: UILabel!
    @IBOutlet weak var topEarnerPositionOne: UILabel!
    @IBOutlet weak var topEarnerOneValue: UILabel!
    @IBOutlet weak var topEarnerPositionTwo: UILabel!
    @IBOutlet weak var topEarnerTwoValue: UILabel!
    @IBOutlet weak var topEarnerPositionThree: UILabel!
    @IBOutlet weak var topEarnerThreeValue: UILabel!
    @IBOutlet weak var lowEarnerPositionOne: UILabel!
    @IBOutlet weak var lowEarnerOneValue: UILabel!
    @IBOutlet weak var lowEarnerPositionTwo: UILabel!
    @IBOutlet weak var lowEarnerTwoValue: UILabel!
    @IBOutlet weak var lowEarnerPositionThree: UILabel!
    @IBOutlet weak var lowEarnerThreeValue: UILabel!
    @IBOutlet weak var topPayoutPositionOne: UILabel!
    @IBOutlet weak var topPayoutOneValue: UILabel!
    @IBOutlet weak var topPayoutPositionTwo: UILabel!
    @IBOutlet weak var topPayoutTwoValue: UILabel!
    @IBOutlet weak var topPayoutPositionThree: UILabel!
    @IBOutlet weak var topPayoutThreeValue: UILabel!
    @IBOutlet weak var lowPayoutPositionOne: UILabel!
    @IBOutlet weak var lowPayoutOneValue: UILabel!
    @IBOutlet weak var lowPayoutPositionTwo: UILabel!
    @IBOutlet weak var lowPayoutTwoValue: UILabel!
    @IBOutlet weak var lowPayoutPositionThree: UILabel!
    @IBOutlet weak var lowPayoutThreeValue: UILabel!
    
    var managedObjectContext: NSManagedObjectContext?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.configureView()
    }
    
    func configureView() {
        if let revenueSevenDaysLabel = revenueSevenDays {
            if let ticketsSevenDaysLabel = ticketsSevenDays {
                let sevenDayTotals = updateRevenueForDays(7, revenueLabel: revenueSevenDaysLabel, ticketsLabel: ticketsSevenDaysLabel)
                let totalsByRevenue = sevenDayTotals.sort() { $0.revenue > $1.revenue }
                let totalsByTickets = sevenDayTotals.sort() { $0.tickets > $1.tickets }
                updateHighScoreLabel(totalsByRevenue, label: topEarnerPositionOne, value: topEarnerOneValue, position: 0, fieldToPrint: "revenue")
                updateHighScoreLabel(totalsByRevenue, label: topEarnerPositionTwo, value: topEarnerTwoValue, position: 1, fieldToPrint: "revenue")
                updateHighScoreLabel(totalsByRevenue, label: topEarnerPositionThree, value: topEarnerThreeValue, position: 2, fieldToPrint: "revenue")
                updateHighScoreLabel(totalsByRevenue, label: lowEarnerPositionOne, value: lowEarnerOneValue, position: 0, fieldToPrint: "revenue", reverseSort: true)
                updateHighScoreLabel(totalsByRevenue, label: lowEarnerPositionTwo, value: lowEarnerTwoValue, position: 1, fieldToPrint: "revenue", reverseSort: true)
                updateHighScoreLabel(totalsByRevenue, label: lowEarnerPositionThree, value: lowEarnerThreeValue, position: 2, fieldToPrint: "revenue", reverseSort: true)
                updateHighScoreLabel(totalsByTickets, label: topPayoutPositionOne, value: topPayoutOneValue, position: 0, fieldToPrint: "tickets")
                updateHighScoreLabel(totalsByTickets, label: topPayoutPositionTwo, value: topPayoutTwoValue, position: 1, fieldToPrint: "tickets")
                updateHighScoreLabel(totalsByTickets, label: topPayoutPositionThree, value: topPayoutThreeValue, position: 2, fieldToPrint: "tickets")
                updateHighScoreLabel(totalsByTickets, label: lowPayoutPositionOne, value: lowPayoutOneValue, position: 0, fieldToPrint: "tickets", reverseSort: true)
                updateHighScoreLabel(totalsByTickets, label: lowPayoutPositionTwo, value: lowPayoutTwoValue, position: 1, fieldToPrint: "tickets", reverseSort: true)
                updateHighScoreLabel(totalsByTickets, label: lowPayoutPositionThree, value: lowPayoutThreeValue, position: 2, fieldToPrint: "tickets", reverseSort: true)
            }
        }
        if let revenueThirtyDaysLabel = revenueThirtyDays {
            if let ticketsThirtyDaysLabel = ticketsThirtyDays {
                updateRevenueForDays(30, revenueLabel: revenueThirtyDaysLabel, ticketsLabel: ticketsThirtyDaysLabel)
            }
        }
    }
    
    func updateHighScoreLabel(totals: [(machine: Machine, revenue: Double, tickets: Int)], label: UILabel?, value: UILabel?, position: Int, fieldToPrint: String, reverseSort: Bool=false) {
        if let labelLabel = label {
            if let valueLabel = value {
                if reverseSort {
                    var valueSet = false
                    var skipped = 0
                    for var i = totals.count - 1; i >= 0; i-- {
                        if fieldToPrint == "revenue" && totals[i].revenue > 0.0 {
                            if skipped == position {
                                labelLabel.text = totals[i].machine.machineName ?? "(No Name)"
                                valueLabel.text = String(format: "%0.02f", totals[i].revenue)
                                valueSet = true
                                break
                            }
                            skipped++
                        } else if fieldToPrint == "tickets" && totals[i].tickets > 0 {
                            if skipped == position {
                                labelLabel.text = totals[i].machine.machineName ?? "(No Name)"
                                valueLabel.text = String(totals[i].tickets)
                                valueSet = true
                                break
                            }
                            skipped++
                        }
                    }
                    if !valueSet {
                        labelLabel.text = "N/A"
                        valueLabel.text = ""
                    }
                } else {
                    if position >= 0 && position < totals.count {
                        labelLabel.text = totals[position].machine.machineName ?? "(No Name)"
                        if fieldToPrint == "revenue" {
                            valueLabel.text = String(format: "%0.02f", totals[position].revenue)
                        } else if fieldToPrint == "tickets" {
                            valueLabel.text = String(totals[position].tickets)
                        }
                    } else {
                        labelLabel.text = "N/A"
                        valueLabel.text = ""
                    }
                }
            }
        }
    }
    
    func updateRevenueForDays(previousDays: Int, revenueLabel: UILabel, ticketsLabel: UILabel) -> [(machine: Machine, revenue: Double, tickets: Int)] {
        var totalRevenue: Double = 0.0
        var totalTickets: Int = 0
        var machineTotals: [(machine: Machine, revenue: Double, tickets: Int)] = []
        if let context = managedObjectContext {
            do {
                let fetchRequest = NSFetchRequest(entityName: "Machine")
                let machines = try context.executeFetchRequest(fetchRequest) as! [Machine]
        
                for detail in machines {
                    do {
                        let subFetchRequest = NSFetchRequest(entityName: "Audit")
                        let machinePredicate = NSPredicate(format: "machine == %@", argumentArray: [detail])
                        let date = NSCalendar.currentCalendar().dateByAddingUnit(NSCalendarUnit.Day, value: -previousDays, toDate: NSDate(), options: NSCalendarOptions(rawValue: 0))
                        let datePredicate = NSPredicate(format: "dateTime >= %@", argumentArray: [date!])
                        subFetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [machinePredicate, datePredicate])
                        let audits = try context.executeFetchRequest(subFetchRequest) as! [Audit]
                        var gameTokens = 0
                        var gameTickets = 0
                        for audit in audits {
                            if detail.countsGames {
                                gameTokens += Int(audit.games ?? 0)
                            } else {
                                gameTokens += Int(audit.tokens ?? 0)
                            }
                            gameTickets += Int(audit.tickets ?? 0)
                        }
                        let gameRevenue = Double(gameTokens) * detail.costPerGame
                        totalRevenue += gameRevenue
                        totalTickets += gameTickets
                        machineTotals.append((machine: detail, revenue: gameRevenue, tickets: gameTickets))
                    } catch {
                        print("Error while fetching recent audits: \(error)")
                    }
                }
            } catch {
                print("Error while fetching machines: \(error)")
            }
        }
        revenueLabel.text = String(format: "%0.02f", totalRevenue)
        ticketsLabel.text = String(totalTickets)
        return machineTotals
    }
}

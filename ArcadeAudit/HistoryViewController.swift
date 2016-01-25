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
    
    var managedObjectContext: NSManagedObjectContext?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.configureView()
    }
    
    func configureView() {
        if let revenueSevenDaysLabel = revenueSevenDays {
            if let ticketsSevenDaysLabel = ticketsSevenDays {
                updateRevenueForDays(7, revenueLabel: revenueSevenDaysLabel, ticketsLabel: ticketsSevenDaysLabel)
            }
        }
        if let revenueThirtyDaysLabel = revenueThirtyDays {
            if let ticketsThirtyDaysLabel = ticketsThirtyDays {
                updateRevenueForDays(30, revenueLabel: revenueThirtyDaysLabel, ticketsLabel: ticketsThirtyDaysLabel)
            }
        }
    }
    
    func updateRevenueForDays(previousDays: Int, revenueLabel: UILabel, ticketsLabel: UILabel) {
        var totalRevenue: Double = 0.0
        var totalTickets: Int = 0
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
                        var gameRevenue = 0
                        var gameTickets = 0
                        for audit in audits {
                            if detail.countsGames {
                                gameRevenue += Int(audit.games ?? 0)
                            } else {
                                gameRevenue += Int(audit.tokens ?? 0)
                            }
                            gameTickets += Int(audit.tickets ?? 0)
                        }
                        totalRevenue += Double(gameRevenue) * detail.costPerGame
                        totalTickets += gameTickets
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
    }
}

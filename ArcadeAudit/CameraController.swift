//
//  CameraController.swift
//  ArcadeAudit
//
//  Created by Doug Kelly on 1/23/16.
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
import AVFoundation

class CameraController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    @IBOutlet var videoView: UIView!
    var session: AVCaptureSession?
    var managedObjectContext: NSManagedObjectContext? = nil
    var captureVideoPreviewLayer: AVCaptureVideoPreviewLayer? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationIsActive:", name: UIApplicationWillEnterForegroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationIsBackground:", name: UIApplicationDidEnterBackgroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "deviceOrientationDidChange", name: UIDeviceOrientationDidChangeNotification, object: nil)
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        capture()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        enterBackground()
    }
    
    func applicationIsActive(notification: NSNotification?) {
        if self.isViewLoaded() && self.view.window != nil {
            capture()
        }
    }
    
    func applicationIsBackground(notification: NSNotification?) {
        enterBackground()
    }
    
    func enterBackground() {
        if let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo) {
            do {
                try device.lockForConfiguration()
                device.torchMode = AVCaptureTorchMode.Off
                device.unlockForConfiguration()
            } catch {
                print("Could not turn off flash")
            }
            if let captureSession = session {
                captureSession.stopRunning()
            }
        }
    }
    
    func deviceOrientationDidChange() {
        resizeView()
    }
    
    func capture() {
        session = AVCaptureSession()
        let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        if device != nil {
            do {
                let input = try AVCaptureDeviceInput(device: device)
                session!.addInput(input)
            } catch {
                print("Error: \(error)")
            }
            
            let output = AVCaptureMetadataOutput()
            output.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
            output.rectOfInterest = self.videoView.bounds
            session!.addOutput(output)
            output.metadataObjectTypes = output.availableMetadataObjectTypes
            do {
                try device.lockForConfiguration()
                if device.torchLevel != AVCaptureMaxAvailableTorchLevel {
                    try device.setTorchModeOnWithLevel(AVCaptureMaxAvailableTorchLevel)
                }
                device.unlockForConfiguration()
            } catch {
                print("Could not turn on flash")
            }
            
            captureVideoPreviewLayer = AVCaptureVideoPreviewLayer()
            resizeView()
            captureVideoPreviewLayer!.session = session
            captureVideoPreviewLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
            self.videoView.layer.insertSublayer(captureVideoPreviewLayer!, above: self.videoView.layer)
            
            session!.startRunning()
        }
    }
    
    func resizeView() {
        let orientation = UIDevice.currentDevice().orientation
        if let layer = captureVideoPreviewLayer {
            switch orientation {
            case UIDeviceOrientation.LandscapeLeft:
                layer.setAffineTransform(CGAffineTransformMakeRotation(CGFloat(-M_PI_2)))
                break
            case UIDeviceOrientation.LandscapeRight:
                layer.setAffineTransform(CGAffineTransformMakeRotation(CGFloat(M_PI_2)))
                break
            default:
                // Include Portrait and all other rotations
                layer.setAffineTransform(CGAffineTransformMakeRotation(CGFloat(0.0)))
                break
            }
            layer.frame = self.videoView.bounds
        }
    }
    
    // MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "addAudit" {
            if let machine = sender as? Machine {
                let controller = segue.destinationViewController as! AuditDetailController
                let newAudit = Audit(entity: NSEntityDescription.entityForName("Audit", inManagedObjectContext: self.managedObjectContext!)!, insertIntoManagedObjectContext: managedObjectContext)
                newAudit.dateTime = NSDate()
                newAudit.machine = machine
                
                // Save the context.
                do {
                    try managedObjectContext!.save()
                } catch {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    //print("Unresolved error \(error), \(error.userInfo)")
                    abort()
                }
                controller.detailItem = newAudit
                controller.managedObjectContext = managedObjectContext
            }
        } else if segue.identifier == "addMachine" {
            if let machineIdentifier = sender as? String {
                let controller = segue.destinationViewController as! DetailViewController
                let newMachine = Machine(entity: NSEntityDescription.entityForName("Machine", inManagedObjectContext: self.managedObjectContext!)!, insertIntoManagedObjectContext: managedObjectContext)
                newMachine.machineName = "New Machine"
                newMachine.machineIdentifier = machineIdentifier
                
                // Save the context.
                do {
                    try managedObjectContext!.save()
                } catch {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    //print("Unresolved error \(error), \(error.userInfo)")
                    abort()
                }
                controller.detailItem = newMachine
                controller.managedObjectContext = managedObjectContext
            }
        }
    }
    
    // MARK: - AVCaptureMetadataOutputObjectsDelegate
    
    func captureOutput(
        captureOutput: AVCaptureOutput!,
        didOutputMetadataObjects metadataObjects: [AnyObject]!,
        fromConnection connection: AVCaptureConnection!) {
            let fetchRequest = NSFetchRequest(entityName: "Machine")
            for metadata in metadataObjects as! [AVMetadataObject] {
                if let machineMetadata = metadata as? AVMetadataMachineReadableCodeObject {
                    if let identifier = machineMetadata.stringValue {
                        print("Identifier: \(identifier)")
                        fetchRequest.predicate = NSPredicate(format: "machineIdentifier == %@", identifier)
                        do {
                            self.enterBackground()
                            let machines = try managedObjectContext?.executeFetchRequest(fetchRequest) as! [Machine]
                            if machines.count == 1 {
                                performSegueWithIdentifier("addAudit", sender: machines[0])
                            } else if machines.count == 0 {
                                performSegueWithIdentifier("addMachine", sender: identifier)
                            } else {
                                let alert = UIAlertController(title: "Warning", message: "Multiple machines have the barcode identifier \"\(identifier)\"", preferredStyle: UIAlertControllerStyle.Alert)
                                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: {(alert: UIAlertAction!) in self.capture()}))
                                self.presentViewController(alert, animated: true, completion: nil)
                            }
                        } catch {
                            print("Error fetching machines: \(error)")
                        }
                    }
                }
            }
    }
}

//
//  DetailViewController.swift
//  Card Maker
//
//  Created by Poul Hornsleth on 11/16/17.
//  Copyright © 2017 Poul Hornsleth. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation


//http://jamesonquave.com/blog/taking-control-of-the-iphone-camera-in-ios-8-with-swift-part-1/

class DetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!
    let captureSession = AVCaptureSession()
    var captureDevice : AVCaptureDevice?
    func configureView() {
        // Update the user interface for the detail item.
        if let detail = detailItem {
            if let label = detailDescriptionLabel {
                label.text = detail.description
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
       // configureView()
        captureSession.sessionPreset = AVCaptureSessionPresetLow
    
        if let device = AVCaptureDevice.defaultDevice(withDeviceType: AVCaptureDeviceType.builtInDualCamera, mediaType: AVMediaTypeVideo, position: AVCaptureDevicePosition.back)
        {
            self.captureDevice = device
            beginSession()
        }
         else
         {
             print("no devices")
         }
    }
    
    func beginSession()
    {
        if let captureDevice = self.captureDevice
        {
            do
            {
                let input = try AVCaptureDeviceInput(device: captureDevice )
                self.captureSession.addInput(input)
                //self.captureSession.addInput(AVCaptureDeviceInput(device: input, error: &err))
        
                
                if let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                {
                    self.view.layer.addSublayer(previewLayer)
                    previewLayer.frame = self.view.layer.frame
                    captureSession.startRunning()
                }
                else
                {
                    print( "no preview")
                }
            }
            catch
            {
                print("caught")
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var detailItem: NSDate? {
        didSet {
            // Update the view.
            configureView()
        }
    }


}


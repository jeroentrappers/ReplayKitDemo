//
//  ViewController.swift
//  ScreenRecord
//
//  Created by Michell Sweet on 25/8/2017.
//  Copyright © 2017 AppCoda. All rights reserved.
//

import UIKit
import SpriteKit
import ReplayKit
import CoreVideo
import VideoToolbox

class ViewController: UIViewController, RPPreviewViewControllerDelegate {
    
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var colorPicker: UISegmentedControl!
    @IBOutlet var colorDisplay: UIView!
    @IBOutlet var recordButton: UIButton!
    @IBOutlet var mirrorView: UIImageView!
    
    let recorder = RPScreenRecorder.shared()
    private var isRecording = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recordButton.layer.cornerRadius = 32.5
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func viewReset() {
        statusLabel.text = "Ready to Record"
        statusLabel.textColor = UIColor.black
        recordButton.backgroundColor = UIColor.green
    }
    
    @IBAction func colors(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            colorDisplay.backgroundColor = UIColor.red
        case 1:
            colorDisplay.backgroundColor = UIColor.blue
        case 2:
            colorDisplay.backgroundColor = UIColor.orange
        case 3:
            colorDisplay.backgroundColor = UIColor.green
        default:
            colorDisplay.backgroundColor = UIColor.red
        }
    }
    
    @IBAction func recordButtonTapped() {
        if !isRecording {
            startRecording()
        } else {
            stopRecording()
        }
    }
    

    func startRecording() {
        
        
        guard recorder.isAvailable else {
            print("Recording is not available at this time.")
            return
        }
        recorder.isMicrophoneEnabled = false
        recorder.startCapture(handler: sampleHandler,
                              completionHandler:
        { (error) in
            guard error == nil else {
                print("There was an error starting the recording.")
                return
            }
            
            print("Started Recording Successfully")
            self.isRecording = true
            DispatchQueue.main.async {
                self.recordButton.backgroundColor = UIColor.red
                self.statusLabel.text = "Recording..."
                self.statusLabel.textColor = UIColor.red
            }

        })
        
    }
    
    func sampleHandler(buffer: CMSampleBuffer, bufferType: RPSampleBufferType, error: Error?) {
        guard error == nil else {
            print("Error handling sample \(error!)")
            return
        }
        let numsamples = CMSampleBufferGetNumSamples(buffer)
        
        switch bufferType {
        case .audioApp, .audioMic:
            return
        case .video:
            guard numsamples == 1 else {
                print("More than 1 sample received, what's this?")
                return
            }
            let image = CMSampleBufferGetImageBuffer(buffer) as CVPixelBuffer?
            if image == nil {
                print("Not a Pixel buffer, what now?")
                return
            }
            var cgImage: CGImage?
            VTCreateCGImageFromCVPixelBuffer(image!, options: nil, imageOut: &cgImage)
            
            let image_ui = UIImage(cgImage: cgImage!)
            DispatchQueue.main.async {
                self.mirrorView.image = image_ui
            }
            return
        default:
            print("unknown buffer type \(bufferType.rawValue)")
        }
    }
    
    func stopRecording() {
        
        recorder.stopCapture { [unowned self] (error) in
            DispatchQueue.main.async {
                self.isRecording = false
                self.viewReset()
            }
        }
    }
    
    func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
        dismiss(animated: true)
    }
}

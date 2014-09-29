/*
* QRCodeReader.swift
*
* Copyright 2014-present Yannick Loriot.
* http://yannickloriot.com
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*
*/

import UIKit
import AVFoundation

class QRCodeReader: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    private var cameraView: UIView     = UIView()
    private var cancelButton: UIButton = UIButton()
    
    private var device: AVCaptureDevice                       = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
    private lazy var deviceInput: AVCaptureDeviceInput        = { return AVCaptureDeviceInput(device: self.device, error: nil) }()
    private var metadataOutput: AVCaptureMetadataOutput       = AVCaptureMetadataOutput()
    private var session: AVCaptureSession                     = AVCaptureSession()
    private lazy var previewLayer: AVCaptureVideoPreviewLayer = { return AVCaptureVideoPreviewLayer(session: self.session) }()
    
    weak var delegate: QRCodeReaderDelegate?
    var completionBlock: ((String?) -> ())?
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    required init(cancelButtonTitle: String) {
        super.init()
        
        setupUIComponentsWithCancelButtonTitle(cancelButtonTitle)
        setupAutoLayoutConstraints()
        configureComponents()
        
        view.backgroundColor = UIColor.blackColor()
        
        cameraView.layer.insertSublayer(previewLayer, atIndex: 0)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        startScanning()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "orientationDidChanged:", name: UIDeviceOrientationDidChangeNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        stopScanning()
        
        super.viewWillDisappear(animated)
    }
    
    // MARK: - Managing the Orientation
    
    func orientationDidChanged(notification: NSNotification) {
        var interfaceOrientation: UIInterfaceOrientation = .Portrait
        switch (UIDevice.currentDevice().orientation) {
        case .LandscapeLeft:
            interfaceOrientation = .LandscapeRight
        case .LandscapeRight:
            interfaceOrientation = .LandscapeLeft
        case .PortraitUpsideDown:
            interfaceOrientation = .PortraitUpsideDown
        default:
            interfaceOrientation = .Portrait
        }
        
        previewLayer.connection.videoOrientation = QRCodeReader.videoOrientationFromInterfaceOrientation(interfaceOrientation)
    }
    
    class func videoOrientationFromInterfaceOrientation(interfaceOrientation: UIInterfaceOrientation) -> AVCaptureVideoOrientation {
        switch (interfaceOrientation) {
        case .LandscapeLeft:
            return .LandscapeLeft
        case .LandscapeRight:
            return .LandscapeRight
        case .Portrait:
            return .Portrait
        default:
            return .PortraitUpsideDown
        }
    }
    
    // MARK: - Initializing the AV Components
    
    private func setupUIComponentsWithCancelButtonTitle(cancelButtonTitle: String) {
        cameraView.clipsToBounds = true
        cameraView.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.addSubview(cameraView)
        
        cancelButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        cancelButton.setTitle(cancelButtonTitle, forState: .Normal)
        cancelButton.setTitleColor(UIColor.grayColor(), forState: .Highlighted)
        cancelButton.addTarget(self, action: "cancelAction:", forControlEvents: .TouchUpInside)
        view.addSubview(cancelButton)
    }
    
    private func setupAutoLayoutConstraints() {
        let views: [NSObject: AnyObject] = [ "cameraView": cameraView, "cancelButton": cancelButton ]
        
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[cameraView][cancelButton(40)]|", options: .allZeros, metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[cameraView]|", options: .allZeros, metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[cancelButton]-|", options: .allZeros, metrics: nil, views: views))
    }
    
    private func configureComponents() {
        session.addOutput(metadataOutput)
        session.addInput(deviceInput)
        metadataOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
        metadataOutput.metadataObjectTypes = [ AVMetadataObjectTypeQRCode ]
        previewLayer.videoGravity          = AVLayerVideoGravityResizeAspectFill
        previewLayer.frame                 = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height)
        
        if previewLayer.connection.supportsVideoOrientation {
            previewLayer.connection.videoOrientation = QRCodeReader.videoOrientationFromInterfaceOrientation(interfaceOrientation)
        }
    }
    
    // MARK: - Controlling Reader
    
    private func startScanning() {
        if !session.running {
            session.startRunning()
        }
    }
    
    private func stopScanning() {
        if session.running {
            session.stopRunning()
        }
    }
    
    // MARK: - Catching Button Events
    
    func cancelAction(button: UIButton) {
        stopScanning()
        
        if let _completionBlock = completionBlock {
            _completionBlock(nil)
        }
        
        delegate?.readerDidCancel(self)
    }
    
    // MARK: - AVCaptureMetadataOutputObjects Delegate Methods
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        for current in metadataObjects {
            if let _readableCodeObject = current as? AVMetadataMachineReadableCodeObject {
                if _readableCodeObject.type == AVMetadataObjectTypeQRCode {
                    let scannedResult: String = _readableCodeObject.stringValue
                    
                    if let _completionBlock = completionBlock {
                        _completionBlock(scannedResult)
                    }

                    delegate?.reader(self, didScanResult: scannedResult)
                }
            }
        }
    }
}

protocol QRCodeReaderDelegate: class {
    func reader(reader: QRCodeReader, didScanResult result: String)
    func readerDidCancel(reader: QRCodeReader)
}
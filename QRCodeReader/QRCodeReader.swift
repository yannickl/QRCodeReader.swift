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

/// Reader object base on the `AVCaptureDevice` to read / scan 1D and 2D codes.
public final class QRCodeReader: NSObject, AVCaptureMetadataOutputObjectsDelegate {
  var defaultDevice: AVCaptureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
  var frontDevice: AVCaptureDevice?  = {
    for device in AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo) {
      if let _device = device as? AVCaptureDevice where _device.position == AVCaptureDevicePosition.Front {
        return _device
      }
    }

    return nil
    }()

  lazy var defaultDeviceInput: AVCaptureDeviceInput? = {
    return try? AVCaptureDeviceInput(device: self.defaultDevice)
    }()

  lazy var frontDeviceInput: AVCaptureDeviceInput?  = {
    if let _frontDevice = self.frontDevice {
      return try? AVCaptureDeviceInput(device: _frontDevice)
    }

    return nil
    }()

  var metadataOutput = AVCaptureMetadataOutput()
  var session        = AVCaptureSession()

  // MARK: - Managing the Properties

  /// CALayer that you use to display video as it is being captured by an input device.
  public lazy var previewLayer: AVCaptureVideoPreviewLayer = { return AVCaptureVideoPreviewLayer(session: self.session) }()

  /// An array of strings identifying the types of metadata objects to process.
  public let metadataObjectTypes: [String]

  // MARK: - Managing the Completion Block

  /// Block is executing when a QRCode or when the user did stopped the scan.
  public var completionBlock: (QRCodeReaderResult -> Void)?

  // MARK: - Creating the Code Reader

  /**
  Initializes the code reader with the QRCode metadata type object.
  */
  public convenience override init() {
    self.init(metadataObjectTypes: [AVMetadataObjectTypeQRCode])
  }

  /**
  Initializes the code reader with an array of metadata object types.

  - parameter metadataObjectTypes: An array of strings identifying the types of metadata objects to process.
  */
  public init(metadataObjectTypes types: [String]) {
    metadataObjectTypes = types

    super.init()

    configureDefaultComponents()
  }

  // MARK: - Initializing the AV Components

  private func configureDefaultComponents() {
    session.addOutput(metadataOutput)

    if let _defaultDeviceInput = defaultDeviceInput {
      session.addInput(_defaultDeviceInput)
    }

    metadataOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
    metadataOutput.metadataObjectTypes = metadataObjectTypes
    previewLayer.videoGravity          = AVLayerVideoGravityResizeAspectFill
  }

  /// Switch between the back and the front camera.
  public func switchDeviceInput() {
    if let _frontDeviceInput = frontDeviceInput {
      session.beginConfiguration()

      if let _currentInput = session.inputs.first as? AVCaptureDeviceInput {
        session.removeInput(_currentInput)

        let newDeviceInput = (_currentInput.device.position == .Front) ? defaultDeviceInput : _frontDeviceInput
        session.addInput(newDeviceInput)
      }

      session.commitConfiguration()
    }
  }

  // MARK: - Controlling Reader

  /// Starts scanning the codes.
  public func startScanning() {
    if !session.running {
      session.startRunning()
    }
  }

  /// Stops scanning the codes.
  public func stopScanning() {
    if session.running {
      session.stopRunning()
    }
  }

  /**
  Indicates whether the session is currently running.

  The value of this property is a Bool indicating whether the receiver is running.
  Clients can key value observe the value of this property to be notified when
  the session automatically starts or stops running.
  */
  public var running: Bool {
    get {
      return session.running
    }
  }

  /**
  Returns true whether a front device is available.

  - returns: true whether the device has a front device.
  */
  public func hasFrontDevice() -> Bool {
    return frontDevice != nil
  }

  /**
  Returns true whether a torch is available.

  - returns: true if a torch is available.
  */
  public func isTorchAvailable() -> Bool {
    return defaultDevice.torchAvailable
  }

  /**
  Toggles torch on the default device.
  */
  public func toggleTorch() {
    do {
      try defaultDevice.lockForConfiguration()

      let current              = defaultDevice.torchMode
      defaultDevice.torchMode = AVCaptureTorchMode.On == current ? .Off : .On

      defaultDevice.unlockForConfiguration()
    }
    catch _ { }
  }

  // MARK: - Managing the Orientation

  /**
  Returns the video orientation correspongind to the given interface orientation.

  - parameter orientation: The orientation of the app's user interface.
  */
  public class func videoOrientationFromInterfaceOrientation(orientation: UIInterfaceOrientation) -> AVCaptureVideoOrientation {
    switch (orientation) {
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

  // MARK: - Checking the Reader Availabilities

  /**
  Checks whether the reader is available.

  - returns: A boolean value that indicates whether the reader is available.
  */
  public class func isAvailable() -> Bool {
    if AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo).count == 0 {
      return false
    }

    do {
      let captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
      let _             = try AVCaptureDeviceInput(device: captureDevice)

      return true
    } catch _ {
      return false
    }
  }

  /**
  Checks and return whether the given metadata object types are supported by the current device.

  - parameter metadataTypes: An array of strings identifying the types of metadata objects to check.

  - returns: A boolean value that indicates whether the device supports the given metadata object types.
  */
  public class func supportsMetadataObjectTypes(metadataTypes: [String]? = nil) -> Bool {
    if !isAvailable() {
      return false
    }

    // Setup components
    let captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
    let deviceInput   = try! AVCaptureDeviceInput(device: captureDevice)
    let output        = AVCaptureMetadataOutput()
    let session       = AVCaptureSession()

    session.addInput(deviceInput)
    session.addOutput(output)

    var metadataObjectTypes = metadataTypes

    if metadataObjectTypes == nil || metadataObjectTypes?.count == 0 {
      // Check the QRCode metadata object type by default
      metadataObjectTypes = [AVMetadataObjectTypeQRCode]
    }

    for metadataObjectType in metadataObjectTypes! {
      if !output.availableMetadataObjectTypes.contains({ $0 as! String == metadataObjectType }) {
        return false
      }
    }

    return true
  }

  // MARK: - AVCaptureMetadataOutputObjects Delegate Methods

  public func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
    for current in metadataObjects {
      if let _readableCodeObject = current as? AVMetadataMachineReadableCodeObject {
        if metadataObjectTypes.contains(_readableCodeObject.type) {
          stopScanning()

          let scannedResult = QRCodeReaderResult(value: _readableCodeObject.stringValue, metadataType:_readableCodeObject.type)

          dispatch_async(dispatch_get_main_queue(), { [weak self] in
            self?.completionBlock?(scannedResult)
          })
        }
      }
    }
  }
}

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
  var defaultDevice: AVCaptureDevice = .defaultDevice(withMediaType: AVMediaTypeVideo)
  var frontDevice: AVCaptureDevice?  = {
    if #available(iOS 10, *) {
      return AVCaptureDevice.defaultDevice(withDeviceType: .builtInWideAngleCamera, mediaType: AVMediaTypeVideo, position: .front)
    }
    else {
      for device in AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo) {
        if let _device = device as? AVCaptureDevice , _device.position == AVCaptureDevicePosition.front {
          return _device
        }
      }
    }

    return nil
  }()

  lazy var defaultDeviceInput: AVCaptureDeviceInput? = {
    return try? AVCaptureDeviceInput(device: self.defaultDevice)
  }()

  lazy var frontDeviceInput: AVCaptureDeviceInput? = {
    if let _frontDevice = self.frontDevice {
      return try? AVCaptureDeviceInput(device: _frontDevice)
    }

    return nil
  }()

  var metadataOutput = AVCaptureMetadataOutput()
  var session        = AVCaptureSession()

  // MARK: - Managing the Properties

  /// CALayer that you use to display video as it is being captured by an input device.
  public lazy var previewLayer: AVCaptureVideoPreviewLayer = {
    return AVCaptureVideoPreviewLayer(session: self.session)
  }()

  /// An array of strings identifying the types of metadata objects to process.
  public let metadataObjectTypes: [String]

  // MARK: - Managing the Code Discovery

  /// Flag to know whether the scanner should stop scanning when a code is found. (default: true)
  public var stopScanningWhenCodeIsFound = true

  /// Flag to buzz when a code is found (default: false)
  public var buzzWhenCodeIsFound = false
  
  /// Block to execute when a metadata object is found.
  public var didFindCode: ((QRCodeReaderResult) -> Void)?
  
  /// Block to execute when corners are found
  public var didFindCorners: (([CGPoint]) -> Void)?

  // MARK: - Creating the Code Reader

  /**
   Initializes the code reader with the QRCode metadata type object.
   */
  public convenience override init() {
    self.init(metadataObjectTypes: [AVMetadataObjectTypeQRCode], captureDevicePosition: .back)
  }

  /**
   Initializes the code reader with an array of metadata object types, and the default initial capture position

   - parameter metadataObjectTypes: An array of strings identifying the types of metadata objects to process.
   */
  public convenience init(metadataObjectTypes types: [String]) {
    self.init(metadataObjectTypes: types, captureDevicePosition: .back)
  }

  /**
   Initializes the code reader with the starting capture device position, and the default array of metadata object types

   - parameter captureDevicePosition: The capture position to use on start of scanning
   */
  public convenience init(captureDevicePosition position: AVCaptureDevicePosition) {
    self.init(metadataObjectTypes: [AVMetadataObjectTypeQRCode], captureDevicePosition: position)
  }

  /**
   Initializes the code reader with an array of metadata object types.

   - parameter metadataObjectTypes: An array of strings identifying the types of metadata objects to process.
   - parameter captureDevicePosition: The Camera to use on start of scanning.
   */
  public init(metadataObjectTypes types: [String], captureDevicePosition: AVCaptureDevicePosition) {
    metadataObjectTypes = types

    super.init()

    configureDefaultComponents(withCaptureDevicePosition: captureDevicePosition)
  }

  // MARK: - Initializing the AV Components

  private func configureDefaultComponents(withCaptureDevicePosition: AVCaptureDevicePosition) {
    session.addOutput(metadataOutput)

    switch withCaptureDevicePosition {
    case .front:
      if let _frontDeviceInput = frontDeviceInput {
        session.addInput(_frontDeviceInput)
      }
    case .back, .unspecified:
      if let _defaultDeviceInput = defaultDeviceInput {
        session.addInput(_defaultDeviceInput)
      }
    }


    metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
    metadataOutput.metadataObjectTypes = metadataObjectTypes
    previewLayer.videoGravity          = AVLayerVideoGravityResizeAspectFill
  }

  /// Switch between the back and the front camera.
  @discardableResult
  public func switchDeviceInput() -> AVCaptureDeviceInput? {
    if let _frontDeviceInput = frontDeviceInput {
      session.beginConfiguration()

      if let _currentInput = session.inputs.first as? AVCaptureDeviceInput {
        session.removeInput(_currentInput)

        let newDeviceInput = (_currentInput.device.position == .front) ? defaultDeviceInput : _frontDeviceInput
        session.addInput(newDeviceInput)
      }

      session.commitConfiguration()
    }
    return session.inputs.first as? AVCaptureDeviceInput
  }

  // MARK: - Controlling Reader

  /**
   Starts scanning the codes.

   *Notes: if `stopScanningWhenCodeIsFound` is sets to true (default behaviour), each time the scanner found a code it calls the `stopScanning` method.*
   */
  public func startScanning() {
    if !session.isRunning {
      session.startRunning()
    }
  }

  /// Stops scanning the codes.
  public func stopScanning() {
    if session.isRunning {
      session.stopRunning()
    }
  }

  /**
   Indicates whether the session is currently running.

   The value of this property is a Bool indicating whether the receiver is running.
   Clients can key value observe the value of this property to be notified when
   the session automatically starts or stops running.
   */
  public var isRunning: Bool {
    return session.isRunning
  }

  /**
   Indicates whether a front device is available.

   - returns: true whether the device has a front device.
   */
  public var hasFrontDevice: Bool {
    return frontDevice != nil
  }

  /**
   Indicates whether the torch is available.

   - returns: true if a torch is available.
   */
  public var isTorchAvailable: Bool {
    return defaultDevice.isTorchAvailable
  }

  /**
   Toggles torch on the default device.
   */
  public func toggleTorch() {
    do {
      try defaultDevice.lockForConfiguration()

      let current             = defaultDevice.torchMode
      defaultDevice.torchMode = AVCaptureTorchMode.on == current ? .off : .on

      defaultDevice.unlockForConfiguration()
    }
    catch _ { }
  }

  // MARK: - Managing the Orientation

  /**
   Returns the video orientation corresponding to the given device orientation.

   - parameter orientation: The orientation of the app's user interface.
   - parameter supportedOrientations: The supported orientations of the application.
   - parameter fallbackOrientation: The video orientation if the device orientation is FaceUp or FaceDown.
   */
  public class func videoOrientation(deviceOrientation orientation: UIDeviceOrientation, withSupportedOrientations supportedOrientations: UIInterfaceOrientationMask, fallbackOrientation: AVCaptureVideoOrientation? = nil) -> AVCaptureVideoOrientation {
    let result: AVCaptureVideoOrientation

    switch (orientation, fallbackOrientation) {
    case (.landscapeLeft, _):
      result = .landscapeRight
    case (.landscapeRight, _):
      result = .landscapeLeft
    case (.portrait, _):
      result = .portrait
    case (.portraitUpsideDown, _):
      result = .portraitUpsideDown
    case (_, .some(let orientation)):
      result = orientation
    default:
      result = .portrait
    }

    if supportedOrientations.contains(orientationMask(videoOrientation: result)) {
      return result
    }
    else if let orientation = fallbackOrientation , supportedOrientations.contains(orientationMask(videoOrientation: orientation)) {
      return orientation
    }
    else if supportedOrientations.contains(.portrait) {
      return .portrait
    }
    else if supportedOrientations.contains(.landscapeLeft) {
      return .landscapeLeft
    }
    else if supportedOrientations.contains(.landscapeRight) {
      return .landscapeRight
    }
    else {
      return .portraitUpsideDown
    }
  }

  class func orientationMask(videoOrientation orientation: AVCaptureVideoOrientation) -> UIInterfaceOrientationMask {
    switch orientation {
    case .landscapeLeft:
      return .landscapeLeft
    case .landscapeRight:
      return .landscapeRight
    case .portrait:
      return .portrait
    case .portraitUpsideDown:
      return .portraitUpsideDown
    }
  }

  // MARK: - Checking the Reader Availabilities

  /**
   Checks whether the reader is available.

   - returns: A boolean value that indicates whether the reader is available.
   */
  public class func isAvailable() -> Bool {
    let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)

    return (try? AVCaptureDeviceInput(device: captureDevice)) != nil
  }

  /**
   Checks and return whether the given metadata object types are supported by the current device.

   - parameter metadataTypes: An array of strings identifying the types of metadata objects to check.

   - returns: A boolean value that indicates whether the device supports the given metadata object types.
   */
  public class func supportsMetadataObjectTypes(_ metadataTypes: [String]? = nil) -> Bool {
    let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)

    guard let deviceInput = try? AVCaptureDeviceInput(device: captureDevice) else { return false }

    let output  = AVCaptureMetadataOutput()
    let session = AVCaptureSession()

    session.addInput(deviceInput)
    session.addOutput(output)

    var metadataObjectTypes = metadataTypes

    if metadataObjectTypes == nil || metadataObjectTypes?.count == 0 {
      // Check the QRCode metadata object type by default
      metadataObjectTypes = [AVMetadataObjectTypeQRCode]
    }

    for metadataObjectType in metadataObjectTypes! {
      if !output.availableMetadataObjectTypes.contains(where: { $0 as! String == metadataObjectType }) {
        return false
      }
    }

    return true
  }

  // MARK: - AVCaptureMetadataOutputObjects Delegate Methods


  public func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
    for current in metadataObjects {
      if let _readableCodeObject = current as? AVMetadataMachineReadableCodeObject {
        if metadataObjectTypes.contains(_readableCodeObject.type) {
          if stopScanningWhenCodeIsFound {
            stopScanning()
          }
          
          if buzzWhenCodeIsFound {
              AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
          }

          // convert corners coordinates to our view
          if let meta = previewLayer.transformedMetadataObject(for: _readableCodeObject) as? AVMetadataMachineReadableCodeObject {
            var points:[CGPoint] = []
            if let corners = meta.corners {
              points = corners.map {
                let dict = $0 as! CFDictionary
                return CGPoint(dictionaryRepresentation: dict)!
              }
              DispatchQueue.main.async(execute: { [weak self] in
                self?.didFindCorners?(points)
              })
            }
            
          }
          
          let scannedResult = QRCodeReaderResult(value: _readableCodeObject.stringValue, metadataType:_readableCodeObject.type)
          
          DispatchQueue.main.async(execute: { [weak self] in
            self?.didFindCode?(scannedResult)
            })
        }
      }
    }
  }
}

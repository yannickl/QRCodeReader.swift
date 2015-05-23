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
  private var defaultDevice: AVCaptureDevice? = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
  private var frontDevice: AVCaptureDevice?   = {
    for device in AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo) {
      if let _device = device as? AVCaptureDevice {
        if _device.position == AVCaptureDevicePosition.Front {
          return _device
        }
      }
    }

    return nil
    }()
  private lazy var defaultDeviceInput: AVCaptureDeviceInput? = {
    if let _defaultDevice = self.defaultDevice {
      return AVCaptureDeviceInput(device: _defaultDevice, error: nil)
    }

    return nil
    }()
  private lazy var frontDeviceInput: AVCaptureDeviceInput?  = {
    if let _frontDevice = self.frontDevice {
      return AVCaptureDeviceInput(device: _frontDevice, error: nil)
    }

    return nil
    }()
  private var metadataOutput = AVCaptureMetadataOutput()
  private var session        = AVCaptureSession()

  // MARK: - Managing the Properties

  /// CALayer that you use to display video as it is being captured by an input device.
  public lazy var previewLayer: AVCaptureVideoPreviewLayer = { return AVCaptureVideoPreviewLayer(session: self.session) }()

  /// An array of strings identifying the types of metadata objects to process.
  public let metadataObjectTypes: [String]

  // MARK: - Managing the Completion Block

  /// Block is executing when a QRCode or when the user did stopped the scan.
  public var completionBlock: ((String?) -> ())?

  // MARK: - Creating the Code Reader

  /**
  Initializes the code reader with an array of metadata object types.

  :param: metadataObjectTypes An array of strings identifying the types of metadata objects to process.
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

  :returns: true whether the device has a front device.
  */
  public func hasFrontDevice() -> Bool {
    return frontDevice != nil
  }

  // MARK: - Managing the Orientation

  /**
  Returns the video orientation correspongind to the given interface orientation.

  :param: orientation The orientation of the app's user interface.
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

  :returns: A boolean value that indicates whether the reader is available.
  */
  class func isAvailable() -> Bool {
    let videoDevices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)

    if videoDevices.count == 0 {
      return false
    }

    let captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo) as AVCaptureDevice

    var error: NSError?
    let deviceInput = AVCaptureDeviceInput.deviceInputWithDevice(captureDevice, error: &error) as! AVCaptureDeviceInput

    if let _error = error {
      return false
    }

    return true
  }

  /**
  Checks and return whether the given metadata object types are supported by the current device.

  :param: metadataTypes An array of strings identifying the types of metadata objects to check.

  :returns: A boolean value that indicates whether the device supports the given metadata object types.
  */
  public class func supportsMetadataObjectTypes(_ metadataTypes: [String]? = nil) -> Bool {
    if !isAvailable() {
      return false
    }

    // Setup components
    let captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo) as AVCaptureDevice
    let deviceInput   = AVCaptureDeviceInput.deviceInputWithDevice(captureDevice, error: nil) as! AVCaptureDeviceInput
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
      if !contains(output.availableMetadataObjectTypes, { $0 as! String == metadataObjectType }) {
        return false
      }
    }

    return true
  }

  // MARK: - AVCaptureMetadataOutputObjects Delegate Methods

  public func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
    for current in metadataObjects {
      if let _readableCodeObject = current as? AVMetadataMachineReadableCodeObject {
        if contains(metadataObjectTypes, _readableCodeObject.type) {
          stopScanning()

          let scannedResult = _readableCodeObject.stringValue

          if let _completionBlock = completionBlock {
            _completionBlock(scannedResult)
          }
        }
      }
    }
  }
}

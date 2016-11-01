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

/// Convenient controller to display a view to scan/read 1D or 2D bar codes like the QRCodes. It is based on the `AVFoundation` framework from Apple. It aims to replace ZXing or ZBar for iOS 7 and over.
public class QRCodeReaderViewController: UIViewController {
  /// The code reader object used to scan the bar code.
  public let codeReader: QRCodeReader

  let readerView: QRCodeReaderContainer
  let startScanningAtLoad: Bool
  let showCancelButton: Bool
  let showSwitchCameraButton: Bool
  let showTorchButton: Bool

  // MARK: - Managing the Callback Responders

  /// The receiver's delegate that will be called when a result is found.
  public weak var delegate: QRCodeReaderViewControllerDelegate?

  /// The completion blocak that will be called when a result is found.
  public var completionBlock: ((QRCodeReaderResult?) -> Void)?

  deinit {
    codeReader.stopScanning()

    NSNotificationCenter.defaultCenter().removeObserver(self)
  }

  // MARK: - Creating the View Controller

  /**
   Initializes a view controller using a builder.

   - parameter builder: A QRCodeViewController builder object.
   */
  required public init(builder: QRCodeReaderViewControllerBuilder) {
    readerView             = builder.readerView
    startScanningAtLoad    = builder.startScanningAtLoad
    codeReader             = builder.reader
    showCancelButton       = builder.showCancelButton
    showSwitchCameraButton = builder.showSwitchCameraButton
    showTorchButton        = builder.showTorchButton

    super.init(nibName: nil, bundle: nil)

    view.backgroundColor = .blackColor()

    codeReader.didFindCodeBlock = { [weak self] resultAsObject in
      if let weakSelf = self {
        weakSelf.completionBlock?(resultAsObject)
        weakSelf.delegate?.reader(weakSelf, didScanResult: resultAsObject)
      }
    }

    setupUIComponentsWithCancelButtonTitle(builder.cancelButtonTitle)

    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(orientationDidChange), name: UIDeviceOrientationDidChangeNotification, object: nil)
    }

  required public init?(coder aDecoder: NSCoder) {
    codeReader             = QRCodeReader()
    readerView             = QRCodeReaderContainer(displayable: QRCodeReaderView())
    startScanningAtLoad    = false
    showCancelButton       = false
    showTorchButton        = false
    showSwitchCameraButton = false

    super.init(coder: aDecoder)
  }

  // MARK: - Responding to View Events
  public override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
    return parentViewController?.supportedInterfaceOrientations() ?? .All
  }

  public override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

    if startScanningAtLoad {
      startScanning()
    }
  }

  public override func viewWillDisappear(animated: Bool) {
    stopScanning()

    super.viewWillDisappear(animated)
  }

  public override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()

    codeReader.previewLayer.frame = view.bounds
  }

  // MARK: - Managing the Orientation

  func orientationDidChange(notification: NSNotification) {
    readerView.view.setNeedsDisplay()

    if let device = notification.object as? UIDevice where codeReader.previewLayer.connection.supportsVideoOrientation {
        codeReader.previewLayer.connection.videoOrientation = QRCodeReader.videoOrientationFromDeviceOrientation(device.orientation, withSupportedOrientations: supportedInterfaceOrientations(), fallbackOrientation: codeReader.previewLayer.connection.videoOrientation)
    }
  }

  // MARK: - Initializing the AV Components

  private func setupUIComponentsWithCancelButtonTitle(cancelButtonTitle: String) {
    view.addSubview(readerView.view)

    let sscb = showSwitchCameraButton && codeReader.hasFrontDevice()
    let stb  = showTorchButton && codeReader.isTorchAvailable()
    
    readerView.setupComponents(showCancelButton, showSwitchCameraButton: sscb, showTorchButton: stb)

    // Setup action methods

    readerView.displayable.switchCameraButton?.addTarget(self, action: #selector(switchCameraAction), forControlEvents: .TouchUpInside)
    readerView.displayable.toggleTorchButton?.addTarget(self, action: #selector(toggleTorchAction), forControlEvents: .TouchUpInside)
    readerView.displayable.cancelButton?.setTitle(cancelButtonTitle, forState: .Normal)
    readerView.displayable.cancelButton?.addTarget(self, action: #selector(cancelAction), forControlEvents: .TouchUpInside)

    // Setup camera preview layer
    codeReader.previewLayer.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)

    if codeReader.previewLayer.connection.supportsVideoOrientation {
      let orientation = UIDevice.currentDevice().orientation

      codeReader.previewLayer.connection.videoOrientation = QRCodeReader.videoOrientationFromDeviceOrientation(orientation, withSupportedOrientations: supportedInterfaceOrientations())
    }

    readerView.displayable.cameraView.layer.insertSublayer(codeReader.previewLayer, atIndex: 0)

    // Setup constraints

    for attribute in [NSLayoutAttribute.Left, NSLayoutAttribute.Top, NSLayoutAttribute.Right, NSLayoutAttribute.Bottom] {
      view.addConstraint(NSLayoutConstraint(item: readerView.view, attribute: attribute, relatedBy: .Equal, toItem: view, attribute: attribute, multiplier: 1, constant: 0))
    }
  }

  // MARK: - Controlling the Reader

  /// Starts scanning the codes.
  public func startScanning() {
    codeReader.startScanning()
  }

  /// Stops scanning the codes.
  public func stopScanning() {
    codeReader.stopScanning()
  }

  // MARK: - Catching Button Events

  func cancelAction(button: UIButton) {
    codeReader.stopScanning()

    if let _completionBlock = completionBlock {
      _completionBlock(nil)
    }

    delegate?.readerDidCancel(self)
  }

  func switchCameraAction(button: SwitchCameraButton) {
    codeReader.switchDeviceInput()

  }

  func toggleTorchAction(button: ToggleTorchButton) {
    codeReader.toggleTorch()
  }
}

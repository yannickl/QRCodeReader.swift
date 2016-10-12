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
  private var cameraView   = ReaderOverlayView()
  private var cancelButton: UIButton?
  private var switchCameraButton: SwitchCameraButton?
  private var toggleTorchButton: ToggleTorchButton?

  /// The code reader object used to scan the bar code.
  public let codeReader: QRCodeReader

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

    NotificationCenter.default.removeObserver(self)
  }

  // MARK: - Creating the View Controller

  /**
   Initializes a view controller using a builder.

   - parameter builder: A QRCodeViewController builder object.
   */
  required public init(builder: QRCodeReaderViewControllerBuilder) {
    startScanningAtLoad    = builder.startScanningAtLoad
    codeReader             = builder.reader
    showCancelButton       = builder.showCancelButton
    showSwitchCameraButton = builder.showSwitchCameraButton
    showTorchButton        = builder.showTorchButton

    super.init(nibName: nil, bundle: nil)

    view.backgroundColor = .black

    codeReader.didFindCode = { [weak self] resultAsObject in
      if let weakSelf = self {
        weakSelf.completionBlock?(resultAsObject)
        weakSelf.delegate?.reader(weakSelf, didScanResult: resultAsObject)
      }
    }

    setupUIComponentsWithCancelButtonTitle(builder.cancelButtonTitle)
    setupAutoLayoutConstraints()

    cameraView.layer.insertSublayer(codeReader.previewLayer, at: 0)

    NotificationCenter.default.addObserver(self, selector: #selector(orientationDidChange), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
  }

  required public init?(coder aDecoder: NSCoder) {
    codeReader             = QRCodeReader()
    startScanningAtLoad    = false
    showCancelButton       = false
    showTorchButton        = false
    showSwitchCameraButton = false

    super.init(coder: aDecoder)
  }

  // MARK: - Responding to View Events
  override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    return parent?.supportedInterfaceOrientations ?? .all
  }

  override public func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    if startScanningAtLoad {
      startScanning()
    }
  }

  override public func viewWillDisappear(_ animated: Bool) {
    stopScanning()

    super.viewWillDisappear(animated)
  }

  override public func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()

    codeReader.previewLayer.frame = view.bounds
  }

  // MARK: - Managing the Orientation

  func orientationDidChange(_ notification: Notification) {
    cameraView.setNeedsDisplay()

    if let device = notification.object as? UIDevice , codeReader.previewLayer.connection.isVideoOrientationSupported {
      codeReader.previewLayer.connection.videoOrientation = QRCodeReader.videoOrientation(deviceOrientation: device.orientation, withSupportedOrientations: supportedInterfaceOrientations, fallbackOrientation: codeReader.previewLayer.connection.videoOrientation)
    }
  }

  // MARK: - Initializing the AV Components

  private func setupUIComponentsWithCancelButtonTitle(_ cancelButtonTitle: String) {
    cameraView.clipsToBounds = true
    cameraView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(cameraView)

    codeReader.previewLayer.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)

    if codeReader.previewLayer.connection.isVideoOrientationSupported {
      let orientation = UIDevice.current.orientation

      codeReader.previewLayer.connection.videoOrientation = QRCodeReader.videoOrientation(deviceOrientation: orientation, withSupportedOrientations: supportedInterfaceOrientations)
    }

    if showSwitchCameraButton && codeReader.hasFrontDevice {
      let newSwitchCameraButton = SwitchCameraButton()
      newSwitchCameraButton.translatesAutoresizingMaskIntoConstraints = false
      newSwitchCameraButton.addTarget(self, action: #selector(switchCameraAction), for: .touchUpInside)
      view.addSubview(newSwitchCameraButton)

      switchCameraButton = newSwitchCameraButton
    }

    if showTorchButton && codeReader.isTorchAvailable {
      let newToggleTorchButton = ToggleTorchButton()
      newToggleTorchButton.translatesAutoresizingMaskIntoConstraints = false
      newToggleTorchButton.addTarget(self, action: #selector(toggleTorchAction), for: .touchUpInside)
      view.addSubview(newToggleTorchButton)
      toggleTorchButton = newToggleTorchButton
    }

    if showCancelButton {
      let newCancelButton = UIButton()
      newCancelButton.translatesAutoresizingMaskIntoConstraints = false
      newCancelButton.setTitle(cancelButtonTitle, for: .normal)
      newCancelButton.setTitleColor(.gray, for: .highlighted)
      newCancelButton.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
      view.addSubview(newCancelButton)

      cancelButton = newCancelButton
    }
  }

  private func setupAutoLayoutConstraints() {
    let views = ["cameraView": cameraView]

    view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[cameraView]|", options: [], metrics: nil, views: views))
    
    if let _cancelButton = cancelButton {
      let cancelViews: [String: UIView] = ["cancelButton": _cancelButton, "cameraView": cameraView]

      view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[cameraView][cancelButton(40)]|", options: [], metrics: nil, views: cancelViews))
      view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[cancelButton]-|", options: [], metrics: nil, views: cancelViews))
    }
    else {
      view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[cameraView]|", options: [], metrics: nil, views: views))
    }

    if let _switchCameraButton = switchCameraButton {
      let switchViews: [String: AnyObject] = ["switchCameraButton": _switchCameraButton, "topGuide": topLayoutGuide]

      view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[topGuide]-[switchCameraButton(50)]", options: [], metrics: nil, views: switchViews))
      view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[switchCameraButton(70)]|", options: [], metrics: nil, views: switchViews))
    }

    if let _toggleTorchButton = toggleTorchButton {
      let toggleViews: [String: AnyObject] = ["toggleTorchButton": _toggleTorchButton, "topGuide": topLayoutGuide]

      view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[topGuide]-[toggleTorchButton(50)]", options: [], metrics: nil, views: toggleViews))
      view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[toggleTorchButton(70)]", options: [], metrics: nil, views: toggleViews))
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

  func cancelAction(_ button: UIButton) {
    codeReader.stopScanning()

    if let _completionBlock = completionBlock {
      _completionBlock(nil)
    }

    delegate?.readerDidCancel(self)
  }

  func switchCameraAction(_ button: SwitchCameraButton) {
    if let newDevice = codeReader.switchDeviceInput() {
      delegate?.reader(self, didSwitchCamera: newDevice)
    }
  }

  func toggleTorchAction(_ button: ToggleTorchButton) {
    codeReader.toggleTorch()
  }
}

/**
 This protocol defines delegate methods for objects that implements the `QRCodeReaderDelegate`. The methods of the protocol allow the delegate to be notified when the reader did scan result and or when the user wants to stop to read some QRCodes.
 */
public protocol QRCodeReaderViewControllerDelegate: class {
  /**
   Tells the delegate that the reader did scan a code.

   - parameter reader: A code reader object informing the delegate about the scan result.
   - parameter result: The result of the scan
   */
  func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult)

  /**
   Tells the delegate that the camera was switched by the user
   
   - parameter reader: A code reader object informing the delegate about the scan result.
   - parameter newCaptureDevice: The capture device that was switched to
   */
  func reader(_ reader: QRCodeReaderViewController, didSwitchCamera newCaptureDevice: AVCaptureDeviceInput)
  
  /**
   Tells the delegate that the user wants to stop scanning codes.

   - parameter reader: A code reader object informing the delegate about the cancellation.
   */
  func readerDidCancel(_ reader: QRCodeReaderViewController)

}

extension QRCodeReaderViewControllerDelegate {
  
  /**
   Default implementation that No-Ops this callBack
   
   - parameter reader: A code reader object informing the delegate about the scan result.
   - parameter newCaptureDevice: The capture device that was switched to
   */
  func reader(_ reader: QRCodeReaderViewController, didSwitchCamera newCaptureDevice: AVCaptureDeviceInput) {
    
  }
}

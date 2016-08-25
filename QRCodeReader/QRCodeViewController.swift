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
  private var cancelButton = UIButton()
  private var switchCameraButton: SwitchCameraButton?
  private var toggleTorchButton: ToggleTorchButton?

  /// The code reader object used to scan the bar code.
  public let codeReader: QRCodeReader

  let startScanningAtLoad: Bool
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
   Initializes a view controller to read QRCodes from a displayed video preview and a cancel button to be go back.

   - parameter cancelButtonTitle:   The title to use for the cancel button.
   - parameter startScanningAtLoad: Flag to know whether the view controller start scanning the codes when the view will appear.

   :see: init(cancelButtonTitle:, metadataObjectTypes:)
   */
  convenience public init(cancelButtonTitle: String, startScanningAtLoad: Bool = true) {
    self.init(cancelButtonTitle: cancelButtonTitle, metadataObjectTypes: [AVMetadataObjectTypeQRCode], startScanningAtLoad: startScanningAtLoad)
  }

  /**
   Initializes a reader view controller with a list of metadata object types.

   - parameter metadataObjectTypes: An array of strings identifying the types of metadata objects to process.
   - parameter startScanningAtLoad: Flag to know whether the view controller start scanning the codes when the view will appear.

   :see: init(cancelButtonTitle:, metadataObjectTypes:)
   */
  convenience public init(metadataObjectTypes: [String], startScanningAtLoad: Bool = true) {
    self.init(cancelButtonTitle: "Cancel", metadataObjectTypes: metadataObjectTypes, startScanningAtLoad: startScanningAtLoad)
  }

  /**
   Initializes a view controller to read wanted metadata object types from a displayed video preview and a cancel button to be go back.

   - parameter cancelButtonTitle:   The title to use for the cancel button.
   - parameter metadataObjectTypes: An array of strings identifying the types of metadata objects to process.
   - parameter startScanningAtLoad: Flag to know whether the view controller start scanning the codes when the view will appear.

   :see: init(cancelButtonTitle:, coderReader:, startScanningAtLoad:)
   */
  convenience public init(cancelButtonTitle: String, metadataObjectTypes: [String], startScanningAtLoad: Bool = true) {
    let reader = QRCodeReader(metadataObjectTypes: metadataObjectTypes)

    self.init(cancelButtonTitle: cancelButtonTitle, codeReader: reader, startScanningAtLoad: startScanningAtLoad)
  }

  /**
   Initializes a view controller using a cancel button title and a code reader.

   - parameter cancelButtonTitle:   The title to use for the cancel button.
   - parameter codeReader:          The code reader object used to scan the bar code.
   - parameter startScanningAtLoad: Flag to know whether the view controller start scanning the codes when the view will appear.
   - parameter showSwitchCameraButton: Flag to display the switch camera button.
   - parameter showTorchButton: Flag to display the toggle torch button. If the value is true and there is no torch the button will not be displayed.
   */
  public convenience init(cancelButtonTitle: String, codeReader reader: QRCodeReader, startScanningAtLoad startScan: Bool = true, showSwitchCameraButton showSwitch: Bool = true, showTorchButton showTorch: Bool = false) {
    self.init(builder: QRCodeViewControllerBuilder { builder in
      builder.cancelButtonTitle      = cancelButtonTitle
      builder.reader                 = reader
      builder.startScanningAtLoad    = startScan
      builder.showSwitchCameraButton = showSwitch
      builder.showTorchButton        = showTorch
      })
  }

  /**
   Initializes a view controller using a builder.

   - parameter builder: A QRCodeViewController builder object.
   */
  required public init(builder: QRCodeViewControllerBuilder) {
    startScanningAtLoad    = builder.startScanningAtLoad
    codeReader             = builder.reader
    showSwitchCameraButton = builder.showSwitchCameraButton
    showTorchButton        = builder.showTorchButton

    super.init(nibName: nil, bundle: nil)

    view.backgroundColor = UIColor.black

    codeReader.didFindCode = { [weak self] resultAsObject in
      if let weakSelf = self {
        weakSelf.completionBlock?(resultAsObject)
        weakSelf.delegate?.reader(weakSelf, didScanResult: resultAsObject)
      }
    }

    setupUIComponentsWithCancelButtonTitle(builder.cancelButtonTitle)
    setupAutoLayoutConstraints()

    cameraView.layer.insertSublayer(codeReader.previewLayer, at: 0)

    NotificationCenter.default.addObserver(self, selector: #selector(orientationDidChanged), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
  }

  required public init?(coder aDecoder: NSCoder) {
    codeReader             = QRCodeReader(metadataObjectTypes: [])
    startScanningAtLoad    = false
    showTorchButton        = false
    showSwitchCameraButton = false

    super.init(coder: aDecoder)
  }

  // MARK: - Responding to View Events

//  public override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
//    return parent?.supportedInterfaceOrientations ?? .all
//  }

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

  func orientationDidChanged(_ notification: Notification) {
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

    cancelButton.translatesAutoresizingMaskIntoConstraints = false
    cancelButton.setTitle(cancelButtonTitle, for: UIControlState())
    cancelButton.setTitleColor(UIColor.gray, for: .highlighted)
    cancelButton.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
    view.addSubview(cancelButton)
  }

  private func setupAutoLayoutConstraints() {
    let views = ["cameraView": cameraView, "cancelButton": cancelButton] as [String : Any]

    view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[cameraView][cancelButton(40)]|", options: [], metrics: nil, views: views))
    view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[cameraView]|", options: [], metrics: nil, views: views))
    view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[cancelButton]-|", options: [], metrics: nil, views: views))

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
    codeReader.switchDeviceInput()
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
   Tells the delegate that the user wants to stop scanning codes.
   
   - parameter reader: A code reader object informing the delegate about the cancellation.
   */
  func readerDidCancel(_ reader: QRCodeReaderViewController)
}

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
  private let builder: QRCodeReaderViewControllerBuilder

  /// The code reader object used to scan the bar code.
  public var codeReader: QRCodeReader {
    return builder.reader
  }

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
    self.builder = builder

    super.init(nibName: nil, bundle: nil)

    view.backgroundColor = .black

    codeReader.didFindCode = { [weak self] resultAsObject in
      if let weakSelf = self {
        if let qrv = builder.readerView.displayable as? QRCodeReaderView {
          qrv.addGreenBorder()
        }
        weakSelf.completionBlock?(resultAsObject)
        weakSelf.delegate?.reader(weakSelf, didScanResult: resultAsObject)
      }
    }

    codeReader.didFailDecoding = {
      if let qrv = builder.readerView.displayable as? QRCodeReaderView {
        qrv.addRedBorder()
      }
    }

    setupUIComponentsWithCancelButtonTitle(builder.cancelButtonTitle)
  }

  required public init?(coder aDecoder: NSCoder) {
    self.builder = QRCodeReaderViewControllerBuilder()

    super.init(coder: aDecoder)
  }

  // MARK: - Responding to View Events

  override public func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    if builder.startScanningAtLoad {
      builder.readerView.displayable.setNeedsUpdateOrientation()

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

  public override var preferredStatusBarStyle: UIStatusBarStyle {
    return builder.preferredStatusBarStyle ?? super.preferredStatusBarStyle
  }

  // MARK: - Initializing the AV Components

  private func setupUIComponentsWithCancelButtonTitle(_ cancelButtonTitle: String) {
    view.addSubview(builder.readerView.view)

    builder.readerView.view.translatesAutoresizingMaskIntoConstraints = false
    builder.readerView.setupComponents(with: builder)

    // Setup action methods

    builder.readerView.displayable.switchCameraButton?.addTarget(self, action: #selector(switchCameraAction), for: .touchUpInside)
    builder.readerView.displayable.toggleTorchButton?.addTarget(self, action: #selector(toggleTorchAction), for: .touchUpInside)
    builder.readerView.displayable.cancelButton?.setTitle(cancelButtonTitle, for: .normal)
    builder.readerView.displayable.cancelButton?.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)

    // Setup constraints

    for attribute in [.left, .top, .right] as [NSLayoutConstraint.Attribute] {
        NSLayoutConstraint(item: builder.readerView.view, attribute: attribute, relatedBy: .equal, toItem: view, attribute: attribute, multiplier: 1, constant: 0).isActive = true
    }
    
    if #available(iOS 11.0, *) {
        view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: builder.readerView.view.bottomAnchor).isActive = true
    }
    else {
        NSLayoutConstraint(item: builder.readerView.view, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
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

  @objc func cancelAction(_ button: UIButton) {
    codeReader.stopScanning()

    if let _completionBlock = completionBlock {
      _completionBlock(nil)
    }

    delegate?.readerDidCancel(self)
  }

  @objc func switchCameraAction(_ button: SwitchCameraButton) {
    if let newDevice = codeReader.switchDeviceInput() {
      delegate?.reader(self, didSwitchCamera: newDevice)
    }
  }
  
  @objc func toggleTorchAction(_ button: ToggleTorchButton) {
    codeReader.toggleTorch()
  }
}

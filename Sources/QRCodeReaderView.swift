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

final public class QRCodeReaderView: UIView, QRCodeReaderDisplayable {
  public lazy var overlayView: UIView? = {
    let ov = ReaderOverlayView()

    ov.backgroundColor                           = .clear
    ov.clipsToBounds                             = true
    ov.translatesAutoresizingMaskIntoConstraints = false

    return ov
  }()

  public let cameraView: UIView = {
    let cv = UIView()

    cv.clipsToBounds                             = true
    cv.translatesAutoresizingMaskIntoConstraints = false

    return cv
  }()

  public lazy var cancelButton: UIButton? = {
    let cb = UIButton()

    cb.translatesAutoresizingMaskIntoConstraints = false
    cb.setTitleColor(.gray, for: .highlighted)

    return cb
  }()

  public lazy var switchCameraButton: UIButton? = {
    let scb = SwitchCameraButton()

    scb.translatesAutoresizingMaskIntoConstraints = false

    return scb
  }()

  public lazy var toggleTorchButton: UIButton? = {
    let ttb = ToggleTorchButton()

    ttb.translatesAutoresizingMaskIntoConstraints = false

    return ttb
  }()

  private weak var reader: QRCodeReader?

  public func setupComponents(showCancelButton: Bool, showSwitchCameraButton: Bool, showTorchButton: Bool, showOverlayView: Bool, reader: QRCodeReader?) {
    self.reader               = reader
    reader?.lifeCycleDelegate = self

    addComponents()

    cancelButton?.isHidden       = !showCancelButton
    switchCameraButton?.isHidden = !showSwitchCameraButton
    toggleTorchButton?.isHidden  = !showTorchButton
    overlayView?.isHidden        = !showOverlayView

    guard let cb = cancelButton, let scb = switchCameraButton, let ttb = toggleTorchButton, let ov = overlayView else { return }

    let views = ["cv": cameraView, "ov": ov, "cb": cb, "scb": scb, "ttb": ttb]

    addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[cv]|", options: [], metrics: nil, views: views))

    if showCancelButton {
      addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[cv][cb(40)]|", options: [], metrics: nil, views: views))
      addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[cb]-|", options: [], metrics: nil, views: views))
    }
    else {
      addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[cv]|", options: [], metrics: nil, views: views))
    }

    if showSwitchCameraButton {
      addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[scb(50)]", options: [], metrics: nil, views: views))
      addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[scb(70)]|", options: [], metrics: nil, views: views))
    }

    if showTorchButton {
      addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[ttb(50)]", options: [], metrics: nil, views: views))
      addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[ttb(70)]", options: [], metrics: nil, views: views))
    }

    for attribute in Array<NSLayoutConstraint.Attribute>([.left, .top, .right, .bottom]) {
      addConstraint(NSLayoutConstraint(item: ov, attribute: attribute, relatedBy: .equal, toItem: cameraView, attribute: attribute, multiplier: 1, constant: 0))
    }
  }

  public override func layoutSubviews() {
    super.layoutSubviews()

    reader?.previewLayer.frame = bounds
  }

  // MARK: - Scan Result Indication

  func startTimerForBorderReset() {
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
      if let ovl = self.overlayView as? ReaderOverlayView {
        ovl.overlayColor = .white
      }
    }
  }

  func addRedBorder() {
    self.startTimerForBorderReset()

    if let ovl = self.overlayView as? ReaderOverlayView {
      ovl.overlayColor = .red
    }
  }

  func addGreenBorder() {
    self.startTimerForBorderReset()
    
    if let ovl = self.overlayView as? ReaderOverlayView {
      ovl.overlayColor = .green
    }
  }

  @objc public func setNeedsUpdateOrientation() {
    setNeedsDisplay()

    overlayView?.setNeedsDisplay()

    if let connection = reader?.previewLayer.connection, connection.isVideoOrientationSupported {
      let application                    = UIApplication.shared
      let orientation                    = UIDevice.current.orientation
      let supportedInterfaceOrientations = application.supportedInterfaceOrientations(for: application.keyWindow)

      connection.videoOrientation = QRCodeReader.videoOrientation(deviceOrientation: orientation, withSupportedOrientations: supportedInterfaceOrientations, fallbackOrientation: connection.videoOrientation)
    }
  }

  // MARK: - Convenience Methods

  private func addComponents() {
    NotificationCenter.default.addObserver(self, selector: #selector(self.setNeedsUpdateOrientation), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)

    addSubview(cameraView)

    if let ov = overlayView {
      addSubview(ov)
    }

    if let scb = switchCameraButton {
      addSubview(scb)
    }

    if let ttb = toggleTorchButton {
      addSubview(ttb)
    }
    
    if let cb = cancelButton {
      addSubview(cb)
    }

    if let reader = reader {
      cameraView.layer.insertSublayer(reader.previewLayer, at: 0)
      
      setNeedsUpdateOrientation()
    }
  }
}

extension QRCodeReaderView: QRCodeReaderLifeCycleDelegate {
  func readerDidStartScanning() {
    setNeedsUpdateOrientation()
  }

  func readerDidStopScanning() {}
}

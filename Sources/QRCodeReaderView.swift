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

final class QRCodeReaderView: UIView, QRCodeReaderDisplayable {
  lazy var overlayView: UIView? = {
    let ov = ReaderOverlayView()

    ov.backgroundColor                           = .clear
    ov.clipsToBounds                             = true
    ov.translatesAutoresizingMaskIntoConstraints = false

    return ov
  }()

  let cameraView: UIView = {
    let cv = UIView()

    cv.clipsToBounds                             = true
    cv.translatesAutoresizingMaskIntoConstraints = false

    return cv
  }()

  lazy var cancelButton: UIButton? = {
    let cb = UIButton()

    cb.translatesAutoresizingMaskIntoConstraints = false
    cb.setTitleColor(.gray, for: .highlighted)

    return cb
  }()

  lazy var switchCameraButton: UIButton? = {
    let scb = SwitchCameraButton()

    scb.translatesAutoresizingMaskIntoConstraints = false

    return scb
  }()

  lazy var toggleTorchButton: UIButton? = {
    let ttb = ToggleTorchButton()

    ttb.translatesAutoresizingMaskIntoConstraints = false

    return ttb
  }()

  func setupComponents(showCancelButton: Bool, showSwitchCameraButton: Bool, showTorchButton: Bool, showOverlayView: Bool) {
    translatesAutoresizingMaskIntoConstraints = false

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

    for attribute in Array<NSLayoutAttribute>([.left, .top, .right, .bottom]) {
      addConstraint(NSLayoutConstraint(item: ov, attribute: attribute, relatedBy: .equal, toItem: cameraView, attribute: attribute, multiplier: 1, constant: 0))
    }
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

  // MARK: - Convenience Methods

  private func addComponents() {
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
  }
}

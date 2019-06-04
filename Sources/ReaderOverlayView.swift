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

/// The overlay state
public enum QRCodeReaderViewOverlayState {
  /// The overlay is in normal state
  case normal
  /// The overlay is in valid state
  case valid
  /// The overlay is in wrong state
  case wrong
}

/// The overlay protocol
public protocol QRCodeReaderViewOverlay: UIView {
  /// Set the state of the overlay
  func setState(_ state: QRCodeReaderViewOverlayState)
}

/// Overlay over the camera view to display the area (a square) where to scan the code.
public final class ReaderOverlayView: UIView {
  private var overlay: CAShapeLayer = {
    var overlay             = CAShapeLayer()
    overlay.backgroundColor = UIColor.clear.cgColor
    overlay.fillColor       = UIColor.clear.cgColor
    overlay.strokeColor     = UIColor.white.cgColor
    overlay.lineWidth       = 3
    overlay.lineDashPattern = [7.0, 7.0]
    overlay.lineDashPhase   = 0

    return overlay
  }()
  
  private var state: QRCodeReaderViewOverlayState = .normal {
    didSet {
      switch state {
      case .normal:
        overlay.strokeColor = defaultColor.cgColor
      case .valid:
        overlay.strokeColor = highlightValidColor.cgColor
      case .wrong:
        overlay.strokeColor = highlightWrongColor.cgColor
      }
      
      setNeedsDisplay()
    }
  }
  
  /// The default overlay color
  public var defaultColor: UIColor = .white
  
  /// The overlay color when a valid code has been scanned
  public var highlightValidColor: UIColor = .green
  
  /// The overlay color when a wrong code has been scanned
  public var highlightWrongColor: UIColor = .red

  override init(frame: CGRect) {
    super.init(frame: frame)

    setupOverlay()
  }

  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)

    setupOverlay()
  }

  private func setupOverlay() {
    state = .normal
    
    layer.addSublayer(overlay)
  }

  var rectOfInterest: CGRect = CGRect(x: 0, y: 0, width: 1, height: 1) {
    didSet {
      setNeedsDisplay()
    }
  }

  public override func draw(_ rect: CGRect) {
    let innerRect = CGRect(
      x: rect.width * rectOfInterest.minX,
      y: rect.height * rectOfInterest.minY,
      width: rect.width * rectOfInterest.width,
      height: rect.height * rectOfInterest.height
    )

    overlay.path = UIBezierPath(roundedRect: innerRect, cornerRadius: 5).cgPath
  }
}

extension ReaderOverlayView: QRCodeReaderViewOverlay {
  public func setState(_ state: QRCodeReaderViewOverlayState) {
    self.state = state
  }
}

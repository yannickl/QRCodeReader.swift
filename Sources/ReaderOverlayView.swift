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

  override init(frame: CGRect) {
    super.init(frame: frame)

    setupOverlay()
  }

  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)

    setupOverlay()
  }

  private func setupOverlay() {
    layer.addSublayer(overlay)
  }

  var overlayColor: UIColor = UIColor.white {
    didSet {
      self.overlay.strokeColor = overlayColor.cgColor
      self.setNeedsDisplay()
    }
  }

  public override func draw(_ rect: CGRect) {
    var innerRect = rect.insetBy(dx: 50, dy: 50)
    let minSize   = min(innerRect.width, innerRect.height)

    if innerRect.width != minSize {
      innerRect.origin.x   += (innerRect.width - minSize) / 2
      innerRect.size.width = minSize
    }
    else if innerRect.height != minSize {
      innerRect.origin.y    += (innerRect.height - minSize) / 2
      innerRect.size.height = minSize
    }

    let offsetRect = innerRect.offsetBy(dx: 0, dy: 15)

    overlay.path  = UIBezierPath(roundedRect: offsetRect, cornerRadius: 5).cgPath
  }
}

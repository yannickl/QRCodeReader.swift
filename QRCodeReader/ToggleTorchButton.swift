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

///The toggle torch button
@IBDesignable final class ToggleTorchButton: UIButton {
  @IBInspectable var edgeColor: UIColor = UIColor.whiteColor() {
    didSet {
      setNeedsDisplay()
    }
  }

  @IBInspectable var fillColor: UIColor  = UIColor.lightGrayColor() {
    didSet {
      setNeedsDisplay()
    }
  }

  @IBInspectable var edgeHighlightedColor: UIColor = UIColor.whiteColor()
  @IBInspectable var fillHighlightedColor: UIColor = UIColor.darkGrayColor()

  override func drawRect(rect: CGRect) {
    // Colors
    let paintColor  = (self.state != .Highlighted) ? fillColor : fillHighlightedColor
    paintColor.setFill()
    let strokeColor = (self.state != .Highlighted) ? edgeColor : edgeHighlightedColor
    strokeColor.setStroke()

    let width  = rect.width
    let height = rect.height
    let centerX = width / 2
    let centerY = height / 2

    let strokeLineWidth: CGFloat = 2
    let circleRadius: CGFloat = width / 10
    let lineLength: CGFloat = width / 10
    let lineOffset: CGFloat = width / 10
    let lineOriginFromCenter = circleRadius + lineOffset
    let sin45 = sin(CGFloat(M_PI_4))
    let inclinedLength = lineLength * sin45
    let inclinedOrigin = lineOriginFromCenter * sin45

    //Circle
    let circlePath = UIBezierPath()
    circlePath.addArcWithCenter(CGPoint(x: centerX, y: centerY), radius: circleRadius, startAngle: 0.0, endAngle: CGFloat(M_PI), clockwise: true)
    circlePath.addArcWithCenter(CGPoint(x: centerX, y: centerY), radius: circleRadius, startAngle: CGFloat(M_PI), endAngle: CGFloat(M_PI * 2), clockwise: true)

    //First beam
    var startPoint = CGPoint(x: centerX, y: centerY + lineOriginFromCenter)
    var endPoint = CGPoint(x: startPoint.x, y: startPoint.y + lineLength)
    let firstBeamPath = linePathWithStartPoint(startPoint, endPoint: endPoint, thickness: strokeLineWidth)
    firstBeamPath.stroke()

    //Second beam
    startPoint = CGPoint(x: centerX + sin45 * lineOriginFromCenter, y: centerY + inclinedOrigin)
    endPoint = CGPoint(x: startPoint.x + inclinedLength, y: startPoint.y + inclinedLength)
    let secondBeamPath = linePathWithStartPoint(startPoint, endPoint: endPoint, thickness: strokeLineWidth)
    secondBeamPath.stroke()

    //Third beam
    startPoint = CGPoint(x: centerX + lineOriginFromCenter, y: centerY)
    endPoint = CGPoint(x: startPoint.x + lineLength, y: startPoint.y)
    let thirdBeamPath = linePathWithStartPoint(startPoint, endPoint: endPoint, thickness: strokeLineWidth)
    thirdBeamPath.stroke()

    //Fourth beam
    startPoint = CGPoint(x: centerX + inclinedOrigin, y: centerY - inclinedOrigin)
    endPoint = CGPoint(x: startPoint.x + inclinedLength, y: startPoint.y - inclinedLength)
    let fourthBeamPath = linePathWithStartPoint(startPoint, endPoint: endPoint, thickness: strokeLineWidth)
    fourthBeamPath.stroke()

    //Fifth beam
    startPoint = CGPoint(x: centerX, y: centerY - lineOriginFromCenter)
    endPoint = CGPoint(x: startPoint.x, y: startPoint.y - lineLength)
    let fifthBeamPath = linePathWithStartPoint(startPoint, endPoint: endPoint, thickness: strokeLineWidth)
    fifthBeamPath.stroke()

    //Sixth beam
    startPoint = CGPoint(x: centerX - inclinedOrigin, y: centerY - inclinedOrigin)
    endPoint = CGPoint(x: startPoint.x - inclinedLength, y: startPoint.y - inclinedLength)
    let sixthBeamPath = linePathWithStartPoint(startPoint, endPoint: endPoint, thickness: strokeLineWidth)
    sixthBeamPath.stroke()

    //Seventh beam
    startPoint = CGPoint(x: centerX - lineOriginFromCenter, y: centerY)
    endPoint = CGPoint(x: startPoint.x - lineLength, y: startPoint.y)
    let seventhBeamPath = linePathWithStartPoint(startPoint, endPoint: endPoint, thickness: strokeLineWidth)
    seventhBeamPath.stroke()

    //Eights beam
    startPoint = CGPoint(x: centerX - inclinedOrigin, y: centerY + inclinedOrigin)
    endPoint = CGPoint(x: startPoint.x - sin45 * lineLength, y: startPoint.y + inclinedLength)
    let eightsBeamPath = linePathWithStartPoint(startPoint, endPoint: endPoint, thickness: strokeLineWidth)
    eightsBeamPath.stroke()


    circlePath.lineWidth = strokeLineWidth
    circlePath.fill()
    circlePath.stroke()
  }

  private func linePathWithStartPoint(startPoint: CGPoint, endPoint: CGPoint, thickness: CGFloat) -> UIBezierPath {
    let linePath = UIBezierPath()

    linePath.moveToPoint(startPoint)
    linePath.addLineToPoint(endPoint)
    linePath.lineCapStyle = .Round
    linePath.lineWidth = thickness

    return linePath
  }

  // MARK: - UIResponder Methods

  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    super.touchesBegan(touches, withEvent: event)

    setNeedsDisplay()
  }

  override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
    super.touchesMoved(touches, withEvent: event)

    setNeedsDisplay()
  }

  override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
    super.touchesEnded(touches, withEvent: event)
    setNeedsDisplay()
  }

  override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
    super.touchesCancelled(touches, withEvent: event)

    setNeedsDisplay()
  }
}

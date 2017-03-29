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

/// The camera switch button.
@IBDesignable
public final class SwitchCameraButton: UIButton {
  @IBInspectable var edgeColor: UIColor = UIColor.white {
    didSet {
      setNeedsDisplay()
    }
  }

  @IBInspectable var fillColor: UIColor = UIColor.darkGray {
    didSet {
      setNeedsDisplay()
    }
  }

  @IBInspectable var edgeHighlightedColor: UIColor = UIColor.white
  @IBInspectable var fillHighlightedColor: UIColor = UIColor.black

  public override func draw(_ rect: CGRect) {
    let width  = rect.width
    let height = rect.height
    let center = width / 2
    let middle = height / 2

    let strokeLineWidth = CGFloat(2)

    // Colors
    let paintColor  = (self.state != .highlighted) ? fillColor : fillHighlightedColor
    let strokeColor = (self.state != .highlighted) ? edgeColor : edgeHighlightedColor

    // Camera box
    let cameraWidth  = width * 0.4
    let cameraHeight = cameraWidth * 0.6
    let cameraX      = center - cameraWidth / 2
    let cameraY      = middle - cameraHeight / 2
    let cameraRadius = cameraWidth / 80

    let boxPath = UIBezierPath(roundedRect: CGRect(x: cameraX, y: cameraY, width: cameraWidth, height: cameraHeight), cornerRadius: cameraRadius)

    // Camera lens
    let outerLensSize = cameraHeight * 0.8
    let outerLensX    = center - outerLensSize / 2
    let outerLensY    = middle - outerLensSize / 2

    let innerLensSize = outerLensSize * 0.7
    let innerLensX    = center - innerLensSize / 2
    let innerLensY    = middle - innerLensSize / 2

    let outerLensPath = UIBezierPath(ovalIn: CGRect(x: outerLensX, y: outerLensY, width: outerLensSize, height: outerLensSize))
    let innerLensPath = UIBezierPath(ovalIn: CGRect(x: innerLensX, y: innerLensY, width: innerLensSize, height: innerLensSize))

    // Draw flash box
    let flashBoxWidth      = cameraWidth * 0.8
    let flashBoxHeight     = cameraHeight * 0.17
    let flashBoxDeltaWidth = flashBoxWidth * 0.14
    let flashLeftMostX     = cameraX + (cameraWidth - flashBoxWidth) * 0.5
    let flashBottomMostY   = cameraY

    let flashPath = UIBezierPath()
    flashPath.move(to: CGPoint(x: flashLeftMostX, y: flashBottomMostY))
    flashPath.addLine(to: CGPoint(x: flashLeftMostX + flashBoxWidth, y: flashBottomMostY))
    flashPath.addLine(to: CGPoint(x: flashLeftMostX + flashBoxWidth - flashBoxDeltaWidth, y: flashBottomMostY - flashBoxHeight))
    flashPath.addLine(to: CGPoint(x: flashLeftMostX + flashBoxDeltaWidth, y: flashBottomMostY - flashBoxHeight))
    flashPath.close()
    flashPath.lineCapStyle  = .round
    flashPath.lineJoinStyle = .round

    // Arrows
    let arrowHeadHeigth = cameraHeight * 0.5
    let arrowHeadWidth  = ((width - cameraWidth) / 2) * 0.3
    let arrowTailHeigth = arrowHeadHeigth * 0.6
    let arrowTailWidth  = ((width - cameraWidth) / 2) * 0.7

    // Draw left arrow
    let arrowLeftX = center - cameraWidth * 0.2
    let arrowLeftY = middle + cameraHeight * 0.45

    let leftArrowPath = UIBezierPath()
    leftArrowPath.move(to: CGPoint(x: arrowLeftX, y: arrowLeftY))
    leftArrowPath.addLine(to: CGPoint(x: arrowLeftX - arrowHeadWidth, y: arrowLeftY - arrowHeadHeigth / 2))
    leftArrowPath.addLine(to: CGPoint(x: arrowLeftX - arrowHeadWidth, y: arrowLeftY - arrowTailHeigth / 2))
    leftArrowPath.addLine(to: CGPoint(x: arrowLeftX - arrowHeadWidth - arrowTailWidth, y: arrowLeftY - arrowTailHeigth / 2))
    leftArrowPath.addLine(to: CGPoint(x: arrowLeftX - arrowHeadWidth - arrowTailWidth, y: arrowLeftY + arrowTailHeigth / 2))
    leftArrowPath.addLine(to: CGPoint(x: arrowLeftX - arrowHeadWidth, y: arrowLeftY + arrowTailHeigth / 2))
    leftArrowPath.addLine(to: CGPoint(x: arrowLeftX - arrowHeadWidth, y: arrowLeftY + arrowHeadHeigth / 2))

    // Right arrow
    let arrowRightX = center + cameraWidth * 0.2
    let arrowRightY = middle + cameraHeight * 0.60

    let rigthArrowPath = UIBezierPath()
    rigthArrowPath.move(to: CGPoint(x: arrowRightX, y: arrowRightY))
    rigthArrowPath.addLine(to: CGPoint(x: arrowRightX + arrowHeadWidth, y: arrowRightY - arrowHeadHeigth / 2))
    rigthArrowPath.addLine(to: CGPoint(x: arrowRightX + arrowHeadWidth, y: arrowRightY - arrowTailHeigth / 2))
    rigthArrowPath.addLine(to: CGPoint(x: arrowRightX + arrowHeadWidth + arrowTailWidth, y: arrowRightY - arrowTailHeigth / 2))
    rigthArrowPath.addLine(to: CGPoint(x: arrowRightX + arrowHeadWidth + arrowTailWidth, y: arrowRightY + arrowTailHeigth / 2))
    rigthArrowPath.addLine(to: CGPoint(x: arrowRightX + arrowHeadWidth, y: arrowRightY + arrowTailHeigth / 2))
    rigthArrowPath.addLine(to: CGPoint(x: arrowRightX + arrowHeadWidth, y: arrowRightY + arrowHeadHeigth / 2))
    rigthArrowPath.close()

    // Drawing
    paintColor.setFill()
    rigthArrowPath.fill()
    strokeColor.setStroke()
    rigthArrowPath.lineWidth = strokeLineWidth
    rigthArrowPath.stroke()

    paintColor.setFill()
    boxPath.fill()
    strokeColor.setStroke()
    boxPath.lineWidth = strokeLineWidth
    boxPath.stroke()

    strokeColor.setFill()
    outerLensPath.fill()

    paintColor.setFill()
    innerLensPath.fill()

    paintColor.setFill()
    flashPath.fill()
    strokeColor.setStroke()
    flashPath.lineWidth = strokeLineWidth
    flashPath.stroke()

    leftArrowPath.close()
    paintColor.setFill()
    leftArrowPath.fill()
    strokeColor.setStroke()
    leftArrowPath.lineWidth = strokeLineWidth
    leftArrowPath.stroke()
  }

  // MARK: - UIResponder Methods

  public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)

    setNeedsDisplay()
  }

  public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesMoved(touches, with: event)

    setNeedsDisplay()
  }

  public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    setNeedsDisplay()
  }

  public override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {
    super.touchesCancelled(touches!, with: event)
    
    setNeedsDisplay()
  }
}

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
@IBDesignable final class SwitchCameraButton: UIButton {
  @IBInspectable var edgeColor: UIColor = UIColor.whiteColor() {
    didSet {
      setNeedsDisplay()
    }
  }

  @IBInspectable var fillColor: UIColor  = UIColor.darkGrayColor() {
    didSet {
      setNeedsDisplay()
    }
  }

  @IBInspectable var edgeHighlightedColor: UIColor = UIColor.whiteColor()
  @IBInspectable var fillHighlightedColor: UIColor = UIColor.blackColor()

  override func drawRect(rect: CGRect) {
    let width  = rect.width
    let height = rect.height
    let center = width / 2
    let middle = height / 2

    let strokeLineWidth = CGFloat(2)

    // Colors

    let paintColor  = (self.state != .Highlighted) ? fillColor : fillHighlightedColor
    let strokeColor = (self.state != .Highlighted) ? edgeColor : edgeHighlightedColor

    // Camera box

    let cameraWidth  = width * 0.4
    let cameraHeight = cameraWidth * 0.6
    let cameraX      = center - cameraWidth / 2
    let cameraY      = middle - cameraHeight / 2
    let cameraRadius = cameraWidth / 80

    let boxPath = UIBezierPath(roundedRect: CGRectMake(cameraX, cameraY, cameraWidth, cameraHeight), cornerRadius: cameraRadius)

    // Camera lens

    let outerLensSize = cameraHeight * 0.8
    let outerLensX    = center - outerLensSize / 2
    let outerLensY    = middle - outerLensSize / 2

    let innerLensSize = outerLensSize * 0.7
    let innerLensX    = center - innerLensSize / 2
    let innerLensY    = middle - innerLensSize / 2

    let outerLensPath = UIBezierPath(ovalInRect: CGRectMake(outerLensX, outerLensY, outerLensSize, outerLensSize))
    let innerLensPath = UIBezierPath(ovalInRect: CGRectMake(innerLensX, innerLensY, innerLensSize, innerLensSize))

    // Draw flash box

    let flashBoxWidth      = cameraWidth * 0.8
    let flashBoxHeight     = cameraHeight * 0.17
    let flashBoxDeltaWidth = flashBoxWidth * 0.14
    let flashLeftMostX     = cameraX + (cameraWidth - flashBoxWidth) * 0.5
    let flashBottomMostY   = cameraY

    let flashPath = UIBezierPath()
    flashPath.moveToPoint(CGPointMake(flashLeftMostX, flashBottomMostY))
    flashPath.addLineToPoint(CGPointMake(flashLeftMostX + flashBoxWidth, flashBottomMostY))
    flashPath.addLineToPoint(CGPointMake(flashLeftMostX + flashBoxWidth - flashBoxDeltaWidth, flashBottomMostY - flashBoxHeight))
    flashPath.addLineToPoint(CGPointMake(flashLeftMostX + flashBoxDeltaWidth, flashBottomMostY - flashBoxHeight))
    flashPath.closePath()
    flashPath.lineCapStyle = kCGLineCapRound
    flashPath.lineJoinStyle = kCGLineJoinRound

    // Arrows


    let arrowHeadHeigth = cameraHeight * 0.5
    let arrowHeadWidth  = ((width - cameraWidth) / 2) * 0.3
    let arrowTailHeigth = arrowHeadHeigth * 0.6
    let arrowTailWidth  = ((width - cameraWidth) / 2) * 0.7

    // Draw left arrow

    let arrowLeftX = center - cameraWidth * 0.2
    let arrowLeftY = middle + cameraHeight * 0.45

    let leftArrowPath = UIBezierPath()
    leftArrowPath.moveToPoint(CGPointMake(arrowLeftX, arrowLeftY))
    leftArrowPath.addLineToPoint(CGPointMake(arrowLeftX - arrowHeadWidth, arrowLeftY - arrowHeadHeigth / 2))
    leftArrowPath.addLineToPoint(CGPointMake(arrowLeftX - arrowHeadWidth, arrowLeftY - arrowTailHeigth / 2))
    leftArrowPath.addLineToPoint(CGPointMake(arrowLeftX - arrowHeadWidth - arrowTailWidth, arrowLeftY - arrowTailHeigth / 2))
    leftArrowPath.addLineToPoint(CGPointMake(arrowLeftX - arrowHeadWidth - arrowTailWidth, arrowLeftY + arrowTailHeigth / 2))
    leftArrowPath.addLineToPoint(CGPointMake(arrowLeftX - arrowHeadWidth, arrowLeftY + arrowTailHeigth / 2))
    leftArrowPath.addLineToPoint(CGPointMake(arrowLeftX - arrowHeadWidth, arrowLeftY + arrowHeadHeigth / 2))

    // Right arrow

    let arrowRightX = center + cameraWidth * 0.2
    let arrowRightY = middle + cameraHeight * 0.60

    let rigthArrowPath = UIBezierPath()
    rigthArrowPath.moveToPoint(CGPointMake(arrowRightX, arrowRightY))
    rigthArrowPath.addLineToPoint(CGPointMake(arrowRightX + arrowHeadWidth, arrowRightY - arrowHeadHeigth / 2))
    rigthArrowPath.addLineToPoint(CGPointMake(arrowRightX + arrowHeadWidth, arrowRightY - arrowTailHeigth / 2))
    rigthArrowPath.addLineToPoint(CGPointMake(arrowRightX + arrowHeadWidth + arrowTailWidth, arrowRightY - arrowTailHeigth / 2))
    rigthArrowPath.addLineToPoint(CGPointMake(arrowRightX + arrowHeadWidth + arrowTailWidth, arrowRightY + arrowTailHeigth / 2))
    rigthArrowPath.addLineToPoint(CGPointMake(arrowRightX + arrowHeadWidth, arrowRightY + arrowTailHeigth / 2))
    rigthArrowPath.addLineToPoint(CGPointMake(arrowRightX + arrowHeadWidth, arrowRightY + arrowHeadHeigth / 2))
    rigthArrowPath.closePath()

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

    leftArrowPath.closePath()
    paintColor.setFill()
    leftArrowPath.fill()
    strokeColor.setStroke()
    leftArrowPath.lineWidth = strokeLineWidth
    leftArrowPath.stroke()
  }

  // MARK: - UIResponder Methods

  override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
    super.touchesBegan(touches, withEvent: event)

    setNeedsDisplay()
  }

  override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
    super.touchesMoved(touches, withEvent: event)

    setNeedsDisplay()
  }

  override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
    super.touchesEnded(touches, withEvent: event)
    setNeedsDisplay()
  }

  override func touchesCancelled(touches: Set<NSObject>!, withEvent event: UIEvent!) {
    super.touchesCancelled(touches, withEvent: event)

    setNeedsDisplay()
  }
}
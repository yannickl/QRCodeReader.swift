// Playground - CameraSwiftIcon: a place where people can play

import UIKit
import XCPlayground

class CameraIconView: UIView {

  override func drawRect(rect: CGRect) {
    let width  = rect.width
    let height = rect.height
    let center = width / 2
    let middle = height / 2
    
    let strokeLineWidth = CGFloat(2)
    
    // Color Declarations
    
    let outerColor = UIColor.whiteColor()
    let innerColor = UIColor.grayColor()
    
    // Camera box
    
    let cameraWidth  = width * 0.4
    let cameraHeight = cameraWidth * 0.6
    let cameraX      = center - cameraWidth / 2
    let cameraY      = middle - cameraHeight / 2
    
    let boxPath = UIBezierPath(roundedRect: CGRectMake(cameraX, cameraY, cameraWidth, cameraHeight), cornerRadius: 2)
    
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
    
    innerColor.setFill()
    rigthArrowPath.fill()
    outerColor.setStroke()
    rigthArrowPath.lineWidth = strokeLineWidth
    rigthArrowPath.stroke()

    innerColor.setFill()
    boxPath.fill()
    outerColor.setStroke()
    boxPath.lineWidth = strokeLineWidth
    boxPath.stroke()
    
    outerColor.setFill()
    outerLensPath.fill()
    
    UIColor.grayColor().setFill()
    innerLensPath.fill()

    UIColor.grayColor().setFill()
    flashPath.fill()
    
    leftArrowPath.closePath()
    UIColor.grayColor().setFill()
    leftArrowPath.fill()
    outerColor.setStroke()
    leftArrowPath.lineWidth = strokeLineWidth
    leftArrowPath.stroke()
  }
}

var view             = CameraIconView(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
view.backgroundColor = UIColor.whiteColor()

XCPShowView("Camera Switch Icon", view)

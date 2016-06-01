// Playground - CameraSwiftIcon: a place where people can play

import UIKit
import XCPlayground

class SwitchCameraButton: UIButton {
  var strokeColor: UIColor = .whiteColor() {
    didSet {
      setNeedsDisplay()
    }
  }
  
  var paintColor: UIColor  = .darkGrayColor() {
    didSet {
      setNeedsDisplay()
    }
  }
  
  override func drawRect(rect: CGRect) {
    let width  = rect.width
    let height = rect.height
    let center = width / 2
    let middle = height / 2
    
    let strokeLineWidth = CGFloat(2)
    
    // Camera box
    
    let cameraWidth  = width * 0.4
    let cameraHeight = cameraWidth * 0.6
    let cameraX      = center - cameraWidth / 2
    let cameraY      = middle - cameraHeight / 2
    
    let boxPath = UIBezierPath(roundedRect: CGRectMake(cameraX, cameraY, cameraWidth, cameraHeight), cornerRadius: 4)
    
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
    flashPath.moveToPoint(CGPoint(x: flashLeftMostX, y: flashBottomMostY))
    flashPath.addLineToPoint(CGPoint(x: flashLeftMostX + flashBoxWidth, y: flashBottomMostY))
    flashPath.addLineToPoint(CGPoint(x: flashLeftMostX + flashBoxWidth - flashBoxDeltaWidth, y: flashBottomMostY - flashBoxHeight))
    flashPath.addLineToPoint(CGPoint(x: flashLeftMostX + flashBoxDeltaWidth, y: flashBottomMostY - flashBoxHeight))
    flashPath.closePath()
    flashPath.lineCapStyle  = .Round
    flashPath.lineJoinStyle = .Round
    
    // Arrows
    
    
    let arrowHeadHeigth = cameraHeight * 0.5
    let arrowHeadWidth  = ((width - cameraWidth) / 2) * 0.3
    let arrowTailHeigth = arrowHeadHeigth * 0.6
    let arrowTailWidth  = ((width - cameraWidth) / 2) * 0.7
    
    // Draw left arrow
    
    let arrowLeftX = center - cameraWidth * 0.2
    let arrowLeftY = middle + cameraHeight * 0.45
    
    let leftArrowPath = UIBezierPath()
    leftArrowPath.moveToPoint(CGPoint(x: arrowLeftX, y: arrowLeftY))
    leftArrowPath.addLineToPoint(CGPoint(x: arrowLeftX - arrowHeadWidth, y: arrowLeftY - arrowHeadHeigth / 2))
    leftArrowPath.addLineToPoint(CGPoint(x: arrowLeftX - arrowHeadWidth, y: arrowLeftY - arrowTailHeigth / 2))
    leftArrowPath.addLineToPoint(CGPoint(x: arrowLeftX - arrowHeadWidth - arrowTailWidth, y: arrowLeftY - arrowTailHeigth / 2))
    leftArrowPath.addLineToPoint(CGPoint(x: arrowLeftX - arrowHeadWidth - arrowTailWidth, y: arrowLeftY + arrowTailHeigth / 2))
    leftArrowPath.addLineToPoint(CGPoint(x: arrowLeftX - arrowHeadWidth, y: arrowLeftY + arrowTailHeigth / 2))
    leftArrowPath.addLineToPoint(CGPoint(x: arrowLeftX - arrowHeadWidth, y: arrowLeftY + arrowHeadHeigth / 2))
    
    // Right arrow
    
    let arrowRightX = center + cameraWidth * 0.2
    let arrowRightY = middle + cameraHeight * 0.60
    
    let rigthArrowPath = UIBezierPath()
    rigthArrowPath.moveToPoint(CGPoint(x: arrowRightX, y: arrowRightY))
    rigthArrowPath.addLineToPoint(CGPoint(x: arrowRightX + arrowHeadWidth, y: arrowRightY - arrowHeadHeigth / 2))
    rigthArrowPath.addLineToPoint(CGPoint(x: arrowRightX + arrowHeadWidth, y: arrowRightY - arrowTailHeigth / 2))
    rigthArrowPath.addLineToPoint(CGPoint(x: arrowRightX + arrowHeadWidth + arrowTailWidth, y: arrowRightY - arrowTailHeigth / 2))
    rigthArrowPath.addLineToPoint(CGPoint(x: arrowRightX + arrowHeadWidth + arrowTailWidth, y: arrowRightY + arrowTailHeigth / 2))
    rigthArrowPath.addLineToPoint(CGPoint(x: arrowRightX + arrowHeadWidth, y: arrowRightY + arrowTailHeigth / 2))
    rigthArrowPath.addLineToPoint(CGPoint(x: arrowRightX + arrowHeadWidth, y: arrowRightY + arrowHeadHeigth / 2))
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
}

var view             = SwitchCameraButton(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
view.backgroundColor = .whiteColor()

XCPlaygroundPage.currentPage.liveView = view

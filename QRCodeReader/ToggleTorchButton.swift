/*
* QRCodeReader.swift
*
* Copyright 2014-present Yannick Loriot.
* http://yannickloriot.com

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
    
    @IBInspectable var fillColor: UIColor  = UIColor.darkGrayColor() {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var edgeHighlightedColor: UIColor = UIColor.whiteColor()
    @IBInspectable var fillHighlightedColor: UIColor = UIColor.blackColor()
    
    override func drawRect(rect: CGRect) {
        UIColor.whiteColor().setFill()
        UIColor.yellowColor().setStroke()
        
        let width  = rect.width
        let height = rect.height
        let center = width / 2
        let middle = height / 2
        
        let strokeLineWidth = CGFloat(2)
        let circleRadius = width / 10
        let lineLength = width / 7
        let lineOffset = width / 14
        
        let circlePath = UIBezierPath()
        circlePath.addArcWithCenter(CGPoint(x: center, y: middle), radius: circleRadius, startAngle: 0.0, endAngle: CGFloat(M_PI), clockwise: true)
        circlePath.addArcWithCenter(CGPoint(x: center, y: middle), radius: circleRadius, startAngle: CGFloat(M_PI), endAngle: CGFloat(M_PI * 2), clockwise: true)
        
        let linePath = UIBezierPath()
        linePath.moveToPoint(CGPointMake(center, middle + circleRadius + lineOffset))
        linePath.addLineToPoint(CGPointMake(center, middle + circleRadius + lineOffset + lineLength))
        linePath.lineWidth = strokeLineWidth
        linePath.stroke()
        
        circlePath.lineWidth = strokeLineWidth
        circlePath.fill()
        circlePath.stroke()
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

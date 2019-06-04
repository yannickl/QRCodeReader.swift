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

/// The `QRCodeReaderDisplayable` procotol that each view embeded a `QRCodeReaderContainer` must conforms to. It defines the required UI component needed and the mandatory methods.
public protocol QRCodeReaderDisplayable {
  /// The view that display video as it is being captured by the camera.
  var cameraView: UIView { get }

  /// A cancel button.
  var cancelButton: UIButton? { get }

  /// A switch camera button.
  var switchCameraButton: UIButton? { get }

  /// A toggle torch button.
  var toggleTorchButton: UIButton? { get }

  /// A guide view upon the camera view
  var overlayView: QRCodeReaderViewOverlay? { get }

  /// Notify the receiver to update its orientation.
  func setNeedsUpdateOrientation()

  /**
   Method called by the container to allows you to layout your view properly using the QR code reader builder.

   - Parameter builder: A QR code reader builder.
   */
  func setupComponents(with builder: QRCodeReaderViewControllerBuilder)
}

/// The `QRCodeReaderContainer` structure embed the view displayed by the controller. The embeded view must be conform to the `QRCodeReaderDisplayable` protocol.
public struct QRCodeReaderContainer {
  let view: UIView
  let displayable: QRCodeReaderDisplayable

  /**
   Creates a QRCode container object that embeds a given displayable view.

   - Parameter displayable: An UIView conforms to the `QRCodeReaderDisplayable` protocol.
   */
  public init<T: QRCodeReaderDisplayable>(displayable: T) where T: UIView {
    self.view        = displayable
    self.displayable = displayable
  }

  // MARK: - Convenience Methods

  func setupComponents(with builder: QRCodeReaderViewControllerBuilder) {
    displayable.setupComponents(with: builder)
  }
}

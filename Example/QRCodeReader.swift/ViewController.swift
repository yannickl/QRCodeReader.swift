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
import AVFoundation

class ViewController: UIViewController, QRCodeReaderViewControllerDelegate {
  lazy var reader: QRCodeReaderViewController = {
    let builder = QRCodeReaderViewControllerBuilder {
      $0.reader = QRCodeReader(metadataObjectTypes: [AVMetadataObjectTypeQRCode], captureDevicePosition: .back)
      $0.showTorchButton = true
    }
    
    return QRCodeReaderViewController(builder: builder)
  }()

  @IBAction func scanAction(_ sender: AnyObject) {
    do {
      if try QRCodeReader.supportsMetadataObjectTypes() {
        reader.modalPresentationStyle = .formSheet
        reader.delegate               = self

        reader.completionBlock = { (result: QRCodeReaderResult?) in
          if let result = result {
            print("Completion with result: \(result.value) of type \(result.metadataType)")
          }
        }

        present(reader, animated: true, completion: nil)
      }
    } catch let error as NSError {
      switch error.code {
      case -11852:
        let alert = UIAlertController(title: "Error", message: "This app is not authorized to use Back Camera.", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Setting", style: .default, handler: { (_) in
          DispatchQueue.main.async {
            if let settingsURL = URL(string: UIApplicationOpenSettingsURLString) {
              UIApplication.shared.openURL(settingsURL)
            }
          }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)



      case -11814:
        let alert = UIAlertController(title: "Error", message: "Reader not supported by the current device", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))

        present(alert, animated: true, completion: nil)
      default:()
      }
    }

  }

  // MARK: - QRCodeReader Delegate Methods

  func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
    reader.stopScanning()

    dismiss(animated: true) { [weak self] in
      let alert = UIAlertController(
        title: "QRCodeReader",
        message: String (format:"%@ (of type %@)", result.value, result.metadataType),
        preferredStyle: .alert
      )
      alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))

      self?.present(alert, animated: true, completion: nil)
    }
  }

  func reader(_ reader: QRCodeReaderViewController, didSwitchCamera newCaptureDevice: AVCaptureDeviceInput) {
    if let cameraName = newCaptureDevice.device.localizedName {
      print("Switching capturing to: \(cameraName)")
    }
  }

  func readerDidCancel(_ reader: QRCodeReaderViewController) {
    reader.stopScanning()

    dismiss(animated: true, completion: nil)
  }
}

## QRCodeReader.swift

The _QRCodeReader.swift_ is a simple QRCode Reader/Scanner based on the _AVFoundation_ framework from Apple written in swift. It aims to replace ZXing or ZBar for iOS 8 and over.

![screenshot](https://github.com/YannickL/QRCodeReader.swift/blob/master/Example/resources/QRCodeReader.gif)

### Installation

#### Manually

[Download](https://github.com/YannickL/QRCodeReader.swift/archive/master.zip) the project and copy the `QRCodeReader.swift` file into your project to use it in.

## Usage

```swift
// Good practive: create the reader lazily to avoid cpu overload during the
// initialization and each time we need to scan a QRCode
lazy var reader: QRCodeReader = QRCodeReader(cancelButtonTitle: "Cancel")

@IBAction func scanAction(sender: AnyObject) {
  // Retrieve the QRCode content
  // By using the delegate pattern
  reader.delegate = self

  // Or by using the closure pattern
  reader.completionBlock = { (result: String?) in
    println(result)
  }

  // Presents the reader as modal form sheet
  reader.modalPresentationStyle = .FormSheet
  presentViewController(reader, animated: true, completion: nil)
}

// MARK: - QRCodeReader Delegate Methods

func reader(reader: QRCodeReader, didScanResult result: String) {
  self.dismissViewControllerAnimated(true, completion: nil)
}

func readerDidCancel(reader: QRCodeReader) {
  self.dismissViewControllerAnimated(true, completion: nil)
}
```

## Contact

Yannick Loriot
 - [https://twitter.com/yannickloriot](https://twitter.com/yannickloriot)
 - [contact@yannickloriot.com](mailto:contact@yannickloriot.com)


## License (MIT)

Copyright (c) 2014-present - Yannick Loriot

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

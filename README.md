![QRCodeReader.swift](http://yannickloriot.com/resources/qrcodereader.swift-logo.png)

[![License](https://cocoapod-badges.herokuapp.com/l/QRCodeReader.swift/badge.svg)](http://cocoadocs.org/docsets/QRCodeReader.swift/) [![Supported Plateforms](https://cocoapod-badges.herokuapp.com/p/QRCodeReader.swift/badge.svg)](http://cocoadocs.org/docsets/QRCodeReader.swift/) [![Version](https://cocoapod-badges.herokuapp.com/v/QRCodeReader.swift/badge.svg)](http://cocoadocs.org/docsets/QRCodeReader.swift/)

The _QRCodeReader.swift_ was initially a simple QRCode reader but it now lets you the possibility to specify the [format type](https://developer.apple.com/library/ios/documentation/AVFoundation/Reference/AVMetadataMachineReadableCodeObject_Class/index.html#//apple_ref/doc/constant_group/Machine_Readable_Object_Types) you want to decode. It is based on the `AVFoundation` framework from Apple in order to replace ZXing or ZBar for iOS 8.0 and over.

It provides a default view controller to display the camera view with the scan area overlay and it also provides a button to switch between the front and the back cameras.

![screenshot](http://yannickloriot.com/resources/qrcodereader.swift-screenshot.jpg)

## Usage

-  Add delegate `QRCodeReaderViewControllerDelegate`
-  Add `import AVFoundation`
-  The `QRCodeReaderViewControllerDelegate` implementations is:
-  
```swift
// Good practice: create the reader lazily to avoid cpu overload during the
// initialization and each time we need to scan a QRCode
lazy var readerVC = QRCodeReaderViewController(metadataObjectTypes: [AVMetadataObjectTypeQRCode])

@IBAction func scanAction(sender: AnyObject) {
  // Retrieve the QRCode content
  // By using the delegate pattern
  readerVC.delegate = self

  // Or by using the closure pattern
  readerVC.completionBlock = { (result: QRCodeReaderResult?) in
    println(result)
  }

  // Presents the readerVC as modal form sheet
  readerVC.modalPresentationStyle = .FormSheet
  presentViewController(readerVC, animated: true, completion: nil)
}

// MARK: - QRCodeReaderViewController Delegate Methods

func reader(reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
   self.dismissViewControllerAnimated(true, completion: nil)
}

func readerDidCancel(reader: QRCodeReaderViewController) {
   self.dismissViewControllerAnimated(true, completion: nil)
}
```

*Note that you should check whether the device supports the reader library by using the `QRCodeReader.isAvailable()` or the `QRCodeReader.supportsMetadataObjectTypes()` methods.*

### Installation

The recommended approach to use _QRCodeReaderViewController_ in your project is using the [CocoaPods](http://cocoapods.org/) package manager, as it provides flexible dependency management and dead simple installation.

#### CocoaPods

Install CocoaPods if not already available:

``` bash
$ [sudo] gem install cocoapods
$ pod setup
```
Go to the directory of your Xcode project, and Create and Edit your Podfile and add _QRCodeReader.swift_ to your corresponding `TargetName`:

``` bash
$ cd /path/to/MyProject
$ touch Podfile
$ edit Podfile
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!

target 'TargetName' do
    pod 'QRCodeReader.swift', '~> 6.1.0'
end
```

Install into your project:

``` bash
$ pod install
```

Open your project in Xcode from the .xcworkspace file (not the usual project file):

``` bash
$ open MyProject.xcworkspace
```

You can now `import QRCodeReader` framework into your files.

#### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that automates the process of adding frameworks to your Cocoa application.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate `QRCodeReader` into your Xcode project using Carthage, specify it in your `Cartfile` file:

```ogdl
github "yannickl/QRCodeReader.swift" >= 6.1.0
```

#### Manually

[Download](https://github.com/YannickL/QRCodeReader.swift/archive/master.zip) the project and copy the `QRCodeReader` folder into your project to use it in.

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

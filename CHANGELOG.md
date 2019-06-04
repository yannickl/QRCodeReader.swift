# Change log

## [Version 10.1.0](https://github.com/yannickl/QRCodeReader.swift/releases/tag/10.1.0)
Release on 2019-05-03

- [ADD] `QRCodeReaderDisplayable` protocol to allow color customisation

## [Version 10.0.0](https://github.com/yannickl/QRCodeReader.swift/releases/tag/10.0.0)
Release on 2019-01-24

**Swift 5 supports**

- [ADD] Allowing the scan area configuration (#157 #106)
- [UPDATE] The `showOverlayView` builder property is now `false` by default

## [Version 9.0.0](https://github.com/yannickl/QRCodeReader.swift/releases/tag/9.0.0)
Release on 2018-09-19

**Swift 4.2 supports**

## [Version 8.2.0](https://github.com/yannickl/QRCodeReader.swift/releases/tag/8.2.0)
Release on 2018-05-17

- [FIX] Camera orientation when view is display (#123)
- [FIX] Safe area constraints (#128)
- [ADD] `preferredStatusBarStyle` property in the `QRCodeReaderViewControllerBuilder`

## [Version 8.1.1](https://github.com/yannickl/QRCodeReader.swift/releases/tag/8.1.1)
Release on 2018-17-02

 - [FIX] Camera display by removing the `weak` reference in the QRCodeReaderView (#120)

## [Version 8.1.0](https://github.com/yannickl/QRCodeReader.swift/releases/tag/8.1.0)
Release on 2018-25-01

 - [FIX] Scan duplication by introducing a backgroun serial queue (#127)
 - [FIX] Camera orientation glitches when init a `QRCodeReaderView` 

## [Version 8.0.4](https://github.com/yannickl/QRCodeReader.swift/releases/tag/8.0.4)
Release on 2017-11-26

 - [FIX] `stopScanning` method to avoid scan duplication (#127)

## [Version 8.0.0](https://github.com/yannickl/QRCodeReader.swift/releases/tag/8.0.0)
Release on 2017-09-21

**Swift 4.0 supports**

## [Version 7.5.0](https://github.com/yannickl/QRCodeReader.swift/releases/tag/7.5.0)
Release on 2017-08-10

- [REFACTORING] Makes the `QRCodeReaderView` public
- [REFACTORING] The rotation is now managed by the `QRCodeReaderView`

## [Version 7.4.2](https://github.com/yannickl/QRCodeReader.swift/releases/tag/7.4.2)
Release on 2017-05-28

- [FIX] Overlay orientation

## [Version 7.4.1](https://github.com/yannickl/QRCodeReader.swift/releases/tag/7.4.1)
Release on 2017-04-16

- [ADD] Make the `QRCodeReader`'s `metadataOutput` property public

## [Version 7.4.0](https://github.com/yannickl/QRCodeReader.swift/releases/tag/7.4.0)
Release on 2017-03-29

**Swift 3.1 supports**

## [Version 7.3.0](https://github.com/yannickl/QRCodeReader.swift/releases/tag/7.3.0)
Release on 2017-02-09

- [ADD] `showOverlayView` property in the `QRCodeReaderViewControllerBuilder`
- [ADD] `supportsMetadataObjectTypes` can throw errors now
- [FIX] `reader(_:didSwitchCamera:)` delegate method is now optional

## [Version 7.2.0](https://github.com/yannickl/QRCodeReader.swift/releases/tag/7.2.0)
Released on 2016-10-20.

- [REFACTORING] The `QRCodeReaderViewController`'s view is now build via the `QRCodeReaderContainer`
- [REFACTORING] The `ReaderOverlayView`, `SwitchCameraButton` and `ToggleTorchButton` are now public
- [ADD] The `readerView` property in the `QRCodeViewControllerBuilder` to allow view customization

## [Version 7.1.0](https://github.com/yannickl/QRCodeReader.swift/releases/tag/7.1.0)
Released on 2016-10-12.

- [ADD] Specify starting camera position in the init of `QRCodeReader` object
- [ADD] `reader:didSwitchCamera` delegate method

## [Version 7.0.1](https://github.com/yannickl/QRCodeReader.swift/releases/tag/7.0.1)
Released on 2016-09-13.

- [FIX] Make type less ambiguous [#58](https://github.com/yannickl/QRCodeReader.swift/issues/58)

## [Version 7.0.0](https://github.com/yannickl/QRCodeReader.swift/releases/tag/7.0.0)
Released on 2016-09-13.

**Swift 3 supports**

- [REFACTORING] Use `QRCodeReaderViewControllerBuilder` instead of `QRCodeViewControllerBuilder`
- [REFACTORING] Remove all deprecated apis
- [ADD] Swift Package Manager supports

`QRCodeReader`:
- Use `didFindCode` instead of `didFindCodeBlock`
- Use `isRunning` instead of `running`
- Use `videoOrientation` instead of `videoOrientationFromDeviceOrientation`
- `hasFrontDevice` is a property
- `isTorchAvailable` is a property

## [Version 6.2.0](https://github.com/yannickl/QRCodeReader.swift/releases/tag/6.2.0)
Released on 2016-09-08.

- [REFACTORING] Deprecating all initializers expect `initWithBuilder` in order to remove them in the next version

## [Version 6.1.0](https://github.com/yannickl/QRCodeReader.swift/releases/tag/6.1.0)
Released on 2016-08-03.

- [ADD] Hide/Display cancel button

## [Version 6.0.0](https://github.com/yannickl/QRCodeReader.swift/releases/tag/6.0.0)
Released on 2016-03-22.

**Swift 2.2 supports**

## [Version 5.4.0](https://github.com/yannickl/QRCodeReader.swift/releases/tag/5.4.0)
Released on 2016-03-14.

- [REFACTORING] make the `codeReader` property public
- [REFACTORING] Rename `completionBlock` of `QRCodeReader` to `codeDidFoundBlock`.
- [ADD] `stopScanningWhenCodeIsFound` flag to stop the scanner when a code is found.

## [Version 5.3.1](https://github.com/yannickl/QRCodeReader.swift/releases/tag/5.3.1)
Released on 2016-01-12.

- [FIX] `value` and `type` of `QRCodeReaderResult` are not optional.
- [REFACTORING] Rename `type` to `metadataType` in `QRCodeReaderResult`.

## [Version 5.3.0](https://github.com/yannickl/QRCodeReader.swift/releases/tag/5.3.0)
Released on 2016-01-11.

- [ADD] Return a `QRCodeReaderResult` instead of a string.
- [ADD] Convenience init with QRCode metadata type.
- [ADD] `QRCodeViewControllerBuilder` object with the corresponding init.

## [Version 5.2.1](https://github.com/yannickl/QRCodeReader.swift/releases/tag/5.2.1)
Released on 2015-11-07.

- [FIX] Switch camera and toggle button under status bar [#35](https://github.com/yannickl/QRCodeReader.swift/issues/35)

## [Version 5.2.0](https://github.com/yannickl/QRCodeReader.swift/releases/tag/5.2.0)
Released on 2015-10-20.

- [UPDATE] Remove the final attribute of the `QRCodeReaderViewController`

## [Version 5.1.1](https://github.com/yannickl/QRCodeReader.swift/releases/tag/5.1.1)
Released on 2015-10-16.

- [FIX] `isAvailable` access control property [#29](https://github.com/yannickl/QRCodeReader.swift/pull/29)

## [Version 5.1.0](https://github.com/yannickl/QRCodeReader.swift/releases/tag/5.1.0)
Released on 2015-10-06.

- [ADD] Options for hiding switch camera button and toggling torch on/off [#27](https://github.com/yannickl/QRCodeReader.swift/pull/27)

## [Version 5.0.0](https://github.com/yannickl/QRCodeReader.swift/releases/tag/5.0.0)
Released on 2015-09-17.

**Swift 2 supports**

- [ADD] Carthage supports

## [Version 4.3.0](https://github.com/yannickl/QRCodeReader.swift/releases/tag/4.3.0)
Released on 2015-07-10.

- [UPDATE] Make the `defaultDeviceInput`, the `frontDeviceInput` and the `metadataOutput` properties accessible in read-only mode

## [Version 4.2.0](https://github.com/yannickl/QRCodeReader.swift/releases/tag/4.2.0)
Released on 2015-05-23.

- [ADD] Init param to delay the start of scanning if necessary
- [FIX] Readme [#17](https://github.com/yannickl/QRCodeReader.swift/pull/17)
- [FIX] Check the nullity of the defaultDeviceInput

## [Version 4.1.0](https://github.com/yannickl/QRCodeReader.swift/releases/tag/4.1.0)
Released on 2015-04-15.

- [ADD] `running` property

## [Version 4.0.0](https://github.com/yannickl/QRCodeReader.swift/releases/tag/4.0.0)
Released on 2015-04-11.

**Swift 1.2 supports**

## [Version 3.1.8](https://github.com/yannickl/QRCodeReader.swift/releases/tag/3.1.8)
Released on 2015-03-28.

- [ADD] Support all code types
- [FIX] Many access methods [#10](https://github.com/yannickl/QRCodeReader.swift/pull/10)

## [Version 3.1.0](https://github.com/yannickl/QRCodeReader.swift/releases/tag/3.1.0)
Released on 2015-03-04.

- [ADD] `isAvailable` method
- [ADD] `areMetadataObjectTypesAvailable` method

## [Version 3.0.0](https://github.com/yannickl/QRCodeReader.swift/releases/tag/3.0.0)
Released on 2015-03-01.

- [REFACTORING] Split the `QRCodeReaderViewController` and `QRCodeReader`

## [Version 2.0.0](https://github.com/yannickl/QRCodeReader.swift/releases/tag/2.0.0)
Released on 2015-02-28.

- [ADD] Front camera supports
- [ADD] Overlay view
- [ADD] Cocoapods supports
- [FIX] Adjust layer when orientation did change [#1](https://github.com/yannickl/QRCodeReader.swift/pull/1)
- [FIX] Stop scanning when QRCode was read

## [Version 1.0.0](https://github.com/yannickl/QRCodeReader.swift/releases/tag/1.0.0)
Released on 2014-09-14.

- Initialize with cancel button title
- Supports only the default camera
- Supports only `AVMetadataObjectTypeQRCode`

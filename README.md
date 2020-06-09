# OverlappingViewsSeparator [![SwiftPM compatible](https://img.shields.io/badge/SwiftPM-compatible-4BC51D.svg)](https://github.com/apple/swift-package-manager) [![CocoaPods](https://img.shields.io/cocoapods/v/OverlappingViewsSeparator.svg?style=flat)](http://cocoapods.org/pods/OverlappingViewsSeparator) ![License](https://img.shields.io/github/license/malt03/OverlappingViewsSeparator.svg)

![Screenshot](https://raw.githubusercontent.com/malt03/OverlappingViewsSeparator/master/readme/screenshot.gif)

## Minimum Example

```swift
import UIKit
import OverlappingViewsSeparator

class ViewController: UIViewController {
    @IBOutlet private var overlappingViews: [UIView]!
    private let separator = OverlappingViewsSeparator(minSpacing: 8)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        separator.register(views: overlappingViews)
    }

    @IBAction private func apply() {
        separator.separate()
    }
}
```

## Installation
### [SwiftPM](https://github.com/apple/swift-package-manager) (Recommended)

- On Xcode, click `File` > `Swift Packages` > `Add Package Dependency...`
- Input `https://github.com/malt03/OverlappingViewsSeparator.git`

### [CocoaPods](https://github.com/cocoapods/cocoapods)

- Insert `pod 'OverlappingViewsSeparator'` to your Podfile.
- Run `pod install`.

## Advanced Example
### Separate with animation
```swift
separator.separate { (reflect) in
    UIView.animate(withDuration: 1) {
        reflect()
    }
}
```

### Register stuck view
```swift
separator.register(stuckView: stuckView)
```

### Reset
```swift
separator.reset()
```

### Set queue
```swift
let separator = OverlappingViewsSeparator(queue: .main) // default: .global()
```

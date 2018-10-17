# DMSegmentedPager

[![Pod Version](http://img.shields.io/cocoapods/v/DMSegmentedPager.svg?style=flat)](http://cocoadocs.org/docsets/DMSegmentedPager)
![Swift 4.2](https://img.shields.io/badge/Swift-4.2-orange.svg)
![Platform](https://img.shields.io/badge/platform-iOS-lightgrey.svg)
[![Pod License](http://img.shields.io/cocoapods/l/DMSegmentedPager.svg?style=flat)](http://opensource.org/licenses/MIT)

This is a Swift conversion of https://github.com/maxep/MXSegmentedPager

DMSegmentedPager combines [DMPagerView](https://github.com/DominicMDev/DMPagerView) with [DMSegmentedControl](https://github.com/DominicMDev/DMSegmentedControl) to control the page selection. The integration of [DMParallaxHeader](https://github.com/DominicMDev/DMParallaxHeader) allows you to add an parallax header on top while keeping a reliable scrolling effect.


|           Simple view         |           Parallax view         |   
|-------------------------------|---------------------------------|
|![Demo](https://raw.githubusercontent.com/maxep/MXSegmentedPager/master/Example-objc/SimpleView.gif)|![Demo](https://raw.githubusercontent.com/maxep/MXSegmentedPager/master/Example-objc/ParallaxView.gif)|

## Highlight
+ [DMSegmentedControl](https://github.com/DominicMDev/DMSegmentedControl) is a very customizable control.
+ [DMParallaxHeader](https://github.com/DominicMDev/DMParallaxHeader) supports any kind of view with different modes.
+ [DMPagerView](https://github.com/DominicMDev/DMPagerView) lazily loads pages and supports reusable page registration.
+ Reliable vertical scroll with any view hierarchy.
+ Can load view-controller from storyboard using a custom segue.

## Usage

+ Adding a parallax header to a DMSegmentedPager is straightforward, e.g:

```swift
let headerView = UIImageView(frame: imageFrame)
headerView.image = UIImage(named:"success-baby")
headerView.contentMode = .scaleAspectFill
   
let segmentedPager = DMSegmentedPager() 
segmentedPager.parallaxHeader.view = headerView
segmentedPager.parallaxHeader.height = 150
segmentedPager.parallaxHeader.mode = .fill
segmentedPager.parallaxHeader.minimumHeight = 20
```

## Examples

If you want to try it, simply run:
```
pod try DMSegmentedPager
```
Or clone the repo and run `pod install` from the Example directory first. 

+ See DMSimpleViewController for a standard implementation.
+ See DMParallaxViewController to implement a pager with a parallax header.

## Installation

DMSegmentedPager is available through [CocoaPods](https://cocoapods.org/pods/DMSegmentedPager). To install
it, simply add the following line to your Podfile:

```
pod 'DMSegmentedPager'
```

## License
                                               
DMSegmentedPager is available under the MIT license. See the [LICENSE](LICENSE) file for more info.

# DMPagerView

[![Pod Version](http://img.shields.io/cocoapods/v/DMPagerView.svg?style=flat)](http://cocoadocs.org/docsets/DMPagerView)
![Swift 4.2](https://img.shields.io/badge/Swift-4.2-orange.svg)
![Platform](https://img.shields.io/badge/platform-iOS-lightgrey.svg)
[![Pod License](http://img.shields.io/cocoapods/l/DMPagerView.svg?style=flat)](http://opensource.org/licenses/MIT)

This is a Swift conversion of https://github.com/maxep/MXPagerView

DMPagerView is a pager view with the ability to reuse pages like you would do with a table view and cells. Depending on the transition style, it will load the current page and neighbors and unload others pages.

DMPagerViewController allows you to load pages from storyboard using the DMPageSegue.

## Usage

If you want to try it, simply run:

```
pod try DMPagerView
```

Or clone the repo and run `pod install` from the Example directory first. 

+ As a UITableView, the MXPagerView calls data source methods to load pages. 
+ In order to reuse pages, first register the reusable view.
+ Then, dequeue a reusable page in the data source.

The DMPagerView comes with a UIView category which exposed the reuse identifier of the page as well as the ```prepareForReuse``` method, this is called just before the page is returned from the pager view method ```dequeueReusablePage(withIdentifier:)```.

+ Using MXPagerViewController in storyboard is super easy:

## Installation

DMPagerView is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'DMPagerView'
```

## License

DMPagerView is available under the MIT license. See the [LICENSE](LICENSE) file for more info.

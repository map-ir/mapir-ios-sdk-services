<p align="center">
<img width="200" src="https://corp.map.ir/wp-content/uploads/2019/06/map-site-logo-1.png" alt="MapirServices Logo">
</p>

<p align="center">
<a href="https://developer.apple.com/swift/">
<img src="https://img.shields.io/badge/Swift-5.0-orange.svg?style=flat" alt="Swift 5.0">
</a>

<a href="http://cocoapods.org/pods/MapirServices">
<img src="https://img.shields.io/cocoapods/v/MapirServices.svg?style=flat" alt="Version">
</a>
<a href="http://cocoapods.org/pods/MapirServices">
<img src="https://img.shields.io/cocoapods/p/MapirServices.svg?style=flat" alt="Platform">
</a>

<a href="https://github.com/Carthage/Carthage">
<img src="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat" alt="Carthage Compatible">
</a>
<a href="https://github.com/apple/swift-package-manager">
<img src="https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg" alt="SPM">
</a>
</p>

# MapirServices

ℹ️ MapirServices framework, helps you with networking part of using services of map.ir

## Features

ℹ️ Support for All version 1 API of Map.ir

## Example

The example application is the best way to see `MapirServices` in action. Simply open the `MapirServices.xcodeproj` and run the `Example` scheme.

## Installation

### CocoaPods

MapirServices is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'MapirServices'
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

To integrate MapirServices into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "map-ir/ios-sdk-v1-services-beta"
```

Run `carthage update` to build the framework and drag the built `MapirServices.framework` into your Xcode project. 

On your application targets’ “Build Phases” settings tab, click the “+” icon and choose “New Run Script Phase” and add the Framework path as mentioned in [Carthage Getting started Step 4, 5 and 6](https://github.com/Carthage/Carthage/blob/master/README.md#if-youre-building-for-ios-tvos-or-watchos)

### Swift Package Manager

To integrate using Apple's [Swift Package Manager](https://swift.org/package-manager/), add the following as a dependency to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/map-ir/ios-sdk-v1-services-beta", from: "0.5.0")
]
```

### Manually

If you prefer not to use any of the aforementioned dependency managers, you can integrate MapirServices into your project manually. Simply drag the `Sources` Folder into your Xcode project. (not recommended)


## Usage
1. Get an access token from [App Registration](https://corp.map.ir/registration/) site.
2. Add a key-value pair of your access token to your project's `info.plist`. Key must be "`MAPIRAccessToken`" and set the access token as value.
3. First import SDK using 
    ```swift
    import MapirServices
    ```
4. create an singleton instance of the `MPSMapirServiecs` class whenever you want to use these services
    ```swift
    let services = MPSMapirServices.shared
    ```
    
## Latest Changes
### Version 0.5.0
- Added a new initializer to `MapirServices` use access token without adding it to info.plist.
- Changed errors to be more expressive.
- Removed `MPS` prefix from every class and struct name.
- Renamed `MPSLocation` to `Place`.
- Refactored the `DistanceMatrix` data structure. Finding distance between two place (by name) had O(N * M) time comlexity, but now it is O(1), So it's a lot faster.
- Added some utility methods to find distance and duration between places in DistanceMatrix.
- Refactored `distanceMatrix(from:to:option:completionHandler)` implementation. Input coordinates changed from `[CLLocationCoordinate2D]` to a `[String: CLLocationCoordinate2D]`. so every input coordinate has a name specified by the user itself and it helps to access distance and duration between coordinates by their name.
- Renamed search options to search categories.
- Changed `search(for:around:categories:filter:completionHandler:)` method result to a complete `Search` object. Search has a property named results of type `Search.Result> which contains the result of the search. This change helps user to have their selected options and categories along with the result of the search.
- Changed `autocomplete(for:around:categories:filter:completionHandler:)` to work the same as `search(for:around:categories:filter:completionHandler:)` to have the same functionality.
- Changed `route(from:to:routeMode:routeOptions:completionHandler:)` to `route(from:to:mode:options:completionHandler:)`.  "route" term seemed obvious.
- All of methods run their prepration in a concurrent thread instead of main (UI) thread.
- Changed result of the `fastReverseGeocode(for:)` to be the same as `reverseGeocode(for:)`. an instance of `ReverseGeocode`.
- Added various documentation to the code itself.
- Removed unused and unnecessary files.
- Updated Examples and Playground files with the latest changes.

*__for more, see CHANGELOG.__*

## License

```
MapirServices
Copyright (c) 2019 Map info@map.ir

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
```

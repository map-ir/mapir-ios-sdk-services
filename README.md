<p align="center">
<img width="200" src="https://corp.map.ir/wp-content/uploads/2019/06/map-site-logo-1.png" alt="MapirServices Logo">
</p>

<p align="center">
<a href="https://developer.apple.com/swift/">
<img src="https://img.shields.io/badge/Swift-5.2-orange.svg?style=flat" alt="Swift 5.2">
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

ℹ️ MapirServices framework, brings you easy access to Map.ir APIs and services.

## Example

The example application is the best way to see `MapirServices` in action. Simply open the `MapirServices.xcodeproj` and run the `MapirServices Swift Example` scheme.

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
github "map-ir/mapir-ios-sdk-services"
```

Run `carthage update` to build the framework and drag the built `MapirServices.framework` into your Xcode project. 

On your application targets’ “Build Phases” settings tab, click the “+” icon and choose “New Run Script Phase” and add the Framework path as mentioned in [Carthage Getting started Step 4, 5 and 6](https://github.com/Carthage/Carthage/blob/master/README.md#if-youre-building-for-ios-tvos-or-watchos)

### Swift Package Manager

To integrate using Apple's [Swift Package Manager](https://swift.org/package-manager/), add the following as a dependency to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/map-ir/mapir-ios-sdk-services", from: "1.0.0")
]
```

### Manually

If you prefer not to use any of the a forementioned dependency managers, you can integrate MapirServices into your project manually. Simply drag the `Sources` Folder into your Xcode project. (not recommended)


## Usage
1. Get an access token from [App Registration](https://corp.map.ir/registration/) site.
2. Add a key-value pair of your access token to your project's `info.plist`. Key must be "`MapirAPIKey`" and set the access token as value.
3. First import SDK using 
    ```swift
    import MapirServices
    ```
4. Create an instance of a class you need. 
    ```swift
    // It's used for geocoding addresses (not available at this moment) and reverse-geocoding coordintes.
    let geocoder = Geocoder()
    
    // Can be used to search over Map.ir data of places and any other geographical place.
    let search = Search()
    
    // `Directions` brings routing features to you. 
    // Using `Directions` you can find multiple routes between multiple waypoints, considering restrictions and traffic situation. 
    let directions = Directions()
    
    // Use `Geofence` to manipulate fences that are associated with you API Key on Map.ir. 
    let geofence = Geofence()
    
    // `MapSnapshotter` is used to create static image of piece of the map. 
    let snapshotter = MapSnapshotter()
    
    // It's used to calculate the distance and duration between multiple origins and multiple destinations.
    let distanceMatrix = DistanceMatrix()
    
    ```
    
## License

See LICENSE file.

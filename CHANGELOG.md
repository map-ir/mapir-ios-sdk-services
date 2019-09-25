#  Changelog
## Version 0.5.0
Since 0.2.0:
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

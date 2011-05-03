Changelog
=========

Changes between 1.1.x and 1.2
-----------------------------

* Flex4 support
* Upgrade Player requirements from Flash 9 to Flash 10
* LonLat has been renamed to Location
* Fix Grid issues
* KML support improvements
* FxMap class has been greatly improved and simplified. OpenScales now set map attributes of controls automatically even if they are in some other Flex Container at any level
* Massive code and API cleanup
* Huge improvement of drag smoothness
* Improved ASDoc
* Gesture handler in order to pan and zoom map on AIR 2.5 android devices
* Mobile Tracker AIR example
* Reprojection fix in FeatureLayer
* Better tween zoom smoothness
* Better image quality when zooming
* Layer tweenOnZoom property in order to disable tween effect per layer (usefull for POI layers)
* Unit tests can now be run in Flash Builder 4, so openscales-testing module has been removed 
* inRange is now calculated from min/maxResolution instead of min/maxZoomLevels
* Feature layer now display by default at all resolutions
* Better performances with many features
* New desktop AIR application : KML viewer
* New mobile AIR application : MobileTracker
* All controls and examples have been upgraded to Flex4
* No more isBaselayer property on Layer classes. Baselayer is now only a reference to the layer that define projection and resolutions
* A XML schema is available in order to validate your xml configuration.
* New OpenScales Viewer module, intended to allow OpenScales configuration without writting any AS3 ou Flex code
* XML configuration API improvements
* Move classes from control to fx sub package
* Improve MapEvent.MOVE events to manage zoom and pan in one event, in order to be consistent with moveTo methods that can both move and pan map.
* Fix zoom transition, and improve it smoothness in fx example
* Brand new OverviewMap, also available as pure AS3 control
* TMS support fixes

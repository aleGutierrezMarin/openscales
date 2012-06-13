Changelog
=========

Changes between 2.1.1 and 2.1.2
-------------------------------
* Javascript API to control swf from your HTML pages
* defaults.css includes components default skins (only new component for now)
* Fix bug from Shane StClair (FxMap.zoomToExtent)
* Adding CSW request sender, CSW Format with GMD and DC format for metadata reading
* Adding a blinkMarker parameter to activate a blink animation on the marker of OpenLSSearch component.
* Add abstract property to Layer
* Add IIPImage client (cf IIPImageViewer)
* Add navigation history logging (see the core class NavigationHistoryLogger and the control NavigationHistoryBrowser)
* New control: AddExternalLayer (and its default skin AddExternalLayerDefaultSkin) which allows to add OGC WxS using a GetCap query on any valide server. Add of KML/GPX & GeoRSS layers is also supported (from local file system or URL)
* Refactor i18n: Catalog now dispatches event when active locale changes .This allows to listen for locale changes without having access to the Map. For backward compatibility, Map instances still dispatche LOCALE_CHANGED events.

Changes between 2.1.0 and 2.1.1
-------------------------------
* Allowing Pan and Zoom while drawin features
* improving overall performances while requesting tiles
* improving center changed performances
* add FxOSM
* fix OSM layers shift
* Adding CSW request sender, CSW Format with GMD and DC format for metadata reading
* Changing the way of editing path and polygon. Now add a virtual vertice inbetween two real vertice instead of a vertice under the mouse
* Changing default styles for points, lines and polygones.
* Changing style when a feature is overed.

Changes between 2.0.0 and 2.1.0
-------------------------------

* BingMaps support
* WMTS default value is image/jpeg
* "name" attribute is separated in "identifier" and "displayedName" in Layer class
* Improved label style for drawing tools
* Renamed genLocale method to addLocale in Locale
* Fix axis order management for openLS search
* Features now holds 2 Geometry: one in original projection, another in map projection.


changes between 1.2.1 and 2.0.0
-------------------------------
* No more baselayer
* Freezoom
* Begining of tile stretching to use different projections for raster layers
* Better rendering
* Replacement of zoom level with resolutions
* Usage of ProProjection instead of String
* i18n
* Restricted extents on layers
* Support multi projection on layer
* Layer legend support
* Remove gteween dependency

* WFS 2.0 support
* WMS 1.3 support
* WMTS 1.0.0 support
* Basic WFTS support
* GML 3.2.1 support
* GPX 1.0 and 1.1 support
* GeoRSS
* better KML support
* Add graticule layers
* WMC parser


* New capabilities component allowing easy import of WFS,WMS,WMTS,KML,GPX,GeoRss layers
* New overviewmapratio (zooming the same way the map change)
* New dataoriginator control to display logos related to layers originator
* Numeric scale control
* Language switcher control
* Several minor components: Copyright, Term of services, permanent logo
* Some controls can be iconified
* Layer catalog control
* New edition tools
* Export feature layers (only KML for now)

* Keyboard handler for keyboard navigation
* Double click handler
* Mouse handler

* Fix lot of bugs

* Xml configuration, no more maintained. You should use WMC parser now.

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

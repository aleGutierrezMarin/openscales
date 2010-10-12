Software design
===============

Modules
-------

OpenScales is composed by different modules (technology used between parenthesis) :

* **openscales-core** (ActionScript 3 library) : core modules that contains main classes like  Map, Layer, Handler ...
* **openscales-proj4as** (ActionScript 3 library) : projection support used to display layers with different projections (EPSG:4326, EPSG:90013) on the same map
* **openscales-geometry** (ActionScript 3 library) : Geometry classes like Location or Polygon
* **openscales-fx** (Flex library) : since openscales-core is developed in pure ActionScript 3 for size and performance reasons, openscales-fx provide some Flex components and wrappers useful to build easily OpenScales based applications using the power of Flex components
* **openscales-as-example** (ActionScript 3 application) : pure ActionScript 3 demo application
* **openscales-fx-examples** (Flex application) : sample Flex demo intended to show code samples and functionalities to application developers
* **openscales-kml-viewer** (AIR application) : desktop application demo build with AIR
* **openscales-mobile-tracker** (AIR application) : mobile application demo build with AIR
* **openscales-viewer** (SWF application) : Flex application that can configure a map dynamically thanks to a xml file URL passed as configurationUrl flashvar paramaeter

Key classes
-----------

OpenScales is composed by the following key concepts :

* **Map** : the map is the main class in OpenScales. A map allows to display one or more layers on a specified extent. Extent and zoom level can change based on user input like mouse or keyboard.
* **Layer** : a layer is a mapping data sources, usually available on a specific extent and zoom level ranges. There is 2 main kinds of layer :
	* **Feature layer** : data are geometries like points or polygons with some attributes and style information
	* **Raster layer** : data are geolocalized pictures
* **Handler** : handlers listen to user input (mouse, keyboard) to move the map, zoom, draw features, etc.
* **Controls** : GUI components used to display buttons, sliders that allows to control the map

Software design
---------------

OpenScales use the Map as a bus event useful for communication between modules in a loosely coupled way. For example, if you want to display a popup when a user click on a KML point feature, add a SelectFeatureHandler on your map and do a map.addEventListener(FeatureEvent.FEATURE_SELECTED, onFeatureSelected) in your application. You will be able to display a popup that will show feature attributes in the popup content.

When building your OpenScales based application, you will usually do this : listen to OpenScales events (MapEvent, LayerEvent, FeatureEvent) and build your own functionalities within a custom Flex user interface. Check openscales-fx-examples for more code samples.

If you need to support a new kind of Layer, for example, you will usually extend existing class like Layer, Grid of FeatureLayer to implements what you need. Feel free to send a patch on openscales.org site if you think this functionality may be integrated in our codebase.


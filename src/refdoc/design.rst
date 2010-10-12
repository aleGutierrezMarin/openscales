Software design
===============

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


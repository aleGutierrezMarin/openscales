Development environment
=======================

Reference development intallation
---------------------------------

Developing an application based on OpenScales is possible with :

* `Flash Builder 4 <http://www.adobe.com/products/flashbuilder/>`_ (reference development environment)
* `Flash Develop <http://www.flashdevelop.org/>`_
* Any editor of your choice, with following requirements installed :
	* `Oracle Java 6 SDK <http://www.oracle.com/technetwork/java/javase/downloads/index.html>`_
	* `Flex SDK 4.1 <http://opensource.adobe.com/wiki/display/flexsdk/Download+Flex+4>`_
	* `Flash player debugger 10.1 <http://www.adobe.com/support/flashplayer/downloads.html>`_
	* `Maven 3 <http://maven.apache.org>`_

Quick start with Flash Builder 4
--------------------------------

* Run Flash Builder 4
* File -> New -> Flex Project, set project name and click on finish
* Create a libs directory where you put following libraries that are distributed in OpenScales 1.2 package :
	* gtween-2.0.1.swc
	* as3corelib-0.92.1.swc
	* openscales-core-1.2.swc
	* openscales-fx-1.2.swc
	* openscales-proj4as-1.2.swc
	* openscales-geometry-1.2.swc
* Right click on your project -> Properties -> Flex build path -> Library path -> Add SWC folder -> libs -> OK -> OK
* Start to develop your application ! You can copy and paste code from samples available in the documentation

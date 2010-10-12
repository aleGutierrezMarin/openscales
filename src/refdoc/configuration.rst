Configuration
=============

There is different ways to configure OpenScales for your need ...

ActionScript API
----------------

The first way to configure your OpenScales map is thanks to the ActionScript API.

.. code-block:: as3

	package {
		import flash.display.Sprite;
		
		import org.openscales.core.Map;
		import org.openscales.core.control.LayerManager;
		import org.openscales.core.control.MousePosition;
		import org.openscales.core.handler.mouse.DragHandler;
		import org.openscales.core.handler.mouse.WheelHandler;
		import org.openscales.core.layer.osm.Mapnik;
		import org.openscales.geometry.basetypes.Bounds;
		import org.openscales.geometry.basetypes.Location;
		import org.openscales.geometry.basetypes.Size;

		[SWF(width='1200',height='700')]
		public class OpenscalesApplication extends Sprite {
			protected var _map:Map;

			public function OpenscalesApplication() {
				_map=new Map();
				_map.size=new Size(1200, 700);

				// Add layers to map
				var mapnik:Mapnik=new Mapnik("Mapnik"); // a base layer
				//mapnik.proxy = "http://openscales.org/proxy.php?url=";
				mapnik.maxExtent = new Bounds(-20037508.34,-20037508.34,20037508.34,20037508.34,mapnik.projection);		
				_map.addLayer(mapnik);

				_map.addControl(new MousePosition());
				_map.addControl(new LayerManager());
				
				_map.addHandler(new WheelHandler());
				_map.addHandler(new DragHandler());

				// Set the map center
				_map.center=new Location(538850.47459,5740916.1243,mapnik.projection);
				_map.zoom=5;
							
				this.addChild(_map);
			}
		}
	}


Flex MXML components
--------------------

The second  way to configure your OpenScales map is thanks to the ActionScript API. If you want to use also ActionScript API, you can retreive
a map instance as shown in the example.

Don't make confusion between :

* fxMap : it is a <Map /> component, wich is a Flex wrapper provided to allow MXML based configuration (org.openscales.fx.FxMap class)
* map : it is a Map (org.openscales.core.Map) instance. You can get the Map instance from a <Map id="fxMap"/> component thanks to fxMap.map.

.. code-block:: mxml

	<?xml version="1.0" encoding="utf-8"?>
	<s:Group xmlns="http://openscales.org" xmlns:fx="http://ns.adobe.com/mxml/2009"
			 xmlns:s="library://ns.adobe.com/flex/spark" width="100%" height="100%"
			 creationComplete="creationCompleteHandler(event)">
		
		<fx:Script>
			<![CDATA[
				import mx.events.FlexEvent;
				
				import org.openscales.core.Map;
				

				protected function creationCompleteHandler(event:FlexEvent):void
				{
					var map:Map = fxMap.map;
					trace(map.center.toString());
				}

			]]>
		</fx:Script>
		
		<Map id="fxMap" width="100%" height="100%" zoom="12" center="4.833,45.767">
			
			<Mapnik name="Mapnik" proxy="http://openscales.org/proxy.php?url="/>
			
			<DragHandler/>
			<WheelHandler/>
			
			<Spinner x="{width / 2}" y="{height / 2}"/>
			<MousePosition x="10" y="{height-20}" displayProjection="EPSG:4326"/>
			<ScaleLine x="{width-100-10}" y="{height-80}"/>
			
			<TraceInfo x="{width-200}" y="0" />
			
			<ControlPanel x="10" y="10" width="140" title="Navigation" visible="false">
				<Pan />
				<s:HGroup width="100%">
					<Zoom />
					<s:VGroup width="100%" horizontalAlign="right" verticalAlign="top">
						<ZoomBox />
					</s:VGroup>
				</s:HGroup>
			</ControlPanel>
			
		</Map>
		
	</s:Group>


XML configuration
-----------------

A usual question, especially from Javascript developpers, is how do I customize OpenScales on runtime ? Indeed, unlike Javascript, ActionScript produce compile (SWF) application.

To customize OpenScales at runtime, you can use XML configuration to configure your application. When OpenScales is integrated in a professional application, the XML configuration file is usually generated dynamically thanks to server side technology like PHP, Ruby or JSP.

You can check the following sample xml configuration file to build your own. A XML schema will be provided in 1.2 release. To use this functionality, check Map and Configuraton classes AsDocs.

.. code-block:: xml

	<?xml version="1.0" encoding="UTF-8"?>
	<Map xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
		 xsi:noNamespaceSchemaLocation="http://openscales.org/schema/openscales-configuration-1.2.xsd"
		 name="xmlMap" width="600" height="400" maxExtent="-180,-90,180,90" zoom="4"
		 proxy="http://openscales.org/proxy.php?url=">

		<Layers>
			<Mapnik name="mapnik" maxExtent="-20037508.34,-20037508.34,20037508.34,20037508.34" />
			<CycleMap name="cycle" maxExtent="-20037508.34,-20037508.34,20037508.34,20037508.34" alpha="0.5" />
		</Layers>

		<Handlers>
			<DragHandler />
			<WheelHandler />
		</Handlers>

		<Controls>
			<LayerManager />
		</Controls>

		<Custom>
			<MyCustomElement />
		</Custom>
	</Map>

You can use the following XML schema in order to validate in your developement environment or with your prefered server technology (Java, PHP, Python) your xml configuration files : http://openscales.org/schema/openscales-configuration-1.2.xsd

OpenScales Viewer
-----------------

OpenScales Viewer is a simple FLex SWF file provided in order to allow you to configure OpenScales without any ActionScript or Flex source file. In order to use it, simply use the openscales-viewer.swf and use the configurationUrl flashvar in order to pass as parameter the xml configuration file URL.

We advise you :
* To use `Swfobject <http://code.google.com/p/swfobject/>`_ library in order to integrate it in your web pages
* To validate on serverside each generated configuration thanks to http://openscales.org/schema/openscales-configuration-1.2.xsd (there is no Flex based XML schema validator, so it won't be checked on client side.)
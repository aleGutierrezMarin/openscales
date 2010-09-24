package org.openscales.core.configuration
{
	import flash.geom.Point;
	
	import org.openscales.basetypes.Bounds;
	import org.openscales.basetypes.Location;
	import org.openscales.core.Map;
	import org.openscales.core.Trace;
	import org.openscales.core.basetypes.maps.HashMap;
	import org.openscales.core.control.Control;
	import org.openscales.core.control.LayerSwitcher;
	import org.openscales.core.control.MousePosition;
	import org.openscales.core.control.PanZoom;
	import org.openscales.core.control.ScaleLine;
	import org.openscales.core.handler.Handler;
	import org.openscales.core.handler.feature.DragFeatureHandler;
	import org.openscales.core.handler.feature.SelectFeaturesHandler;
	import org.openscales.core.handler.mouse.BorderPanHandler;
	import org.openscales.core.handler.mouse.ClickHandler;
	import org.openscales.core.handler.mouse.DragHandler;
	import org.openscales.core.handler.mouse.WheelHandler;
	import org.openscales.core.layer.FeatureLayer;
	import org.openscales.core.layer.Layer;
	import org.openscales.core.layer.ogc.WFS;
	import org.openscales.core.layer.ogc.WMS;
	import org.openscales.core.layer.ogc.WMSC;
	import org.openscales.core.layer.osm.Mapnik;
	import org.openscales.core.layer.params.ogc.WMSParams;
	import org.openscales.core.security.AbstractSecurity;
	import org.openscales.core.security.ign.IGNGeoRMSecurity;
	import org.openscales.core.style.Rule;
	import org.openscales.core.style.Style;
	import org.openscales.core.style.fill.SolidFill;
	import org.openscales.core.style.marker.Marker;
	import org.openscales.core.style.marker.WellKnownMarker;
	import org.openscales.core.style.stroke.Stroke;
	import org.openscales.core.style.symbolizer.LineSymbolizer;
	import org.openscales.core.style.symbolizer.PointSymbolizer;
	import org.openscales.core.style.symbolizer.PolygonSymbolizer;
	import org.openscales.proj4as.ProjProjection;
	
	/**
	 * Sample XML OpenScales configuration format.
	 * Have a look to openscales-core/src/test/resources/configuration/sampleMapConfOk.xml for a sample valid XML file
	 * 
	 * TODO : create an XML schema
	 * 
	 * Don't forget : the map is create in actionScript, so values in the XML for the size are in pixel.
	 * If you want to use the map in your flex application (and thus use widht and height in percent), you'll 
	 * have to redefine the size in you mxml.
	 */
	public class Configuration implements IConfiguration
	{
		protected var _config:XML;
		protected var _styles:Object = {};
		
		public function Configuration(config:XML = null) {
			this.config = config;
		}
		
		public function configureMap(map:Map):void {
			this.loadStyles();
			this.beginConfigureMap(map);
			this.middleConfigureMap(map);
			this.endConfigureMap(map);
		}
		
		/* load Styles */
		private function loadStyles():void {
			var styles:XMLList=config.Styles.*;
			var style:Style;
			var xmlNode:XML
			for each(xmlNode in styles){
				if(xmlNode.@id=="")
					continue;
				this._styles[xmlNode.@id.toString()] = this.parseStyle(xmlNode);
				Trace.log("Find new style");
			}
			
		}
		
		public function beginConfigureMap(map:Map):void {
			
			// Parse the XML (children of Layers, Handlers, Controls ...)    
			if(config.@id != ""){
				map.name = config.@id;
			}
			if(String(config.@proxy) != ""){
				map.proxy = config.@proxy;
			}
			
			if(String(config.@width) != ""){
				map.width = Number(config.@width);
			}
			if(String(config.@height) != ""){
				map.height = Number(config.@height);
			}
			map.x = Number(config.@x);
			map.y = Number(config.@y);
			
			if(String(config.@maxExtent) != ""){
				map.maxExtent = Bounds.getBoundsFromString(config.@maxExtent,Layer.DEFAULT_PROJECTION);
			}
			
		}
		
		public function middleConfigureMap(map:Map):void {
			//add layers
			map.addLayers(layersFromMap);
			
			//add controls
			for each (var xmlControl:XML in controls){
				var control:Control = this.parseControl(xmlControl);
				if (control != null) {
					map.addControl(control);
				}
			}
			//add handlers
			for each (var xmlHandler:XML in handlers){
				var handler:Handler = this.parseHandler(xmlHandler);
				if (handler != null){
					handler.map = map;
				}
				
			}
			//add  securities egg:IGNGeoRMSecurity
			for each(var xmlSecurity:XML in securities){
				var security:AbstractSecurity=this.parseSecurity(xmlSecurity,map);
				if(xmlSecurity.@layers!=null && map!=null){
					var layers:Array = xmlSecurity.@layers.split(",");
					for each (var name:String in layers) {
						var layer:Layer=map.getLayerByName(name);
						if(layer!=null) layer.security=security;
					}
				}
			}
		}
		
		public function endConfigureMap(map:Map):void {
			if(config.@zoom != ""){
				map.zoom = Number(config.@zoom);
			}
			if((config.@lon != "") && (config.@lat != "")){
				if(config.@projection && config.@projection != "") {
					map.center = new Location(Number(config.@lon), Number(config.@lat),ProjProjection.getProjProjection(config.@projection));
				} else if(map.baseLayer) {
					map.center = new Location(Number(config.@lon), Number(config.@lat),map.baseLayer.projection);
				} else {
					map.center = new Location(Number(config.@lon), Number(config.@lat),Layer.DEFAULT_PROJECTION);
				}
			}
		}
		
		public function set config(value:XML):void {
			this._config = value;
		}
		
		public function get config():XML {
			return this._config;
		}
		
		public function get layersFromMap():Vector.<Layer> {
			//we search direclty all nodes contained in <Layers> </Layers>
			var layersNodes:XMLList = config.Layers.*;
			
			//the tab which contains layers to add
			var layers:Vector.<Layer> = new Vector.<Layer> ();
			
			if (layersNodes.length() == 0) {
				Trace.log("There's no layer on the map");return layers;
			} 
			// Manage the different catalog in the file
			for each(var node:XML in layersNodes){
				var layer:Layer = this.parseLayer(node);
				//Add the layer if it's correct
				if(layer){layers.push(layer);}
			}                                        
			return layers;
		}
		
		public function get layersFromCatalog():Vector.<Layer> {                  
			if (this.catalog.length == 0) {
				Trace.log("There's no layer on the catalog");return layers;
			}
			
			var layersNodes:XMLList = config.Catalog..Category.*;
			var layers:Vector.<Layer> = new Vector.<Layer> ();             
			
			for each(var layerXml:XML in layersNodes)
			{
				if(layerXml.name() != "Category"){
					var layer:Layer = this.parseLayer(layerXml);
					if (layer) {
						layers.push(layer);
					}
				}
			}
			return layers;
		}
		
		public function get catalog():XMLList {
			var catalogNode:XMLList = config.Catalog.*;
			return catalogNode;
		}
		
		public function get custom():XML {
			var customNode:XML = XML(config.Custom);
			return customNode;
		}
		
		public function get handlers():XMLList {
			var handlersNode:XMLList = config.Handlers.*;
			return handlersNode;
		}
		
		public function get controls():XMLList {
			var controlsNode:XMLList = config.Controls.*;
			return controlsNode;
		}
		public function get securities():XMLList{
			var securitiesNode:XMLList=config.Securities.*;
			return securitiesNode;
		}
		public function parseLayer(xmlNode:XML):Layer {
			// The layer which will return
			var layer:Layer=null;
			
			//Loading params
			var isBaseLayer:Boolean;
			var visible:Boolean;         
			// parse params in boolean
			if(xmlNode.@isBaseLayer == "true"){isBaseLayer=true;}
			else{isBaseLayer=false;}
			if(xmlNode.@visible == "false"){visible=false;}
			else{visible = true;}
			
			var name:String=xmlNode.@name;
			var proxy:String = null;
			if(String(xmlNode.@proxy) != "")
			{
				proxy=xmlNode.@proxy;
			}
			
			var projection:String=xmlNode.@projection;
			var resolution:Array=null;
			if(xmlNode.@resolutions!=null && xmlNode.@resolutions=="") 
			{
				resolution=xmlNode.@resolutions.split(",");
				for(var i:int =0;i<resolution.length;i++){
					resolution[i]=int(resolution[i]);
				}   
			}             
			// Case where the layer is WMS or WMSC
			if(xmlNode.name()== "WMSC" || xmlNode.name()== "WMS"){
				var type:String = xmlNode.name();
				
				//Params for layer                 
				var urlWMS:String=xmlNode.@url;
				var paramsWms:WMSParams;
				
				//Params for WMSparams
				var layers:String=xmlNode.@layers; 
				var format:String=xmlNode.@format; 
				
				var transparent:Boolean;
				if(xmlNode.@transparent == "true"){transparent=true;}
				else{transparent = false;}
				
				var tiled:Boolean;
				if(xmlNode.@tiled == "true" || xmlNode.@tiled == ""){tiled=true;}
				else{tiled = false;}
				
				var styles:String=xmlNode.@styles; 
				var bgcolor:String=xmlNode.@bgcolor;
				
				
				
				paramsWms = new WMSParams(layers,format,transparent,tiled,styles,bgcolor);
				paramsWms.exceptions=xmlNode.@exceptions;
				
				switch(type){
					case "WMSC":{
						Trace.log("Configuration - Find WMSC Layer : " + xmlNode.name());                                
						// We create the WMSC Layer with all params
						var wmscLayer:WMSC = new WMSC(name,urlWMS,layers);
						wmscLayer.visible=visible;
						wmscLayer.projection = new ProjProjection(projection);
						wmscLayer.proxy = proxy;                  	   
						wmscLayer.maxExtent = Bounds.getBoundsFromString(xmlNode.@maxExtent,wmscLayer.projection);
						wmscLayer.params = paramsWms;
						layer=wmscLayer;
						break;
					}
						
					case "WMS":{
						Trace.log("Configuration - Find WMS Layer : " + xmlNode.name());
						// We create the WMS Layer with all params
						var wmslayer:WMS = new WMS(name,urlWMS,layers);
						wmslayer.visible = visible;
						wmslayer.proxy = proxy;
						wmslayer.projection = new ProjProjection(projection);                       
						wmslayer.maxExtent = Bounds.getBoundsFromString(xmlNode.@maxExtent,wmslayer.projection);
						wmslayer.params = paramsWms;
						layer=wmslayer;
						break;
					}                                  
				}
				if(resolution!=null) layer.resolutions=resolution;                 
			}
				// Case when the layer is WFS 
			else if(xmlNode.name() == "WFS"){
				
				//params for layer
				var urlWfs:String=xmlNode.@url;
				
				var capabilitiesVersion:String = String(xmlNode.@capabilitiesVersion);
				
				var use110Capabilities:Boolean;
				if(xmlNode.@use110Capabilities == "true"){use110Capabilities=true;}
				else{use110Capabilities = false;}
				
				var useCapabilities:Boolean=xmlNode.@useCapabilities;
				if(xmlNode.@useCapabilities == "true"){useCapabilities=true;}
				else{useCapabilities = false;}
				
				var capabilities:HashMap;
				
				Trace.log("Configuration - Find WFS Layer : " + xmlNode.name());
				
				// We create the WFS Layer with all params
				var wfsLayer:WFS = new WFS(name,urlWfs,xmlNode.@typename);
				wfsLayer.visible = visible;
				wfsLayer.proxy = proxy;
				wfsLayer.useCapabilities = useCapabilities;
				wfsLayer.capabilities = capabilities;
				wfsLayer.projection = new ProjProjection(projection);
				
				if(String(xmlNode.@style) !="")
				{
					if(this._styles[xmlNode.@style.toString()])
						wfsLayer.style = this._styles[xmlNode.@style.toString()];
					else
						wfsLayer.style = this.getDefaultStyle(String(xmlNode.@style));
				}
				
				if (String(xmlNode.@minZoomLevel) != "" ) {
					wfsLayer.minZoomLevel = Number(xmlNode.@minZoomLevel);
				}
				if (String(xmlNode.@minZoomLevel) != "") {
					wfsLayer.maxZoomLevel = Number(xmlNode.@maxZoomLevel);
				}
				wfsLayer.capabilitiesVersion = capabilitiesVersion;
				layer=wfsLayer;
			}
				// Case when the layer is Mapnik
			else if(xmlNode.name() == "Mapnik"){
				Trace.log("Configuration - Find Mapnik Layer : " + xmlNode.name());
				// We create the Mapnik Layer with all params
				var mapnik:Mapnik=new Mapnik("Mapnik"); // a base layer
				mapnik.maxExtent = Bounds.getBoundsFromString(xmlNode.@maxExtent,mapnik.projection);
				layer=mapnik;
			}
			else if(xmlNode.name() == "FeatureLayer"){
				// Case when the layer is FeatureLayer
				var featurelayer:FeatureLayer = new FeatureLayer(name);
				featurelayer.projection = new ProjProjection(projection);
				layer = featurelayer;
			} else {
				// Case when the layer is unknown
				Trace.error("Configuration - Layer unknown or not managed : "+xmlNode.name());
			}
			
			if(layer != null){
				if((String(xmlNode.@numZoomLevels) != "") && (String(xmlNode.@maxResolution) != "")){
					layer.generateResolutions(Number(xmlNode.@numZoomLevels), Number(xmlNode.@maxResolution));
				}
				if(String(xmlNode.@resolutions) != ""){
					layer.resolutions = String(xmlNode.@resolutions).split(",");
				}
			}
			//opacity
			if(String(xmlNode.@alpha))
			{
				layer.alpha = Number(xmlNode.@alpha);
			}
			
			//Init layer parameters
			return layer;
		}
		/**
		 * 
		 **/
		
		protected function parseStyle(styleNode:XML):Style {
			var style:Style = new Style();
			var ruleNodes:XMLList = styleNode.rules.*;
			var i:uint = 0;
			for each (var xmlRule:XML in ruleNodes){
				
				style.rules[i] = this.parseRule(xmlRule);
				i++;
			}
			
			return style;
			
		}
		
		protected function parseRule(xmlRule:XML):Rule{
			
			var rule:Rule = new Rule();
			var symbolizer:XMLList = xmlRule.*;
			
			for each (var xmlSymbolizer:XML in symbolizer){
				if(xmlSymbolizer.name() =="PointSymbolizer"){
					rule.symbolizers.push(this.parsePointSymbolizer(xmlSymbolizer));
				}else if(xmlSymbolizer.name() =="PolygonSymbolizer"){
					rule.symbolizers.push(this.parsePolygonSymbolizer(xmlSymbolizer));
				}else if(xmlSymbolizer.name() =="LineSymbolizer"){
					rule.symbolizers.push(this.parseLineSymbolizer(xmlSymbolizer));
				}
			}
			return rule;
		}
		
		protected function parsePointSymbolizer(xmlSymbolizer:XML):PointSymbolizer{
			var xmlMakers:XML = xmlSymbolizer.child(0);
			var poinSymbolizer:PointSymbolizer;
			var marker:Marker;
			
			if(xmlMakers.name() =="WellKnownMarker"){
				var fill:SolidFill = null;
				var stroke:Stroke = null;
				for each (var fillAndStroke:XML in xmlMakers.children()){
					if(fillAndStroke.name() == "SolidFill"){
						fill = new SolidFill(fillAndStroke.@color,fillAndStroke.@opacity);
					}else if(fillAndStroke.name() == "stroke"){
						stroke = new Stroke(fillAndStroke.@color,fillAndStroke.@width,fillAndStroke.@opacity,fillAndStroke.@linecap,fillAndStroke.@linejoin);
					}
				}
				marker = new WellKnownMarker(xmlMakers.@wellKnowName,null,null,xmlMakers.@size,xmlMakers.@opacity,xmlMakers.@rotation);
				poinSymbolizer = new PointSymbolizer(marker);
				
			}else if(xmlMakers.name() =="Marker"){
				marker = new Marker(xmlMakers.@size,xmlMakers.@opacity,xmlMakers.@rotation);
			}
			return poinSymbolizer;
		}
		
		protected function parsePolygonSymbolizer(xmlSymbolizer:XML):PolygonSymbolizer{
			
			var polygonSymbolizer:PolygonSymbolizer;
			var fill:SolidFill = null;
			var stroke:Stroke = null;
			for each (var fillAndStroke:XML in xmlSymbolizer.children()){
				if(fillAndStroke.name() == "fill"){
					var solidFill:XML = fillAndStroke.children()[0];
					if(solidFill.name() == "SolidFill"){
						fill = new SolidFill(solidFill.@color,solidFill.@opacity);
					}
				}else if(fillAndStroke.name() == "stroke"){
					stroke = new Stroke(fillAndStroke.@color,fillAndStroke.@width,fillAndStroke.@opacity,fillAndStroke.@linecap,fillAndStroke.@linejoin);
				}
			}
			polygonSymbolizer = new PolygonSymbolizer(fill,stroke);
			
			return polygonSymbolizer;
		}
		
		protected function parseLineSymbolizer(xmlSymbolizer:XML):LineSymbolizer{
			var xmlStroke:XML = xmlSymbolizer.child(0);
			var lineSymbolizer:LineSymbolizer;
			var stroke:Stroke = null;
			stroke = new Stroke(xmlStroke.@color,xmlStroke.@width,xmlStroke.@opacity,xmlStroke.@linecap,xmlStroke.@linejoin);
			
			lineSymbolizer = new LineSymbolizer(stroke)
			
			return lineSymbolizer;
		}
		
		
		
		
		
		protected function getDefaultStyle(defaultStyle:String):Style {
			if(defaultStyle == "DefaultCircleStyle"){
				return Style.getDefaultCircleStyle();
			}
			if(defaultStyle == "DefaultLineStyle"){
				return Style.getDefaultLineStyle();
			}
			if(defaultStyle == "DefaultLineStyle"){
				return Style.getDefaultLineStyle();
			}
			if(defaultStyle == "DefaultPointStyle"){
				return Style.getDefaultPointStyle();
			}
			if(defaultStyle == "DefaultSurfaceStyle"){
				return Style.getDefaultSurfaceStyle();
			}
			if(defaultStyle == "DrawLineStyle"){
				return Style.getDrawLineStyle();
			}
			if(defaultStyle == "DrawSurfaceStyle"){
				return Style.getDrawSurfaceStyle();
			}
			
			Trace.error("you must define a style for feature layer");
			return null;
		}
		
		protected function parseHandler(xmlNode:XML):Handler {
			var handler:Handler;
			if(xmlNode.name() == "DragHandler"){
				handler = new DragHandler();
				if(String(xmlNode.@active) == "true"){handler.active = true;}
				else {handler.active = false};
			}
			else if (xmlNode.name() == "WheelHandler"){
				handler = new WheelHandler();
				if(String(xmlNode.@active) == "true"){handler.active = true;}
				else {handler.active = false};
			}
			else if (xmlNode.name() == "ClickHandler"){
				handler = new ClickHandler();
				if(String(xmlNode.@active) == "true"){handler.active = true;}
				else {handler.active = false};
			}
			else if (xmlNode.name() == "BorderPanHandler"){
				handler = new BorderPanHandler();
				if(String(xmlNode.@active) == "true"){handler.active = true;}
				else {handler.active = false};
			}
			else if (xmlNode.name() == "DragFeatureHandler"){
				handler = new DragFeatureHandler();
				if(String(xmlNode.@active) == "true"){handler.active = true;}
				else {handler.active = false};
			}
			else if (xmlNode.name() == "SelectFeaturesHandler"){
				handler = new SelectFeaturesHandler();
				if(String(xmlNode.@active) == "true"){handler.active = true;}
				else {handler.active = false};
			}
			else {
				Trace.error("Handler unknown !");
			}   
			return handler;
		}
		
		protected function parseControl(xmlNode:XML):Control {
			var control:Control = null;
			if(xmlNode.name() == "LayerSwitcher"){
				var layerSwitcher:LayerSwitcher = new LayerSwitcher();
				layerSwitcher.name = xmlNode.@id;
				layerSwitcher.x = xmlNode.@x;
				layerSwitcher.y = xmlNode.@y;
				control = layerSwitcher;
			}
			else if(xmlNode.name() == "PanZoom"){
				var pan:PanZoom = new PanZoom();
				pan.name = xmlNode.@id;
				pan.x = xmlNode.@x;
				pan.y = xmlNode.@y;
				control = pan;
			} 
			else if(xmlNode.name() == "ScaleLine"){
				var scaleLine:ScaleLine = new ScaleLine();
				scaleLine.name = xmlNode.@id;
				scaleLine.x = xmlNode.@x;
				scaleLine.y = xmlNode.@y;
				control = scaleLine;
			}     
			else if(xmlNode.name() == "MousePosition"){
				var mousePosition:MousePosition = new MousePosition();
				mousePosition.name = xmlNode.@id;
				mousePosition.displayProjection = new ProjProjection(String(xmlNode.@displayProjection));
				control = mousePosition;
			}
			return control;         
		}
		protected function parseSecurity(xmlNode:XML,map:Map):AbstractSecurity{
			var security:AbstractSecurity=null;
			if(xmlNode.name()=="IGNGeoRMSecurity"){
				Trace.log("bleh1");
				if(map!=null && xmlNode.@key!=null)
					security=new IGNGeoRMSecurity(map,xmlNode.@key,xmlNode.@proxy);
			}
			return security;
		}
		
	}
}

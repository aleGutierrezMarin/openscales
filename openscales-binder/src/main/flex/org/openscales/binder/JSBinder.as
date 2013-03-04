package org.openscales.binder
{
	import flash.external.ExternalInterface;
	import flash.system.Security;
	import flash.utils.ByteArray;
	
	import org.openscales.core.Map;
	import org.openscales.core.basetypes.Resolution;
	import org.openscales.core.events.LayerEvent;
	import org.openscales.core.events.MapEvent;
	import org.openscales.core.json.GENERICJSON;
	import org.openscales.core.layer.Layer;
	import org.openscales.core.layer.VectorLayer;
	import org.openscales.core.utils.Util;
	import org.openscales.geometry.Geometry;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Size;
	import org.openscales.proj4as.ProjProjection;
	
	public class JSBinder
	{
		[Embed(source="/assets/interfaceViewer.js",mimeType="application/octet-stream")]
		private var _interfaceViewer:Class;
		
		private var _map:Map = null;
		private var _configured:Boolean = false;
		private var _initCallback:String = "onViewerReady";
		private var viewerid:String = null;
		
		public function JSBinder()
		{
		}
		
		/**
		 * define the callback to call when the binder is ready
		 */
		public function get initCallback():String
		{
			return _initCallback;
		}
		/**
		 * @private
		 */
		public function set initCallback(value:String):void
		{
			_initCallback = value;
		}

		/**
		 * Map associated to the JSBinder
		 */
		public function get map():Map
		{
			return this._map;
		}
		/**
		 * @private
		 */
		public function set map(value:Map):void
		{
			if(this._map && ExternalInterface.available) {
				this._map.removeEventListener(MapEvent.RELOAD, this.onMapReload);
				this._map.removeEventListener(LayerEvent.LAYER_OPACITY_CHANGED, this.onLayerChanged);
				this._map.removeEventListener(LayerEvent.LAYER_VISIBLE_CHANGED, this.onLayerChanged);
				this._map.removeEventListener(LayerEvent.LAYER_MOVED_UP, this.onLayerChanged);
				this._map.removeEventListener(LayerEvent.LAYER_MOVED_DOWN, this.onLayerChanged);
				this._map.removeEventListener(LayerEvent.LAYER_EDITED, this.onLayerChanged);
				this._map.removeEventListener(LayerEvent.LAYER_REMOVED, this.onLayerAddedOrRemoved);
				this._map.removeEventListener(LayerEvent.LAYER_ADDED, this.onLayerAddedOrRemoved);
				this._map.removeEventListener(LayerEvent.LAYER_AVAILABILITY_CHANGED, this.onLayerAvailabilityChanged);
			}
			this._map = value;
			if(this._map && ExternalInterface.available) {
				this._map.addEventListener(MapEvent.RELOAD, this.onMapReload);
				this._map.addEventListener(LayerEvent.LAYER_OPACITY_CHANGED, this.onLayerChanged);
				this._map.addEventListener(LayerEvent.LAYER_VISIBLE_CHANGED, this.onLayerChanged);
				this._map.addEventListener(LayerEvent.LAYER_MOVED_UP, this.onLayerChanged);
				this._map.addEventListener(LayerEvent.LAYER_MOVED_DOWN, this.onLayerChanged);
				this._map.addEventListener(LayerEvent.LAYER_EDITED, this.onLayerChanged);
				this._map.addEventListener(LayerEvent.LAYER_REMOVED, this.onLayerAddedOrRemoved);
				this._map.addEventListener(LayerEvent.LAYER_ADDED, this.onLayerAddedOrRemoved);
				this._map.addEventListener(LayerEvent.LAYER_AVAILABILITY_CHANGED, this.onLayerAvailabilityChanged);
				this.configureInterface();
			}
		}
		
		/**
		 * initialize the external interface
		 */
		protected function configureInterface():void {
			if(!this._configured && ExternalInterface.available) {
				Security.allowDomain("*");
				
				//Inject javascript
				var interfaceViewer:String = (new _interfaceViewer() as ByteArray).toString();
				interfaceViewer = interfaceViewer.replace("UID",ExternalInterface.objectID);
				viewerid = "OpenScales"+new Date().time.toString();
				interfaceViewer = interfaceViewer.replace("VIEWERID",viewerid);
				interfaceViewer = interfaceViewer.replace("VIEWERID",viewerid);
				ExternalInterface.call("function(){"+interfaceViewer+"}");
				
				// Registration of the ActionScript methods callable from the HTML page
				// WARNING ! the name of the methods must be with ' ' and not " ". If not, the binding do not properly work
				ExternalInterface.addCallback('setCenter', this.setCenter);
				ExternalInterface.addCallback('setResolution', this.setResolution);
				ExternalInterface.addCallback('zoomToExtent', this.zoomToExtent);
				ExternalInterface.addCallback('panMap', this.pan);
				ExternalInterface.addCallback('zoomIn', this.zoomIn);
				ExternalInterface.addCallback('zoomOut', this.zoomOut);
				ExternalInterface.addCallback('setLayerVisibility', this.setLayerVisibility);
				ExternalInterface.addCallback('setLayerOpacity', this.setLayerOpacity);
				ExternalInterface.addCallback('moveLayer', this.moveLayer);
				ExternalInterface.addCallback('removeLayer', this.removeLayer);
				ExternalInterface.addCallback('setLanguage', this.setLanguage);
				ExternalInterface.addCallback('setSize', this.setSize);
				ExternalInterface.addCallback('getBounds', this.getBounds);
				ExternalInterface.addCallback('getResolution', this.getResolution);
				
				var obj:Object = new Object();
				obj.eventName = "viewerLoaded";
				this.sendEvent(obj);
				ExternalInterface.call(this._initCallback,viewerid);
				
				this._configured = true;
			}
		}
		
		/**
		 * send event to the javascript
		 * 
		 * @param obj object to send. It should contains at least an "eventName" property
		 */
		public function sendEvent(obj:Object):void {
			var jsonString:String = GENERICJSON.stringify(obj);
			ExternalInterface.call(viewerid+".dispatch", obj.eventName, jsonString, ExternalInterface.objectID);
		}
		
		/**
		 * Broadcast the mapreload event 
		 */
		private function onMapReload(event:MapEvent):void
		{
			var obj:Object = new Object();
			obj.eventName = "mapreload";
			obj.resolution = this._map.resolution.reprojectTo("EPSG:4326").value;
			var newCenter:Location = this._map.center.reprojectTo(ProjProjection.getProjProjection("EPSG:4326"));
			obj.x = newCenter.x;
			obj.y = newCenter.y;
			obj.sx = Util.degToDMS(newCenter.x).split(" ").join("").split("°").join("_").split("'").join("_").split("\"")[0];
			obj.sy = Util.degToDMS(newCenter.y).split(" ").join("").split("°").join("_").split("'").join("_").split("\"")[0];
			
			var mapExtent:Bounds = this.map.extent.reprojectTo(ProjProjection.getProjProjection("EPSG:4326"));
			obj.left = mapExtent.left;
			obj.bottom = mapExtent.bottom;
			obj.right = mapExtent.right;
			obj.top = mapExtent.top;
			
			this.sendEvent(obj);
		}
		
		/**
		 * This method is called when :
		 * 		- a layer availability is changed
		 * It builds a JSON string and send it to the HTML page by calling the triggerEvent function (defined in a javascript file and loaded in the HTML page)
		 * The JSON string informations are :
		 *		- eventName : the name of the event occured on the map
		 *		- layerIdentifier : the identifier of the layer
		 * 		- layerAvailability : the availability of the layer
		 */
		private function onLayerAvailabilityChanged(event:LayerEvent):void
		{
			var obj:Object = new Object();
			obj.eventName = "layeravailabilitychanged";
			obj.layerIdentifier = event.layer.identifier;
			obj.layerAvailability = event.layer.available;
			this.sendEvent(obj);
		}
		
		/**
		 * This function centers the map to the coordinates passed by parameter
		 * @param lon:Number - The longitude of the new center
		 * @param lat:Number - The latitude of the new center
		 * @param proj:String - The projection code associated to coordinates, default Geometry.DEFAULT_SRS_CODE
		 */
		protected function setCenter(lon:Number, lat:Number, proj:String=null):void{
			if(!this._map)
				return;
			if(!proj)
				proj = Geometry.DEFAULT_SRS_CODE;
			var _proj:ProjProjection = ProjProjection.getProjProjection(proj);
			if(!_proj)
				return;
			var loc:Location = new Location(lon, lat, _proj);
			this._map.center = loc;
		}
		
		/**
		 * This function defines the resolution of the map in decimal degrees
		 * @param value:Number - The resolution
		 * @param proj:String - The projection code associated to resolution, default Geometry.DEFAULT_SRS_CODE
		 */
		protected function setResolution(value:Number, proj:String=null):void
		{
			if(!proj)
				proj = Geometry.DEFAULT_SRS_CODE;
			var _proj:ProjProjection = ProjProjection.getProjProjection(proj);
			if(!_proj)
				return;
			this._map.resolution = new Resolution(value,_proj);
		}
		
		/**
		 * This function centers the map to the coordinates passed by parameter
		 * @param lonMin:Number - The longitude of bottom left corner
		 * @param latMin:Number - The latitude of bottom left corner
		 * @param lonMax:Number - The longitude of the top left corner
		 * @param latMax:Number - The latitude of the top left corner
		 * @param proj:String - The projection code associated to coordinates
		 */
		protected function zoomToExtent(lonMin:Number,latMin:Number,lonMax:Number,latMax:Number, proj:String=null):void {
			if(!this._map)
				return;
			if(!proj)
				proj = Geometry.DEFAULT_SRS_CODE;
			var _proj:ProjProjection = ProjProjection.getProjProjection(proj);
			if(!_proj)
				return;
			this._map.zoomToExtent(new Bounds(lonMin,latMin,lonMax,latMax,_proj));
		}
		
		/**
		 * This function changes the visibility of a layer
		 * @param name:String - The name of the layer
		 * @param bool:Boolean - The new visibility of this layer (true = visible or false = unvisible)
		 */
		protected function setLayerVisibility(name:String, bool:Boolean):void{
			if(!this._map)
				return;
			var lay:Layer = this._map.getLayerByIdentifier(name);
			if(!lay)
				return;
			lay.visible = bool;
			if(bool)
			{
				lay.redraw();
			}
		}
		
		/**
		 * This function changes the opacity of a layer
		 * @param name:String - The name of the layer
		 * @param value:Number - The new opacity of this layer (0 &gt;= value &gt;= 1)
		 */
		protected function setLayerOpacity(name:String, value:Number):void{
			if(!this._map)
				return;
			var lay:Layer = this._map.getLayerByIdentifier(name);
			if(!lay)
				return;
			lay.alpha = value;
		}
		
		/**
		 * This function changes the order of a layer
		 * @param name:String - The name of the layer
		 * @param direction:String - "UP" to move up the layer ou "DOWN" to move it down
		 */
		protected function moveLayer(name:String, direction:String):void{
			if(!this._map)
				return;
			var lay:Layer = this._map.getLayerByIdentifier(name);
			if(!lay)
				return;
			
			// Move the layer if possible
			if (direction == "DOWN")
			{
				if ((lay.zindex - 1) >= 0)
				{
					this._map.changeLayerIndexByDelta(lay, -1);
				}
			}
			else if (direction == "UP")
			{
				if((lay.zindex + 1) <= (this._map.layers.length - 1))
				{
					this._map.changeLayerIndexByDelta(lay, +1);
				}
			}
		}
		
		/**
		 * This function removes a layer from the map
		 * @param name:String - The name of the layer to remove
		 */
		protected function removeLayer(name:String):void{
			if(!this._map)
				return;
			var lay:Layer = this._map.getLayerByIdentifier(name);
			if(!lay)
				return;
			this._map.removeLayer(lay);
		}
		
		/**
		 * Return the displayed map Extent in EPSG:4326
		 */
		protected function getBounds():Object
		{
			var obj:Object = new Object();
			var mapExtent:Bounds = this.map.extent.reprojectTo(ProjProjection.getProjProjection("EPSG:4326"));
			obj.left = mapExtent.left;
			obj.bottom = mapExtent.bottom;
			obj.right = mapExtent.right;
			obj.top = mapExtent.top;
			return obj;
		}
		
		/**
		 * Return the resolution of the map in decimal degrees
		 */
		protected function getResolution():Number
		{
			var mapRes:Resolution = this.map.resolution.reprojectTo(ProjProjection.getProjProjection("EPSG:4326"));
			return mapRes.value;
		}
		
		/**
		 * This function moves the center of map from {x, y} to {x + dx, y + dy}
		 * @param dx:int - The horizontal pixel offset
		 * @param dy:int - The vertical pixel offset
		 */
		protected function pan(dx:int, dy:int):void {
			if(!this._map)
				return;
			this._map.pan(dx, dy);
		}
		
		/**
		 * This function increases the zoom level of the map by one
		 */
		protected function zoomIn():void{
			if(!this._map)
				return;
			this._map.zoomIn();
		}
		
		/**
		 * This function decreases the zoom level of the map by one
		 */
		protected function zoomOut():void{
			if(!this._map)
				return;
			this._map.zoomOut();
		}
		
		/**
		 * This function changes the language of the map
		 * @param language:String - The new language for the map in IETF 4646
		 */
		protected function setLanguage(language:String):void{
			if(!this._map)
				return;
			this._map.locale = language;
		}
		
		/**
		 * This function changes the size of the map
		 * @param width:Number - The new width of the map
		 * @param height:Number - The new height of the map
		 */
		protected function setSize(width:Number, height:Number):void{
			if(!this._map)
				return;
			this._map.size = new Size(width, height);
		}
		
		/**
		 * This method is called when :
		 * 		- the alpha of a layer changed
		 * 		- the visibility of a layer changed
		 * 		- the order of a layer changed
		 * It builds a JSON string and send it to the HTML page by calling the dispatch function (defined in a javascript file and loaded in the HTML page)
		 * The JSON string informations are :
		 *		- eventName : the name of the event occured on the map ('layerchanged')
		 *		- layerName : the name of the layer
		 * 		- layerOpacity : the opacity value of the layer
		 * 		- layerVisibility : true if the layer is visible, false otherwise
		 * 		- layerMovedUp : true if the layer has been moved up, false otherwise
		 * 		- layerMovedDown : true if the layer has been moved down, false otherwise
		 * 		- LayerEdited : true if the layer has beed edited, false otherwise
		 * 		- LayerEditable : true if the layer is editable, false otherwise
		 */
		protected function onLayerChanged(event:LayerEvent):void
		{
			var obj:Object = new Object();
			obj.eventName = "layerchanged";
			obj.layerName = event.layer.identifier;
			obj.layerOpacity = event.newOpacity;
			obj.layerVisibility = event.layer.visible;
			obj.layerMovedUp = (event.type.split(".")[1] == "layerMovedUp");
			obj.layerMovedDown = (event.type.split(".")[1] == "layerMovedDown");
			var layerEditable:Boolean = false;
			var layerEdited:Boolean = false;
			if (event.layer is VectorLayer)
			{
				layerEdited = (event.layer as VectorLayer).edited;
				layerEditable = (event.layer as VectorLayer).editable;
			}
			obj.layerEdited = layerEdited;
			obj.layerEditable = layerEditable;
			obj.displayInLayerSwitcher = event.layer.displayInLayerManager;
			this.sendEvent(obj);
		}
		
		/**
		 * This method is called when :
		 * 		- a layer is added on the map
		 * 		- a layer is removed from the map
		 * It builds a JSON string and send it to the HTML page by calling the dispatch function (defined in a javascript file and loaded in the HTML page)
		 * The JSON string informations are :
		 *		- eventName : the name of the event occured on the map ('layeradded','layerremoved')
		 *		- layerName : the name of the layer
		 */
		protected function onLayerAddedOrRemoved(event:LayerEvent):void
		{
			var obj:Object = new Object();
			obj.eventName = (event.type == LayerEvent.LAYER_ADDED) ? "layeradded" : "layerremoved";
			obj.layerName = event.layer.identifier;
			obj.layerDisplayedName = event.layer.displayedName;
			var layerEditable:Boolean = false;
			var layerEdited:Boolean = false;
			if (event.layer is VectorLayer)
			{
				layerEdited = (event.layer as VectorLayer).edited;
				layerEditable = (event.layer as VectorLayer).editable;
			}
			obj.layerEdited = layerEdited;
			obj.layerEditable = layerEditable;
			obj.displayInLayerSwitcher = event.layer.displayInLayerManager;
			
			this.sendEvent(obj);
		}
	}
}
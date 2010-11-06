package org.openscales.fx
{
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	import mx.core.IVisualElement;
	import mx.core.IVisualElementContainer;
	import mx.core.UIComponent;
	import mx.events.DragEvent;
	import mx.events.FlexEvent;
	import mx.events.ResizeEvent;
	
	import org.openscales.core.Map;
	import org.openscales.core.Trace;
	import org.openscales.core.control.IControl;
	import org.openscales.core.events.MapEvent;
	import org.openscales.core.handler.IHandler;
	import org.openscales.core.layer.Layer;
	import org.openscales.core.security.ISecurity;
	import org.openscales.fx.configuration.FxConfiguration;
	import org.openscales.fx.control.FxControl;
	import org.openscales.fx.control.FxOverviewMap;
	import org.openscales.fx.handler.FxHandler;
	import org.openscales.fx.layer.FxLayer;
	import org.openscales.fx.security.FxAbstractSecurity;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Pixel;
	import org.openscales.geometry.basetypes.Size;
	
	import spark.components.Group;
	import spark.core.SpriteVisualElement;
	
	
	[Event(name="openscalesmaploadstart", type="org.openscales.core.events.MapEvent")]
	[Event(name="openscalesmaploadcomplete", type="org.openscales.core.events.MapEvent")]
	
	/**
	 * <p>Map Flex wrapper, used to create OpenScales Flex 4 based applications.</p>
	 * <p>To use it, declare a &lt;Map /&gt; MXML component using xmlns="http://openscales.org"</p>
	 * 
	 * <p>You can configure a FxMap by adding componenents from openscales-fx as child MXML component. 
	 * It is ready to use after it throw an Event.COMPLETE event.
	 * You can retreive the org.openscales.core.Map instance from a FxMap isntance, use fxMap.map getter.</p>
	 */
	public class FxMap extends Group
	{
		private var _map:Map;
		private var _zoom:Number = NaN;
		private var _center:Location = null;
		private var _creationHeight:Number = NaN;
		private var _creationWidth:Number = NaN;
		private var _proxy:String = "";
		private var _maxExtent:Bounds = null;
		private var _flexOverlay:Group = null;
		
		/**
		 * FxMap constructor
		 */
		public function FxMap() {
			super();
			
			// Useful for a Map only defined with width="100%" or "height="100%"
			this.minWidth = 100;
			this.minHeight = 100;
			
			this.addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
		}
		
		/**
		 * Add a Flex wrapper layer to the map
		 */
		private function addFxLayer(l:FxLayer):void {
			// Add the layer to the map
			l.fxmap = this;
			l.configureLayer();
			this._map.addLayer(l.layer);
		}
		
		
		/**
		 * FxMap creation complete callback, initialize the map at the right Flex lifecycle time 
		 */
		private function onCreationComplete(event:Event):void {
			this._map = new Map(this.width, this.height);
			
			var i:int = 0;
			var element:IVisualElement = null;
			
			// override configuration with a Flex aware configuration
			this._map.configuration = new FxConfiguration(null,this);
			
			var mapContainer:SpriteVisualElement = new SpriteVisualElement();
			this.addElementAt(mapContainer, 0);
			mapContainer.addChild(this._map);
			
			this._flexOverlay = new Group();
			this.addElementAt(_flexOverlay,1);
			
			
			if (this._proxy != "")
				this._map.proxy = this._proxy;
			
			// Some operations must be done at the begining, in order to not
			// depend on the declaration order
			if (this._maxExtent != null)
				this._map.maxExtent = this._maxExtent;
			else {
				var maxExtentDefined:Boolean = false;
				for(i=0; (!maxExtentDefined) && (i<this.numElements); i++) {
					element = this.getElementAt(i);
					if (element is FxMaxExtent) {
						this._map.maxExtent = (element as FxMaxExtent).bounds;
						maxExtentDefined = true;
					}
				}
			}
			
			if (!isNaN(this._creationWidth) && !isNaN(this._creationHeight))
				this._map.size = new Size(this._creationWidth, this._creationHeight);
			
			// We use an interlediate Array in order to avoid adding new component it the loop
			// because it will modify numChildren
			var componentToAdd:Array = new Array();
			
			for(i=0; i<this.numElements; i++) {
				element = this.getElementAt(i);
				if (element is FxLayer) {
					this.addFxLayer(element as FxLayer);
				} else if (element is FxControl) {
					this._map.addControl((element as FxControl).control);
				} else if (element is IControl) {
					this._map.addControl(element as IControl, false);
				}
			}
			
			for(i=0; i<this.numElements; i++) {
				element = this.getElementAt(i);
				
				if (element is FxAbstractSecurity){
					var fxSecurity:FxAbstractSecurity = (element as FxAbstractSecurity);
					fxSecurity.map = this._map;
					var security:ISecurity = fxSecurity.security;
					var layers:Array = fxSecurity.layers.split(",");
					var layer:Layer = null;
					for each (var name:String in layers) {
						layer = map.getLayerByName(name);
						if(layer) {
							(element as FxAbstractSecurity).map = this._map;
							layer.security = security;
						}
					}
				}
			}
			
			// Set both center and zoom to avoid invalid request set when we define both separately
			var mapCenter:Location = this._center;
			if (mapCenter && this._map.baseLayer) {
				mapCenter = mapCenter.reprojectTo(this._map.baseLayer.projection);
			}
			if (mapCenter || (! isNaN(this._zoom))) {
				this._map.moveTo(mapCenter, this._zoom);
			}
			
			var extentDefined:Boolean = false;
			for(i=0; (!extentDefined) && (i<this.numElements); i++) {
				element = this.getElementAt(i);
				if (element is FxExtent) {
					this._map.zoomToExtent((element as FxExtent).bounds);
					extentDefined = true;
				}
			}
			
			setMapRecursively(this);
			
			this.addEventListener(ResizeEvent.RESIZE, this.onResize);
		}
		
		/**
		 * Set the current map in controls or wrapper recursively, useful where they are added as
		 * children of other Flex components like Panel or Group 
		 */
		private function setMapRecursively(component:UIComponent):void {
			var i:int = 0;
			var element:IVisualElement = null;
			
			if(component is IVisualElementContainer) {
				for(i=0; i<(component as IVisualElementContainer).numElements; i++) {
					element = (component as IVisualElementContainer).getElementAt(i);
					if (element is FxControl ) {
						(element as FxControl).control.map = this._map;
					} else if (element is IControl) {
						(element as IControl).map = this._map;
					} else if (element is FxHandler) {
						(element as FxHandler).handler.map = this._map;
					} else if (element is IHandler) {
						(element as IHandler).map = this._map;
					} else if(element is FxOverviewMap) {
						(element as FxOverviewMap).map = this._map;
					} else if (element is UIComponent){
						setMapRecursively(element as UIComponent);
					}
				}
			}
		}
		
		/**
		 * Resize event callback
		 */
		private function onResize(event:ResizeEvent):void {
			var o:DisplayObject = event.target as DisplayObject;
			this._map.size = new Size(o.width, o.height);
		}
		
		/**
		 * Get the "real" map instance from the Flex wrapper. Often used to configure more
		 * in details a map thnaks to ActionScript API
		 */
		public function get map():Map {
			return this._map;
		}
		
		/**
		 * Zoom MXML setter
		 */
		public function set zoom(value:Number):void {
			this._zoom = value;
		}
		
		/**
		 * Set the center of the map using its longitude and its latitude.
		 * 
		 * @param value a string of two coordinates separated by a coma, in
		 * WGS84 = EPSG:4326 only (not in the SRS of the base layer) !
		 */
		public function set center(value:String):void {
			var strCenterLonLat:Array = value.split(",");
			if (strCenterLonLat.length != 2) {
				Trace.error("Map.centerLonLat: invalid number of components");
				return ;
			}
			_center = new Location(Number(strCenterLonLat[0]), Number(strCenterLonLat[1]),Layer.DEFAULT_PROJECTION);
		}
		
		/**
		 * Width MXML setter
		 */
		override public function set width(value:Number):void {
			super.width = value;
			if (map != null)
				this._map.width = value;
			else
				this._creationWidth = value;
		}
		
		/**
		 * Height MXML setter
		 */
		override public function set height(value:Number):void {
			super.height = value;
			if (map != null)
				this._map.height = value;
			else
				this._creationHeight = value;
		}
		
		/**
		 * Proxy MXML setter
		 */
		public function set proxy(value:String):void {
			this._proxy = value;
		}
		
		/**
		 * MaxExtent MXML setter
		 */
		public function set maxExtent(value:String):void {
			this._maxExtent = Bounds.getBoundsFromString(value,Layer.DEFAULT_PROJECTION);
		}
		
	}
}

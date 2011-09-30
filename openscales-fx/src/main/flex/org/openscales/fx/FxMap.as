package org.openscales.fx
{
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	import mx.core.IVisualElement;
	import mx.core.IVisualElementContainer;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import mx.events.ResizeEvent;
	
	import org.openscales.core.Map;
	import org.openscales.core.utils.Trace;
	import org.openscales.core.basetypes.Resolution;
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
	import org.openscales.fx.popup.FxPopup;
	import org.openscales.fx.security.FxAbstractSecurity;
	import org.openscales.geometry.Geometry;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.geometry.basetypes.Location;
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
		protected var _map:Map;
		private var _center:Location = null;
		private var _creationHeight:Number = NaN;
		private var _creationWidth:Number = NaN;
		private var _proxy:String = "";
		private var _maxExtent:Bounds = null;
		private var _restrictedExtent:Bounds = null;
		private var _flexOverlay:Group = null;
		
		/**
		 * FxMap constructor
		 */
		public function FxMap() {
			super();
			
			//create a new map object
			this._map = new Map();
			
			// Useful for a Map only defined with width="100%" or "height="100%"
			this.minWidth = 100;
			this.minHeight = 100;
			
			this.addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
		}
		
		public function reset():void {
			var i:int = this.numElements;
			var elt:IVisualElement;
			for(i;i>0;--i) {
				elt = this.removeElementAt(0);
				if(elt is IControl)
					(elt as IControl).destroy();
			}
			this.map.reset();
			var mapContainer:SpriteVisualElement = new SpriteVisualElement();
			this.addElementAt(mapContainer, 0);
			mapContainer.addChild(this._map);
		}
		/**
		 * Add a Flex wrapper layer to the map
		 */
		private function addFxLayer(l:FxLayer):void {
			// Add the layer to the map
			l.fxmap = this;
			l.configureLayer();
			if(l.nativeLayer)
				this._map.addLayer(l.nativeLayer);
		}
		
		public function set resolution(value:*):void
		{
			if(value is Resolution)
				this.map.resolution = value as Resolution;
			else if (value is String) {
				var val:Array=(value as String).split(",");
				if(val.length==2) {
					var proj:String = String(val[1]).replace(/\s/g,"");
					if(proj && proj!="")
						this.map.resolution = new Resolution(Number(val[0]),proj);
					else
						this.map.resolution = new Resolution(Number(val[0]));
				}
				else if(val.length == 1)
					this.map.resolution = new Resolution(Number(val[0]));
			}
			else if (value is Number) {
				this.map.resolution = new Resolution(value as Number);
			}
		}
		
		public function get resolution():Resolution
		{
			return this.map.resolution;
		}
		
		private function onMoveStart(event:MapEvent):void{
			_flexOverlay.visible = false;
		}
		
		private function onMoveEnd(event:MapEvent):void{
			_flexOverlay.visible = true;
			var j:uint = _flexOverlay.numElements;
			var element:IVisualElement;
			for(var i:uint=0;i<j;++i){
				element = _flexOverlay.getElementAt(i);
				if(element is FxPopup)
					(element as FxPopup).position = (element as FxPopup).fxmap.map.getMapPxFromLocation((element as FxPopup).loc);
			}
		}
		
		
		public function addFxPopup(fxPopup:FxPopup, exclusive:Boolean = true):void{
			_flexOverlay.visible = true;
			map.addEventListener(MapEvent.DRAG_START,onMoveStart);
			map.addEventListener(MapEvent.LAYERS_LOAD_START,onMoveStart);
			map.addEventListener(MapEvent.LAYERS_LOAD_END,onMoveEnd);
			map.addEventListener(MapEvent.MOVE_START,onMoveStart);
			map.addEventListener(MapEvent.MOVE_END,onMoveEnd);
			map.addEventListener(MapEvent.MOVE_NO_MOVE,onMoveEnd);
			var i:Number;
			if(exclusive){
				var element:IVisualElement;
				for(i=this._flexOverlay.numElements-1;i>=0;i--){
					element = this._flexOverlay.getElementAt(i);
					if(element is FxPopup){
						if(element != fxPopup) {
							Trace.warn("Map.addFxPopup: fxPopup already displayed so escape");
							return;
						}
						this.removeFxPopup(element as FxPopup);
					}
				}
			}
			
			if (fxPopup != null){
				fxPopup.fxmap = this;
				this._flexOverlay.addElement(fxPopup);
			}
		}
		
		public function removeFxPopup(fxPopup:FxPopup):void{
			
			if(this._flexOverlay.contains(fxPopup))
				this._flexOverlay.removeElement(fxPopup);
		}
		
		/**
		 * FxMap creation complete callback, initialize the map at the right Flex lifecycle time 
		 */
		protected function onCreationComplete(event:Event):void {
			
			// Check is a child class as already created the map
			if (this._map == null)
			{
				this._map = new Map(this.width, this.height);
			} else {
				this._map.size = new Size(this.width,this.height);
			}
			
			var i:int = 0;
			var element:IVisualElement = null;
			
			// override configuration with a Flex aware configuration
			this._map.configuration = new FxConfiguration(null,this);
			
			var mapContainer:SpriteVisualElement = new SpriteVisualElement();
			this.addElementAt(mapContainer, 0);
			mapContainer.addChild(this._map);
			
			this._flexOverlay = new Group();
			//given the priority, the flexOverlay will be the highest layer (best visibility)
			this.addElementAt(_flexOverlay,this.numElements - 1);
			
			if (this._proxy != "")
				this._map.proxy = this._proxy;
			
			// Some operations must be done at the begining, in order to not
			// depend on the declaration order
			if (this._maxExtent != null)
				this._map.maxExtent = this._maxExtent;
			else {
				var maxExtentDefined:Boolean = false;
				//for(i=0; (!maxExtentDefined) && (i<this.numElements); i++) {
					//element = this.getElementAt(i);
				i = this.numElements;
				for(i; (!maxExtentDefined) && (i>0); --i) {
					element = this.getElementAt(i-1);
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
			//i = this.numElements;
			//for(i; i>0; --i) {
				//element = this.getElementAt(i-1);
				if (element is FxLayer) {
					this.addFxLayer(element as FxLayer);
				} else if (element is FxControl) {
					this._map.addControl((element as FxControl).control);
				} else if (element is IControl) {
					this._map.addControl(element as IControl, false);
				}
			}
			
			//for(i=0; i<this.numElements; i++) {
				//element = this.getElementAt(i);
			i = this.numElements;
			for(i; i>0; --i) {
				element = this.getElementAt(i-1);
				
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
			if (mapCenter) {
				//this._map.moveTo(mapCenter, this._zoom);
				this._map.center = mapCenter;
			}
			
			var extentDefined:Boolean = false;
			//for(i=0; (!extentDefined) && (i<this.numElements); i++) {
				//element = this.getElementAt(i);
			i = this.numElements;
			for(i; (!extentDefined) && (i>0); --i) {
				element = this.getElementAt(i-1);
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
		 * Set the center of the map using its longitude and its latitude.
		 * 
		 * @param value a string of two coordinates separated by a coma, in
		 * WGS84 = EPSG:4326 only (not in the SRS of the base layer) !
		 */
		public function set center(value:String):void {
			
			var centerStringArray:Array = value.split(",");
			
			if ( centerStringArray.length == 2)
			{
				_map.center = new Location(centerStringArray[0], centerStringArray[1], Geometry.DEFAULT_SRS_CODE);
			} else 
				if ( centerStringArray.length == 3 )
				{
					_map.center = new Location(centerStringArray[0], centerStringArray[1], centerStringArray[2]);
				} else
				{
					return;
				}
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
		public function set maxExtent(value:*):void {
			
			var newBounds:Bounds = null;
			
			if( value is String )
				newBounds = Bounds.getBoundsFromString(value);
			
			if( value is Bounds )
				newBounds = value;
			
			this._maxExtent = newBounds;
			if(this._map)
				this.map.maxExtent = newBounds;
		}
		
		public function get maxExtent():Bounds {
			if(this._map)
				return this.map.maxExtent;
				
			else
				return this._maxExtent;
		}
		
		/**
		 * restrictedExtent MXML setter
		 */
		public function set restrictedExtent(value:*):void {
			
			var newBounds:Bounds = null;
			
			if( value is String )
				newBounds = Bounds.getBoundsFromString(value);
			
			if( value is Bounds )
				newBounds = value;

			this._restrictedExtent = newBounds;
			if(this._map)
				this.map.restrictedExtent = newBounds;
		}
		
		public function get restrictedExtent():Bounds {
			if(this._map)
				return this.map.restrictedExtent;
				
			else
				return this._restrictedExtent;
		}
		
		
		public function get flexOverlay():Group{
			return this._flexOverlay;
		}
		
		
		
		/** 
		 * Url to the theme used to custom the components of the current map
		 */
		public function get theme():String
		{
			if(!this._map) 
				return null;
			else
				return (this._map as Map).theme;
		}
		
		/**
		 * @private
		 */
		public function set theme(value:String):void
		{
			if(this.map.theme)
				styleManager.unloadStyleDeclarations(this._map.theme);
			
			this._map.theme = value;
			
			if(this._map.theme && this._map.theme != "")
				styleManager.loadStyleDeclarations(value);
		}
		
		// --- Layer management --- //
		public function get layers():Vector.<Layer>{
			
			return this._map.layers;
		}
		
		// --- Control and Handler management --- //
		/**
		 * List of the controls and handlers linked to the map
		 */
		public function get controls():Vector.<IHandler>
		{
			// TODO : return a clone of the controls list
			return this._map.controls;
		}
		
		/**
		 * Adds given control or handler to the map, displaying it (for a control) on the map if the <code>attach</code> parameter is true.
		 * Otherwise, the control is just linked to the map and can be displayed anywhere else.
		 * 
		 * @param control Control or Handler to add.
		 * @param attach If true, control is displayed on the map. Otherwise, control is just linked to the map. 
		 * 
		 * @example The following code explains how to add a control :
		 * 
		 * <listing version="3.0">
		 * 	myMap.addControl(new geoportal.control.OverviewMap());
		 * </listing>
		 */
		public function addControl(control:IHandler, attach:Boolean = true):void{
			
			if(control is IVisualElement){
				
				if(attach){
					this.addElement(control as IVisualElement);
					(control as IVisualElement).visible = true;
				}
				
				this._map.addControl(control, false);
			}
			else{
				this._map.addControl(control,attach);
			}
		}
		
		/**
		 * Adds a list of controls and handlers to the map and displays them.
		 * 
		 * @param controls The list of controls and handlers to add to the map.
		 */
		public function addControls(controls:Vector.<IHandler>):void{
			
			for each (var control:IHandler in controls){
				
				this.addControl(control);
			}
		}
		
		/**
		 * Removes given control or handler from the map.
		 * 
		 * @param control Control or Handler to remove
		 * 
		 * @example The following code explains how to remove a control :
		 * 
		 * <listing version="3.0">
		 * 	myMap.removeControl(new geoportal.control.OverviewMap());
		 * </listing>
		 */
		public function removeControl(control:IHandler):void
		{
			var test:Vector.<IVisualElement> = new Vector.<IVisualElement>();
			
			var h:int = 0;
			var j:int = this.numElements;
			
			for(; h<j; ++h)
			{
				test.push(this.getElementAt(h));
			}
			
			// removeElement if added as IVisualElement
			var i:int = this.controls.indexOf(control);
			if (i != -1)
			{
				if ((control as IVisualElement) && ((control as IVisualElement).parent == this)) {
					this.removeElement(control as IVisualElement);
				}
				this._map.removeControl(control);
			}
		}
		
		/** 
		 * Current projection system used in the map.
		 */
		public function get projection():String
		{
			return (this._map as Map).projection;
		}
		
		/**
		 * @private
		 */
		public function set projection(value:String):void
		{
			(this._map as Map).projection = value;
		}
		
		/**
		 * The minimum resolution of the map.
		 * You cannot reach a resolution lower than this resolution
		 * If you try to reach a resolution behind the minResolution nothing will be done
		 */
		public function get minResolution():Resolution
		{
			return (this._map as Map).minResolution;
		}
		
		/**
		 * @private
		 */
		public function set minResolution(value:*):void
		{
			if(value is Resolution)
				(this._map as Map).minResolution = value as Resolution;
			else if (value is String) {
				var val:Array=(value as String).split(",");
				if(val.length==2) {
					var proj:String = String(val[1]).replace(/\s/g,"");
					if(proj && proj!="")
						(this._map as Map).minResolution = new Resolution(Number(val[0]),proj);
					else
						(this._map as Map).minResolution = new Resolution(Number(val[0]));
				}
				else if(val.length == 1)
					(this._map as Map).minResolution = new Resolution(Number(val[0]));
			}
			else if (value is Number) {
				(this._map as Map).minResolution = new Resolution(value as Number);
			}
		}
		
		/**
		 * The maximum resolution of the map.
		 * You cannot reach a resolution higher than this resolution
		 * If you try to reach a resolution above the maxResolution nothing will be done
		 */
		public function get maxResolution():Resolution
		{
			return (this._map as Map).maxResolution;
		}
		
		/**
		 * @private
		 */
		public function set maxResolution(value:*):void
		{
			if(value is Resolution)
				(this._map as Map).maxResolution = value as Resolution;
			else if (value is String) {
				var val:Array=(value as String).split(",");
				if(val.length==2) {
					var proj:String = String(val[1]).replace(/\s/g,"");
					if(proj && proj!="")
						(this._map as Map).maxResolution = new Resolution(Number(val[0]),proj);
					else
						(this._map as Map).maxResolution = new Resolution(Number(val[0]));
				}
				else if(val.length == 1)
					(this._map as Map).maxResolution = new Resolution(Number(val[0]));
			}
			else if (value is Number) {
				(this._map as Map).maxResolution = new Resolution(value as Number);
			}
		}
	}
}

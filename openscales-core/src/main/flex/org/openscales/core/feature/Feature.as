package org.openscales.core.feature {
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.utils.getQualifiedClassName;
	
	import org.openscales.core.events.FeatureEvent;
	import org.openscales.core.events.WFSTFeatureEvent;
	import org.openscales.core.filter.ElseFilter;
	import org.openscales.core.layer.VectorLayer;
	import org.openscales.core.style.Rule;
	import org.openscales.core.style.Style;
	import org.openscales.core.style.stroke.Stroke;
	import org.openscales.core.style.symbolizer.Symbolizer;
	import org.openscales.core.utils.Util;
	import org.openscales.geometry.Geometry;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Pixel;
	import org.openscales.geometry.basetypes.Unit;
	import org.openscales.proj4as.ProjProjection;

	/** 
	 * @eventType org.openscales.core.events.FeatureEvent.FEATURE_OVER 
	 */ 
	[Event(name="openscales.feature.over", type="org.openscales.core.events.FeatureEvent")]
	
	/** 
	 * @eventType org.openscales.core.events.FeatureEvent.FEATURE_MOUSEMOVE 
	 */ 
	[Event(name="openscales.feature.mousemove", type="org.openscales.core.events.FeatureEvent")]
	
	/** 
	 * @eventType org.openscales.core.events.FeatureEvent.FEATURE_CLICK
	 */ 
	[Event(name="openscales.feature.click", type="org.openscales.core.events.FeatureEvent")]
	
	/**  
	 * @eventType org.openscales.core.events.FeatureEvent.FEATURE_DOUBLECLICK
	 */ 
	[Event(name="openscales.feature.doubleclick", type="org.openscales.core.events.FeatureEvent")]
	
	/** 
	 * @eventType org.openscales.core.events.FeatureEvent.FEATURE_MOUSEDOWN
	 */ 
	[Event(name="openscales.feature.mousedown", type="org.openscales.core.events.FeatureEvent")]
	
	/** 
	 * @eventType org.openscales.core.events.FeatureEvent.FEATURE_MOUSEUP
	 */ 
	[Event(name="openscales.feature.mouseup", type="org.openscales.core.events.FeatureEvent")]
	
	/**
	 * Features is a geolocalized graphical element.
	 * It is generally subclassed to customized how it is displayed.
	 * They have an ‘attributes’ property, which is the data object.
	 */
	public class Feature extends Sprite {

		private var _geometry:Geometry = null;
		protected var _originGeometry:Geometry = null;
		private var _state:String = null;
		private var _style:Style = null;
		private var _originalStyle:Style = null;
		private var _selectable:Boolean = true;
		
		private var _mouseDown:Boolean = false;
		
		//GAB
		private var _dateCreation:String="";
		//End GAB

		/**
		 * To know if the vector feature is editable when its
		 * vector layer is in edit mode
		 **/
		private var _isEditable:Boolean = false;

		/**
		 * Attributes usually generated from data parsing or user input
		 */
		private var _attributes:Object = null;

		/**
		 * Raw data that represent this feature. For exemple, this could contains the
		 * GML data for WFS features
		 *
		 * TODO : specify where we can specify if data are kept or not, in order to
		 * minimize memory consumption (GML uses a lot of memory)
		 */
		private var _data:Object = null;

		/**
		 * The layer where this feature belong. Should be a LayerFeature or inherited classes.
		 */
		private var _layer:VectorLayer = null;

		/**
		 * The geolocalized position of this feature, will be used to know where
		 * this feature should be drawn. Please not that lonlat getter and setter
		 * may be override in inherited classes to use other attributes to determine
		 * the position (for exemple the geometry)
		 */
		private var _lonlat:Location = null;

		/**
		 * Is this feature selected ?
		 */
		private var _selected:Boolean = false;
		
		static public function compatibleFeatures(features:Vector.<Feature>):Boolean {
			if ((!features) || (features.length == 0) || (!features[0]) || (!(features[0] is Feature))) {
				return false;
			}
			var firstFeatureClassName:String = getQualifiedClassName(features[0]);
			for each (var feature:Feature in features) {
				if ((!(feature is Feature)) || (getQualifiedClassName(feature) != firstFeatureClassName)) {
					return false;
				}
			}
			return true;
		}

		/**
		 * Constructor class
		 *
		 * @param layer The layer containing the feature.
		 * @param lonlat The lonlat position of the feature.
		 * @param data
		 */
		public function Feature(geom:Geometry=null, data:Object=null, style:Style=null, isEditable:Boolean=false) {
			if (data != null) {
				this._data = data;
			} else {
				this._data = new Object();
			}

			this._attributes = new Object();
			if (data) {
				this._attributes = Util.extend(this._attributes, data);
			}
			//GAB
			if (this._attributes["date_modif"] != undefined )
				this._dateCreation = this._attributes["date_modif"];
			//END GAB

			this._geometry = geom;
			this._originGeometry = geom;
			this._state = null;
			this._attributes = new Object();
			if (data) {
				this.attributes = Util.extend(this._attributes, data);
			}
			this._style = style ? style : null;

			this._isEditable = isEditable;
			this.cacheAsBitmap = true;
		}

		/**
		 * Register all the events used in this class
		 */
		public function registerListeners():void {
			this.addEventListener(MouseEvent.ROLL_OVER, this.onMouseHover);
			this.addEventListener(MouseEvent.ROLL_OUT, this.onMouseOut);
			//this.addEventListener(MouseEvent.CLICK, this.onMouseClick);
			this.addEventListener(MouseEvent.DOUBLE_CLICK, this.onMouseDoubleClick);
			this.addEventListener(MouseEvent.MOUSE_DOWN, this.onMouseDown);
			this.addEventListener(MouseEvent.MOUSE_UP, this.onMouseUp);
			this.addEventListener(MouseEvent.MOUSE_MOVE, this.onMouseMove);
		}

		/**
		 * Unregister all the events used in this class
		 */
		public function unregisterListeners():void {
			this.removeEventListener(MouseEvent.ROLL_OVER, this.onMouseHover);
			this.removeEventListener(MouseEvent.ROLL_OUT, this.onMouseOut);
			//this.removeEventListener(MouseEvent.CLICK, this.onMouseClick);
			this.removeEventListener(MouseEvent.DOUBLE_CLICK, this.onMouseDoubleClick);
			this.removeEventListener(MouseEvent.MOUSE_DOWN, this.onMouseDown);
			this.removeEventListener(MouseEvent.MOUSE_UP, this.onMouseUp);
			this.removeEventListener(MouseEvent.MOUSE_MOVE, this.onMouseMove);
		}

		/**
		 * Method to destroy a the feature instance.
		 */
		public function destroy():void {
			this._attributes = null;
			this._data = null;
			this._layer = null;
			this._lonlat = null;
			this._geometry = null;
			this._originGeometry = null;
		}

		/**
		 * To obtain feature clone
		 * */
		public function clone():Feature {
			return null;
		}
		
		
		/**
		 * Transform the feature in the dest ProjProjection
		 */
		public function reprojectTo(dest:ProjProjection):void
		{
			this._geometry = this._originGeometry.clone();
			if (dest != this._originGeometry.projection)
			{
				this._geometry.transform(dest);
			}
		}

		/**
		 * Draw the feature
		 * The function allow to customize the display of this feature.
		 * Inherited Feature classes usually override this function.
		 */
		public function draw():void {

			this.graphics.clear();
			while (this.numChildren > 0) {
				this.removeChildAt(0);
			}
			
			if(!this.layer || !this.layer.map)
				return;
			
			var style:Style;
			if (this._style == null) {
				// FIXME : Ugly thing done here
				style = this.layer.style;
			} else {
				style = this._style;
			}

			// Storage variables to handle the rules to render if no rule applied to the feature
			var rendered:Boolean = false;
			var elseRules:Array = [];
			
			var scaleDem:Number = Unit.getScaleDenominatorFromResolution(this.layer.map.resolution.value,this.layer.map.resolution.projection.projParams.units);
			
			for each (var rule:Rule in style.rules) {
				if(!isNaN(rule.minScaleDenominator) && rule.minScaleDenominator>scaleDem) {
					continue;
				}
				if(!isNaN(rule.maxScaleDenominator) && rule.maxScaleDenominator<scaleDem) {
					continue;
				}
				// If a filter is set and no rule matches the filter skip the rule
				if (rule.filter != null) {
					if (rule.filter is ElseFilter) {
						elseRules.push(rule);
						continue;
					} else if (!rule.filter.matches(this)) {
						continue;
					}
				}
				this.renderRule(rule);
				rendered = true;
			}

			if (!rendered) {
				for each (var elseRule:Rule in elseRules) {
					this.renderRule(elseRule);
				}
			}
		}
		
		/**
		 * Determines if the feature is visible on the screen
		 */
		public function onScreen():Boolean {
			var onScreen:Boolean = false;
			if ((this._layer != null) && (this._layer.map != null)) {
				var screenBounds:Bounds = this._layer.map.extent;
				onScreen = screenBounds.containsLocation(this.lonlat);
			}
			return onScreen;
		}
		
		/**
		 * Determines if the feature is placed at the given point with a certain tolerance (or not).
		 *
		 * @param lonlat The given point
		 * @param toleranceLon The longitude tolerance
		 * @param toleranceLat The latitude tolerance
		 */
		public function atPoint(lonlat:Location, toleranceLon:Number, toleranceLat:Number):Boolean {
			var atPoint:Boolean = false;
			if (this.geometry) {
				atPoint = this._geometry.atPoint(lonlat, toleranceLon, toleranceLat);
			}
			return atPoint;
		}
		
		/**
		 * Method that will check the rules of the associated style to check with ones must be rendered
		 */
		protected function renderRule(rule:Rule):void {
			var symbolizer:Symbolizer;
			var symbolizers:Array;
			var j:uint;
			var symbolizersCount:uint = rule.symbolizers.length;
			for (j = 0; j < symbolizersCount; ++j) {
				symbolizer = rule.symbolizers[j];
				if (this.acceptSymbolizer(symbolizer)) {
					symbolizer.configureGraphics(this.graphics, this);
					this.executeDrawing(symbolizer);
				}
			}
		}
		
		/**
		 * This method return true if the given symbolizer is accepted for the current feature.
		 * This method will be called while rendering the feature.
		 * Override this method in your feature to specify wich symbolizer is supported 
		 */
		protected function acceptSymbolizer(symbolizer:Symbolizer):Boolean {
			return true;
		}
		
		/**
		 * This method is the method that will be called to draw your feature with the given symbolizer.
		 * It will be called on time per symbolizer supported by the feature.
		 * To determine supported symbolizer for a feature see acceptSymbolizer method
		 */
		protected function executeDrawing(symbolizer:Symbolizer):void {
		}

		protected function dottedTo(px1:Pixel, px2:Pixel, stroke:Stroke):void
		{
			var dx:Number = px2.x - px1.x;
			var dy:Number = px2.y - px1.y;
			var dist:Number = Math.sqrt(Math.pow(dx,2) + Math.pow(dy,2));
			var angle:Number = Math.atan2(dy, dx) * 180 / Math.PI;
			
			var tempPixel:Pixel = px1.clone();
			this.graphics.moveTo(tempPixel.x, tempPixel.y);
			var cos:Number = Math.cos(angle / 180 * Math.PI);
			var sin:Number = Math.sin(angle / 180 * Math.PI);
			var num:uint = stroke.dashArray.length;
			var i:uint = 0;
			var l:Number;
			var dcap:Number = 0;
			if(stroke.linecap==Stroke.LINECAP_ROUND||stroke.linecap==Stroke.LINECAP_SQUARE) {
				dcap = stroke.width;
			}
			var move:Boolean;
			while (dist > 0)
			{
				move=(i%2==1);
				l = Math.abs(stroke.dashArray[i]);
				dist -= l;
				if(!move) {
					if(l>dcap) {
						l-=dcap;
					} else if (l==dcap) {
						l=1;
						dist-=1;
					} else {
						move=true;
					}
				}
				if (dist < 0){
					tempPixel.x = px2.x;
					tempPixel.y = px2.y;
				}
				else{
					tempPixel.x += (l * cos);
					tempPixel.y += (l * sin);
				}
				if(move) {
					this.graphics.moveTo(tempPixel.x, tempPixel.y);
				} else {
					this.graphics.lineTo(tempPixel.x, tempPixel.y);
					tempPixel.x += (dcap * cos);
					tempPixel.y += (dcap * sin);
				}
				i=(i+1)%num;
			}
		}
		
		// Callbacks
		
		/**
		 * Callback that dispatch the FEATURE_OVER event
		 */
		public function onMouseHover(pevt:MouseEvent):void {
			this.buttonMode = true;
			this._layer.map.dispatchEvent(new FeatureEvent(FeatureEvent.FEATURE_OVER, this));
		}
		
		/**
		 * Callback that dispatch the FEATURE_MOUSEMOVE event
		 */
		public function onMouseMove(pevt:MouseEvent):void {
			this._layer.map.dispatchEvent(new FeatureEvent(FeatureEvent.FEATURE_MOUSEMOVE, this));
		}
		
		/**
		 * Callback that dispatch the FEATURE_OUT event
		 */
		public function onMouseOut(pevt:MouseEvent):void {
			this.buttonMode = false;
			if (_layer)
				this._layer.map.dispatchEvent(new FeatureEvent(FeatureEvent.FEATURE_OUT, this));
		}

		/**
		 * Callback that dispatch the FEATURE_CLICK event
		 */
		public function onMouseClick(pevt:MouseEvent):void {
			if(pevt)
				this._layer.map.dispatchEvent(new FeatureEvent(FeatureEvent.FEATURE_CLICK, this, pevt.ctrlKey));
			else
				this._layer.map.dispatchEvent(new FeatureEvent(FeatureEvent.FEATURE_CLICK, this, false));
		}

		/**
		 * Callback that dispatch the FEATURE_DOUBLECLICK event
		 */
		public function onMouseDoubleClick(pevt:MouseEvent):void {
			this._layer.map.dispatchEvent(new FeatureEvent(FeatureEvent.FEATURE_DOUBLECLICK, this));
		}

		/**
		 * Callback that dispatch the FEATURE_MOUSEDOWN event
		 */
		public function onMouseDown(pevt:MouseEvent):void {
			this._layer.map.dispatchEvent(new FeatureEvent(FeatureEvent.FEATURE_MOUSEDOWN, this));
			this._mouseDown = true;
		}

		/**
		 * Callback that dispatch the FEATURE_MOUSEUP event
		 */
		public function onMouseUp(pevt:MouseEvent):void {
			if(pevt)
			{
				if (this._mouseDown)
				{
					this._mouseDown = false;
					this._layer.map.dispatchEvent(new FeatureEvent(FeatureEvent.FEATURE_MOUSEUP, this, pevt.ctrlKey));
					this._layer.map.dispatchEvent(new FeatureEvent(FeatureEvent.FEATURE_CLICK, this, pevt.ctrlKey));
				}
				else
				{
					this._layer.map.dispatchEvent(new FeatureEvent(FeatureEvent.FEATURE_MOUSEUP, this, pevt.ctrlKey));
				}
			}
				
			else
				this._layer.map.dispatchEvent(new FeatureEvent(FeatureEvent.FEATURE_MOUSEUP, this, false));
		}
		
		// Getter Setters
		
		/**
		 * Return if the feature is selectable or not
		 */
		public function get selectable():Boolean
		{
			return this._selectable;	
		}
		
		/**
		 * @private
		 */
		public function set selectable(value:Boolean):void
		{
			this._selectable = value;
		}
		
		/**
		 * Attributes usually generated from data parsing or user input
		 */
		public function get attributes():Object {
			return this._attributes;
		}
		
		/**
		 * @private
		 */
		public function set attributes(value:Object):void {
			this._attributes = value;
		}
		
		/**
		 * Raw data that represent this feature. For exemple, this could contains the
		 * GML data for WFS features
		 */
		public function get data():Object {
			return this._data;
		}
		
		/**
		 * @private
		 */
		public function set data(value:Object):void {
			this._data = value;
		}

		/**
		 * The layer that contain the feature
		 */
		public function get layer():VectorLayer {
			return this._layer;
		}
		
		/**
		 * @private
		 */
		public function set layer(value:VectorLayer):void {
			if(this._layer) {
				unregisterListeners();
			}
			this._layer = value;
			if (this._layer != null) {
				registerListeners();
			}
		}
		
		/**
		 * Return the Location at the center of the feature
		 */
		public function get lonlat():Location {
			var value:Location = null;
			if (this._geometry != null) {
				value = this._geometry.bounds.center;   
			}
			return value;
		}

		/**
		 * Boolean that says if the feature is currently selected
		 */
		public function get selected():Boolean {
			return this._selected;
		}

		/**
		 * @private
		 */
		public function set selected(value:Boolean):void {
			this._selected = value;
		}

		/**
		 * The number of pixels between the feature and the top of it's container
		 */
		public function get top():Number {
			if (this._layer)
				return this._layer.extent.top / this._layer.map.resolution.value;
			else
				return NaN;
		}

		/**
		 * The number of pixels between the feature and the left side of it's container
		 */
		public function get left():Number {
			if (this.layer)
				return -this._layer.extent.left / this._layer.map.resolution.value;
			else
				return NaN;
		}

		/**
		 * This is the geometry of the feature.
		 * When you reproject the feature, it will keep an origin geometry to us it for reprojection.
		 * If you set another geometry it will override the origin geometry too.
		 */
		public function get geometry():Geometry {
			return this._geometry;
		}
		
		/**
		 * @private
		 */
		public function set geometry(value:Geometry):void {
			this._geometry = value;
			this._originGeometry = this._geometry.clone();
		}
		
		/**
		 * The WFST state of the feature. 
		 * Used for WFST layers.
		 */
		public function get state():String {
			if(this._state ==  null){
			  return State.UNKNOWN
			}
			return this._state;
		}

		/**
		 * @private
		 */
		public function set state(value:String):void {
			if (value == State.UPDATE) {
				switch (this.state) {
					case State.UNKNOWN:
					case State.DELETE:
						this._state = value;
						if(this._layer != null && this._layer.map != null){
							this._layer.map.dispatchEvent(new WFSTFeatureEvent(WFSTFeatureEvent.UPDATE,this));
						}
						
						break;
					case State.UPDATE:
					case State.INSERT:
						break;
				}
			} else if (value == State.INSERT) {
				switch (this.state) {
					case State.UNKNOWN:
						this._state = value;
						if(this._layer != null && this._layer.map != null ){
							this._layer.map.dispatchEvent(new WFSTFeatureEvent(WFSTFeatureEvent.INSERT,this));
						}
						break;
					default:
						
						break;
				}
			} else if (value == State.DELETE) {
				switch (this.state) {
					case State.INSERT:
						break;
					case State.DELETE:
						break;
					case State.UNKNOWN:
					case State.UPDATE:
						this._state = value;
						if(this._layer != null && this._layer.map != null){
							this._layer.map.dispatchEvent(new WFSTFeatureEvent(WFSTFeatureEvent.DELETE,this));
						}
						break;
				}
			} else if (value == State.UNKNOWN) {
				this._state = value;
			}
		}

		/**
		 * The style that will be applied to the feature.
		 * A style is a set of rules. 
		 * A Rule is used to do conditional styling based on feature parameters
		 * Each rule as several symbolizers.
		 * A symbolizer is designed for a feature type eg : PointSymbolizer and says precisely 
		 * how to draw the feature
		 */
		public function get style():Style {
			return this._style;
		}

		/**
		 * @private
		 */
		public function set style(value:Style):void {
			this._style = value;
		}

		/**
		 * A bufferized style.
		 * Used to handle select style a apply back to proper style
		 */
		public function get originalStyle():Style {
			return this._originalStyle;
		}

		/**
		 * @private
		 */
		public function set originalStyle(value:Style):void {
			this._originalStyle = value;
		}

		/**
		 * To know if the vector feature is editable when its
		 * vector layer is in edit mode
		 **/
		public function get isEditable():Boolean {
			return this._isEditable;
		}

		/**
		 * @private
		 * */
		public function set isEditable(value:Boolean):void {
			this._isEditable = value;

		}
		
		/**
		 * Creation date of the feature
		 */
		public function get dateCreation():String{
			var _value:String;
			if (this._dateCreation == ""){
				if (this._attributes["date_modif"] != undefined )
					this._dateCreation = this._attributes["date_modif"];
			}
			if (this._dateCreation.indexOf(".")>=0)
				_value = this._dateCreation.split(".")[0];
			else
				_value = this._dateCreation;
			
			return _value.replace("T", " ");
		}
		
		/**
		 * @private
		 */
		public function set dateCreation(value:String):void{
			this._dateCreation = value;
		}
		
		/**
		 * The actual projection of the feature.
		 * If you want to change it, use the transform method
		 */
		public function get projection():ProjProjection
		{
			return this._geometry.projection;
		}
		
		/**
		 * The original projection of the feature.
		 * If you want to change it, use the transform method
		 */
		public function get originProjection():ProjProjection
		{
			return this._originGeometry.projection;
		}
	}
}
package org.openscales.fx.layer
{	
	import org.openscales.core.Map;
	import org.openscales.core.layer.Layer;
	import org.openscales.fx.FxMap;
	import org.openscales.geometry.Geometry;
	import org.openscales.geometry.basetypes.Bounds;
	
	import spark.components.Group;
	
	/**
	 * Abstract Layer Flex wrapper
	 */
	public class FxLayer extends Group
	{
		protected var _layer:Layer;
		
		protected var _minZoomLevel:Number = NaN;
		
		protected var _maxZoomLevel:Number = NaN;
		
		protected var _dpi:Number = NaN;
		
		protected var _maxResolution:Number = NaN;
		
		protected var _numZoomLevels:Number = NaN;
		
		protected var _maxExtent:Bounds = null;
		
		protected var _resolutions:Array = null;
		
		protected var _projection:String = null;
		
		protected var _tweenOnZoom:Boolean = true;
		
		protected var _proxy:String = null;
		
		protected var _fxmap:FxMap;
		
		public function FxLayer() {
			super();
			this.init();
		}
		

		public function init():void {
			
		}
		
		/**
		 * Configure the layer upon what have been specified in the flex wrapper
		 */
		public function configureLayer():Layer {
			
			if(this._projection)
				this.layer.projSrsCode = this._projection;
			
			this.generateResolutions();
			
			this.layer.name = this.name;
			
			if(this._proxy)
				this.layer.proxy = this._proxy;
			
			if(this._dpi)
				this.layer.dpi = this._dpi;
			
			if(this._resolutions)
				this.layer.resolutions = this._resolutions;
			
			if(!isNaN(this.minZoomLevel))
				this.layer.minZoomLevel = this.minZoomLevel;
			
			if(!isNaN(this.maxZoomLevel))
				this.layer.maxZoomLevel = this.maxZoomLevel;
			
			if(this._maxExtent) {
				this.layer.maxExtent = this._maxExtent;
				this._maxExtent = null;
			}
			
			this.layer.tweenOnZoom = this._tweenOnZoom;
			
			this.layer.alpha = super.alpha;
			this.layer.visible = super.visible;
			
			return this.layer;
		}
		
		/**
		 * @Private
		 * generate layer resolutions
		 */
		private function generateResolutions():void {
			if(!this.layer)
				return;
			
			if(!isNaN(this.numZoomLevels)) {
				this.layer.generateResolutions(this.numZoomLevels, this.maxResolution);
			}else{
				if(!isNaN(this.maxResolution)) {
					this.layer.generateResolutions(Layer.DEFAULT_NUM_ZOOM_LEVELS, this.maxResolution);
				}
			}
		}
		
		/**
		 * Indicates the layer represented by the flex wrapper
		 */
		public function get layer():Layer {
			return this._layer;
		}
		
		/**
		 * Indicates the fxmap associated to the object
		 */
		public function get fxmap():FxMap {
			return this._fxmap;
		}
		/**
		 * @Private
		 */
		public function set fxmap(value:FxMap):void {
			this._fxmap = value;
		}
		
		/**
		 * Indicates the map associated to the layer
		 */
		public function get map():Map {
			if (this.layer != null)
				return this.layer.map;
			else
				return null;
		}
		
		/**
		 * Indicates the dpi used to calculate resolution and scale upon this layer
		 */
		public function get dpi():Number {
			if(this.layer)
				return this.layer.dpi;
			return this._dpi;
		}
		/**
		 * @Private
		 */
		public function set dpi(value:Number):void {
			if(this.layer != null)
				this.layer.dpi = value;
			else
				this._dpi = value;
		}
		
		/**
		 * Indicates the layer name
		 */
		public override function get name():String {
			if(this.layer)
				return this.layer.name;
			return super.name;
		}
		/**
		 * @Private
		 */
		public override function set name(value:String):void {
			super.name = value;
			if(this.layer != null)
				this.layer.name = value;
		}
		
		/**
		 * Whether or not the layer is a fixed layer.
		 * Fixed layers cannot be controlled by users
		 */
		public function get isFixed():Boolean {
			if(this.layer)
				return this.layer.isFixed;
			return false;
		}
		/**
		 * @Private
		 */
		public function set isFixed(value:Boolean):void {
			if(this.layer != null)
				this.layer.isFixed = value;
		}
		
		/**
		 * Indicates the max extent as a string in the layer projection
		 */
		public function get maxExtent():String {
			if(this.layer)
				return this.layer.maxExtent.toString();
			if(this._maxExtent)
				return this._maxExtent.toString();
			return null;
		}
		/**
		 * @Private
		 */
		public function set maxExtent(value:String):void {
			if(this.layer)
				this.layer.maxExtent = Bounds.getBoundsFromString(value,this.layer.projSrsCode);
			else if(this._projection)
				this._maxExtent = Bounds.getBoundsFromString(value,this._projection);
			else
				this._maxExtent = Bounds.getBoundsFromString(value,Geometry.DEFAULT_SRS_CODE);
		}
		
		/**
		 * Indicates the proxy used to request layer datas
		 */
		public function get proxy():String {
			if(this.layer)
				return this.layer.proxy;
			return this._proxy;
		}
		/**
		 * @Private
		 */
		public function set proxy(value:String):void {
			this._proxy = value;
			if(this.layer)
				this.layer.proxy = this._proxy;
		}
		
		/**
		 * Indicates if the layer is visible
		 */
		override public function get visible():Boolean {
			if(this.layer)
				return this.layer.visible;
			return super.visible;
		}
		/**
		 * @Private
		 */
		override public function set visible(value:Boolean):void {
			if(this.layer)
				this.layer.visible = value;
		}
		
		/**
		 * Indicates the layer maxResolution
		 */
		public function get maxResolution():Number {
			if(this.layer)
				return this.layer.maxResolution;
			return this._maxResolution;
		}
		/**
		 * @Private
		 */
		public function set maxResolution(value:Number):void {
			this._maxResolution = value;
			this.generateResolutions();
		}
		
		/**
		 * Indicates the minZoomLevel of the layer
		 */
		public function get minZoomLevel():Number {
			if(this.layer)
				return this.layer.minZoomLevel;
			return this._minZoomLevel;
		}
		/**
		 * @Private
		 */
		public function set minZoomLevel(value:Number):void {
			this._minZoomLevel = value;
			this.generateResolutions();
		}
		
		/**
		 * Indicates the maxZoomLevel of the layer
		 */
		public function get maxZoomLevel():Number {
			if(this.layer)
				return this.layer.maxZoomLevel;
			return this._maxZoomLevel;
		}
		/**
		 * @Private
		 */
		public function set maxZoomLevel(value:Number):void {
			this._maxZoomLevel = value;
			this.generateResolutions();
		}
		
		/**
		 * Indicates the layer numZoomLevel
		 */
		public function get numZoomLevels():Number {
			return this._numZoomLevels;
		}
		/**
		 * @Private
		 */
		public function set numZoomLevels(value:Number):void {
			this._numZoomLevels = value;
			this.generateResolutions();
		}
		
		/**
		 * Indicates available resolutions of the layer
		 */
		public function get resolutions():String {
			if(this.layer)
				return this.layer.resolutions.join(",");
			return this._resolutions.join(",");
		}
		/**
		 * @Private
		 */
		public function set resolutions(value:String):void {
			var resString:String = null;
			var resNumberArray:Array = new Array();
			for each (resString in value.split(",")) {
				resNumberArray.push(Number(resString));
			}
			this._resolutions = resNumberArray;
			if(this.layer)
				this.layer.resolutions = this._resolutions;
		}
		
		/**
		 * Indicates teh projection of the layer
		 */
		public function get projection():String {
			if(this.layer)
				return this.layer.projSrsCode;
			return this._projection;
		}
		/**
		 * @Private
		 */
		public function set projection(value:String):void {
			this._projection = value;
			if(this.layer) {
				this.layer.projSrsCode = this._projection;
				if(this.layer.maxExtent)
					this.layer.maxExtent.projSrsCode = this._projection;
			}
			else if(this._maxExtent)
				this._maxExtent.projSrsCode = this._projection;
		}
		
		/**
		 * Indicates the alpha of the layer
		 */
		override public function get alpha():Number {
			if(this.layer)
				return this.layer.alpha;
			return super.alpha;
		}
		/**
		 * @Private
		 */
		override public function set alpha(value:Number):void {
			super.alpha = value;
			if(layer)
				this.layer.alpha = value;
		}
		
		/**
		 * Indicates if the layer should be tweened on zoom
		 */
		public function get tweenOnZoom():Boolean {
			if(this.layer)
				return this.layer.tweenOnZoom;
			return this._tweenOnZoom;
		}
		/**
		 * @Private
		 */
		public function set tweenOnZoom(value:Boolean):void {
			this._tweenOnZoom = value;
			if(this.layer)
				this._layer.tweenOnZoom;
		}
		
	}
}
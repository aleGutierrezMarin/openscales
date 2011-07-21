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

		protected var _displayInLayerManager:Boolean = true;
		
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
				this._layer.projSrsCode = this._projection;
			
			this.generateResolutions();
			
			this._layer.name = this.name;
			
			if(this._proxy)
				this._layer.proxy = this._proxy;
			
			if(this._dpi)
				this._layer.dpi = this._dpi;
			
			if(this._resolutions)
				this._layer.resolutions = this._resolutions;
			
			if(!isNaN(this.minZoomLevel))
				this._layer.minZoomLevel = this.minZoomLevel;
			
			if(!isNaN(this.maxZoomLevel))
				this._layer.maxZoomLevel = this.maxZoomLevel;
			
			if(this._maxExtent) {
				this._layer.maxExtent = this._maxExtent;
				this._maxExtent = null;
			}
			
			this._layer.tweenOnZoom = this._tweenOnZoom;
			
			this._layer.alpha = super.alpha;
			this._layer.visible = super.visible;
			
			return this._layer;
		}
		
		/**
		 * @Private
		 * generate layer resolutions
		 */
		private function generateResolutions():void {
			if(!this._layer)
				return;
			
			if(!isNaN(this.numZoomLevels)) {
				this._layer.generateResolutions(this.numZoomLevels, this.maxResolution);
			}else{
				if(!isNaN(this.maxResolution)) {
					this._layer.generateResolutions(Layer.DEFAULT_NUM_ZOOM_LEVELS, this.maxResolution);
				}
			}
		}
		
		/**
		 * Indicates the layer represented by the flex wrapper
		 */
		public function get nativeLayer():Layer {
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
			if (this._layer != null)
				return this._layer.map;
			else
				return null;
		}
		
		/**
		 * Indicates the dpi used to calculate resolution and scale upon this layer
		 */
		public function get dpi():Number {
			if(this._layer)
				return this._layer.dpi;
			return this._dpi;
		}
		/**
		 * @Private
		 */
		public function set dpi(value:Number):void {
			if(this._layer != null)
				this._layer.dpi = value;
			else
				this._dpi = value;
		}
		
		/**
		 * Indicates the layer name
		 */
		public override function get name():String {
			if(this._layer)
				return this._layer.name;
			return super.name;
		}
		/**
		 * @Private
		 */
		public override function set name(value:String):void {
			super.name = value;
			if(this._layer != null)
				this._layer.name = value;
		}
		
		/**
		 * Whether or not the layer is a fixed layer.
		 * Fixed layers cannot be controlled by users
		 */
		public function get isFixed():Boolean {
			if(this._layer)
				return this._layer.isFixed;
			return false;
		}
		/**
		 * @Private
		 */
		public function set isFixed(value:Boolean):void {
			if(this._layer != null)
				this._layer.isFixed = value;
		}
		
		/**
		 * Indicates the max extent as a string in the layer projection
		 */
		public function get maxExtent():String {
			if(this._layer)
				return this._layer.maxExtent.toString();
			if(this._maxExtent)
				return this._maxExtent.toString();
			return null;
		}
		/**
		 * @Private
		 */
		public function set maxExtent(value:String):void {
			if(this._layer)
				this._layer.maxExtent = Bounds.getBoundsFromString(value,this._layer.projSrsCode);
			else if(this._projection)
				this._maxExtent = Bounds.getBoundsFromString(value,this._projection);
			else
				this._maxExtent = Bounds.getBoundsFromString(value,Geometry.DEFAULT_SRS_CODE);
		}
		
		/**
		 * Indicates the proxy used to request layer datas
		 */
		public function get proxy():String {
			if(this._layer)
				return this._layer.proxy;
			return this._proxy;
		}
		/**
		 * @Private
		 */
		public function set proxy(value:String):void {
			this._proxy = value;
			if(this._layer)
				this._layer.proxy = this._proxy;
		}
		
		/**
		 * Indicates if the layer is visible
		 */
		override public function get visible():Boolean {
			if(this._layer)
				return this._layer.visible;
			return super.visible;
		}
		/**
		 * @Private
		 */
		override public function set visible(value:Boolean):void {
			if(this._layer)
				this._layer.visible = value;
		}
		
		/**
		 * Indicates the layer maxResolution
		 */
		public function get maxResolution():Number {
			if(this._layer)
				return this._layer.maxResolution;
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
			if(this._layer)
				return this._layer.minZoomLevel;
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
			if(this._layer)
				return this._layer.maxZoomLevel;
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
			if(this._layer)
				return this._layer.resolutions.join(",");
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
			if(this._layer)
				this._layer.resolutions = this._resolutions;
		}
		
		/**
		 * Indicates teh projection of the layer
		 */
		public function get projection():String {
			if(this._layer)
				return this._layer.projSrsCode;
			return this._projection;
		}
		/**
		 * @Private
		 */
		public function set projection(value:String):void {
			
			this._projection = value;
			if(this._layer) {
				this._layer.projSrsCode = this._projection;
			}
		}
		
		/**
		 * Indicates the alpha of the layer
		 */
		override public function get alpha():Number {
			if(this._layer)
				return this._layer.alpha;
			return super.alpha;
		}
		/**
		 * @Private
		 */
		override public function set alpha(value:Number):void {
			super.alpha = value;
			if(_layer)
				this._layer.alpha = value;
		}
		
		/**
		 * Indicates if the layer should be tweened on zoom
		 */
		public function get tweenOnZoom():Boolean {
			if(this._layer)
				return this._layer.tweenOnZoom;
			return this._tweenOnZoom;
		}
		/**
		 * @Private
		 */
		public function set tweenOnZoom(value:Boolean):void {
			this._tweenOnZoom = value;
			if(this._layer)
				this._layer.tweenOnZoom;
		}
		
		/**
		 * Indicates if the layer should be displayed in the LayerSwitcher List or not
		 * @default true
		 */
		public function get displayInLayerManager():Boolean 
		{		
			if(this.nativeLayer)
				return this.nativeLayer.displayInLayerManager;
			else return this._displayInLayerManager;
		}
		
		/**
		 * @private
		 */
		public function set displayInLayerManager(value:Boolean):void 
		{
			this._displayInLayerManager = value;
			if(this.nativeLayer)
				this.nativeLayer.displayInLayerManager = value;
		}
	}
}
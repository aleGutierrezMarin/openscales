package org.openscales.fx.layer
{	
	import org.openscales.core.Map;
	import org.openscales.core.basetypes.Resolution;
	import org.openscales.core.layer.Constraint;
	import org.openscales.core.layer.Layer;
	import org.openscales.core.layer.originator.DataOriginator;
	import org.openscales.fx.FxMap;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.proj4as.ProjProjection;
	
	import spark.components.Group;
	
	/**
	 * Abstract Layer Flex wrapper
	 */
	public class FxLayer extends Group
	{
		protected var _layer:Layer;
		
		protected var _dpi:Number = NaN;
		
		protected var _minResolution:Resolution = null;
		
		protected var _maxResolution:Resolution = null;
		
		protected var _numZoomLevels:Number = NaN;
		
		protected var _maxExtent:Bounds = null;
		
		protected var _resolutions:Array = null;
		
		protected var _projection:ProjProjection = null;
		
		protected var _tweenOnZoom:Boolean = true;
		
		protected var _proxy:String = null;
		
		protected var _fxmap:FxMap;
		
		protected var _displayInLayerManager:Boolean = true;
		
		protected var _identifier:String;
		
		protected var _displayedName:String;
		
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
				this._layer.projection = this._projection;
			
			this.generateResolutions();
			
			if(!_identifier || _identifier == "") this._identifier = this._layer.identifier; // If no identifer a been set to fxLayer, we take it from layer
			else this._layer.identifier = this._identifier; // Otherwise fxLayer's identifier must be given to layer
			if(!_displayedName || _displayedName=="") this._layer.displayedName = this._identifier; // If no displayedName a been set to fxLayer, we take the identifier as a displayName (to match Layer's behavior)
			else this._layer.displayedName = this._displayedName; // Otherwise we use fxLayer's displayedName
			
			
			if(this._proxy)
				this._layer.proxy = this._proxy;
			
			if(this._dpi)
				this._layer.dpi = this._dpi;
			
			if(this._resolutions)
				this._layer.resolutions = this._resolutions;
			
			if(!isNaN(this.minResolution.value))
				this._layer.minResolution = this.minResolution;
			
			if(!isNaN(this.maxResolution.value))
				this._layer.maxResolution = this.maxResolution;
			
			if(this._maxExtent) {
				this._layer.maxExtent = this._maxExtent;
				this._maxExtent = null;
			}
			
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
				this._layer.generateResolutions(this.numZoomLevels, this.maxResolution.value);
			}else{
				if(!isNaN(this.maxResolution.value)) {
					this._layer.generateResolutions(Layer.DEFAULT_NUM_ZOOM_LEVELS, this.maxResolution.value);
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
		
		public function get constraints():Vector.<Constraint>{
			if(this._layer){
				return this._layer.constraints;
			}
			return null;
		}
		
		public function set constraints(value:Vector.<Constraint>):void{
			if(this._layer){
				this._layer.constraints = value;
			}
		}
		
		/**
		 * Identifier of the layer
		 */ 
		public function get identifier():String{
			if(this._layer)return this._layer.identifier;
			return null;
		}
		
		/**
		 * @private
		 */ 
		public function set identifier(value:String):void{
			this._identifier = value;
			if(this._layer) this._layer.identifier = value;
			
		}
		
		/**
		 * Name and identifier of the layer.
		 * 
		 * @deprecated You shall not more use this to set layer's name. Use <code>identifier</code> and <code>displayedName</code> instead
		 */ 
		override public function get name():String{
			if(this._layer)return this._layer.name
			return super.name;
		}
		
		/**
		 * @private
		 */ 
		override public function set name(value:String):void{
			super.name = value;
			if(this._layer)this._layer.name = value;
		}
		
		/**
		 * Human readable name of the layer
		 */ 
		public function get displayedName():String{
			if(this._layer)return this._layer.displayedName;
			return null;
		}
		
		/**
		 * @private
		 */ 
		public function set displayedName(value:String):void{
			this._displayedName = value;
			if(this._layer) this._layer.displayedName = value;
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
		 * Indicates the max extent in the layer's projection (can be set as a Bounds or as a string: "x1,y1,x2,y2,projection")
		 */
		public function get maxExtent():Bounds {
			if(this._layer)
				return this._layer.maxExtent;
			if(this._maxExtent)
				return this._maxExtent;
			return null;
		}
		/**
		 * @Private
		 */
		public function set maxExtent(value:*):void {
			if(value)
			{
				if(value is Bounds) {
					this._maxExtent = value as Bounds;
					if(this._layer)
						this._layer.maxExtent = this._maxExtent;
				} else if (value is String) {
					var length:Number = (value.split(",")).length;
					var newExtent:Bounds;
					if(length == 4)
					{
						if(this._layer)
							this._layer.maxExtent = Bounds.getBoundsFromString(value+",EPSG:4326");
						else if(this._projection)
							this._maxExtent = Bounds.getBoundsFromString(value+",EPSG:4326");
					}
					else
					{
						this._maxExtent = Bounds.getBoundsFromString(value);
						
						if(this._layer)
							this._layer.maxExtent = this._maxExtent;
					}
				}
			}
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
			super.visible = value;
		}
		
		/**
		 * Indicates the layer maxResolution
		 */
		public function get minResolution():Resolution {
			if(this._layer)
				return this._layer.minResolution;
			return this._minResolution;
		}
		/**
		 * @Private
		 */
		public function set minResolution(value:*):void {
			
			var newResolution:Resolution;
			
			if(value is Resolution)
				newResolution = value as Resolution;
			else if (value is String) {
				var val:Array=(value as String).split(",");
				if(val.length==2) {
					var proj:String = String(val[1]).replace(/\s/g,"");
					if(proj && proj!="")
						newResolution = new Resolution(Number(val[0]),proj);
					else
						newResolution = new Resolution(Number(val[0]));
				}
				else if(val.length == 1)
					newResolution = new Resolution(Number(val[0]));
			}
			else if (value is Number) {
				newResolution = new Resolution(value as Number);
			}
			
			this._minResolution = newResolution;
			if(this._layer)
				this._layer.minResolution = newResolution;
			
			this.generateResolutions();
		}
		
		/**
		 * Indicates the layer maxResolution
		 */
		public function get maxResolution():Resolution {
			if(this._layer)
				return this._layer.maxResolution;
			return this._maxResolution;
		}
		/**
		 * @Private
		 */
		public function set maxResolution(value:*):void {
			var newResolution:Resolution;
			
			if(value is Resolution)
				newResolution = value as Resolution;
			else if (value is String) {
				var val:Array=(value as String).split(",");
				if(val.length==2) {
					var proj:String = String(val[1]).replace(/\s/g,"");
					if(proj && proj!="")
						newResolution = new Resolution(Number(val[0]),proj);
					else
						newResolution = new Resolution(Number(val[0]));
				}
				else if(val.length == 1)
					newResolution = new Resolution(Number(val[0]));
			}
			else if (value is Number) {
				newResolution = new Resolution(value as Number);
			}
			
			this._maxResolution = newResolution;
			if(this._layer)
				this._layer.maxResolution = newResolution;
			
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
		public function get projection():ProjProjection {
			if(this._layer)
				return this._layer.projection;
			return this._projection;
		}
		/**
		 * @Private
		 */
		public function set projection(value:*):void {
			
			this._projection = ProjProjection.getProjProjection(value);
			if(this._layer) {
				this._layer.projection = this._projection;
			}
		}
		
		/**
		 * Indicates the available projections of the layer
		 */
		public function get availableProjections():Vector.<String> {
			if(this._layer)
				return this._layer.availableProjections;
			return null;
		}
		/**
		 * @Private
		 */
		public function set availableProjections(value:*):void {
		
			if(this._layer) {
				this._layer.availableProjections = value;
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
		
		/**
		 * @inheritDoc
		 */
		public function get originators():Vector.<DataOriginator> 
		{		
			if(this.nativeLayer)
				return this.nativeLayer.originators;
			return null;
		}
		
		/**
		 * @private
		 */
		public function set originators(value:Vector.<DataOriginator>):void 
		{
			if(this.nativeLayer)
				this.nativeLayer.originators = value;
		}
	}
}
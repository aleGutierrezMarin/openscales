package org.openscales.fx.layer
{
	import mx.core.Container;
	
	import org.openscales.basetypes.Bounds;
	import org.openscales.core.Map;
	import org.openscales.core.layer.Layer;
	import org.openscales.fx.FxMap;
	import org.openscales.proj4as.ProjProjection;
	
	public class FxLayer extends Container
	{
		protected var _layer:Layer;
		
		protected var _minResolution:Number = NaN;
		
		protected var _maxResolution:Number = NaN;
				
		protected var _numZoomLevels:Number = NaN;
		
		protected var _maxExtent:Bounds = null;
		
		protected var _resolutions:Array = null;
		
		protected var _projection:String = null;
		
		protected var _fxmap:FxMap;
		
		public function FxLayer() {
			super();
			this.init();
		}
		
		public function init():void {
			
		}
		
		public function configureLayer():Layer {
			
			if(this._projection)
				this.layer.projection = new ProjProjection(this._projection);
			if(!isNaN(this.numZoomLevels)) {
				this.layer.generateResolutions(this.numZoomLevels, this.maxResolution);
			}
			if(this._resolutions)
				this.layer.resolutions = this._resolutions;
			if(!isNaN(this.minResolution))
				this.layer.minResolution = this.minResolution;
			if(!isNaN(this.maxResolution))
				this.layer.maxResolution = this.maxResolution;
			if(this._maxExtent)
				this.layer.maxExtent = this._maxExtent;
			
			return this.layer;
		}
		
		public function get layer():Layer {
			return this._layer;
		}
		
		public function getInstance():Layer {
			return this.layer;
		}
		
		public function get fxmap():FxMap {
			return this._fxmap;
		}
		
		public function set fxmap(value:FxMap):void {
			this._fxmap = value;
		}
		
		public function get map():Map {
			if (this.layer != null)
				return this.layer.map;
			else
				return null;
		}
		
		public override function set name(value:String):void {
			if(this.layer != null)
				this.layer.name = value;
		}
		
		public function set isBaseLayer(value:Boolean):void {
			if(this.layer != null)
				this.layer.isBaseLayer = value;
		}
		
		public function set isFixed(value:Boolean):void {
			if(this.layer != null)
				this.layer.isFixed = value;
		}
		
		public function set maxExtent(value:String):void {
			if(this._projection)
				this._maxExtent = Bounds.getBoundsFromString(value,ProjProjection.getProjProjection(this._projection));
			else
				this._maxExtent = Bounds.getBoundsFromString(value,Layer.DEFAULT_PROJECTION);
		}
		
		public function set proxy(value:String):void {
			if(this.layer != null)
				this.layer.proxy = value;
		}
		
		override public function set visible(value:Boolean):void {
			if(this.layer != null)
				this.layer.visible = value;
		}
		
		public function set maxResolution(value:Number):void {
			this._maxResolution = value;
		}
		
		public function get maxResolution():Number {
			return this._maxResolution;
		}
		
		public function set minResolution(value:Number):void {
			this._minResolution = value;
		}
		
		public function get minResolution():Number {
			return this._minResolution;
		}
		
		
		public function set numZoomLevels(value:Number):void {
			this._numZoomLevels = value;
		}
		
		public function get numZoomLevels():Number {
			return this._numZoomLevels;
		}
		
		public function set resolutions(value:String):void {
			var resString:String = null;
			var resNumberArray:Array = new Array();
			for each (resString in value.split(",")) {
				resNumberArray.push(Number(resString));
			}
			this._resolutions = resNumberArray;
		}
		
		public function set projection(value:String):void {
			this._projection = value;
			if(this._maxExtent)
				this._maxExtent.projection = ProjProjection.getProjProjection(this._projection);
		}
		
		override public function set alpha(value:Number):void {
			if(layer)
				this.layer.alpha = value;
		}
		
		override public function get alpha():Number {
			var value:Number = NaN;
			if(layer)
				value = this.layer.alpha;
			return value;
		}
		
	}
}
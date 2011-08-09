package org.openscales.fx.layer
{
	import org.openscales.core.layer.ogc.GPX;

	public class FxGPX extends FxFeatureLayer
	{
		//private var _xmlData:XML;
		
		public function FxGPX()
		{
			super();
		}
		
		
		override public function init():void {
			this._layer = new GPX("", "", "", null);
		}
	
		/**
		 * Setters & Getters 
		 */
		
		public function get url():String{
			if(this._layer != null)
				return (this._layer as GPX).url;
			return null;
		}
		
		public function set url(value:String):void {
			if(this._layer != null)
				(this._layer as GPX).url = value;
		}
		
		public function get version ():String{
			if(this._layer != null)
				return (this._layer as GPX).version;
			return null;
		}
		
		public function set version (value:String):void{
			if(this._layer != null)
				(this._layer as GPX).version = value;
		}
		
		public function set xmlData(value:XML):void{
			if(this._layer != null)
				(this._layer as GPX).gpxData = value;
		}
		
		public function get xmlData():XML{
			if(this._layer != null)
				return (this._layer as GPX).gpxData;
			return null;
		}
		
	}
}
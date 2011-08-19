package org.openscales.fx.layer
{
	import org.openscales.core.feature.Feature;
	import org.openscales.core.layer.ogc.GeoRss;

	public class FxGeoRss extends FxFeatureLayer
	{
		private var _url:String;
		
		public function FxGeoRss()
		{
			super();
		}
		
		
		override public function init():void {
			this._layer = new GeoRss("","");
		}
		
		/**
		 * Setters and Getters 
		 */
		
		public function get url():String{
			if(this._layer != null)
				return (this._layer as GeoRss).url;
			return null;
			this.id = "";
		}
		
		public function set url(value:String):void {
			if(this._layer != null)
				(this._layer as GeoRss).url = value;
		}
		
		
		public function set georssData(value:XML):void{
			if(this._layer != null)
				(this._layer as GeoRss).georssData = value;
		}
		
		public function get georssData():XML{
			if(this._layer != null)
				return (this._layer as GeoRss).georssData;
			return null;
		}
		
		public function get featureVector():Vector.<Feature>
		{
			if(this._layer != null)
				return (this._layer as GeoRss).featureVector;
			return null;
		}
		
		override public function set name(value:String):void{
			if(this._layer != null)
				(this._layer as GeoRss).name = value;
		}
		
		override public function get name():String{
			if(this._layer != null)
				return (this._layer as GeoRss).name;
			return null;
		}
	}
}
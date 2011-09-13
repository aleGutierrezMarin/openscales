package org.openscales.fx.layer
{
	import org.openscales.core.feature.Feature;
	import org.openscales.core.layer.ogc.GeoRss;

	public class FxGeoRss extends FxVectorLayer
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
		
		public function get popUpWidth():Number{
			if(this._layer != null)
				return (this._layer as GeoRss).popUpWidth;
			return NaN;
		}
		
		public function set popUpWidth(value:Number):void {
			if(this._layer != null)
				(this._layer as GeoRss).popUpWidth = value;
		}
		
		public function get popUpHeight():Number{
			if(this._layer != null)
				return (this._layer as GeoRss).popUpHeight;
			return NaN;
		}
		
		public function set popUpHeight(value:Number):void {
			if(this._layer != null)
				(this._layer as GeoRss).popUpHeight = value;
		}
		
		public function get useFeedTitle():Boolean{
			if(this._layer != null)
				return (this._layer as GeoRss).useFeedTitle;
			return false;
		}
		
		public function set useFeedTitle(value:Boolean):void {
			if(this._layer != null)
				(this._layer as GeoRss).useFeedTitle = value;
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
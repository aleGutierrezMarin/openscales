package org.openscales.fx.layer
{
	import org.openscales.core.format.GPXFormat;
	import org.openscales.core.layer.ogc.GPX;
	import org.openscales.core.style.Style;

	public class FxGPX extends FxVectorLayer
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
		 * Setters and Getters 
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
		
		public function get xmlData():XML{
			if(this._layer != null)
				return (this._layer as GPX).gpxData;
			return null;
		}
		
		public function set xmlData(value:XML):void{
			if(this._layer != null)
				(this._layer as GPX).gpxData = value;
		}
		
		override public function get style():Style{
			if(this._layer != null)
				return (this._layer as GPX).style;
			return null;
		}
		
		override public function set style(value:Style):void{
			if(this._layer != null)
				(this._layer as GPX).style = value;
		}

		public function get extractAttributes():Boolean{
			if(this._layer != null)
				return (this._layer as GPX).extractAttributes;
			return false;
		}
		
		public function set extractAttributes(value:Boolean):void{
			if(this._layer != null)
			{
				(this._layer as GPX).extractAttributes = value;
				(this._layer as GPX).gpxFormat.extractAttributes = value;
			}
				
		}
		public function get extractWaypoints():Boolean{
			if(this._layer != null)
				return (this._layer as GPX).extractWaypoints;
			return false;
		}
		
		public function set extractWaypoints(value:Boolean):void{
			if(this._layer != null)
			{
				(this._layer as GPX).extractWaypoints = value;
				(this._layer as GPX).gpxFormat.extractWaypoints = value;
			}		
		}
		public function get extractTracks():Boolean{
			if(this._layer != null)
				return (this._layer as GPX).extractTracks;
			return false;
		}
		
		public function set extractTracks(value:Boolean):void{
			if(this._layer != null)
			{
				(this._layer as GPX).extractTracks = value;
				(this._layer as GPX).gpxFormat.extractTracks = value;
			}		
		}
		public function get extractRoutes():Boolean{
			if(this._layer != null)
				return (this._layer as GPX).extractRoutes;
			return false;
		}
		
		public function set extractRoutes(value:Boolean):void{
			if(this._layer != null)
			{
				(this._layer as GPX).extractRoutes = value;
				(this._layer as GPX).gpxFormat.extractRoutes = value;
			}	
		}

	}
}
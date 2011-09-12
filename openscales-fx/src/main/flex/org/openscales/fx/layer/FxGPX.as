package org.openscales.fx.layer
{
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
				return (this._layer as GPX).data;
			return null;
		}
		
		public function set xmlData(value:XML):void{
			if(this._layer != null)
				(this._layer as GPX).data = value;
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

	}
}
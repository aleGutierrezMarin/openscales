package org.openscales.core.style.graphic
{
	public class ExternalGraphic implements Graphic
	{
		
		private var _size:Object;
		private var _format:String;
		private var _onlineResource:String;
		
		public function ExternalGraphic(onlineResource:String=null,size:Object=10,format:String="image/png")
		{
			this._onlineResource = onlineResource;
			this._size = size;
			this._format = format;
		}
		
		public function clone():Graphic {
			return new ExternalGraphic(this._onlineResource,this._size,this.format);
		}
		
		public function get sld():String
		{
			if(!this._onlineResource)
				return null;
			var res:String = "<sld:Graphic>\n";
			res+= "<sld:ExternalGraphic>\n";
			res+= "<sld:OnlineResource xlink:type=\"simple\" xlink:href=\""+this._onlineResource+"\"/>";
			res+= "<sld:Format>"+this._format+"</sld:Format>";
			res+= "</sld:ExternalGraphic>\n";
			if(this._size is Number)
				res+= "<sld:Size>"+this._size+"</sld:Size>";
			res+= "</sld:Graphic>\n";
			return res;
		}
		
		public function set sld(value:String):void
		{
			//TODO
		}

		public function get size():Object
		{
			return _size;
		}

		public function set size(value:Object):void
		{
			_size = value;
		}

		public function get format():String
		{
			return _format;
		}

		public function set format(value:String):void
		{
			_format = value;
		}

		public function get onlineResource():String
		{
			return _onlineResource;
		}

		public function set onlineResource(value:String):void
		{
			_onlineResource = value;
		}


	}
}
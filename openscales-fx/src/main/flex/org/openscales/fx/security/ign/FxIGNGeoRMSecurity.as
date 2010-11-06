package org.openscales.fx.security.ign
{
	import org.openscales.core.security.ISecurity;
	import org.openscales.core.security.ign.IGNGeoRMSecurity;
	import org.openscales.fx.security.FxAbstractSecurity;
	
	/**
	 * <p>IGNGeoRMSecurity Flex wrapper.</p>
	 * <p>To use it, declare a &lt;IGNGeoRMSecurity /&gt; MXML component using xmlns="http://openscales.org"</p>
	 */
	public class FxIGNGeoRMSecurity extends FxAbstractSecurity
	{
		private var _key:String;
		private var _proxy:String;
		private var _host:String;
		private var _method:String;
		
		public function FxIGNGeoRMSecurity()
		{			
			super();
		}
		
		public function set key(value:String):void{
			this._key = value;	
		}

		public function get key():String{
			return this._key;	
		}

		public function set proxy(value:String):void{
			this._proxy=value;
		}

		public function set host(value:String):void{
			this._host=value;
		}
		
		public function get method():String{
			return this._method;	
		}
		
		public function set method(value:String):void{
			this._method=value;
		}
		override public function get security():ISecurity {
			return new IGNGeoRMSecurity(this.map,this._key,this._proxy, this._host,this._method);
		}
	}
}
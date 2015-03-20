package org.openscales.fx.security
{
	import org.openscales.core.security.AuthBasicSecurity;
	import org.openscales.core.security.ISecurity;

	/**
	 * <p>AuthBasicSecurity Flex wrapper.</p>
	 * <p>To use it, declare a &lt;AuthBasicSecurity /&gt; MXML component using xmlns="http://openscales.org"</p>
	 */
	public class FxAuthBasicSecurity extends FxAbstractSecurity
	{
		
		/** 
		 * String containing "login:pass" for an AuthBasic authentication security
		 */
		private var _loginPass:String;
		
		public function FxAuthBasicSecurity()
		{
			super();
		}
		
		public function set loginPass(value:String):void{
			this._loginPass = value;	
		}
		
		public function get loginPass():String{
			return this._loginPass;	
		}
		
		override public function get security():ISecurity {
			return new AuthBasicSecurity(this.map, this.loginPass);
		}
		
	}
}
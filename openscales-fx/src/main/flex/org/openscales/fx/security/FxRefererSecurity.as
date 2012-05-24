package org.openscales.fx.security
{
	import org.openscales.core.security.ISecurity;
	import org.openscales.core.security.RefererSecurity;

	/**
	 * <p>RefererSecurity Flex wrapper.</p>
	 * <p>To use it, declare a &lt;RefererSecurity /&gt; MXML component using xmlns="http://openscales.org"</p>
	 */
	public class FxRefererSecurity extends FxAbstractSecurity
	{
		public function FxRefererSecurity()
		{
			super();
		}
		
		override public function get security():ISecurity {
			return new RefererSecurity(this.map);
		}
	}
}
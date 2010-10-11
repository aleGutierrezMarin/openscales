package org.openscales.fx.routing
{
	import org.openscales.core.Map;
	import org.openscales.core.layer.FeatureLayer;
	import org.openscales.core.routing.SampleRouting;
	
	/**
	 * <p>SampleRouting Flex wrapper.</p>
	 * <p>To use it, declare a &lt;SampleRouting /&gt; MXML component using xmlns="http://openscales.org"</p>
	 */
	public class FxSampleRouting extends FxAbstractRouting
	{
		public function FxSampleRouting(map:Map=null,active:Boolean=true,resultsLayer:FeatureLayer=null) 
		{
			//We define here our routing Handler
			_routingHandler=new SampleRouting(map,active,resultsLayer);			
			super(map,active,resultsLayer);
		}
		
	}
}
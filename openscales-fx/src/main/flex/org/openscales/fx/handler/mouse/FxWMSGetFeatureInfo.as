package org.openscales.fx.handler.mouse
{
	import org.openscales.core.handler.mouse.WMSGetFeatureInfo;
	import org.openscales.fx.handler.FxHandler;
	
	/**
	 * <p>WMSGetFeatureInfo Flex wrapper.</p>
	 * <p>To use it, declare a &lt;WMSGetFeatureInfo /&gt; MXML component using xmlns="http://openscales.org"</p>
	 */
	public class FxWMSGetFeatureInfo extends FxHandler
	{
	
		public function FxWMSGetFeatureInfo()
		{
			this.handler = new WMSGetFeatureInfo();
			super();
		}
		
		public function set maxFeatures(maxFeatures:Number):void {
			(this.handler as WMSGetFeatureInfo).maxFeatures = maxFeatures;
		}
	
		public function set drillDown(drillDown:Boolean):void{
			(this.handler as WMSGetFeatureInfo).drillDown = drillDown;
		}
		
		public function set format(infoFormat:String):void {
			(this.handler as WMSGetFeatureInfo).infoFormat = infoFormat;
		}
		
		public function set layers(layers:String):void {
			(this.handler as WMSGetFeatureInfo).layers = layers;
		}
	}
}
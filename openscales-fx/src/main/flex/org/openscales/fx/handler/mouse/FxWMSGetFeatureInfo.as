package org.openscales.fx.handler.mouse
{
	import org.openscales.core.handler.mouse.WMSGetFeatureInfo_old;
	import org.openscales.fx.handler.FxHandler;
	
	/**
	 * <p>WMSGetFeatureInfo Flex wrapper.</p>
	 * <p>To use it, declare a &lt;WMSGetFeatureInfo /&gt; MXML component using xmlns="http://openscales.org"</p>
	 */
	public class FxWMSGetFeatureInfo extends FxHandler
	{
	
		public function FxWMSGetFeatureInfo()
		{
			this.handler = new WMSGetFeatureInfo_old();
			super();
		}
		
		public function set url(url:String):void {
			(this.handler as WMSGetFeatureInfo_old).url = url;
		}
		
		public function set layers(layers:String):void {
			(this.handler as WMSGetFeatureInfo_old).layers = layers;
		}
		
		public function set srs(srs:String):void {
			(this.handler as WMSGetFeatureInfo_old).srs = srs;
		}
		
		public function set format(format:String):void {
			(this.handler as WMSGetFeatureInfo_old).format = format;
		}
		
		public function set maxFeatures(maxFeatures:Number):void {
			(this.handler as WMSGetFeatureInfo_old).maxFeatures = maxFeatures;
		}
		
	}
}
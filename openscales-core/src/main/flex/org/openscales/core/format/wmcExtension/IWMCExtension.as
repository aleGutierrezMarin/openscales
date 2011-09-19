package org.openscales.core.format.wmcextension
{
	import org.openscales.core.layer.Layer;

	public interface IWMCExtension
	{
		
		/**
		 * Function that will be used to parse the generalTypeExtension
		 * of the WMC
		 */
		function parseGeneralTypeExtension(data:XML):void
		
		/**
		 * Function that will be used to parse the layerTypeExtension
		 * of the WMC
		 */
		function parseLayerTypeExtension(data:XML, layer:Layer):void
	}
}
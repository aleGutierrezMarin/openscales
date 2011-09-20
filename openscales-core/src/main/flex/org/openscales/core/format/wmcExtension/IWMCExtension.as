package org.openscales.core.format.wmcExtension
{
	import org.openscales.core.layer.Layer;

	public interface IWMCExtension
	{
		
		/**
		 * Function that will be used to parse the generalTypeExtension
		 * of the WMC
		 */
		function parseGeneralTypeExtension(data:XML):Object
		
		/**
		 * Function that will be used to parse the layerTypeExtension
		 * of the WMC
		 */
		function parseLayerTypeExtension(data:XML, layer:Layer):Object
	}
}
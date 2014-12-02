package org.openscales.core.configuration
{
	import org.openscales.core.Map;
	import org.openscales.core.layer.Layer;
	
	public interface IConfiguration
	{
		
		/**
		 * 
		 * @param config The XML config file
		 */		
		function configure():void;
		
		/**
		 * Set the map to configure
		 */
		function set map(value:Map):void;
		
		/**
		 * Get the map to configure 
		 */
		function get map():Map;
		
		/**
		 * Set and store the configuration file that will be used further
		 */
		function set config(value:XML):void;
		
		/**
		 * Get the config file as a raw XML instance 
		 */
		function get config():XML;
		
		/**
		 * Return layers configured between the <layers> </layers> elements
		 */
		function get layersFromMap():Vector.<Layer>;

		/**
		 * Return layers configured between the <Catalog> </Catalog> elements (recursively parsed in all categories)
		 */	
		function get layersFromCatalog():Vector.<Layer>;
		
		/**
		 * Return layers configured in the node passed in parameter
		 */	
		function parseLayer(value:XML):Layer;
		
		/**
		 * @return The child items of <Catalog> </Catalog> elements 
		 */	
		function get catalog():XMLList;
		
		/**
		 * @return The child items of <Custom> </Custom> elements
		 * It's an XML and not a XMLList because in case we have several customs, we can't access specificly to a custom.
		 */	
		function get custom():XML;
		
		/**
		 * @return The child items of <Handlers> </Handlers> elements 
		 */
		function get handlers():XMLList;
		
		/**
		 * @return The child items of <Controls> </Controls> elements 
		 */
		 function get controls():XMLList;
		 /**
		 * @return The child items of <Securities> </Securities> elements 
		 */
		 function get securities():XMLList;
		 /**
		  * @return The styles defined in the configuration
		  */
		 function get styles():Object;
		 
		
	}
}
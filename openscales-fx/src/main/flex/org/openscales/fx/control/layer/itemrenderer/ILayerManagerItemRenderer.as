package org.openscales.fx.control.layer.itemrenderer
{
	import org.openscales.fx.control.layer.LayerManager;
	
	import spark.components.IItemRenderer;
	
	public interface ILayerManagerItemRenderer extends IItemRenderer{
		
		function set rendererOptions(value:Object):void;
		
		function set layerManager(value:LayerManager):void;
	}
}
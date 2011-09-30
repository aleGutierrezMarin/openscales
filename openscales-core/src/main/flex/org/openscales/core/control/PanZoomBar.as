package org.openscales.core.control
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import org.openscales.core.Map;
	import org.openscales.core.utils.Util;
	import org.openscales.core.control.ui.Button;
	import org.openscales.core.events.LayerEvent;
	import org.openscales.core.events.MapEvent;
	import org.openscales.geometry.basetypes.Pixel;
	import org.openscales.geometry.basetypes.Size;
	
	/**
	 * As the PanZoom control, it allows to pan and zoom in/out the map.
	 * It adds a vertical slider for zooming functionality
	 */
	public class PanZoomBar extends PanZoom
	{	
		public function PanZoomBar(position:Pixel = null) {
			super(position);
			
			this.zoom = new ZoomBar(position);
		}
	}
}




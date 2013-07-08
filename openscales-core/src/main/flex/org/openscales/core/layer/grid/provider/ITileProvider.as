package org.openscales.core.layer.grid.provider
{
	import org.openscales.core.layer.Layer;
	import org.openscales.core.tile.ImageTile;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.geometry.basetypes.Pixel;
	
	/**
	 * This interface enables any layer to fetch its tiles
	 * from the correct server. 
	 * 
	 * @author javocale
	 * @author htulipe
	 */
	public interface ITileProvider
	{
		/**
		 * This method fetches the server and return the appropriate ImageTile
		 * 
		 * @param bounds Bounding box for the required tile (in map coordinates)
		 * @param position Center pixel of the required tile
		 * @param the layer that needs the tile
		 * @return an ImageTile representing the tile
		 */ 
		function getTile(bounds:Bounds, center:Pixel, layer:Layer):ImageTile;
		
		/**
		 * If true, when tile loading fails, a pictogram will replace the tile.
		 * 
		 * @default true
		 */ 
		function get useNoDataTile():Boolean;
		
		/**
		 * @private
		 */ 
		function set useNoDataTile(value:Boolean):void;
	}
}
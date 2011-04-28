package org.openscales.core.layer.grid.provider
{
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
		 * @return an ImageTile representing the tile
		 */ 
		function getTile(bounds:Bounds):ImageTile;
		
	}
}
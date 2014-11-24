package org.openscales.core.layer.ogc
{
	import mx.containers.Tile;
	
	import org.openscales.core.layer.ogc.WMS;
	import org.openscales.core.layer.ogc.provider.WMSTileProvider;
	import org.openscales.core.tile.ImageTile;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.geometry.basetypes.Pixel;
	
	public class BalancedWMS extends WMS
	{
		
		private var _urls:Array = [];
		
		public function BalancedWMS(identifier:String="", urls:Array = null, layers:String="", styles:String="", format:String="image/png" ) {
			super(identifier, urls[0], layers, styles, format);
			this._urls = urls;
		}
		
		override public function addTile(bounds:Bounds, position:Pixel):ImageTile {
			var x:Number = randomRange(1, _urls.length)-1;
			super.url  =  _urls[x];
			
			return super.addTile(bounds, position);
		}
		
		private function randomRange(minNum:Number, maxNum:Number):Number {
			return (Math.floor(Math.random() * (maxNum - minNum + 1)) + minNum);
		}
		
	}
}
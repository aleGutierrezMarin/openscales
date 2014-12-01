package org.openscales.core.layer
{
	import org.openscales.core.layer.osm.OSM;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.core.basetypes.Resolution;
	
	public class NokiaHere extends OSM
	{
		public function NokiaHere( identifier:String, layer:String = "normal.day" ) {
			
			var url:String = null;
			this.altUrls = [];
			
			switch(layer)
			{
				// Mapa comum
				case "normal.day": {
					url = "http://1.base.maps.api.here.com/maptile/2.1/maptile/3348a7b73b/normal.day/";
					this.altUrls = [ 
						"http://2.base.maps.api.here.com/maptile/2.1/maptile/3348a7b73b/normal.day/",
						"http://3.base.maps.api.here.com/maptile/2.1/maptile/3348a7b73b/normal.day/",
						"http://4.base.maps.api.here.com/maptile/2.1/maptile/3348a7b73b/normal.day/" 
						];
					break;
				}
					
				// Satelite
				case "hybrid.day": {
					url = "http://1.aerial.maps.api.here.com/maptile/2.1/maptile/3348a7b73b/hybrid.day/";
					this.altUrls = [
						"http://2.aerial.maps.api.here.com/maptile/2.1/maptile/3348a7b73b/hybrid.day/",
						"http://3.aerial.maps.api.here.com/maptile/2.1/maptile/3348a7b73b/hybrid.day/",
						"http://4.aerial.maps.api.here.com/maptile/2.1/maptile/3348a7b73b/hybrid.day/"
						];
					break;
				}
					
				// Terreno
				case "terrain.day": {
					url = "http://1.aerial.maps.api.here.com/maptile/2.1/maptile/3348a7b73b/terrain.day/";
					this.altUrls = [
						"http://2.aerial.maps.api.here.com/maptile/2.1/maptile/3348a7b73b/terrain.day/",
						"http://3.aerial.maps.api.here.com/maptile/2.1/maptile/3348a7b73b/terrain.day/",
						"http://4.aerial.maps.api.here.com/maptile/2.1/maptile/3348a7b73b/terrain.day/"
						];
					break;
				}
					
				default: {
					break;
				}
			}
			
			super(identifier, url);
			
			// Comunidade
			//"http://3.mapcreator.tilehub.api.here.com/tilehub/live/map/png/21031110303?app_id=SqE1xcSngCd3m4a1zEGb&token=r0sR1DzqDkS6sDnh902FWQ&xnlp=CL_JSMv2.5.3.2"
			
			this.generateResolutions(18, OSM.DEFAULT_MAX_RESOLUTION);
		}
		
		
		override public function getURL(bounds:Bounds):String
		{
			var res:Resolution = this.getSupportedResolution(this.map.resolution.reprojectTo(this.projection));
			var x:Number = Math.round((bounds.left - this.maxExtent.left) / (res.value * this.tileWidth));
			var y:Number = Math.round((this.maxExtent.top - bounds.top) / (res.value * this.tileHeight));
			var z:Number = this.getZoomForResolution(res.reprojectTo(this.projection).value);
			var limit:Number = Math.pow(2, z);
			
			if (y < 0 || y >= limit ||x < 0 || x >= limit) {
				return OSM.MISSING_TILE_URL;
			} else {
				x = ((x % limit) + limit) % limit;
				y = ((y % limit) + limit) % limit;
				var url:String = this.url;
				var path:String = z + "/" + x + "/" + y;
				if (this.altUrls != null) {
					url = this.selectUrl(this.url + path, this.getUrls());
				}
				
				// 256x256
				return url + path + "/256/png8?app_id=SqE1xcSngCd3m4a1zEGb&token=r0sR1DzqDkS6sDnh902FWQ";
			}
		}
		
	}
}
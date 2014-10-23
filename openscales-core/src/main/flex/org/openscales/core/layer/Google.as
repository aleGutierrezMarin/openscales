package org.openscales.core.layer
{
	import org.openscales.core.layer.osm.OSM;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.core.basetypes.Resolution;
	
	public class Google extends OSM
	{
		public function Google( identifier:String, layer:String = "map" ) {
				// Hibrido ( png transparente )
				// https://mts1.google.com/vt/lyrs=h@273000000,highlight:0x94c90217156c504d:0xdb7389b2e36aca0d@1|style:maps&hl=x-local&src=app&expIds=201527&rlbl=1&x=3029&y=4620&z=13&s=Gal
				// https://mts1.google.com/vt/lyrs=h@273000000&rlbl=1&x=3029&y=4620&z=13&s=Gal
				
				// Satelite
				// https://www.googleapis.com/tile/v1/tiles/16/24243/36963?session=jgAAACYOn4E-A_GU7RBCOh9LWKDb4dGTXz4OsS4hF6iGFwf0mX7GO8LMyYRZ7tXZmSAe3Q9wdBNi3bJMhZtnsQzjDw2cGvfrqJ2hXyhnNMhwjgAjM2_g9PSRxjYrt5meBRBQXxvXmL4PWK9oV5RIjbh1QRyiBknJApXoCdSZlL8Ku3hF_dpyGhZqlxAjpjMTzevwOA&key=AIzaSyBqNsU8C7J58w88XgvCnAwwEnFWpD_i0ac
				// https://khms1.google.com/kh/v=157&src=app&expIds=201527&rlbl=1&x=3031&y=4619&z=13&s=
				
				// comum
				// https://mts0.google.com/vt/lyrs=m@273051318,highlight:0x94c90217156c504d:0xdb7389b2e36aca0d@1|style:maps&hl=x-local&src=app&expIds=201527&rlbl=1&x=6060&y=9239&z=14&s=Gal
				// https://mts1.google.com/vt/rlbl=1&x=4027&y=6101&z=14
				
				var url:String = null;
				this.altUrls = [];
				
				switch(layer) 
				{
					case "map": {
						url = "https://mts0.google.com/vt/?lyrs=m@273051318&rlbl=2";
						this.altUrls = [ 
							"https://mts1.google.com/vt/?lyrs=m@273051318&rlbl=2",
							"https://mts2.google.com/vt/?lyrs=m@273051318&rlbl=2",
							"https://mts3.google.com/vt/?lyrs=m@273051318&rlbl=2"
						];
						break;
					}
						
					case "hybrid": {
						url = "https://mts0.google.com/vt/?lyrs=h@273000000&rlbl=1";
						this.altUrls = [ 
							"https://mts1.google.com/vt/?lyrs=h@273000000&rlbl=1",
							"https://mts2.google.com/vt/?lyrs=h@273000000&rlbl=1",
							"https://mts3.google.com/vt/?lyrs=h@273000000&rlbl=1"
						];
						break;
					}
						
					case "sat": {
						url = "https://khms0.google.com/kh/v=157&rlbl=1";
						this.altUrls = [
							"https://khms1.google.com/kh/v=157&rlbl=1",
							"https://khms2.google.com/kh/v=157&rlbl=1",
							"https://khms3.google.com/kh/v=157&rlbl=1"
						];
						break;
					}
						
					default: {
						break;
					}
				}
				
				super(identifier, url);
				
				this.generateResolutions(18, OSM.DEFAULT_MAX_RESOLUTION);
			}
			
			
			override public function getURL(bounds:Bounds):String {
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
					var path:String = "&z=" + z + "&x=" + x + "&y=" + y;
					if (this.altUrls != null) {
						url = this.selectUrl(this.url + path, this.getUrls());
					}
					
					return url + path;
				}
			}
			
		}
	}
package org.openscales.core.layer.ogc {
	
	import flash.events.Event;
	
	import org.flexunit.asserts.*;
	import org.flexunit.async.Async;
	import org.openscales.core.Map;
	import org.openscales.core.basetypes.maps.HashMap;
	import org.openscales.core.events.TileEvent;
	import org.openscales.core.layer.ogc.wmts.TileMatrix;
	import org.openscales.core.layer.ogc.wmts.TileMatrixSet;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Size;
	
	public class WMTSTest {
		
		private const NAME:String = "WMTS Layer";
		private const URL:String = "http://someServer.com/wmts";
		private const LAYER:String = "someLayer";
		private const CRS:String = "IGNF:LAMB93";
		private const MATRIX_SET_ID:String = "LAMB93_12.5m";
		private const STYLE:String = "default";
		private const FORMAT:String = "image/jpeg";
		
		
		private function generateTileMatrixSet():TileMatrixSet{
			
			var result:TileMatrixSet = new TileMatrixSet(MATRIX_SET_ID,CRS,new HashMap());
			
			result.tileMatrices.put('0',new TileMatrix('0',365714285,new Location(0,12000000,CRS),256,256,1,1));
			result.tileMatrices.put('1',new TileMatrix('1',182857142,new Location(0,12000000,CRS),256,256,1,1));
			result.tileMatrices.put('2',new TileMatrix('2',91428571,new Location(0,12000000,CRS),256,256,1,2));
			result.tileMatrices.put('3',new TileMatrix('2',45714285,new Location(0,12000000,CRS),256,256,1,3));
			
			return result;
		}
		
		[Test(async)] 
		public function shouldGenerateCorrectQueriesWithMinimumParams():void
		{
			// Given a map of 200x200px, centered on 0,0
			var map:Map = new Map();
			map.size = new Size(200,200);
			map.center = new Location(0,0);
			
			// And a WMTS layer on this map
			var matrixSet:TileMatrixSet = this.generateTileMatrixSet();
			var tms:HashMap = new HashMap();
			tms.put(matrixSet.identifier,matrixSet);
			
			var wmts:WMTS = new WMTS(NAME,URL,LAYER, matrixSet.identifier, tms );		
			map.addLayer(wmts);
			
			// Then request is sent according to the layer parameters
			wmts.addEventListener(TileEvent.TILE_LOAD_START,Async.asyncHandler(this,function(event:TileEvent,obj:Object):void{
				
				var url:String = event.tile.url;
				assertTrue("Request sent to incorrect server",url.match('^'+wmts.url));
				
				// OGC parameters (version, service & request)
				assertTrue("Incorrect VERSION", url.match('VERSION=1.0.0'));
				assertTrue("Incorrect REQUEST", url.match('REQUEST=GetTile'));
				assertTrue("Incorrect SERVICE", url.match('SERVICE=WMTS'));
				
				// wmts specific parameters
				assertTrue("Incorrect LAYER parameter",url.match('LAYER='+wmts.layer));
				assertTrue("Incorrect TILEMATRIXSET parameter", url.match('TILEMATRIXSET='+wmts.tileMatrixSet));
				assertTrue("Incorrect STYLE parameter",url.match('STYLE='+wmts.style));
				
			},100,null,function(event:Event):void{
				
				fail("No request sent");
			}));
			
			// When layer is redrawn
			wmts.redraw();
			
		}
	}
}
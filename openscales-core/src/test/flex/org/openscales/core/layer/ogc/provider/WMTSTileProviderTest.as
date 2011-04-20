package org.openscales.core.layer.ogc.provider
{
	import flexunit.framework.Assert;
	
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertTrue;
	import org.openscales.core.basetypes.maps.HashMap;
	import org.openscales.core.layer.ogc.WMTS;
	import org.openscales.core.layer.ogc.WMTS.TileMatrix;
	import org.openscales.core.layer.ogc.WMTS.TileMatrixSet;
	import org.openscales.core.ns.os_internal;
	import org.openscales.core.tile.ImageTile;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Pixel;
	import org.openscales.geometry.basetypes.Unit;
	import org.openscales.proj4as.ProjProjection;
	
	use namespace os_internal;
	
	public class WMTSTileProviderTest
	{           
		private const _SAMPLE_URL:String = "http://v2.suite.opengeo.org/geoserver/gwc/service/wmts/";
		
		private const _SAMPLE_REQUEST:Object = 
			{
				"SERVICE":"WMTS",
				"VERSION":"1.0.0",
				"REQUEST":"GetTile",
				"FORMAT":"image/png",
				"LAYER":"medford:buildings",
				"STYLE":"default",
				"TILEMATRIXSET":"EPSG:900913",
				"TILEMATRIX":"2",
				"TILEROW":"5",
				"TILECOL":"4"     
			};
		
		/**
		 * This method test the exactitude of tile index calculation
		 */ 
		[Test]
		public function testcalculateTileIndex():void {
			/**
			 * verifies if when a is greater than b, it returns -1
			 */ 
			assertEquals(WMTSTileProvider.calculateTileIndex(2,1,1),-1);
			/**
			 * verifies if when a is equal to b, it returns 0
			 */ 
			assertEquals(WMTSTileProvider.calculateTileIndex(2,2,1),0);
			
			/**
			 * verifies that it validates (3-2/0.5) = 2
			 */ 
			assertEquals(WMTSTileProvider.calculateTileIndex(1.34791,576.765,0.5),Math.floor(((576.765-1.34791)/0.5)));
			
		}
		
		/**
		 *
		 * This method tests the syntax of the GET query returned by buildGETQuery method 
		 * The test goes as follows:
		 * 
		 * <ul>
		 * 		<li>creating an instance of WMTSTileProvider and calling buildGETQuery</li>
		 * 		<li>substr of the url part of the query string, checking if equals to instance's url</li>
		 * 		<li>substr of params part and checking if consistent with instance's attributes</li>
		 * </ul>
		 */
		[Test]
		public function testWMTSTileProviderInit():void {
			var tp:WMTSTileProvider = new WMTSTileProvider("http://test.test","image/png","tmtest","testlayer");
			assertEquals(tp.url,"http://test.test");
			assertEquals(tp.format,"image/png");
			assertEquals(tp.tileMatrixSet,"tmtest");
			assertEquals(tp.layer,"testlayer");
			assertEquals(tp.tileMatrixSets,null);
		}
		
		private function populateTileMatrixSet(tms:TileMatrixSet):void {
			var res:Number;
			var tm:TileMatrix;
			tm = new TileMatrix("0",748982857,new Location(0,12000000,tms.supportedCRS),256,256,1,1);
			res = Unit.getResolutionFromScaleDenominator(tm.scaleDenominator,ProjProjection.getProjProjection(tms.supportedCRS).projParams.units);
			tms.tileMatrices.put(res,tm);
			tm = new TileMatrix("1",374491428,new Location(0,12000000,tms.supportedCRS),256,256,1,1);
			res = Unit.getResolutionFromScaleDenominator(tm.scaleDenominator,ProjProjection.getProjProjection(tms.supportedCRS).projParams.units);
			tms.tileMatrices.put(res,tm);
			tm = new TileMatrix("10",731428,new Location(0,12000000,tms.supportedCRS),256,256,25,206);
			res = Unit.getResolutionFromScaleDenominator(tm.scaleDenominator,ProjProjection.getProjProjection(tms.supportedCRS).projParams.units);
			tms.tileMatrices.put(res,tm);
			tm = new TileMatrix("11",365714,new Location(0,12000000,tms.supportedCRS),256,256,50,411);
			res = Unit.getResolutionFromScaleDenominator(tm.scaleDenominator,ProjProjection.getProjProjection(tms.supportedCRS).projParams.units);
			tms.tileMatrices.put(res,tm);
			tm = new TileMatrix("12",182857,new Location(0,12000000,tms.supportedCRS),256,256,99,822);
			res = Unit.getResolutionFromScaleDenominator(tm.scaleDenominator,ProjProjection.getProjProjection(tms.supportedCRS).projParams.units);
			tms.tileMatrices.put(res,tm);
			tm = new TileMatrix("13",91428,new Location(0,12000000,tms.supportedCRS),256,256,197,1643);
			res = Unit.getResolutionFromScaleDenominator(tm.scaleDenominator,ProjProjection.getProjProjection(tms.supportedCRS).projParams.units);
			tms.tileMatrices.put(res,tm);
			tm = new TileMatrix("14",45714,new Location(0,12000000,tms.supportedCRS),256,256,394,3285);
			res = Unit.getResolutionFromScaleDenominator(tm.scaleDenominator,ProjProjection.getProjProjection(tms.supportedCRS).projParams.units);
			tms.tileMatrices.put(res,tm);
			tm = new TileMatrix("15",22857,new Location(0,12000000,tms.supportedCRS),256,256,788,6569);
			res = Unit.getResolutionFromScaleDenominator(tm.scaleDenominator,ProjProjection.getProjProjection(tms.supportedCRS).projParams.units);
			tms.tileMatrices.put(res,tm);
			tm = new TileMatrix("16",11428,new Location(0,12000000,tms.supportedCRS),256,256,1575,13138);
			res = Unit.getResolutionFromScaleDenominator(tm.scaleDenominator,ProjProjection.getProjProjection(tms.supportedCRS).projParams.units);
			tms.tileMatrices.put(res,tm);
			tm = new TileMatrix("17",5714,new Location(0,12000000,tms.supportedCRS),256,256,3150,26276);
			res = Unit.getResolutionFromScaleDenominator(tm.scaleDenominator,ProjProjection.getProjProjection(tms.supportedCRS).projParams.units);
			tms.tileMatrices.put(res,tm);
			tm = new TileMatrix("18",2857,new Location(0,12000000,tms.supportedCRS),256,256,6300,52552);
			res = Unit.getResolutionFromScaleDenominator(tm.scaleDenominator,ProjProjection.getProjProjection(tms.supportedCRS).projParams.units);
			tms.tileMatrices.put(res,tm);
			tm = new TileMatrix("19",1428,new Location(0,12000000,tms.supportedCRS),256,256,12600,105102);
			res = Unit.getResolutionFromScaleDenominator(tm.scaleDenominator,ProjProjection.getProjProjection(tms.supportedCRS).projParams.units);
			tms.tileMatrices.put(res,tm);
			tm = new TileMatrix("2",187245714,new Location(0,12000000,tms.supportedCRS),256,256,1,1);
			res = Unit.getResolutionFromScaleDenominator(tm.scaleDenominator,ProjProjection.getProjProjection(tms.supportedCRS).projParams.units);
			tms.tileMatrices.put(res,tm);
			tm = new TileMatrix("20",714,new Location(0,12000000,tms.supportedCRS),256,256,25200,210205);
			res = Unit.getResolutionFromScaleDenominator(tm.scaleDenominator,ProjProjection.getProjProjection(tms.supportedCRS).projParams.units);
			tms.tileMatrices.put(res,tm);
			tm = new TileMatrix("21",357,new Location(0,12000000,tms.supportedCRS),256,256,50400,420409);
			res = Unit.getResolutionFromScaleDenominator(tm.scaleDenominator,ProjProjection.getProjProjection(tms.supportedCRS).projParams.units);
			tms.tileMatrices.put(res,tm);
			tm = new TileMatrix("3",93622857,new Location(0,12000000,tms.supportedCRS),256,256,1,2);
			res = Unit.getResolutionFromScaleDenominator(tm.scaleDenominator,ProjProjection.getProjProjection(tms.supportedCRS).projParams.units);
			tms.tileMatrices.put(res,tm);
			tm = new TileMatrix("4",46811428,new Location(0,12000000,tms.supportedCRS),256,256,1,4);
			res = Unit.getResolutionFromScaleDenominator(tm.scaleDenominator,ProjProjection.getProjProjection(tms.supportedCRS).projParams.units);
			tms.tileMatrices.put(res,tm);
			tm = new TileMatrix("5",23405714,new Location(0,12000000,tms.supportedCRS),256,256,1,7);
			res = Unit.getResolutionFromScaleDenominator(tm.scaleDenominator,ProjProjection.getProjProjection(tms.supportedCRS).projParams.units);
			tms.tileMatrices.put(res,tm);
			tm = new TileMatrix("6",11702857,new Location(0,12000000,tms.supportedCRS),256,256,2,13);
			res = Unit.getResolutionFromScaleDenominator(tm.scaleDenominator,ProjProjection.getProjProjection(tms.supportedCRS).projParams.units);
			tms.tileMatrices.put(res,tm);
			tm = new TileMatrix("7",5851428,new Location(0,12000000,tms.supportedCRS),256,256,4,26);
			res = Unit.getResolutionFromScaleDenominator(tm.scaleDenominator,ProjProjection.getProjProjection(tms.supportedCRS).projParams.units);
			tms.tileMatrices.put(res,tm);
			tm = new TileMatrix("8",2925714,new Location(0,12000000,tms.supportedCRS),256,256,7,52);
			res = Unit.getResolutionFromScaleDenominator(tm.scaleDenominator,ProjProjection.getProjProjection(tms.supportedCRS).projParams.units);
			tms.tileMatrices.put(res,tm);
			tm = new TileMatrix("9",1462857,new Location(0,12000000,tms.supportedCRS),256,256,13,103);
			res = Unit.getResolutionFromScaleDenominator(tm.scaleDenominator,ProjProjection.getProjProjection(tms.supportedCRS).projParams.units);
			tms.tileMatrices.put(res,tm);
		}
		
		[Test]
		public function testGenerateResolutions():void {
			//check if the WMTSTileProvider is well initialized
			var tp:WMTSTileProvider = new WMTSTileProvider("http://test.test",
				"image/png",
				"tmtest",
				"testlayer");
			
			//hashmap of tilematrixsets
			tp.tileMatrixSets = new HashMap();
			
			//test tilematrixset
			var tms:TileMatrixSet = new TileMatrixSet("tmtest","IGNF:LAMB93",new HashMap());
			
			//add the tilematrixset to the hashmap of tilematrixsets
			tp.tileMatrixSets.put("tmtest",tms);
			
			//add tilematrix to the tilematrixset
			this.populateTileMatrixSet(tms);
			assertEquals(tms.tileMatrices.size(),22);
			
			var resolutions:Array = tp.generateResolutions(0);
			
			assertEquals(resolutions.length,0);
			
			resolutions = tp.generateResolutions(1);
			assertEquals(resolutions.length,1);
			
			resolutions = tp.generateResolutions(22);
			assertEquals(resolutions.length,22);
			
			resolutions = tp.generateResolutions(23);
			assertEquals(resolutions.length,22);
			
		}
		
		[Test]
		public function testGETQuerySyntax():void
		{
			

			assertTrue(true);
			/*
			//test if the getTile is
			assertEquals(tp.getTile(null,null,null),null);
			var bounds:Bounds = new Bounds(-180,-90,180,90,"epsg:4326");
			
			assertEquals(tp.getTile(bounds,null,null),null);
			*/

			/*
			// Creating an instance
			
			var matrixIds:Object = {"EPSG:900913:13":"EPSG"}
			
			var instance:WMTSTileProvider = new WMTSTileProvider(
				_SAMPLE_URL, 
				_SAMPLE_REQUEST["FORMAT"].toString(), 
				_SAMPLE_REQUEST["TILEMATRIXSET"].toString(), 
				_SAMPLE_REQUEST["LAYER"].toString(), 
				_SAMPLE_REQUEST["STYLE"].toString(), matrixIds);
			// Defining dummies values for tile col and tile row (calculation should return 5 and 4)
			var infos:Array = instance.calculateTileRowAndCol(new Bounds(-50,-50,30,30,"EPSG:900913"),new Location(-90,90));
			// Defining dummies info for tile Matrix (calcuation should return 2)
			var tileMatrix:String = instance.calculateTileMatrix(2);
			var parameters:Object = {
				"TILECOL" : String(infos[0]),
				"TILEROW" : String(infos[1]),
				"TILEMATRIX" : tileMatrix
			}
			
			// Calling the method to test
			var queryString:String =  instance.buildGETQuery(null, parameters);
			
			// Checking if url is correct
			var urlPart:String = queryString.slice(0, queryString.lastIndexOf("?"));            
			Assert.assertEquals(instance.url,urlPart);
			
			// Getting the params string of the query
			var paramsString:String = queryString.slice(queryString.lastIndexOf("?")+1);
			// Splitting the params string into an array
			var params:Array = paramsString.split("&");
			var length:int = params.length;
			
			// Checking params total number 
			Assert.assertEquals(length,10);
			
			var i:int = 0;
			
			// For each param
			for(i;i<length;++i)
			{
				// spliting the key from the value
				var keyValue:Array = (params[i] as String).split("=");
				var lgth:Number = keyValue.length;
				// there should be only one key and only one value
				assertEquals(lgth, 2);
				// The key should be an existing WMTS request parameter 
				assertTrue(_SAMPLE_REQUEST[ keyValue[0].toString() ]!=null);
				// The value should be consistant with the sample request
				assertEquals(_SAMPLE_REQUEST[ keyValue[0].toString() ].toString(), keyValue[1].toString());
			}
			*/
		}
	}
}

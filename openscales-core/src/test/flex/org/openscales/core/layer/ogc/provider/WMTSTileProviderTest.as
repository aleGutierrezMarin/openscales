package org.openscales.core.layer.ogc.provider
{
	import flexunit.framework.Assert;
	
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertTrue;
	import org.openscales.core.layer.ogc.WMTS;
	import org.openscales.core.ns.os_internal;
	import org.openscales.core.tile.ImageTile;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Pixel;
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
		public function testGETQuerySyntax():void
		{           
			
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
		}
		
		/**
		 * This method test the exactitude of tile row and tile col calculation
		 * 
		 * The test goes as follows:
		 * <ul>
		 * 		<li>Creating an instance of WMTSTileProvider and calling calculateTileRowAndCol</li>
		 * 		<li>Calling buildGETQquery to have a query string with calculated values</li>
		 * 		<li>Checking that calculated values are in the query string and are consistent with expected values</li>
		 * </ul> 
		 */ 
		[Test]
		public function testCalculatetileRowAndCol():void
		{
			// Creating an instance
			
			var matrixIds:Array = new Array(
				"EPSG:900913:1",
				"EPSG:900913:2",
				"EPSG:900913:3",
				"EPSG:900913:4",
				"EPSG:900913:5",
				"EPSG:900913:6",
				"EPSG:900913:7",
				"EPSG:900913:8",
				"EPSG:900913:9",
				"EPSG:900913:10",
				"EPSG:900913:11",
				"EPSG:900913:12",
				"EPSG:900913:13",
				"EPSG:900913:14",
				"EPSG:900913:15",
				"EPSG:900913:16",
				"EPSG:900913:17",
				"EPSG:900913:18",
				"EPSG:900913:19"
			);
			
			var instance:WMTSTileProvider = new WMTSTileProvider(
				_SAMPLE_URL, 
				_SAMPLE_REQUEST["FORMAT"].toString(), 
				_SAMPLE_REQUEST["TILEMATRIXSET"].toString(), 
				_SAMPLE_REQUEST["LAYER"].toString(), 
				_SAMPLE_REQUEST["STYLE"].toString(),matrixIds);
			
			var projection:ProjProjection = new ProjProjection("EPSG:900913");
			
			// With these values tileCol should be 1299 and tileRow 3030
			var b:Bounds = new Bounds(
				-13682839.557368,
				5209947.8471924,
				-13677947.587559,
				5214839.817002,
				"EPSG:900913");
			
			var tileWidth:Number = 256;
			var tileHeight:Number = 256;
			
			// Should be 19.109257067871095 but with Math.abs the value is a bit different
			var resolution:Number = Math.abs(Math.abs(b.left)-Math.abs(b.right))/tileWidth;
			
			var tileOrigin:Location = new Location(-20037508.34,20037508.34,"EPSG:900913")
			
			var infos:Array = instance.calculateTileRowAndCol(b, tileOrigin);
			var tileMatrix:String = instance.calculateTileMatrix(13);
			
			var params:Object = {
				"TILECOL" : String(infos[0]),
				"TILEROW" : String(infos[1]),
				"TILEMATRIX" : tileMatrix
			}
			
			var queryString:String = instance.buildGETQuery(b, params);
			
			assertTrue(queryString.indexOf("TILEROW=3030")!=-1);
			assertTrue(queryString.indexOf("TILECOL=1299")!=-1);
		}
	}
}

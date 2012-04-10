package org.openscales.proj4as {
	import org.openscales.proj4as.proj.*;
	
	/**
	 * Define a projection in Proj4as, provided with builtin projection definitions.
	 */
	public class ProjProjection {
		/**
		 * Property: readyToUse
		 * Flag to indicate if initialization is complete for this Proj object
		 */
		public var readyToUse:Boolean=false;
		
		/**
		 * Property: title
		 * The title to describe the projection
		 */
		public var projParams:ProjParams=new ProjParams();
		
		static public const equivalentDefs:Vector.<String> = new <String>["WGS84,EPSG:4326,CRS:84,IGNF:WGS84G","IGNF:LAMB93,EPSG:2154"];
		static public const stretchableDefs:Vector.<String> = new <String>["WGS84,IGNF:WGS84G,EPSG:4326,CRS:84,EPSG:900913,EPSG:3857"]; 
		
		static public const defs:Object={
			'EPSG:900913': "+title=Google Mercator EPSG:900913 +proj=merc +ellps=WGS84 +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +no_defs",
			'WGS84': "+title=long/lat:WGS84 +proj=longlat +ellps=WGS84 +datum=WGS84 +units=degrees",
			'IGNF:WGS84G': "+title=World Geodetic System 1984 +proj=longlat +towgs84=0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,0.000000 +a=6378137.0000 +rf=298.2572221010000 +units=degrees +no_defs",
			'EPSG:4326': "+title=long/lat:WGS84 +proj=longlat +a=6378137.0 +b=6356752.31424518 +ellps=WGS84 +datum=WGS84 +units=degrees",
			'EPSG:4269': "+title=long/lat:NAD83 +proj=longlat +a=6378137.0 +b=6356752.31414036 +ellps=GRS80 +datum=NAD83 +units=degrees",
			'EPSG:27700': "+title=OSGB36/British National Grid +proj=tmerc +lat_0=49 +lon_0=-2 +k=0.9996012717 +x_0=400000 +y_0=-100000 +ellps=airy +datum=OSGB36 +units=m +no_defs",
			
			'EPSG:32637': "+title=WGS 84 / UTM zone 37N +proj=utm +zone=37 +ellps=WGS84 +datum=WGS84 +units=m +no_defs",
			'EPSG:32638': "+title=WGS 84 / UTM zone 38N +proj=utm +zone=38 +ellps=WGS84 +datum=WGS84 +units=m +no_defs",
			'EPSG:32639': "+title=WGS 84 / UTM zone 39N +proj=utm +zone=39 +ellps=WGS84 +datum=WGS84 +units=m +no_defs",
			'EPSG:32640': "+title=WGS 84 / UTM zone 40N +proj=utm +zone=40 +ellps=WGS84 +datum=WGS84 +units=m +no_defs",
			'EPSG:32641': "+title=WGS 84 / UTM zone 41N +proj=utm +zone=41 +ellps=WGS84 +datum=WGS84 +units=m +no_defs",			 
			
			'EPSG:28991': "+title=RD +proj=sterea +lat_0=52.15616055555555 +lon_0=5.38763888888889 +k=0.9999079 +x_0=0 +y_0=0 +ellps=bessel +units=m +no_defs",
			'EPSG:28992': "+title=RD2004 +proj=sterea +lat_0=52.15616055555555 +lon_0=5.38763888888889 +k=0.999908 +x_0=155000 +y_0=463000 +ellps=bessel +units=m +towgs84=565.2369,50.0087,465.658,-0.406857330322398,0.350732676542563,-1.8703473836068,4.0812 +no_defs",					 
			
			'EPSG:31300': "+title=Lambert72 +proj=lcc +lat_1=49.83333333333334 +lat_2=51.16666666666666 +lat_0=90 +lon_0=4.356939722222222 +x_0=150000.01256 +y_0=5400088.4378 +ellps=intl +towgs84=106.869,-52.2978,103.724,-0.33657,0.456955,-1.84218,1 +units=m +no_defs",
			'EPSG:31370': "+title=Lambert72 New +proj=lcc +lat_1=51.16666723333334 +lat_2=49.83333389999999 +lat_0=90 +lon_0=4.367486666666666 +x_0=150000.013 +y_0=5400088.438 +ellps=intl +towgs84=-99.1,53.3,-112.5,0.419,-0.83,1.885,-1.0 +units=m +no_defs",			
			
			'EPSG:2176': "+title=Poland CS2000 zone 5 +proj=tmerc +lat_0=0 +lon_0=15 +k=0.999923 +x_0=5500000 +y_0=0 +ellps=GRS80 +units=m +no_defs",
			'EPSG:2177': "+title=Poland CS2000 zone 6 +proj=tmerc +lat_0=0 +lon_0=18 +k=0.999923 +x_0=6500000 +y_0=0 +ellps=GRS80 +units=m +no_defs",
			'EPSG:2178': "+title=Poland CS2000 zone 7 +proj=tmerc +lat_0=0 +lon_0=21 +k=0.999923 +x_0=7500000 +y_0=0 +ellps=GRS80 +units=m +no_defs",
			'EPSG:2179': "+title=Poland CS2000 zone 8 +proj=tmerc +lat_0=0 +lon_0=24 +k=0.999923 +x_0=8500000 +y_0=0 +ellps=GRS80 +units=m +no_defs",
			'EPSG:2180': "+title=Poland CS92 +proj=tmerc +lat_0=0 +lon_0=19 +k=0.9993 +x_0=500000 +y_0=-5300000 +ellps=GRS80 +units=m +no_defs",
			
			'EPSG:2154'	: "+title=RGF93 / Lambert-93 +proj=lcc +lat_1=49 +lat_2=44 +lat_0=46.5 +lon_0=3 +x_0=700000 +y_0=6600000 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs", 	
			
			'EPSG:3346' : "+title=LKS94 / Lithuania TM +proj=tmerc +lat_0=0 +lon_0=24 +k=0.9998 +x_0=500000 +y_0=0 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs",
			'EPSG:3857' : "+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +units=m +k=1.0 +nadgrids=@null +no_defs",
			'EPSG:2065' : "+title=S-JTSK (Ferro) / Krovak +proj=krovak +lat_0=49.5 +lon_0=42.5 +alpha=30.28813972222222 +k=0.9999 +x_0=0 +y_0=0 +ellps=bessel +pm=ferro +units=m +no_defs",
			
			// DGR 2009-08-27 : IGNF, Geoportal cache projections :
			'IGNF:GEOPORTALANF': "+title=Geoportail - Antilles francaises +proj=eqc +nadgrids=null +towgs84=0.0000,0.0000,0.0000 +a=6378137.0000 +rf=298.2572221010000 +lat_0=0.000000000 +lon_0=0.000000000 +lat_ts=15.000000000 +x_0=0.000 +y_0=0.000 +units=m +no_defs",
			'IGNF:GEOPORTALASP': "+title=Geoportail - Saint Paul et Amsterdam (Iles) +proj=eqc +nadgrids=null +towgs84=0.0000,0.0000,0.0000 +a=6378137.0000 +rf=298.2572221010000 +lat_0=0.000000000 +lon_0=0.000000000 +lat_ts=38.000000000 +x_0=0.000 +y_0=0.000 +units=m +no_defs",
			'IGNF:GEOPORTALCRZ': "+title=Geoportail - Crozet +proj=eqc +nadgrids=null +towgs84=0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,0.000000 +a=6378137.0000 +rf=298.2572221010000 +lat_0=0.000000000 +lon_0=0.000000000 +lat_ts=-46.000000000 +x_0=0.000 +y_0=0.000 +units=m +no_defs",
			'IGNF:GEOPORTALFXX': "+title=Geoportail - France metropolitaine +proj=eqc +nadgrids=null +towgs84=0.0000,0.0000,0.0000 +a=6378137.0000 +rf=298.2572221010000 +lat_0=0.000000000 +lon_0=0.000000000 +lat_ts=46.500000000 +x_0=0.000 +y_0=0.000 +units=m +no_defs",
			'IGNF:GEOPORTALGUF': "+title=Geoportail - Guyane +proj=eqc +nadgrids=null +towgs84=0.0000,0.0000,0.0000 +a=6378137.0000 +rf=298.2572221010000 +lat_0=0.000000000 +lon_0=0.000000000 +lat_ts=4.000000000 +x_0=0.000 +y_0=0.000 +units=m +no_defs",
			'IGNF:GEOPORTALKER': "+title=Geoportail - Kerguelen +proj=eqc +nadgrids=null +towgs84=0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,0.000000 +a=6378137.0000 +rf=298.2572221010000 +lat_0=0.000000000 +lon_0=0.000000000 +lat_ts=-49.500000000 +x_0=0.000 +y_0=0.000 +units=m +no_defs",
			'IGNF:GEOPORTALMYT': "+title=Geoportail - Mayotte +proj=eqc +nadgrids=null +towgs84=0.0000,0.0000,0.0000 +a=6378137.0000 +rf=298.2572221010000 +lat_0=0.000000000 +lon_0=0.000000000 +lat_ts=-12.000000000 +x_0=0.000 +y_0=0.000 +units=m +no_defs",
			'IGNF:GEOPORTALNCL': "+title=Geoportail - Nouvelle-Caledonie +proj=eqc +nadgrids=null +towgs84=0.0000,0.0000,0.0000 +a=6378137.0000 +rf=298.2572221010000 +lat_0=0.000000000 +lon_0=0.000000000 +lat_ts=-22.000000000 +x_0=0.000 +y_0=0.000 +units=m +no_defs",
			'IGNF:GEOPORTALPYF': "+title=Geoportail - Polynesie francaise +proj=eqc +nadgrids=null +towgs84=0.0000,0.0000,0.0000 +a=6378137.0000 +rf=298.2572221010000 +lat_0=0.000000000 +lon_0=0.000000000 +lat_ts=-15.000000000 +x_0=0.000 +y_0=0.000 +units=m +no_defs",
			'IGNF:GEOPORTALREU': "+title=Geoportail - Reunion et dependances +proj=eqc +nadgrids=null +towgs84=0.0000,0.0000,0.0000 +a=6378137.0000 +rf=298.2572221010000 +lat_0=0.000000000 +lon_0=0.000000000 +lat_ts=-21.000000000 +x_0=0.000 +y_0=0.000 +units=m +no_defs",
			'IGNF:GEOPORTALSPA': "+title=Geoportail - Saint-Paul et Amsterdam +proj=eqc +nadgrids=null +towgs84=0.0000,0.0000,0.0000 +a=6378137.0000 +rf=298.2572221010000 +lat_0=0.000000000 +lon_0=0.000000000 +lat_ts=-38.000000000 +x_0=0.000 +y_0=0.000 +units=m +no_defs",
			'IGNF:GEOPORTALSPM': "+title=Geoportail - Saint-Pierre et Miquelon +proj=eqc +nadgrids=null +towgs84=0.0000,0.0000,0.0000 +a=6378137.0000 +rf=298.2572221010000 +lat_0=0.000000000 +lon_0=0.000000000 +lat_ts=47.000000000 +x_0=0.000 +y_0=0.000 +units=m +no_defs",
			'IGNF:GEOPORTALWLF': "+title=Geoportail - Wallis et Futuna +proj=eqc +nadgrids=null +towgs84=0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,0.000000 +a=6378137.0000 +rf=298.2572221010000 +lat_0=0.000000000 +lon_0=0.000000000 +lat_ts=-14.000000000 +x_0=0.000 +y_0=0.000 +units=m +no_defs",
			
			//DGR 2010-02-10 :
			'IGNF:RGF93G': "+title=Reseau geodesique francais 1993 +proj=longlat +towgs84=0.0000,0.0000,0.0000 +a=6378137.0000 +rf=298.2572221010000 +units=m +no_defs",
			'IGNF:LAMB93': "+title=Lambert 93 +proj=lcc +towgs84=0.0000,0.0000,0.0000 +a=6378137.0000 +rf=298.2572221010000 +lat_0=46.500000000 +lon_0=3.000000000 +lat_1=44.000000000 +lat_2=49.000000000 +x_0=700000.000 +y_0=6600000.000 +units=m +no_defs",
			
			'CRS:84': "+title=WGS 84 longitude-latitude +proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +units=degrees"
		};
		
		static public const urns:Object={
			'WGS84': "urn:ogc:def:crs:EPSG::4326",
			'IGNF:WGS84G': "urn:ogc:def:crs:OGC:1.3:CRS84",
			
			'IGNF:GEOPORTALANF': "urn:ogc:def:crs:EPSG::301642009814",
			'IGNF:GEOPORTALASP': "urn:ogc:def:crs:EPSG::301642009813",
			'IGNF:GEOPORTALCRZ': "urn:ogc:def:crs:EPSG::310642011",
			'IGNF:GEOPORTALFXX': "urn:ogc:def:crs:EPSG::310024001",
			'IGNF:GEOPORTALGUF': "urn:ogc:def:crs:EPSG::310486003",
			'IGNF:GEOPORTALKER': "urn:ogc:def:crs:EPSG::310642010",
			'IGNF:GEOPORTALMYT': "urn:ogc:def:crs:EPSG::310702005",
			'IGNF:GEOPORTALNCL': "urn:ogc:def:crs:EPSG::310504007",
			'IGNF:GEOPORTALPYF': "urn:ogc:def:crs:EPSG::310032009",
			'IGNF:GEOPORTALREU': "urn:ogc:def:crs:EPSG::310700004",
			//'IGNF:GEOPORTALSPA': "",
			'IGNF:GEOPORTALSPM': "urn:ogc:def:crs:EPSG::310706006",
			'IGNF:GEOPORTALWLF': "urn:ogc:def:crs:EPSG::310642008",

			'IGNF:RGF93G': "urn:ogc:def:crs:EPSG::213024000",
			'IGNF:LAMB93': "urn:ogc:def:crs:EPSG:6.11.2:2154",
			
			'CRS:84': "urn:ogc:def:crs:OGC:1.3:CRS84"
		};
		
		//North/East ordering (lon/lat)
		static public const AXIS_ORDER_EN:String="EN";
		//East/North ordering (lat/lon)
		static public const AXIS_ORDER_NE:String="NE";
		
		static public const projAxisOrder:Object={
			'EPSG:900913': ProjProjection.AXIS_ORDER_EN,
			'WGS84': ProjProjection.AXIS_ORDER_NE,
			'IGNF:WGS84G': ProjProjection.AXIS_ORDER_NE,
			'EPSG:4326': ProjProjection.AXIS_ORDER_NE,
			'EPSG:4269': ProjProjection.AXIS_ORDER_NE,
			'EPSG:27700': ProjProjection.AXIS_ORDER_EN,
			
			'EPSG:4171'	: ProjProjection.AXIS_ORDER_NE, 
			
			'EPSG:32637': ProjProjection.AXIS_ORDER_EN,
			'EPSG:32638': ProjProjection.AXIS_ORDER_EN,
			'EPSG:32639': ProjProjection.AXIS_ORDER_EN,
			'EPSG:32640': ProjProjection.AXIS_ORDER_EN,
			'EPSG:32641': ProjProjection.AXIS_ORDER_EN,			 
			
			'EPSG:28991': ProjProjection.AXIS_ORDER_EN,
			'EPSG:28992': ProjProjection.AXIS_ORDER_EN,					 
			
			'EPSG:31300': ProjProjection.AXIS_ORDER_EN,
			'EPSG:31370': ProjProjection.AXIS_ORDER_EN,			
			
			'EPSG:2176': ProjProjection.AXIS_ORDER_EN,
			'EPSG:2177': ProjProjection.AXIS_ORDER_EN,
			'EPSG:2178': ProjProjection.AXIS_ORDER_EN,
			'EPSG:2179': ProjProjection.AXIS_ORDER_EN,
			'EPSG:2180': ProjProjection.AXIS_ORDER_EN,
			
			'EPSG:2154'	: ProjProjection.AXIS_ORDER_EN, 	
			
			'EPSG:3346' : ProjProjection.AXIS_ORDER_EN,
			'EPSG:3857' : ProjProjection.AXIS_ORDER_EN,
			'EPSG:2065' : ProjProjection.AXIS_ORDER_EN,
			
			// DGR 2009-08-27 : IGNF, Geoportal cache projections :
			'IGNF:GEOPORTALANF': ProjProjection.AXIS_ORDER_EN,
			'IGNF:GEOPORTALASP': ProjProjection.AXIS_ORDER_EN,
			'IGNF:GEOPORTALCRZ': ProjProjection.AXIS_ORDER_EN,
			'IGNF:GEOPORTALFXX': ProjProjection.AXIS_ORDER_EN,
			'IGNF:GEOPORTALGUF': ProjProjection.AXIS_ORDER_EN,
			'IGNF:GEOPORTALKER': ProjProjection.AXIS_ORDER_EN,
			'IGNF:GEOPORTALMYT': ProjProjection.AXIS_ORDER_EN,
			'IGNF:GEOPORTALNCL': ProjProjection.AXIS_ORDER_EN,
			'IGNF:GEOPORTALPYF': ProjProjection.AXIS_ORDER_EN,
			'IGNF:GEOPORTALREU': ProjProjection.AXIS_ORDER_EN,
			'IGNF:GEOPORTALSPA': ProjProjection.AXIS_ORDER_EN,
			'IGNF:GEOPORTALSPM': ProjProjection.AXIS_ORDER_EN,
			'IGNF:GEOPORTALWLF': ProjProjection.AXIS_ORDER_EN,
			
			//DGR 2010-02-10 :
			'IGNF:RGF93G': ProjProjection.AXIS_ORDER_EN,
			'IGNF:LAMB93': ProjProjection.AXIS_ORDER_EN,
			
			'CRS:84': ProjProjection.AXIS_ORDER_EN
		};
		
		static private const projProjections:Object={}
		
		protected var proj:IProjection;
		
		private var _lonlat:Boolean = true;

		/**
		 * Return the ProjProjection for a specific srsCode
		 * @param srsCode:String the srsCode
		 * @return ProjProjection the ProjProjection
		 */
		public static function getProjProjection(proj:*):ProjProjection {
			if(proj==null)
				return null;
			
			if(proj is ProjProjection)
				return proj as ProjProjection;
			
			var srsCode:String;
			if(proj is String)
			{
				var splitArray:Array;
				if ((proj as String).match("http://www.opengis.net/gml/srs/epsg.xml") != null)
				{
					splitArray = (proj as String).split("#");
					if (splitArray.length == 2)
					{
						proj = "EPSG:"+splitArray[1];
					}else
					{
						proj = "EPSG:4326";
					}
				}
				else if ((proj as String).match("urn:x-ogc:def:crs:") != null)
				{
					splitArray = (proj as String).split(":");
					if (splitArray.length == 7)
					{
						proj = splitArray[splitArray.length-3]+":"+splitArray[splitArray.length-1];
					}else if (splitArray.length >= 2)
					{
						proj = splitArray[splitArray.length-2]+":"+splitArray[splitArray.length-1];
					}
				}
				srsCode = (proj as String).toUpperCase();
				while(srsCode.search(" ") != -1)
				{
					srsCode = (srsCode as String).replace(" ", "");
				}
			}
			
			if (!ProjProjection.defs[srsCode]) {
				return null;
			}
			if (ProjProjection.projProjections[srsCode]) {
				return ProjProjection.projProjections[srsCode];
			}
			ProjProjection.projProjections[srsCode] = new ProjProjection(srsCode);
			return ProjProjection.projProjections[srsCode];
		}
		
		/**
		 * mark two projection as equivalent
		 * 
		 * @param first projection code
		 * @param second projection code
		 */
		public static function addEquivalentDefs(srsCode1:String, srsCode2:String):void {
			var i:uint = ProjProjection.equivalentDefs.length;
			var arr:Array = null;
			var s:String;
			for(;i>0;--i) {
				
				s = ProjProjection.equivalentDefs[i-1];
				arr = s.split(",");
				
				if(arr.indexOf(srsCode1)!=-1) {
					
					if(arr.indexOf(srsCode2)!=-1) {
						return;
					}
					
					ProjProjection.equivalentDefs[i-1]=s+","+srsCode2;
					return;
					
				} else if(arr.indexOf(srsCode2)!=-1) {
					
					ProjProjection.equivalentDefs[i-1]=s+","+srsCode1;
					return;
					
				}
			}
			ProjProjection.equivalentDefs.push(srsCode1+","+srsCode2);
		}
		
		/**
		 * Gives known equivalent projections to a given one
		 * 
		 * @param the projection
		 * @return vector of equivalent srscodes
		 */
		public static function getEquivalentProjection(srs:ProjProjection):Vector.<String> {
			var compat:Vector.<String> = new <String>[];
			var i:uint = ProjProjection.equivalentDefs.length;
			var j:uint;
			var arr:Array = null;
			for(;i>0;--i) {
				arr = ProjProjection.equivalentDefs[i-1].split(",");
				if(arr.indexOf(srs.srsCode)!=-1) {
					j = arr.length;
					for(;j>0;--j)
						if(arr[j-1] != "")
							compat.push(arr[j-1]);
				}
			}
			return compat;
		}
		
		/**
		 * mark two projection as strechable
		 * 
		 * @param first projection code
		 * @param second projection code
		 */
		public static function addStretchableProjection(srsCode1:String, srsCode2:String):void {
			var i:uint = ProjProjection.stretchableDefs.length;
			var arr:Array = null;
			var s:String;
			for(;i>0;--i) {
				
				s = ProjProjection.stretchableDefs[i-1];
				arr = s.split(",");
				
				if(arr.indexOf(srsCode1)!=-1) {
					
					if(arr.indexOf(srsCode2)!=-1) {
						return;
					}
					
					ProjProjection.stretchableDefs[i-1]=s+","+srsCode2;
					return;
					
				} else if(arr.indexOf(srsCode2)!=-1) {
					
					ProjProjection.stretchableDefs[i-1]=s+","+srsCode1;
					return;
					
				}
			}
			ProjProjection.stretchableDefs.push(srsCode1+","+srsCode2);
		}
		
		/**
		 * Gives known strechable projections to a given one
		 * 
		 * @param the projection
		 * @return vector of strechable srscodes
		 */
		public static function getStretchableProjection(srs:ProjProjection):Vector.<String> {
			var compat:Vector.<String> = new <String>[];
			var i:uint = ProjProjection.stretchableDefs.length;
			var j:uint;
			var arr:Array = null;
			for(;i>0;--i) {
				arr = ProjProjection.stretchableDefs[i-1].split(",");
				if(arr.indexOf(srs.srsCode)!=-1) {
					j = arr.length;
					for(;j>0;--j)
						if(arr[j-1] != "")
							compat.push(arr[j-1]);
				}
			}
			return compat;
		}
		
		/**
		 * indicates if two projections are strechable
		 * 
		 * @param first projection
		 * @param second projection
		 * 
		 * @return true if strachable, else false
		 */
		public static function isStretchable(srs1:ProjProjection,srs2:ProjProjection): Boolean {
			if(!srs1||!srs2)
				return false;
			if(srs1==srs2
				|| ProjProjection.stretchableDefs.indexOf(srs1.srsCode+","+srs2.srsCode)!=-1
				|| ProjProjection.stretchableDefs.indexOf(srs2.srsCode+","+srs1.srsCode)!=-1)
				return true;
			return (ProjProjection.getStretchableProjection(srs1).indexOf(srs2.srsCode)!=-1);
		}
		
		/**
		 * indicates if two projections are equivalent
		 * 
		 * @param first projection
		 * @param second projection
		 * 
		 * @return true if equivalent, else false
		 */
		public static function isEquivalentProjection(srs1:ProjProjection,srs2:ProjProjection): Boolean {
			if(!srs1||!srs2)
				return false;
			if(srs1==srs2
				|| ProjProjection.equivalentDefs.indexOf(srs1.srsCode+","+srs2.srsCode)!=-1
				|| ProjProjection.equivalentDefs.indexOf(srs2.srsCode+","+srs1.srsCode)!=-1)
				return true;
			return (ProjProjection.getEquivalentProjection(srs1).indexOf(srs2.srsCode)!=-1);
		}
		
		/**
		 * indicates the projection srscode
		 */ 
		public function get srsCode():String {
			return projParams.srsCode;
		}
		
		/**
		 * indicates the projection srsProjNumber
		 */ 
		public function get srsProjNumber():String {
			return projParams.srsProjNumber;
		}
		
		/**
		 * indicates the projection name
		 */ 
		public function get projName():String {
			return projParams.projName;
		}
		
		/**
		 * indicates the projection datum
		 */ 
		public function get datum():Datum {
			return projParams.datum;
		}
		
		/**
		 * indicates the projection datum code
		 */ 
		public function get datumCode():String {
			return projParams.datumCode;
		}
		
		public function get from_greenwich():Number {
			return projParams.from_greenwich;
		}
		
		public function get to_meter():Number {
			return projParams.to_meter;
		}
		
		public function get a():Number {
			return projParams.a;
		}
		
		public function get b():Number {
			return projParams.b;
		}
		
		public function get ep2():Number {
			return projParams.epTwo;
		}
		
		public function get es():Number {
			return projParams.es;
		}
		
		public function get datum_params():Array {
			return projParams.datum_params;
		}
		
		/**
		 * indicates if the axis order is lonlat or not
		 */ 
		public function get lonlat():Boolean
		{
			return _lonlat;
		}
		
		public function get urnCode():String {
			if(!ProjProjection.urns[this.srsCode])
				return "urn:ogc:def:crs:"+this.srsCode.toUpperCase().replace(":","::");
			else
				return ProjProjection.urns[this.srsCode];
		}
		
		/**
		 * Constructor
		 * do not use it directly, use static method getProjProjection(proj:*) instead
		 */
		public function ProjProjection(srsCode:String) {
			this.projParams.srsCode=srsCode.toUpperCase();
			this.init();
			this.loadProjDefinition();
			this.setAxisOrder();
		}
		
		private function init():void {
			if (this.projParams.srsCode.indexOf("EPSG") == 0) {
				this.projParams.srsAuth='epsg';
				this.projParams.srsProjNumber=this.projParams.srsCode.substring(5);
				// DGR 2007-11-20 : authority IGNF
			} else if (this.projParams.srsCode.indexOf("IGNF") == 0) {
				this.projParams.srsAuth='IGNF';
				this.projParams.srsProjNumber=this.projParams.srsCode.substring(5);
				// DGR 2008-06-19 : pseudo-authority CRS for WMS
			} else if (this.projParams.srsCode.indexOf("CRS") == 0) {
				this.projParams.srsAuth='CRS';
				this.projParams.srsProjNumber=this.projParams.srsCode.substring(4);
			} else {
				this.projParams.srsAuth='';
				this.projParams.srsProjNumber=this.projParams.srsCode;
			}
		}
		
		private function setAxisOrder():void {
			if(ProjProjection.projAxisOrder[this.srsCode]
				&& ProjProjection.projAxisOrder[this.srsCode] == ProjProjection.AXIS_ORDER_NE)
				this._lonlat = false;
		}
		
		private function loadProjDefinition():void {
			if (this.srsCode != null && ProjProjection.defs[this.srsCode] != null) {
				this.parseDef(ProjProjection.defs[this.projParams.srsCode]);
				this.initTransforms();
			}
		}
		
		protected function initTransforms():void {
			switch (this.projParams.projName) {
				case "aea":
					this.proj=new ProjAea(this.projParams);
					break;
				case "aeqd":
					this.proj=new ProjAeqd(this.projParams);
					break;
				case "eqc":
					this.proj=new ProjEqc(this.projParams);
					break;
				case "eqdc":
					this.proj=new ProjEqdc(this.projParams);
					break;
				case "equi":
					this.proj=new ProjEqui(this.projParams);
					break;
				case "gauss":
					this.proj=new ProjGauss(this.projParams);
					break;
				case "gstmerc":
					this.proj=new ProjGstmerc(this.projParams);
					break;
				case "laea":
					this.proj=new ProjLaea(this.projParams);
					break;
				case "lcc":
					this.proj=new ProjLcc(this.projParams);
					break;
				case "longlat":
					this.proj=new ProjLonglat(this.projParams);
					break;
				case "merc":
					this.proj=new ProjMerc(this.projParams);
					break;
				case "mill":
					this.proj=new ProjMill(this.projParams);
					break;
				case "moll":
					this.proj=new ProjMoll(this.projParams);
					break;
				case "nzmg":
					this.proj=new ProjNzmg(this.projParams);
					break;
				case "omerc":
					this.proj=new ProjOmerc(this.projParams);
					break;
				case "ortho":
					this.proj=new ProjOrtho(this.projParams);
					break;
				case "sinu":
					this.proj=new ProjSinu(this.projParams);
					break;
				case "stere":
					this.proj=new ProjStere(this.projParams);
					break;
				case "sterea":
					this.proj=new ProjSterea(this.projParams);
					break;
				case "tmerc":
					this.proj=new ProjTmerc(this.projParams);
					break;
				case "utm":
					this.proj=new ProjUtm(this.projParams);
					break;
				case "vandg":
					this.proj=new ProjVandg(this.projParams);
					break;
				default:
					this.proj=null;
			}
			if (this.proj != null) {
				this.proj.init();
				this.readyToUse=true;
			}
		}
		
		private function parseDef(definition:String):void {
			var paramName:String='';
			var paramVal:String='';
			var paramArray:Array=definition.split("+");
			for (var prop:int=0; prop < paramArray.length; prop++) {
				var property:Array=paramArray[prop].split("=");
				paramName=property[0].toLowerCase();
				paramVal=property[1];
				
				switch (paramName.replace(/\s/gi, "")) { // trim out spaces
					case "":
						break; // throw away nameless parameter
					case "title":
						this.projParams.title=paramVal;
						break;
					case "proj":
						this.projParams.projName=paramVal.replace(/\s/gi, "");
						break;
					case "units":
						this.projParams.units=paramVal.replace(/\s/gi, "");
						break;
					case "datum":
						this.projParams.datumCode=paramVal.replace(/\s/gi, "");
						break;
					case "nadgrids":
						this.projParams.nagrids=paramVal.replace(/\s/gi, "");
						break;
					case "ellps":
						this.projParams.ellps=paramVal.replace(/\s/gi, "");
						break;
					case "a":
						this.projParams.a=parseFloat(paramVal);
						break; // semi-major radius
					case "b":
						this.projParams.b=parseFloat(paramVal);
						break; // semi-minor radius
					// DGR 2007-11-20
					case "rf":
						this.projParams.rf=parseFloat(paramVal);
						break; // inverse flattening rf= a/(a-b)
					case "lat_0":
						this.projParams.latZero=parseFloat(paramVal) * ProjConstants.D2R;
						break; // phi0, central latitude
					case "lat_1":
						this.projParams.latOne=parseFloat(paramVal) * ProjConstants.D2R;
						break; //standard parallel 1
					case "lat_2":
						this.projParams.latTwo=parseFloat(paramVal) * ProjConstants.D2R;
						break; //standard parallel 2
					case "lat_ts":
						this.projParams.lat_ts=parseFloat(paramVal) * ProjConstants.D2R;
						break; // used in merc and eqc
					case "lon_0":
						this.projParams.longZero=parseFloat(paramVal) * ProjConstants.D2R;
						break; // lam0, central longitude
					case "alpha":
						this.projParams.alpha=parseFloat(paramVal) * ProjConstants.D2R;
						break; //for somerc projection
					case "lonc":
						this.projParams.longc=parseFloat(paramVal) * ProjConstants.D2R;
						break; //for somerc projection
					case "x_0":
						this.projParams.xZero=parseFloat(paramVal);
						break; // false easting
					case "y_0":
						this.projParams.yZero=parseFloat(paramVal);
						break; // false northing
					case "k_0":
						this.projParams.kZero=parseFloat(paramVal);
						break; // projection scale factor
					case "k":
						this.projParams.kZero=parseFloat(paramVal);
						break; // both forms returned
					case "r_a":
						this.projParams.R_A=true;
						break; //Spheroid radius 
					case "zone":
						this.projParams.zone=parseInt(paramVal);
						break; // UTM Zone
					case "south":
						this.projParams.utmSouth=true;
						break; // UTM north/south
					case "towgs84":
						this.projParams.datum_params=paramVal.split(",");
						break;
					case "to_meter":
						this.projParams.to_meter=parseFloat(paramVal);
						break; // cartesian scaling
					case "from_greenwich":
						this.projParams.from_greenwich=parseFloat(paramVal) * ProjConstants.D2R;
						break;
					// DGR 2008-07-09 : if pm is not a well-known prime meridian take
					// the value instead of 0.0, then convert to radians
					case "pm":
						paramVal=paramVal.replace(/\s/gi, "");
						this.projParams.from_greenwich=ProjConstants.PrimeMeridian[paramVal] ? ProjConstants.PrimeMeridian[paramVal] : parseFloat(paramVal);
						this.projParams.from_greenwich*=ProjConstants.D2R;
						break;
					case "no_defs":
						break;
					default:
						trace("Unrecognized parameter: " + paramName);
						break;
				} // switch()
			} // for paramArray
			this.deriveConstants();
		}
		
		private function deriveConstants():void {
			if (this.projParams.nagrids == '@null')
				this.projParams.datumCode='none';
			if (this.projParams.datumCode && this.projParams.datumCode != 'none') {
				var datumDef:Object=ProjConstants.Datum[this.projParams.datumCode];
				if (datumDef) {
					this.projParams.datum_params=datumDef.towgs84.split(',');
					this.projParams.ellps=datumDef.ellipse;
					this.projParams.datumName=datumDef.datumName ? datumDef.datumName : this.projParams.datumCode;
				}
			}
			
			if (!this.projParams.a) { // do we have an ellipsoid?
				var ellipse:Object=ProjConstants.Ellipsoid[this.projParams.ellps] ? ProjConstants.Ellipsoid[this.projParams.ellps] : ProjConstants.Ellipsoid['WGS84'];
				extend(this.projParams, ellipse);
			}
			if (this.projParams.rf && !this.projParams.b)
				this.projParams.b=(1.0 - 1.0 / this.projParams.rf) * this.projParams.a;
			if (Math.abs(this.projParams.a - this.projParams.b) < ProjConstants.EPSLN) {
				this.projParams.sphere=true;
				this.projParams.b=this.projParams.a;
			}
			this.projParams.aTwo=this.projParams.a * this.projParams.a; // used in geocentric
			this.projParams.bTwo=this.projParams.b * this.projParams.b; // used in geocentric
			this.projParams.es=(this.projParams.aTwo - this.projParams.bTwo) / this.projParams.aTwo; // e ^ 2
			this.projParams.e=Math.sqrt(this.projParams.es); // eccentricity
			if (this.projParams.R_A) {
				this.projParams.a*=1. - this.projParams.es * (ProjConstants.SIXTH + this.projParams.es * (ProjConstants.RA4 + this.projParams.es * ProjConstants.RA6));
				this.projParams.aTwo=this.projParams.a * this.projParams.a;
				this.projParams.bTwo=this.projParams.b * this.projParams.b;
				this.projParams.es=0.;
			}
			this.projParams.epTwo=(this.projParams.aTwo - this.projParams.bTwo) / this.projParams.bTwo; // used in geocentric
			if (!this.projParams.kZero)
				this.projParams.kZero=1.0; //default value
			
			this.projParams.datum=new Datum(this);
		}
		
		private function extend(destination:Object, source:Object):void {
			destination=destination || {};
			if (source) {
				for (var property:String in source) {
					var value:Object=source[property];
					if (value != null) {
						destination[property]=value;
					}
				}
			}
		}
		
		public function forward(p:ProjPoint):ProjPoint {
			if (this.proj != null) {
				return this.proj.forward(p);
			}
			return p;
		}
		
		public function inverse(p:ProjPoint):ProjPoint {
			if (this.proj != null) {
				return this.proj.inverse(p);
			}
			return p;
		}
		
	}
}

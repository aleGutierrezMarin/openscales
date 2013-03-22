package org.openscales.proj4as.proj {

	import org.openscales.proj4as.Datum;

	public class ProjParams {

		public var title:Object;

		/**
		 * Property: projName
		 * The projection class for this projection, e.g. lcc (lambert conformal conic,
		 * or merc for mercator.  These are exactly equicvalent to their Proj4
		 * counterparts.
		 */
		public var projName:String;
		
		/**
		 * Property: units
		 * The units of the projection.  Values include 'm' and 'degrees'
		   /**
		 * Property: units
		 * The units of the projection.  Values include 'm' and 'degrees'
		 */
		
		public var units:String;
		
		/**
		 * Property: datum
		 * The datum specified for the projection
		 */
		public var datum:Datum;
		
		public var datumCode:String;
		public var datumName:String;
		public var nadgrids:String;
		public var grids:Object;
		public var ellps:String;
		public var a:Number;
		public var b:Number;
		public var aTwo:Number;
		public var bTwo:Number;
		public var e:Number;
		public var es:Number;
		public var epTwo:Number;
		public var rf:Number;
		public var longZero:Number;
		public var longOne:Number;
		public var longTwo:Number;
		public var latZero:Number;
		public var latOne:Number;
		public var latTwo:Number;
		public var lat_ts:Number;
		public var alpha:Number;
		public var longc:Number;
		public var xZero:Number=0.0;
		public var yZero:Number=0.0;
		public var kZero:Number=1.0;
		public var k:Number;
		public var R_A:Boolean=false;
		public var zone:int;
		public var utmSouth:Boolean=false;
		public var to_meter:Number;
		public var from_greenwich:Number;
		public var datum_params:Array;
		public var sphere:Boolean=false;
		public var ellipseName:String;
		public var no_rot:Boolean=false;
		public var gamma:Number;
		public var no_off:Boolean=false;

		public var srsCode:String;
		public var srsAuth:String;
		public var srsProjNumber:String;

		public function ProjParams() {
		}

	}
}
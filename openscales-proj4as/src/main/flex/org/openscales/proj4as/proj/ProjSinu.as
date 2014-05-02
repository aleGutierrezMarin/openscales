package org.openscales.proj4as.proj {

	import org.openscales.proj4as.Datum;
	import org.openscales.proj4as.ProjConstants;
	import org.openscales.proj4as.ProjPoint;

	/**
	 <p>SINUSOIDAL projection</p>
	 
	 <p>PURPOSE:	Transforms input longitude and latitude to Easting and
	 Northing for the Sinusoidal projection.  The
	 longitude and latitude must be in radians.  The Easting
	 and Northing values will be returned in meters.</p>
	 
	 <p>This function was adapted from the Sinusoidal projection code (FORTRAN) in the
	 General Cartographic Transformation Package software which is available from
	 the U.S. Geological Survey National Mapping Division.</p>
	 
	 <p>ALGORITHM REFERENCES</p>
	 
	 <p>1.  Snyder, John P., "Map Projections--A Working Manual", U.S. Geological
	 Survey Professional Paper 1395 (Supersedes USGS Bulletin 1532), United
	 State Government Printing Office, Washington D.C., 1987.</p>
	 
	 <p>2.  "Software Documentation for GCTP General Cartographic Transformation
	 Package", U.S. Geological Survey National Mapping Division, May 1982.</p>
	 **/
	public class ProjSinu extends AbstractProjProjection {
		private var R:Number;
		private var e0:Number,e1:Number,e2:Number,e3:Number;

		public function ProjSinu(data:ProjParams) {
			super(data);
		}

		/* Initialize the Sinusoidal projection
		 ------------------------------------*/
		override public function init():void {
			/* Place parameters in static storage for common use
			 -------------------------------------------------*/
			//this.R=6370997.0; //Radius of earth
			this.e0 = ProjConstants.e0fn(this.es);
			this.e1 = ProjConstants.e1fn(this.es);
			this.e2 = ProjConstants.e2fn(this.es);
			this.e3 = ProjConstants.e3fn(this.es);
		}

		/* Sinusoidal forward equations--mapping lat,long to x,y
		 -----------------------------------------------------*/
		override public function forward(p:ProjPoint):ProjPoint {
			var x:Number, y:Number, delta_lon:Number;
			var lon:Number=p.x;
			var lat:Number=p.y;
			/* Forward equations
			 -----------------*/
			delta_lon = ProjConstants.adjust_lon(lon-this.longZero);
			
			x= this.xZero + this.a*delta_lon*ProjConstants.msfnz(this.e, Math.sin(lat), Math.cos(lat));
			y= this.yZero + this.a*ProjConstants.mlfn(e0,e1,e2,e3,lat);
			
			p.x=x;
			p.y=y;
			return p;
		}

		override public function inverse(p:ProjPoint):ProjPoint {
			var lat:Number, temp:Number, lon:Number;

			/* Inverse equations
			 -----------------*/
			p.x-=this.xZero;
			p.y-=this.yZero;
			lat=p.y/this.a;
			if (!this.sphere) {
				lat = ProjConstants.imlfn(lat,this.e0,this.e1,this.e2,this.e3);
			}
			
			if (Math.abs(lat) > ProjConstants.HALF_PI) {
				trace("sinu:Inv:DataError");
			}
			lon=this.longZero;
			
			temp=Math.abs(lat) - ProjConstants.HALF_PI;
			if (Math.abs(temp) > ProjConstants.EPSLN) {
				temp=this.longZero + p.x/this.a/ProjConstants.msfnz(this.e, Math.sin(lat), Math.cos(lat));
				lon=ProjConstants.adjust_lon(temp);
			}

			p.x=lon;
			p.y=lat;
			return p;
		}


	}
}
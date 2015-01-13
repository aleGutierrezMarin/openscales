package org.openscales.proj4as.proj {
	
	import org.openscales.proj4as.Datum;
	import org.openscales.proj4as.ProjConstants;
	import org.openscales.proj4as.ProjPoint;

	/**
	 <p>LAMBERT CONFORMAL CONIC projection</p>
	 
	 <p>PURPOSE:	Transforms input longitude and latitude to Easting and
	 Northing for the Lambert Conformal Conic projection.  The
	 longitude and latitude must be in radians.  The Easting
	 and Northing values will be returned in meters.</p>
	 
	 <p>ALGORITHM REFERENCES</p>
	 
	 <p>1.  Snyder, John P., "Map Projections--A Working Manual", U.S. Geological
	 Survey Professional Paper 1395 (Supersedes USGS Bulletin 1532), United
	 State Government Printing Office, Washington D.C., 1987.</p>
	 
	 <p>2.  Snyder, John P. and Voxland, Philip M., "An Album of Map Projections",
	 U.S. Geological Survey Professional Paper 1453 , United State Government</p>
	 **/
	public class ProjLcc extends AbstractProjProjection {
		private var f0:Number;

		public function ProjLcc(data:ProjParams) {
			super(data);
		}

		override public function init():void {
			// array of:  r_maj,r_min,lat1,lat2,c_lon,c_lat,false_east,false_north
			//double c_lat;                   /* center latitude                      */
			//double c_lon;                   /* center longitude                     */
			//double lat1;                    /* first standard parallel              */
			//double lat2;                    /* second standard parallel             */
			//double r_maj;                   /* major axis                           */
			//double r_min;                   /* minor axis                           */
			//double false_east;              /* x offset in meters                   */
			//double false_north;             /* y offset in meters                   */

			if (!this.latTwo) {
				this.latTwo=this.latOne;
			} //if lat2 is not defined
			if (!this.kZero)
				this.kZero=1.0;

			// Standard Parallels cannot be equal and on opposite sides of the equator
			if (Math.abs(this.latOne + this.latTwo) < ProjConstants.EPSLN) {
				trace("lcc:init: Equal Latitudes");
				return;
			}

			var temp:Number=this.b / this.a;
			this.e=Math.sqrt(1.0 - temp * temp);

			var sin1:Number=Math.sin(this.latOne);
			var cos1:Number=Math.cos(this.latOne);
			var ms1:Number=ProjConstants.msfnz(this.e, sin1, cos1);
			var ts1:Number=ProjConstants.tsfnz(this.e, this.latOne, sin1);

			var sin2:Number=Math.sin(this.latTwo);
			var cos2:Number=Math.cos(this.latTwo);
			var ms2:Number=ProjConstants.msfnz(this.e, sin2, cos2);
			var ts2:Number=ProjConstants.tsfnz(this.e, this.latTwo, sin2);

			var ts0:Number=ProjConstants.tsfnz(this.e, this.latZero, Math.sin(this.latZero));
			
			
			if (Math.abs(this.latOne - this.latTwo) > ProjConstants.EPSLN) {
				this.ns=Math.log(ms1 / ms2) / Math.log(ts1 / ts2);
			} else {
				this.ns=sin1;
			}
			this.f0=ms1 / (this.ns * Math.pow(ts1, this.ns));
			this.rh=this.a * this.f0 * Math.pow(ts0, this.ns);
			
			
			
			if (!this.title)
				this.title="Lambert Conformal Conic";
		}


		// Lambert Conformal conic forward equations--mapping lat,long to x,y
		// -----------------------------------------------------------------
		override public function forward(p:ProjPoint):ProjPoint {
			var lon:Number=p.x;
			var lat:Number=p.y;

            // singular cases :
            if (Math.abs(2*Math.abs(lat)-ProjConstants.PI)<=ProjConstants.EPSLN) {
                lat= ProjConstants.sign(lat)*(ProjConstants.HALF_PI - 2*ProjConstants.EPSLN);
            }

			var con:Number=Math.abs(Math.abs(lat) - ProjConstants.HALF_PI);
			var ts:Number;
			var rh1:Number;
			if (con > ProjConstants.EPSLN) {
				ts=ProjConstants.tsfnz(this.e, lat, Math.sin(lat));
				rh1=this.a * this.f0 * Math.pow(ts, this.ns);
			} else {
				con=lat * this.ns;
				if (con <= 0) {
					trace("lcc:forward: No Projection");
					return null;
				}
				rh1=0;
			}
			var theta:Number=this.ns * ProjConstants.adjust_lon(lon - this.longZero);
			p.x=this.kZero * (rh1 * Math.sin(theta)) + this.xZero;
			p.y=this.kZero * (this.rh - rh1 * Math.cos(theta)) + this.yZero;

			return p;
		}

		// Lambert Conformal Conic inverse equations--mapping x,y to lat/long
		// -----------------------------------------------------------------
		override public function inverse(p:ProjPoint):ProjPoint {
			var rh1:Number;
			var con:Number;
			var ts:Number;
			var lat:Number;
			var lon:Number;
			var x:Number=(p.x - this.xZero) / this.kZero;
			var y:Number=(this.rh - (p.y - this.yZero) / this.kZero);
			if (this.ns > 0) {
				rh1=Math.sqrt(x * x + y * y);
				con=1.0;
			} else {
				rh1=-Math.sqrt(x * x + y * y);
				con=-1.0;
			}
			var theta:Number=0.0;
			if (rh1 != 0) {
				theta=Math.atan2((con * x), (con * y));
			}
			if ((rh1 != 0) || (this.ns > 0.0)) {
				con=1.0 / this.ns;
				ts=Math.pow((rh1 / (this.a * this.f0)), con);
				lat=ProjConstants.phi2z(this.e, ts);
				if (lat == -9999)
					return null;
			} else {
				lat=-ProjConstants.HALF_PI;
			}
			lon=ProjConstants.adjust_lon(theta / this.ns + this.longZero);

			p.x=lon;
			p.y=lat;
			return p;
		}


	}
}

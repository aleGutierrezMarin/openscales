package org.openscales.proj4as.proj {

	import org.openscales.proj4as.ProjPoint;
	import org.openscales.proj4as.ProjConstants;
	import org.openscales.proj4as.Datum;

	/**
	 <p>TRANSVERSE MERCATOR projection</p>
	 
	 <p>PURPOSE:	Transforms input longitude and latitude to Easting and
	 Northing for the Transverse Mercator projection.  The
	 longitude and latitude must be in radians.  The Easting
	 and Northing values will be returned in meters.</p>
	 
	 <p>ALGORITHM REFERENCES</p>
	 
	 <p>1.  Snyder, John P., "Map Projections--A Working Manual", U.S. Geological
	 Survey Professional Paper 1395 (Supersedes USGS Bulletin 1532), United
	 State Government Printing Office, Washington D.C., 1987.</p>
	 
	 <p>2.  Snyder, John P. and Voxland, Philip M., "An Album of Map Projections",
	 U.S. Geological Survey Professional Paper 1453 , United State Government
	 Printing Office, Washington D.C., 1989.</p>
	 **/
	public class ProjTmerc extends AbstractProjProjection {
		public function ProjTmerc(data:ProjParams) {
			super(data);
		}

		override public function init():void {
			this.eZero=ProjConstants.e0fn(this.es);
			this.eOne=ProjConstants.e1fn(this.es);
			this.eTwo=ProjConstants.e2fn(this.es);
			this.eThree=ProjConstants.e3fn(this.es);
			this.mlZero=this.a * ProjConstants.mlfn(this.eZero, this.eOne, this.eTwo, this.eThree, this.latZero);
		}

		/**
		   Transverse Mercator Forward  - long/lat to x/y
		   long/lat in radians
		 */
		override public function forward(p:ProjPoint):ProjPoint {
			var lon:Number=p.x;
			var lat:Number=p.y;

			var delta_lon:Number=ProjConstants.adjust_lon(lon - this.longZero); // Delta longitude
			var con:Number; // cone constant
			var x:Number, y:Number;
			var sin_phi:Number=Math.sin(lat);
			var cos_phi:Number=Math.cos(lat);

			if (this.sphere) { /* spherical form */
				var b:Number=cos_phi * Math.sin(delta_lon);
				if ((Math.abs(Math.abs(b) - 1.0)) < .0000000001) {
					trace("tmerc:forward: Point projects into infinity");
					return null;
				} else {
					x=.5 * this.a * this.kZero * Math.log((1.0 + b) / (1.0 - b));
					con=Math.acos(cos_phi * Math.cos(delta_lon) / Math.sqrt(1.0 - b * b));
					if (lat < 0)
						con=-con;
					y=this.a * this.kZero * (con - this.latZero);
				}
			} else {
				var al:Number=cos_phi * delta_lon;
				var als:Number=Math.pow(al, 2);
				var c:Number=this.epTwo * Math.pow(cos_phi, 2);
				var tq:Number=Math.tan(lat);
				var t:Number=Math.pow(tq, 2);
				con=1.0 - this.es * Math.pow(sin_phi, 2);
				var n:Number=this.a / Math.sqrt(con);
				var ml:Number=this.a * ProjConstants.mlfn(this.eZero, this.eOne, this.eTwo, this.eThree, lat);

				x=this.kZero * n * al * (1.0 + als / 6.0 * (1.0 - t + c + als / 20.0 * (5.0 - 18.0 * t + Math.pow(t, 2) + 72.0 * c - 58.0 * this.epTwo))) + this.xZero;
				y=this.kZero * (ml - this.mlZero + n * tq * (als * (0.5 + als / 24.0 * (5.0 - t + 9.0 * c + 4.0 * Math.pow(c, 2) + als / 30.0 * (61.0 - 58.0 * t + Math.pow(t, 2) + 600.0 * c - 330.0 * this.epTwo))))) + this.yZero;

			}
			p.x=x;
			p.y=y;
			return p;
		} // tmercFwd()

		/**
		   Transverse Mercator Inverse  -  x/y to long/lat
		 */
		override public function inverse(p:ProjPoint):ProjPoint {
			var con:Number, phi:Number; /* temporary angles       */
			var delta_phi:Number; /* difference between longitudes    */
			var i:Number;
			var max_iter:Number=6; /* maximun number of iterations */
			var lat:Number, lon:Number;

			if (this.sphere) { /* spherical form */
				var f:Number=Math.exp(p.x / (this.a * this.kZero));
				var g:Number=.5 * (f - 1 / f);
				var temp:Number=this.latZero + p.y / (this.a * this.kZero);
				var h:Number=Math.cos(temp);
				con=Math.sqrt((1.0 - h * h) / (1.0 + g * g));
				lat=ProjConstants.asinz(con);
				if (temp < 0)
					lat=-lat;
				if ((g == 0) && (h == 0)) {
					lon=this.longZero;
				} else {
					lon=ProjConstants.adjust_lon(Math.atan2(g, h) + this.longZero);
				}
			} else { // ellipsoidal form
				var x:Number=p.x - this.xZero;
				var y:Number=p.y - this.yZero;

				con=(this.mlZero + y / this.kZero) / this.a;
				phi=con;
				for (i=0; ; i++) {
					delta_phi=((con + this.eOne * Math.sin(2.0 * phi) - this.eTwo * Math.sin(4.0 * phi) + this.eThree * Math.sin(6.0 * phi)) / this.eZero) - phi;
					phi+=delta_phi;
					if (Math.abs(delta_phi) <= ProjConstants.EPSLN)
						break;
					if (i >= max_iter) {
						trace("tmerc:inverse: Latitude failed to converge");
						return null;
					}
				} // for()
				if (Math.abs(phi) < ProjConstants.HALF_PI) {
					// sincos(phi, &sin_phi, &cos_phi);
					var sin_phi:Number=Math.sin(phi);
					var cos_phi:Number=Math.cos(phi);
					var tan_phi:Number=Math.tan(phi);
					var c:Number=this.epTwo * Math.pow(cos_phi, 2);
					var cs:Number=Math.pow(c, 2);
					var t:Number=Math.pow(tan_phi, 2);
					var ts:Number=Math.pow(t, 2);
					con=1.0 - this.es * Math.pow(sin_phi, 2);
					var n:Number=this.a / Math.sqrt(con);
					var r:Number=n * (1.0 - this.es) / con;
					var d:Number=x / (n * this.kZero);
					var ds:Number=Math.pow(d, 2);
					lat=phi - (n * tan_phi * ds / r) * (0.5 - ds / 24.0 * (5.0 + 3.0 * t + 10.0 * c - 4.0 * cs - 9.0 * this.epTwo - ds / 30.0 * (61.0 + 90.0 * t + 298.0 * c + 45.0 * ts - 252.0 * this.epTwo - 3.0 * cs)));
					lon=ProjConstants.adjust_lon(this.longZero + (d * (1.0 - ds / 6.0 * (1.0 + 2.0 * t + c - ds / 20.0 * (5.0 - 2.0 * c + 28.0 * t - 3.0 * cs + 8.0 * this.epTwo + 24.0 * ts))) / cos_phi));
				} else {
					lat=ProjConstants.HALF_PI * ProjConstants.sign(y);
					lon=this.longZero;
				}
			}
			p.x=lon;
			p.y=lat;
			return p;
		} // tmercInv()


	}
}
package org.openscales.proj4as.proj {

	import org.openscales.proj4as.Datum;
	import org.openscales.proj4as.ProjConstants;
	import org.openscales.proj4as.ProjPoint;

	/**
	 <p>VAN DER GRINTEN projection</p>
	 
	 <p>PURPOSE:	Transforms input Easting and Northing to longitude and
	 latitude for the Van der Grinten projection.  The
	 Easting and Northing must be in meters.  The longitude
	 and latitude values will be returned in radians.</p>
	  
	 <p>This function was adapted from the Van Der Grinten projection code
	 (FORTRAN) in the General Cartographic Transformation Package software
	 which is available from the U.S. Geological Survey National Mapping Division.</p>
	 
	 <p>ALGORITHM REFERENCES</p>
	 
	 <p>1.  "New Equal-Area Map Projections for Noncircular Regions", John P. Snyder,
	 The American Cartographer, Vol 15, No. 4, October 1988, pp. 341-355.</p>
	 
	 <p>2.  Snyder, John P., "Map Projections--A Working Manual", U.S. Geological
	 Survey Professional Paper 1395 (Supersedes USGS Bulletin 1532), United
	 State Government Printing Office, Washington D.C., 1987.</p>
	 
	 <p>3.  "Software Documentation for GCTP General Cartographic Transformation
	 Package", U.S. Geological Survey National Mapping Division, May 1982.</p>
	 **/
	public class ProjVandg extends AbstractProjProjection {

		protected var R:Number;

		public function ProjVandg(data:ProjParams) {
			super(data);
		}

		override public function init():void {
			//this.R=6370997.0; //Radius of earth
			this.R=this.a;
		}

		override public function forward(p:ProjPoint):ProjPoint {
			var lon:Number=p.x;
			var lat:Number=p.y;

			/* Forward equations
			 -----------------*/
			var dlon:Number=ProjConstants.adjust_lon(lon - this.longZero);
			var x:Number, y:Number;

			if (Math.abs(lat) <= ProjConstants.EPSLN) {
				x=this.xZero + this.R * dlon;
				y=this.yZero;
			}
			var theta:Number=ProjConstants.asinz(2.0 * Math.abs(lat / ProjConstants.PI));
			if ((Math.abs(dlon) <= ProjConstants.EPSLN) || (Math.abs(Math.abs(lat) - ProjConstants.HALF_PI) <= ProjConstants.EPSLN)) {
				x=this.xZero;
				if (lat >= 0) {
					y=this.yZero + ProjConstants.PI * this.R * Math.tan(.5 * theta);
				} else {
					y=this.yZero + ProjConstants.PI * this.R * -Math.tan(.5 * theta);
				}
					//  return(OK);
			}
			var al:Number=.5 * Math.abs((ProjConstants.PI / dlon) - (dlon / ProjConstants.PI));
			var asq:Number=al * al;
			var sinth:Number=Math.sin(theta);
			var costh:Number=Math.cos(theta);

			var g:Number=costh / (sinth + costh - 1.0);
			var gsq:Number=g * g;
			var m:Number=g * (2.0 / sinth - 1.0);
			var msq:Number=m * m;
			var con:Number=ProjConstants.PI * this.R * (al * (g - msq) + Math.sqrt(asq * (g - msq) * (g - msq) - (msq + asq) * (gsq - msq))) / (msq + asq);
			if (dlon < 0) {
				con=-con;
			}
			x=this.xZero + con;
			//con=Math.abs(con / (ProjConstants.PI * this.R));
			var q:Number = asq+g;
			con=ProjConstants.PI*this.R*(m*q-al*Math.sqrt((msq+asq)*(asq+1.0)-q*q))/(msq+asq);
			if (lat >= 0) {
				//y=this.yZero + ProjConstants.PI * this.R * Math.sqrt(1.0 - con * con - 2.0 * al * con);
				y=this.yZero + con;
			} else {
				//y=this.yZero - ProjConstants.PI * this.R * Math.sqrt(1.0 - con * con - 2.0 * al * con);
				y=this.yZero - con;
			}
			p.x=x;
			p.y=y;
			return p;
		}

		/* Van Der Grinten inverse equations--mapping x,y to lat/long
		 ---------------------------------------------------------*/
		override public function inverse(p:ProjPoint):ProjPoint {
			var lat:Number, lon:Number;
			var xx:Number, yy:Number, xys:Number, c1:Number, c2:Number, c3:Number;
			var aOne:Number;
			var mOne:Number;
			var con:Number;
			var thOne:Number;
			var d:Number;

			/* inverse equations
			 -----------------*/
			p.x-=this.xZero;
			p.y-=this.yZero;
			con=ProjConstants.PI * this.R;
			xx=p.x / con;
			yy=p.y / con;
			xys=xx * xx + yy * yy;
			c1=-Math.abs(yy) * (1.0 + xys);
			c2=c1 - 2.0 * yy * yy + xx * xx;
			c3=-2.0 * c1 + 1.0 + 2.0 * yy * yy + xys * xys;
			d=yy * yy / c3 + (2.0 * c2 * c2 * c2 / c3 / c3 / c3 - 9.0 * c1 * c2 / c3 / c3) / 27.0;
			aOne=(c1 - c2 * c2 / 3.0 / c3) / c3;
			mOne=2.0 * Math.sqrt(-aOne / 3.0);
			con=((3.0 * d) / aOne) / mOne;
			if (Math.abs(con) > 1.0) {
				if (con >= 0.0) {
					con=1.0;
				} else {
					con=-1.0;
				}
			}
			thOne=Math.acos(con) / 3.0;
			if (p.y >= 0) {
				lat=(-mOne * Math.cos(thOne + ProjConstants.PI / 3.0) - c2 / 3.0 / c3) * ProjConstants.PI;
			} else {
				lat=-(-mOne * Math.cos(thOne + ProjConstants.PI / 3.0) - c2 / 3.0 / c3) * ProjConstants.PI;
			}

			if (Math.abs(xx) < ProjConstants.EPSLN) {
				lon=this.longZero;
			} else {
				lon=ProjConstants.adjust_lon(this.longZero + ProjConstants.PI * (xys - 1.0 + Math.sqrt(1.0 + 2.0 * (xx * xx - yy * yy) + xys * xys)) / 2.0 / xx);
			}

			p.x=lon;
			p.y=lat;
			return p;
		}


	}
}
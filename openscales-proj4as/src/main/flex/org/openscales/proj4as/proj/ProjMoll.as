package org.openscales.proj4as.proj {

	import org.openscales.proj4as.Datum;
	import org.openscales.proj4as.ProjConstants;
	import org.openscales.proj4as.ProjPoint;

	/**
	 <p>MOLLWEIDE projection</p>
	 
	 <p>PURPOSE:	Transforms input longitude and latitude to Easting and
	 Northing for the MOllweide projection.  The
	 longitude and latitude must be in radians.  The Easting
	 and Northing values will be returned in meters.</p>
	  
	 <p>ALGORITHM REFERENCES</p>
	 
	 <p>1.  Snyder, John P. and Voxland, Philip M., "An Album of Map Projections",
	 U.S. Geological Survey Professional Paper 1453 , United State Government
	 Printing Office, Washington D.C., 1989.</p>
	 
	 <p>2.  Snyder, John P., "Map Projections--A Working Manual", U.S. Geological
	 Survey Professional Paper 1395 (Supersedes USGS Bulletin 1532), United
	 State Government Printing Office, Washington D.C., 1987.</p>
	 **/
	public class ProjMoll extends AbstractProjProjection {
		public function ProjMoll(data:ProjParams) {
			super(data);
		}

		override public function init():void {
			//no-op
		}

		/* Mollweide forward equations--mapping lat,long to x,y
		 ----------------------------------------------------*/
		override public function forward(p:ProjPoint):ProjPoint {
			/* Forward equations
			 -----------------*/
			var lon:Number=p.x;
			var lat:Number=p.y;

			var delta_lon:Number=ProjConstants.adjust_lon(lon - this.longZero);
			var theta:Number=lat;
			var con:Number=ProjConstants.PI * Math.sin(lat);

			/* Iterate using the Newton-Raphson method to find theta
			 -----------------------------------------------------*/
			for (var i:int=0; ; i++) {
				var delta_theta:Number=-(theta + Math.sin(theta) - con) / (1.0 + Math.cos(theta));
				theta+=delta_theta;
				if (Math.abs(delta_theta) < ProjConstants.EPSLN)
					break;
				if (i >= 50) {
					trace("moll:Fwd:IterationError");
						//return(241);
				}
			}
			theta/=2.0;

			/* If the latitude is 90 deg, force the x coordinate to be "0 + false easting"
			   this is done here because of precision problems with "cos(theta)"
			 --------------------------------------------------------------------------*/
			if (ProjConstants.PI / 2 - Math.abs(lat) < ProjConstants.EPSLN)
				delta_lon=0;
			var x:Number=0.900316316158 * this.a * delta_lon * Math.cos(theta) + this.xZero;
			var y:Number=1.4142135623731 * this.a * Math.sin(theta) + this.yZero;

			p.x=x;
			p.y=y;
			return p;
		}

		override public function inverse(p:ProjPoint):ProjPoint {
			var theta:Number;
			var arg:Number;

			/* Inverse equations
			 -----------------*/
			p.x-=this.xZero;
			p.y-= this.yZero;
			arg=p.y / (1.4142135623731 * this.a);

			/* Because of division by zero problems, 'arg' can not be 1.0.  Therefore
			   a number very close to one is used instead.
			 -------------------------------------------------------------------*/
			//if (Math.abs(arg) > 0.999999999999)
			//	arg=0.999999999999;
			if (Math.abs(arg-1.0)<ProjConstants.EPSLN) {
				p.x=this.longZero;
				p.y=ProjConstants.HALF_PI;
				return p;
			} else if (Math.abs(arg+1.0)<ProjConstants.EPSLN) {
				p.x=this.longZero;
				p.y=-1.0*ProjConstants.HALF_PI;
				return p;
			} else {
				theta=Math.asin(arg);
				p.x=ProjConstants.adjust_lon(this.longZero + (p.x / (0.900316316158 * this.a * Math.cos(theta))));
				arg=(2.0 * theta + Math.sin(2.0 * theta)) / ProjConstants.PI;
				p.y=Math.asin(arg);
				return p;
			}

		}

	}
}
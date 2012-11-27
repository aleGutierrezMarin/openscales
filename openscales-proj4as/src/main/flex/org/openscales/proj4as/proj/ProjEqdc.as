package org.openscales.proj4as.proj {
	
	import flash.external.ExternalInterface;
	
	import org.openscales.proj4as.Datum;
	import org.openscales.proj4as.ProjConstants;
	import org.openscales.proj4as.ProjPoint;

	/**
	 EQUIDISTANT CONIC projection
	 
	 <p>PURPOSE:	Transforms input longitude and latitude to Easting and Northing
	 for the Equidistant Conic projection.  The longitude and
	 latitude must be in radians.  The Easting and Northing values
	 will be returned in meters.</p>
	 
	 <p>ALGORITHM REFERENCES</p>
	 
	 <p>1.  Snyder, John P., "Map Projections--A Working Manual", U.S. Geological
	 Survey Professional Paper 1395 (Supersedes USGS Bulletin 1532), United
	 State Government Printing Office, Washington D.C., 1987.</p>
	 
	 <p>2.  Snyder, John P. and Voxland, Philip M., "An Album of Map Projections",
	 U.S. Geological Survey Professional Paper 1453 , United State Government
	 Printing Office, Washington D.C., 1989.</p>
	 **/
	public class ProjEqdc extends AbstractProjProjection {
		public function ProjEqdc(data:ProjParams) {
			super(data);
		}


		/* Variables common to all subroutines in this code file
		 -----------------------------------------------------*/

		/* Initialize the Equidistant Conic projection
		 ------------------------------------------*/
		override public function init():void {
			/* Place parameters in static storage for common use
			 -------------------------------------------------*/
			// Standard Parallels cannot be equal and on opposite sides of the equator
			if (Math.abs(this.latOne + this.latTwo) < ProjConstants.EPSLN) {
				trace("eqdc:init: Equal Latitudes");
				return;
			}
			if (isNaN(this.latTwo)){
				trace('eqdc:init:lat2 is nan, replace by lat1');
				this.latTwo=this.latOne;
			}
			this.temp=this.b / this.a;
			this.es=1.0 - Math.pow(this.temp, 2);
			this.e=Math.sqrt(this.es);
			this.eZero=ProjConstants.e0fn(this.es);
			this.eOne=ProjConstants.e1fn(this.es);
			this.eTwo=ProjConstants.e2fn(this.es);
			this.eThree=ProjConstants.e3fn(this.es);

			this.sinphi=Math.sin(this.latOne);
			this.cosphi=Math.cos(this.latOne);

			this.msOne=ProjConstants.msfnz(this.e, this.sinphi, this.cosphi);
			this.mlOne=ProjConstants.mlfn(this.eZero, this.eOne, this.eTwo, this.eThree, this.latOne);


			if (Math.abs(this.latOne - this.latTwo) < ProjConstants.EPSLN) {
				this.ns=this.sinphi;
				trace("eqdc:Init:EqualLatitudes");
			} else {
				this.sinphi=Math.sin(this.latTwo);
				this.cosphi=Math.cos(this.latTwo);
				this.msTwo=ProjConstants.msfnz(this.e, this.sinphi, this.cosphi);
				this.mlTwo=ProjConstants.mlfn(this.eZero, this.eOne, this.eTwo, this.eThree, this.latTwo);
				this.ns=(this.msOne - this.msTwo) / (this.mlTwo - this.mlOne);
			}

			this.g=this.mlOne + this.msOne / this.ns;
			this.mlZero=ProjConstants.mlfn(this.eZero, this.eOne, this.eTwo, this.eThree, this.latZero);
			this.rh=this.a * (this.g - this.mlZero);
			
			trace(String("ns=").concat(this.ns.toString()));
			trace(String("g=").concat(this.g.toString()));
			trace(String("ml=").concat(this.mlZero.toString()));
			trace(String("rh=").concat(this.rh.toString()));
		}


		/* Equidistant Conic forward equations--mapping lat,long to x,y
		 -----------------------------------------------------------*/
		override public function forward(p:ProjPoint):ProjPoint {
			var lon:Number=p.x;
			var lat:Number=p.y;
			var rh1:Number;

			/* Forward equations
			 -----------------*/
			
			if (this.sphere){
				rh1 = this.a *(this.g - lat);
			} else {
				var ml:Number=ProjConstants.mlfn(this.eZero, this.eOne, this.eTwo, this.eThree, lat);
				rh1=this.a * (this.g - ml);
			}
			var theta:Number=this.ns * ProjConstants.adjust_lon(lon - this.longZero);
			var x:Number=this.xZero + rh1 * Math.sin(theta);
			var y:Number=this.yZero + this.rh - rh1 * Math.cos(theta);
			p.x=x;
			p.y=y;
			return p;
		}

		/* Inverse equations
		 -----------------*/
		override public function inverse(p:ProjPoint):ProjPoint {
			p.x-=this.xZero;
			p.y=this.rh - p.y + this.yZero;
			var con:Number;
			var rh1:Number;
			var lat:Number;
			var lon:Number;
			if (this.ns >= 0) {
				rh1=Math.sqrt(p.x * p.x + p.y * p.y);
				con=1.0;
			} else {
				rh1=-Math.sqrt(p.x * p.x + p.y * p.y);
				con=-1.0;
			}
			var theta:Number=0.0;
			if (rh1 != 0.0) {
				theta=Math.atan2(con * p.x, con * p.y);
			} 
			if (this.sphere){
				lon=ProjConstants.adjust_lon(this.longZero+theta/this.ns);
				lat=ProjConstants.adjust_lat(this.g-rh1/this.a);
				p.x=lon;
				p.y=lat;
				return p;
			} else {
				this.ml=this.g - rh1 / this.a;
				lat=ProjConstants.imlfn(this.ml, this.eZero, this.eOne, this.eTwo, this.eThree);
				lon=ProjConstants.adjust_lon(this.longZero + theta / this.ns);
				p.x=lon;
				p.y=lat;
				return p;
			}
			
		}

		


	}
}
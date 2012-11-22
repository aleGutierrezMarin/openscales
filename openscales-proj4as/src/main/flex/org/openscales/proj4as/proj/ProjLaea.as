package org.openscales.proj4as.proj {
	
	import org.openscales.proj4as.Datum;
	import org.openscales.proj4as.ProjCalculus;
	import org.openscales.proj4as.ProjConstants;
	import org.openscales.proj4as.ProjPoint;

	/**
	 <p>LAMBERT AZIMUTHAL EQUAL-AREA projection</p>
	 
	 <p>PURPOSE:	Transforms input longitude and latitude to Easting and
	 Northing for the Lambert Azimuthal Equal-Area projection.  The
	 longitude and latitude must be in radians.  The Easting
	 and Northing values will be returned in meters.</p>
	 
	 <p>This function was adapted from the Lambert Azimuthal Equal Area projection
	 code (FORTRAN) in the General Cartographic Transformation Package software
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
	public class ProjLaea extends AbstractProjProjection {
		private var sin_lat_o:Number;
		private var cos_lat_o:Number;
		private var qp:Number;
		private var Rq:Number;
		private var Beta1:Number;
		private var D:Number;

		public function ProjLaea(data:ProjParams) {
			super(data);
		}

		/* Initialize the Lambert Azimuthal Equal Area projection
		 ------------------------------------------------------*/
		override public function init():void {
			this.sin_lat_o=Math.sin(this.latZero);
			this.cos_lat_o=Math.cos(this.latZero);
		}

		/* Lambert Azimuthal Equal Area forward equations--mapping lat,long to x,y
		 -----------------------------------------------------------------------*/
		override public function forward(p:ProjPoint):ProjPoint {

			/* Forward equations
			 -----------------*/
			var lon:Number=p.x;
			var lat:Number=p.y;
			var cos_lat:Number=Math.cos(lat);
			var sin_lat:Number=Math.sin(lat);
			var delta_lon:Number=ProjConstants.adjust_lon(lon - this.longZero);
			var kp:Number;
			var x:Number;
			var y:Number;
			var g:Number;
			
			if (this.sphere){
				if (Math.abs(this.latZero)<ProjConstants.EPSLN){
					//Equtorial aspect
					g=cos_lat*Math.cos(delta_lon);
					if (g == -1.0) {
						trace("laea:fwd:Point projects to a circle of radius ");
						return null;
					}
					kp=this.a*Math.sqrt(2.0/(1.0+g));
					y=kp*sin_lat;
				} else {
					g=this.sin_lat_o*sin_lat+this.cos_lat_o*cos_lat*Math.cos(delta_lon);
					if (g == -1.0) {
						trace("laea:fwd:Point projects to a circle of radius ");
						return null;
					}
					kp=this.a*Math.sqrt(2/(1.0+g));
					y=kp*(this.cos_lat_o*sin_lat- this.sin_lat_o*cos_lat*Math.cos(delta_lon));
				}
				x=kp*cos_lat*Math.sin(delta_lon);
				p.x=x+this.xZero;
				p.y=y+this.yZero;
				return p;
			} else {
				var rho:Number;
				this.qp=ProjConstants.qsfnz(this.e,1.0,0.0);
				var q:Number=ProjConstants.qsfnz(this.e,sin_lat,cos_lat);
				if (Math.abs(this.latZero-ProjConstants.HALF_PI)<ProjConstants.EPSLN){
					//North pole
					rho=this.a*Math.sqrt(this.qp-q);
					x=rho*Math.sin(delta_lon);
					y=-rho*Math.cos(delta_lon);
				} else if (Math.abs(this.latZero+ProjConstants.HALF_PI)<ProjConstants.EPSLN){
					//South pole
					rho=this.a*Math.sqrt(this.qp+q);
					x=rho*Math.sin(delta_lon);
					y=rho*Math.cos(delta_lon);
				} else {
					
					this.Rq=this.a*Math.sqrt(this.qp*0.5);
					var Beta:Number =ProjConstants.asinz(q/this.qp);
					var q1:Number = ProjConstants.qsfnz(this.e,this.sin_lat_o,0.0);
					this.Beta1 =ProjConstants.asinz(q1/this.qp);
					g = Math.sin(this.Beta1)*Math.sin(Beta)+Math.cos(this.Beta1)*Math.cos(Beta)*Math.cos(delta_lon);
					if (g == -1.0) {
						trace("laea:fwd:Point projects to a circle of radius ");
						return null;
					}
					var B:Number=this.Rq*Math.sqrt(2/(1+g));
					var m1:Number = ProjConstants.msfnz(this.e, this.sin_lat_o,this.cos_lat_o);
					this.D = this.a*m1/(this.Rq*Math.cos(this.Beta1));
					x=B*this.D*Math.cos(Beta)*Math.sin(delta_lon);
					y=B/this.D*(Math.cos(this.Beta1)*Math.sin(Beta)-Math.sin(this.Beta1)*Math.cos(Beta)*Math.cos(delta_lon));
				}
				
				p.x=x+this.xZero;
				p.y=y+this.yZero;
				return p;
			}
		} //lamazFwd()

		/* Inverse equations
		 -----------------*/
		override public function inverse(p:ProjPoint):ProjPoint {
			p.x-=this.xZero;
			p.y-=this.yZero;

			var Rh:Number;
			var q:Number;
			var lon:Number;
			var lat:Number;
			var ce:Number;
			if (this.sphere){
				Rh=Math.sqrt(p.x * p.x + p.y * p.y);
				var temp:Number=Rh / (2.0 * this.a);
				if (temp > 1) {
					trace("laea:Inv:DataError");
					return null;
				}
				var z:Number=2.0 * ProjConstants.asinz(temp);
				var sin_z:Number=Math.sin(z);
				var cos_z:Number=Math.cos(z);
				lon=this.longZero;
				if (Math.abs(Rh) > ProjConstants.EPSLN) {
					lat=ProjConstants.asinz(this.sin_lat_o * cos_z + this.cos_lat_o * sin_z * p.y / Rh);
					temp=Math.abs(this.latZero) - ProjConstants.HALF_PI;
					if (Math.abs(temp) > ProjConstants.EPSLN) {
						lon=ProjConstants.adjust_lon(this.longZero+Math.atan2(p.x*sin_z,Rh*this.cos_lat_o*cos_z-p.y*this.sin_lat_o*sin_z));
					} else if (this.latZero < 0.0) {
						lon=ProjConstants.adjust_lon(this.longZero - Math.atan2(-p.x, p.y));
					} else {
						lon=ProjConstants.adjust_lon(this.longZero + Math.atan2(p.x, -p.y));
					}
				} else {
					lat=this.latZero;
				}
				p.x=lon;
				p.y=lat;
				return p;
			} else {
				
				
				if (Math.abs(this.latZero-ProjConstants.HALF_PI)<ProjConstants.EPSLN){
					//North pole
					Rh=p.x * p.x + p.y * p.y;
					q=this.qp-Rh/(this.a*this.a);
					if (Math.sqrt(Rh)<ProjConstants.EPSLN){
						lon=this.longZero;
					} else {
						lon=ProjConstants.adjust_lon(this.longZero+Math.atan2(p.x,-1.0*p.y));
					}
					lat=ProjConstants.iqsfnz(this.e,q);
					p.x=lon;
					p.y=lat;
					return p;
				} else if (Math.abs(this.latZero+ProjConstants.HALF_PI)<ProjConstants.EPSLN){
					//North pole
					Rh=p.x * p.x + p.y * p.y;
					q=Rh/(this.a*this.a)-this.qp;
					if (Math.sqrt(Rh)<ProjConstants.EPSLN){
						lon=this.longZero;
					} else {
						lon=ProjConstants.adjust_lon(this.longZero+Math.atan2(p.x,p.y));
					}
					lat=ProjConstants.iqsfnz(this.e,q);
					p.x=lon;
					p.y=lat;
					return p;
				} else {
					Rh=Math.sqrt(Math.pow(p.x/this.D,2.0)+Math.pow(this.D*p.y,2.0));
					ce=2.0*ProjConstants.asinz(Rh/(this.Rq*2.0));
					var sin_ce:Number=Math.sin(ce);
					var cos_ce:Number=Math.cos(ce);
					var sin_Beta1:Number=Math.sin(this.Beta1);
					var cos_Beta1:Number=Math.cos(this.Beta1);
					q=this.qp*(cos_ce*sin_Beta1+this.D*p.y*sin_ce*cos_Beta1/Rh);
					lat=ProjConstants.iqsfnz(this.e,q);
					lon=ProjConstants.adjust_lon(this.longZero+Math.atan2(p.x*sin_ce,this.D*Rh*cos_Beta1*cos_ce-this.D*this.D*p.y*sin_Beta1*sin_ce));
					p.x=lon;
					p.y=lat;
					return p;
				}
			}
			

			
		} //lamazInv()


	}
}
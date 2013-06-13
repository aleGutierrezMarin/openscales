package org.openscales.proj4as.proj {

	import org.openscales.proj4as.Datum;
	import org.openscales.proj4as.ProjConstants;
	import org.openscales.proj4as.ProjPoint;

	/**
	 <p>OBLIQUE MERCATOR (HOTINE) projection</p>
	 
	 <p>PURPOSE:	Transforms input longitude and latitude to Easting and
	 Northing for the Oblique Mercator projection.  The
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
	public class ProjOmerc extends AbstractProjProjection {
		
		private var al:Number;
		private var bl:Number;
		private var el:Number;
		private var uc:Number;
		private var gammaZero:Number;
		

		public function ProjOmerc(data:ProjParams) {
			super(data);
		}


		override public function init():void {
			trace('omerc:start init');
			if (isNaN(this.kZero))
				this.kZero=1.0;
			var sinlat:Number = Math.sin(this.latZero);
			var coslat:Number = Math.cos(this.latZero);
			var con:Number = this.e*sinlat;

		    this.bl=Math.sqrt(1.0+this.es/(1.0-this.es)*Math.pow(coslat,4.0));
			this.al= this.a*this.bl*this.kZero*Math.sqrt(1-this.es)/(1-con*con);
			var tZero:Number = ProjConstants.tsfnz(this.e,this.latZero,sinlat);
			var dl:Number = this.bl/coslat*Math.sqrt((1-this.es)/(1-con*con));
			if (dl*dl<1.0)
				dl=1.0;
			var fl:Number;
			var gl:Number;
			if (!isNaN(this.longc)){
				//Central point and azimuth method
				trace("central point and azimuth");
				//trace(String("g=").concat(this.gamma.toString()));
				//trace(String("alpha=").concat(this.alpha.toString()));
				
				if (this.latZero>=0.0){
					fl = dl+Math.sqrt(dl*dl-1.0);
				} else {
					fl = dl-Math.sqrt(dl*dl-1.0);
				}
				this.el = fl*Math.pow(tZero,this.bl);
				gl = 0.5*(fl-1.0/fl);
				this.gammaZero=Math.asin(Math.sin(this.alpha)/dl);
				this.longZero = this.longc-Math.asin(gl*Math.tan(this.gammaZero))/this.bl;
				
			} else {
				//Two points method
				trace("two points method");
				var tOne:Number = ProjConstants.tsfnz(this.e,this.latOne,Math.sin(this.latOne));
				var tTwo:Number = ProjConstants.tsfnz(this.e,this.latTwo,Math.sin(this.latTwo));
				if (this.latZero>=0.0){
					this.el = (dl+Math.sqrt(dl*dl-1.0))*Math.pow(tZero,this.bl);
				} else {
					this.el = (dl-Math.sqrt(dl*dl-1.0))*Math.pow(tZero,this.bl);
				}
				var hl:Number = Math.pow(tOne,this.bl);
				var ll:Number = Math.pow(tTwo,this.bl);
				fl = this.el/hl;
				gl = 0.5*(fl-1.0/fl);
				var jl:Number = (this.el*this.el-ll*hl)/(this.el*this.el+ll*hl);
				var pl:Number = (ll-hl)/(ll+hl);
				var dlon12:Number=ProjConstants.adjust_lon(this.longOne-this.longTwo);
				this.longZero=0.5*(this.longOne+this.longTwo)-Math.atan(jl*Math.tan(0.5*this.bl*(dlon12))/pl)/this.bl;
				this.longZero=ProjConstants.adjust_lon(this.longZero);
				var dlon10:Number=ProjConstants.adjust_lon(this.longOne-this.longZero);
				this.gammaZero = Math.atan(Math.sin(this.bl*(dlon10))/gl);
				this.alpha = Math.asin(dl*Math.sin(this.gammaZero));
			}
			
			if (this.no_off){
				this.uc=0.0;
			} else {
				if (this.latZero>=0.0) {
					this.uc=this.al/this.bl*Math.atan2(Math.sqrt(dl*dl-1.0),Math.cos(this.alpha));
				} else {
					this.uc=-1.0*this.al/this.bl*Math.atan2(Math.sqrt(dl*dl-1.0),Math.cos(this.alpha));
				}
			}
			
		}


		/* Oblique Mercator forward equations--mapping lat,long to x,y
		 ----------------------------------------------------------*/
		override public function forward(p:ProjPoint):ProjPoint {
			trace('omerc:start forward');
			var lon:Number = p.x;
			var lat:Number = p.y;
			var dlon:Number=ProjConstants.adjust_lon(lon-this.longZero);
			var us:Number, vs:Number;
			var con:Number;
			if (Math.abs(Math.abs(lat)-ProjConstants.HALF_PI)<=ProjConstants.EPSLN){
				if (lat>0.0){
					trace("exception : north pole");
					con=-1.0;
				} else {
					trace("exception : south pole");
					con=1.0;
				}
				vs=this.al/this.bl*Math.log(Math.tan(ProjConstants.FORTPI+con*this.gammaZero*0.5));
				us=-1.0*con*ProjConstants.HALF_PI*this.al/this.bl;
			} else {
				var t:Number = ProjConstants.tsfnz(this.e,lat,Math.sin(lat));
				var ql:Number = this.el/Math.pow(t,this.bl);
				var sl:Number = 0.5*(ql-1.0/ql);
				var tl:Number = 0.5*(ql+1.0/ql);
				var vl:Number=Math.sin(this.bl*(dlon));
				var ul:Number=(sl*Math.sin(this.gammaZero)-vl*Math.cos(this.gammaZero))/tl;
				if (Math.abs(Math.abs(ul)-1.0)<=ProjConstants.EPSLN) {
					trace("exception : U=+/-1");
					vs=Number.POSITIVE_INFINITY;
				} else {
					vs=0.5*this.al*Math.log((1.0-ul)/(1.0+ul))/this.bl;
				}
				if (Math.abs(Math.cos(this.bl*(dlon)))<=ProjConstants.EPSLN) {
					trace("exception : cos(b*dlon)=0");
					us=this.al*this.bl*(dlon);
				} else {
					us=this.al*Math.atan2(sl*Math.cos(this.gammaZero)+vl*Math.sin(this.gammaZero),Math.cos(this.bl*dlon))/this.bl;
				}
				
			}
			
 
			if (this.no_rot){
				p.x=this.xZero+us;
				p.y=this.yZero+vs;
			} else {
				us-=this.uc;
				p.x=this.xZero+vs*Math.cos(this.alpha)+us*Math.sin(this.alpha);
				p.y=this.yZero+us*Math.cos(this.alpha)-vs*Math.sin(this.alpha);
			}
			trace(p.toString());
			trace('omerc:finish forward');
			return p;
		}

		override public function inverse(p:ProjPoint):ProjPoint {
			var us:Number, vs:Number;
			if (this.no_rot){
				vs=p.y-this.yZero;
				us=p.x-this.xZero;
			} else {
				vs=(p.x-this.xZero)*Math.cos(this.alpha)-(p.y-this.yZero)*Math.sin(this.alpha);
				us=(p.y-this.yZero)*Math.cos(this.alpha)+(p.x-this.xZero)*Math.sin(this.alpha);
				us+=this.uc;
			}
			var qp:Number = Math.exp(-1.0*this.bl*vs/this.al);
			var sp:Number=0.5*(qp-1.0/qp);
			var tp:Number = 0.5*(qp+1.0/qp);
			var vp:Number = Math.sin(this.bl*us/this.al);
			var up:Number = (vp*Math.cos(this.gammaZero)+sp*Math.sin(this.gammaZero))/tp;
			var ts:Number = Math.pow(this.el/Math.sqrt((1.0+up)/(1.0-up)),1.0/this.bl);
			if (Math.abs(up-1.0)<ProjConstants.EPSLN){
				p.x=this.longZero;
				p.y=ProjConstants.HALF_PI;
			} else if (Math.abs(up+1.0)<ProjConstants.EPSLN){
				p.x=this.longZero;
				p.y=-1.0*ProjConstants.HALF_PI;
			} else {
				p.y=ProjConstants.phi2z(this.e, ts);
				p.x=ProjConstants.adjust_lon(this.longZero-Math.atan2(sp*Math.cos(this.gammaZero)-vp*Math.sin(this.gammaZero),Math.cos(this.bl*us/this.al))/this.bl);
			}
			return p;
		}


	}
}
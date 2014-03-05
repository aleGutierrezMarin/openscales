package org.openscales.proj4as.proj {

	import org.openscales.proj4as.Datum;
	import org.openscales.proj4as.ProjConstants;
	import org.openscales.proj4as.ProjPoint;

	public class ProjStere extends AbstractProjProjection {
		private var coslatZero:Number,sinlatZero:Number;
		private var XZero:Number, cosXZero:Number, sinXZero:Number;
		private var cons:Number;



		public function ProjStere(data:ProjParams) {
			super(data);
		}

		private function ssfn_(phit:Number, sinphi:Number, eccen:Number):Number {
			sinphi*=eccen;
			return (Math.tan(.5 * (ProjConstants.HALF_PI + phit)) * Math.pow((1. - sinphi) / (1. + sinphi), .5 * eccen));
		}


		override public function init():void {
			this.coslatZero=Math.cos(this.latZero);
			this.sinlatZero=Math.sin(this.latZero);
			if (this.sphere){
				if (this.kZero==1.0 && !isNaN(this.lat_ts) && Math.abs(this.coslatZero)<=ProjConstants.EPSLN){
					this.kZero=0.5*(1.0+ProjConstants.sign(this.latZero)*Math.sin(this.lat_ts));
				}
			}
			else {
				if (Math.abs(this.coslatZero)<=ProjConstants.EPSLN) {
					if (this.latZero>0){
						//North pole
						trace('stere:north pole');
						this.con=1.0;
					} else {
						//South pole
						trace('stere:south pole');
						this.con=-1.0;
					}
				}
				this.cons=Math.sqrt(Math.pow(1+this.e,1+this.e)*Math.pow(1-this.e,1-this.e));
				if (this.kZero==1.0 && !isNaN(this.lat_ts) && Math.abs(this.coslatZero)<=ProjConstants.EPSLN){
					this.kZero=0.5*this.cons*ProjConstants.msfnz(this.e, Math.sin(this.lat_ts), Math.cos(this.lat_ts))/ProjConstants.tsfnz(this.e, this.con*this.lat_ts, this.con*Math.sin(this.lat_ts));
				}
				this.msOne = ProjConstants.msfnz(this.e,this.sinlatZero, this.coslatZero);
	
				this.XZero = 2.0*Math.atan(ssfn_(this.latZero,this.sinlatZero, this.e))-ProjConstants.HALF_PI;
				this.cosXZero=Math.cos(this.XZero);
				this.sinXZero=Math.sin(this.XZero);
			}
		}

		// Stereographic forward equations--mapping lat,long to x,y
		override public function forward(p:ProjPoint):ProjPoint {
			var lon:Number=p.x;
			var lat:Number=p.y;
			var sinlat:Number = Math.sin(lat);
			var coslat:Number = Math.cos(lat);
			var x:Number, y:Number, A:Number, X:Number,sinX:Number,cosX:Number;
			var dlon:Number = ProjConstants.adjust_lon(lon-this.longZero);
			
			if (Math.abs(Math.abs(lon-this.longZero)-ProjConstants.PI)<=ProjConstants.EPSLN && Math.abs(lat+this.latZero)<=ProjConstants.EPSLN){
				//case of the origine point
				trace('stere:this is the origin point');
				p.x=NaN;
				p.y=NaN;
				return p;
			}
			
			if (this.sphere){
				trace('stere:sphere case');
				A=2*this.kZero/(1.0+this.sinlatZero*sinlat+this.coslatZero*coslat*Math.cos(dlon));
				p.x=this.a*A*coslat*Math.sin(dlon)+this.xZero;
				p.y=this.a*A*(this.coslatZero*sinlat-this.sinlatZero*coslat*Math.cos(dlon))+this.yZero;
				return p;
			} else {
				X = 2.0*Math.atan(ssfn_(lat,sinlat, this.e))-ProjConstants.HALF_PI;
				cosX=Math.cos(X);
				sinX=Math.sin(X);
				if (Math.abs(this.coslatZero)<=ProjConstants.EPSLN) {
					var ts:Number = ProjConstants.tsfnz(this.e, lat*this.con, this.con*sinlat);
					var rh:Number=2.0*this.a*this.kZero*ts/this.cons;
				
					
					p.x=this.xZero+rh*Math.sin(lon-this.longZero);
					p.y=this.yZero-this.con*rh*Math.cos(lon-this.longZero);
					trace(p.toString());
					return p;
				} else if (Math.abs(this.sinlatZero)<ProjConstants.EPSLN) { 
					//Eq
					trace('stere:equateur');
					A=2.0*this.a*this.kZero/(1.0+cosX*Math.cos(dlon));
					p.y=A*sinX;
				}else {
					//other case
					trace('stere:normal case');
					A = 2.0*this.a*this.kZero*this.msOne/(this.cosXZero*(1.0+this.sinXZero*sinX+this.cosXZero*cosX*Math.cos(dlon)));
					p.y=A*(this.cosXZero*sinX-this.sinXZero*cosX*Math.cos(dlon))+this.yZero;
				}
				p.x=A*cosX*Math.sin(dlon)+this.xZero;
				
			}
			
			trace(p.toString());
			return p;
		}


		//* Stereographic inverse equations--mapping x,y to lat/long
		override public function inverse(p:ProjPoint):ProjPoint {
			p.x-=this.xZero;
			p.y-=this.yZero
			var lon:Number, lat:Number;
			var rh:Number = Math.sqrt(p.x*p.x + p.y*p.y);
			if (this.sphere){
				var c:Number=2*Math.atan(rh/(0.5*this.a*this.kZero));
				lon=this.longZero;
				lat=this.latZero;
				if (rh<=ProjConstants.EPSLN){
					p.x=lon;
					p.y=lat;
					return p;
				}
				lat=Math.asin(Math.cos(c)*this.sinlatZero+p.y*Math.sin(c)*this.coslatZero/rh);
				if (Math.abs(this.coslatZero)<ProjConstants.EPSLN){
					if (this.latZero>0.0){
						lon=ProjConstants.adjust_lon(this.longZero+Math.atan2(p.x,-1.0*p.y));
					} else {
						lon=ProjConstants.adjust_lon(this.longZero+Math.atan2(p.x,p.y));
					}
				} else {
					lon=ProjConstants.adjust_lon(this.longZero+Math.atan2(p.x*Math.sin(c),rh*this.coslatZero*Math.cos(c)-p.y*this.sinlatZero*Math.sin(c)));
				}
				p.x=lon;
				p.y=lat;
				return p;
				
			} else {
				if (Math.abs(this.coslatZero)<=ProjConstants.EPSLN){
					if (rh<=ProjConstants.EPSLN){
						lat=this.latZero;
						lon=this.longZero;
						p.x=lon;
						p.y=lat;
						
						trace(p.toString());
						return p;
					}
					
					p.x*=this.con;
					p.y*=this.con;
					
					var ts:Number = rh*this.cons/(2.0*this.a*this.kZero);
					lat=this.con*ProjConstants.phi2z(this.e,ts);
					lon=this.con*ProjConstants.adjust_lon(this.con*this.longZero+Math.atan2(p.x,-1.0*p.y));
				} else {
					var ce:Number = 2.0*Math.atan(rh*this.cosXZero/(2.0*this.a*this.kZero*this.msOne));
					lon=this.longZero;
					var Chi:Number;
					if (rh<=ProjConstants.EPSLN){
						Chi=this.XZero;
					} else {
						Chi=Math.asin(Math.cos(ce)*this.sinXZero+p.y*Math.sin(ce)*this.cosXZero/rh);
						lon=ProjConstants.adjust_lon(this.longZero+Math.atan2(p.x*Math.sin(ce),rh*this.cosXZero*Math.cos(ce)-p.y*this.sinXZero*Math.sin(ce)));
					}
					lat=-1.0*ProjConstants.phi2z(this.e,Math.tan(0.5*(ProjConstants.HALF_PI+Chi)));
					
				}
			}
			
			
			p.x=lon;
			p.y=lat;
			
			trace(p.toString());
			return p;
		}

	}
}
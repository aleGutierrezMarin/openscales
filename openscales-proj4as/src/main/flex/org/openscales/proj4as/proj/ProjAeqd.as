package org.openscales.proj4as.proj {
	import org.openscales.proj4as.Datum;
	import org.openscales.proj4as.ProjConstants;
	import org.openscales.proj4as.ProjPoint;

	public class ProjAeqd extends AbstractProjProjection {
		public function ProjAeqd(data:ProjParams) {
			super(data);
		}

		override public function init():void {
			this.sin_pTwelve=Math.sin(this.latZero)
			this.cos_pTwelve=Math.cos(this.latZero)
		}

		override public function forward(p:ProjPoint):ProjPoint {
			var lon:Number=p.x;
			var lat:Number=p.y;
			var dlon:Number=ProjConstants.adjust_lon(lon - this.longZero);
			var c:Number;
			var Ml:Number;
			var Mlp:Number;
			if (this.sphere){
				if (Math.abs(this.sin_pTwelve-1.0)<=ProjConstants.EPSLN){
					//North Pole case
					p.x=this.xZero + this.a * (ProjConstants.HALF_PI-lat) *  Math.sin(dlon);
					p.y=this.yZero - this.a * (ProjConstants.HALF_PI-lat) *  Math.cos(dlon);
					return p;
				} else if (Math.abs(this.sin_pTwelve+1.0)<=ProjConstants.EPSLN){
					//South Pole case
					p.x=this.xZero + this.a * (ProjConstants.HALF_PI+lat) *  Math.sin(dlon);
					p.y=this.yZero + this.a * (ProjConstants.HALF_PI+lat) *  Math.cos(dlon);
					return p;
				}
				else {
					//default case
					var cos_c:Number=this.sin_pTwelve*Math.sin(lat)+this.cos_pTwelve*Math.cos(lat)*Math.cos(dlon);
					c = Math.acos(cos_c);
					var kp:Number = c/Math.sin(c);
					p.x=this.xZero + this.a*kp*Math.cos(lat)*Math.sin(dlon);
					p.y=this.yZero + this.a*kp*(this.cos_pTwelve*Math.sin(lat)-this.sin_pTwelve*Math.cos(lat)*Math.cos(dlon));
					return p;
							}
			
			}
			else {
				var e0:Number = ProjConstants.e0fn(this.es);
				var e1:Number = ProjConstants.e1fn(this.es);
				var e2:Number = ProjConstants.e2fn(this.es);
				var e3:Number = ProjConstants.e3fn(this.es);
				if (Math.abs(this.sin_pTwelve-1.0)<=ProjConstants.EPSLN){
					//North Pole case
						Mlp = this.a*ProjConstants.mlfn(e0,e1,e2,e3,ProjConstants.HALF_PI);
						Ml = this.a*ProjConstants.mlfn(e0,e1,e2,e3,lat);
						p.x = this.xZero + (Mlp-Ml)*Math.sin(dlon);
						p.y = this.yZero - (Mlp-Ml)*Math.cos(dlon);
						return p;
				} else if (Math.abs(this.sin_pTwelve+1.0)<=ProjConstants.EPSLN){
					//South Pole case
					Mlp = this.a*ProjConstants.mlfn(e0,e1,e2,e3,ProjConstants.HALF_PI);
					Ml = this.a*ProjConstants.mlfn(e0,e1,e2,e3,lat);
					p.x = this.xZero + (Ml+Mlp)*Math.sin(dlon);
					p.y = this.yZero + (Ml+Mlp)*Math.cos(dlon);
					return p;
				} else {
					var sin_phi:Number=Math.sin(lat);
					var cos_phi:Number=Math.cos(lat);
					var tan_phi:Number=sin_phi/cos_phi;
					
					var Nl1:Number = ProjConstants.gN(this.a,this.e, this.sin_pTwelve);
					var Nl:Number = ProjConstants.gN(this.a, this.e, sin_phi);
					var psi:Number;
					var Az:Number;

					psi = Math.atan((1.0-this.es)*tan_phi+this.es*Nl1*this.sin_pTwelve/(Nl*cos_phi));
					Az = Math.atan2(Math.sin(dlon),this.cos_pTwelve*Math.tan(psi)-this.sin_pTwelve*Math.cos(dlon));

					var s:Number;
					if (Math.abs(Az)<ProjConstants.EPSLN) {
						s=Math.asin(this.cos_pTwelve*Math.sin(psi)-this.sin_pTwelve*Math.cos(psi));
					} else if (Math.abs(Math.abs(Az)-ProjConstants.PI)<=ProjConstants.EPSLN){
						s=-Math.asin(this.cos_pTwelve*Math.sin(psi)-this.sin_pTwelve*Math.cos(psi));
					} else {
						s=Math.asin(Math.sin(dlon)*Math.cos(psi)/Math.sin(Az));
					}
					var G:Number = this.e*this.sin_pTwelve/Math.sqrt(1.0-this.es);
					var H:Number = this.e*this.cos_pTwelve*Math.cos(Az)/Math.sqrt(1.0-this.es);
					var Hs:Number = H*H;
					c = Nl1*s*(1.0-s*s*Hs*(1.0-Hs)/6.0+s*s*s/8.0*G*H*(1.0-2.0*Hs)+s*s*s*s/120.0*(Hs*(4.0-7.0*Hs)-3.0*G*G*(1.0-7.0*Hs))-s*s*s*s*s/48.0*G*H);
					p.x=this.xZero+c*Math.sin(Az);
					p.y=this.yZero+c*Math.cos(Az);
	
					
					return p;
				}
			}
			return p;
			
		}
		

		override public function inverse(p:ProjPoint):ProjPoint {
			p.x-=this.xZero;
			p.y-=this.yZero;
			var lon:Number;
			var lat:Number;
			var rh:Number;
			var Mlp:Number;
			var M:Number;
			if (this.sphere){
				rh=Math.sqrt(p.x * p.x + p.y * p.y);
				if (rh > (2.0 * ProjConstants.HALF_PI * this.a)) {
					//trace("aeqdInvDataError");
					return null;
				}
				var z:Number=rh / this.a;

				var sinz:Number=Math.sin(z)
				var cosz:Number=Math.cos(z)

				lon=this.longZero;
				if (Math.abs(rh) <= ProjConstants.EPSLN) {
					lat=this.latZero;
				} else {
					lat=ProjConstants.asinz(cosz * this.sin_pTwelve + (p.y * sinz * this.cos_pTwelve) / rh);
					var con:Number=Math.abs(this.latZero) - ProjConstants.HALF_PI;
					if (Math.abs(con) <= ProjConstants.EPSLN) {
						if (latZero >= 0.0) {
							lon=ProjConstants.adjust_lon(this.longZero + Math.atan2(p.x, -p.y));
						} else {
							lon=ProjConstants.adjust_lon(this.longZero + Math.atan2(p.x, p.y));
						}
					} else {
					
						lon=ProjConstants.adjust_lon(this.longZero+Math.atan2(p.x*sinz,rh*this.cos_pTwelve*cosz-p.y*this.sin_pTwelve*sinz));
					}
				}

				p.x=lon;
				p.y=lat;
				return p;
			} else {
				var e0:Number = ProjConstants.e0fn(this.es);
				var e1:Number = ProjConstants.e1fn(this.es);
				var e2:Number = ProjConstants.e2fn(this.es);
				var e3:Number = ProjConstants.e3fn(this.es);
				if (Math.abs(this.sin_pTwelve-1.0)<=ProjConstants.EPSLN){
					//North pole case
					Mlp = this.a*ProjConstants.mlfn(e0,e1,e2,e3,ProjConstants.HALF_PI);
					rh = Math.sqrt(p.x*p.x+p.y*p.y);
					M = Mlp-rh;
					lat = ProjConstants.imlfn(M/this.a,e0,e1,e2,e3);
					lon = ProjConstants.adjust_lon(this.longZero+Math.atan2(p.x,-1.0*p.y));
					p.x=lon,
					p.y=lat;
					return p;
				} else if (Math.abs(this.sin_pTwelve+1.0)<=ProjConstants.EPSLN){
					//South pole case
					Mlp = this.a*ProjConstants.mlfn(e0,e1,e2,e3,ProjConstants.HALF_PI);
					rh = Math.sqrt(p.x*p.x+p.y*p.y);
					M = rh-Mlp;
					lat = ProjConstants.imlfn(M/this.a,e0,e1,e2,e3);
					lon = ProjConstants.adjust_lon(this.longZero+Math.atan2(p.x,p.y));
					p.x=lon,
					p.y=lat;
					return p;
				} else {
					//default case
					rh = Math.sqrt(p.x*p.x+p.y*p.y);
					var Az:Number = Math.atan2(p.x,p.y);
					var N1:Number = ProjConstants.gN(this.a, this.e, this.sin_pTwelve);
					var cosAz:Number = Math.cos(Az);
					var tmp:Number = this.e*cos_pTwelve*cosAz;
					var A:Number = -tmp*tmp/(1.0 - this.es);
					//trace(A.toString());
					var B:Number=3.0*this.es*(1.0-A) * this.sin_pTwelve*this.cos_pTwelve*cosAz/(1.0-this.es);
					//trace(B.toString());
					var D:Number = rh/N1;
					//trace(D.toString());
					var E:Number = D-A*(1.0+A)*Math.pow(D,3.0)/6.0-B*(1+3.0*A)*Math.pow(D,4.0)/24.0;
					//trace(E.toString());
					var F:Number = 1.0-A*E*E*0.5-D*E*E*E/6.0;
					//trace(F.toString());
					var psi:Number = Math.asin(this.sin_pTwelve*Math.cos(E)+this.cos_pTwelve*Math.sin(E)*cosAz);
					//trace(psi.toString());
					lon=Math.asin(Math.sin(Az)*Math.sin(E)/Math.cos(psi));
					lon = ProjConstants.adjust_lon(this.longZero+lon);
					lat = Math.atan((1.0-this.es*F*this.sin_pTwelve/Math.sin(psi))*Math.tan(psi)/(1.0-this.es));
					//trace("--------");
					p.x=lon;
					p.y=lat;
					return p;
				}
				
			
			}
			return p;
		}

	}
}
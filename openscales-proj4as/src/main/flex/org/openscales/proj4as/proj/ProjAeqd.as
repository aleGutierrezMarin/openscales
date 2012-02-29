package org.openscales.proj4as.proj {
	import org.openscales.proj4as.ProjPoint;
	import org.openscales.proj4as.ProjConstants;
	import org.openscales.proj4as.Datum;

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
			var ksp:Number;

			var sinphi:Number=Math.sin(p.y);
			var cosphi:Number=Math.cos(p.y);
			var dlon:Number=ProjConstants.adjust_lon(lon - this.longZero);
			var coslon:Number=Math.cos(dlon);
			var g:Number=this.sin_pTwelve * sinphi + this.cos_pTwelve * cosphi * coslon;
			if (Math.abs(Math.abs(g) - 1.0) < ProjConstants.EPSLN) {
				ksp=1.0;
				if (g < 0.0) {
					trace("aeqd:Fwd:PointError");
					return null;
				}
			} else {
				var z:Number=Math.acos(g);
				ksp=z / Math.sin(z);
			}
			p.x=this.xZero + this.a * ksp * cosphi * Math.sin(dlon);
			p.y=this.yZero + this.a * ksp * (this.cos_pTwelve * sinphi - this.sin_pTwelve * cosphi * coslon);
			return p;
		}

		override public function inverse(p:ProjPoint):ProjPoint {
			p.x-=this.xZero;
			p.y-=this.yZero;

			var rh:Number=Math.sqrt(p.x * p.x + p.y * p.y);
			if (rh > (2.0 * ProjConstants.HALF_PI * this.a)) {
				trace("aeqdInvDataError");
				return null;
			}
			var z:Number=rh / this.a;

			var sinz:Number=Math.sin(z)
			var cosz:Number=Math.cos(z)

			var lon:Number=this.longZero;
			var lat:Number;
			if (Math.abs(rh) <= ProjConstants.EPSLN) {
				lat=this.latZero;
			} else {
				lat=ProjConstants.asinz(cosz * this.sin_pTwelve + (p.y * sinz * this.cos_pTwelve) / rh);
				var con:Number=Math.abs(this.latZero) - ProjConstants.HALF_PI;
				if (Math.abs(con) <= ProjConstants.EPSLN) {
					if (latZero >= 0.0) {
						lon=ProjConstants.adjust_lon(this.longZero + Math.atan2(p.x, -p.y));
					} else {
						lon=ProjConstants.adjust_lon(this.longZero - Math.atan2(-p.x, p.y));
					}
				} else {
					con=cosz - this.sin_pTwelve * Math.sin(lat);
					if((Math.abs(con) >= ProjConstants.EPSLN) || (Math.abs(p.x) >= ProjConstants.EPSLN)) {
						var temp:Number=Math.atan2((p.x * sinz * this.cos_pTwelve), (con * rh));
						lon=ProjConstants.adjust_lon(this.longZero + Math.atan2((p.x * sinz * this.cos_pTwelve), (con * rh)));
					}
				}
			}

			p.x=lon;
			p.y=lat;
			return p;
		}


	}
}
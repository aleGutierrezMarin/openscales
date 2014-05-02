package org.openscales.proj4as.proj {

	import org.openscales.proj4as.ProjPoint;
	import org.openscales.proj4as.ProjConstants;
	import org.openscales.proj4as.Datum;

	public class ProjSterea extends ProjGauss {

		protected var sincZero:Number;
		protected var coscZero:Number;
		protected var RTwo:Number;

		public function ProjSterea(data:ProjParams) {
			super(data);
		}

		override public function init():void {
			super.init();
			if (!this.rc) {
				trace("sterea:init:E_ERROR_0");
				return;
			}
			this.sincZero=Math.sin(this.phicZero);
			this.coscZero=Math.cos(this.phicZero);
			this.RTwo=2.0 * this.rc;
			if (!this.title)
				this.title="Oblique Stereographic Alternative";
		}

		override public function forward(p:ProjPoint):ProjPoint {
			p.x=ProjConstants.adjust_lon(p.x - this.longZero); /* adjust del longitude */
			super.forward(p);
			var sinc:Number=Math.sin(p.y);
			var cosc:Number=Math.cos(p.y);
			var cosl:Number=Math.cos(p.x);
			var k:Number = this.kZero * this.RTwo / (1.0 + this.sincZero * sinc + this.coscZero * cosc * cosl);
			p.x=k * cosc * Math.sin(p.x);
			p.y=k * (this.coscZero * sinc - this.sincZero * cosc * cosl);
			p.x=this.a * p.x + this.xZero;
			p.y=this.a * p.y + this.yZero;
			return p;
		}

		override public function inverse(p:ProjPoint):ProjPoint {
			var lon:Number, lat:Number, rho:Number, sinc:Number, cosc:Number, c:Number;
			p.x=(p.x - this.xZero) / this.a; /* descale and de-offset */
			p.y=(p.y - this.yZero) / this.a;

			p.x/=this.kZero;
			p.y/=this.kZero;
			if ((rho=Math.sqrt(p.x * p.x + p.y * p.y))) {
				c=2.0 * Math.atan2(rho, this.RTwo);
				sinc=Math.sin(c);
				cosc=Math.cos(c);
				lat=Math.asin(cosc * this.sincZero + p.y * sinc * this.coscZero / rho);
				lon=Math.atan2(p.x * sinc, rho * this.coscZero * cosc - p.y * this.sincZero * sinc);
			} else {
				lat=this.phicZero;
				lon=0.;
			}

			p.x=lon;
			p.y=lat;
			super.inverse(p);
			p.x=ProjConstants.adjust_lon(p.x + this.longZero); /* adjust longitude to CM */
			return p;
		}

	}
}
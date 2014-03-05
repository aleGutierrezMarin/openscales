package org.openscales.proj4as.proj {
	
	import org.openscales.proj4as.ProjPoint;
	import org.openscales.proj4as.ProjConstants;
	import org.openscales.proj4as.Datum;

	/*
	*	Projection from ellipsoid to conformal sphere
	*
	*
	*/
	
	
	public class ProjGauss extends AbstractProjProjection {

		protected var phicZero:Number;
		protected var ratexp:Number;

		public function ProjGauss(data:ProjParams) {
			super(data);
		}

		override public function init():void {
			var sphi:Number=Math.sin(this.latZero);
			var cphi:Number=Math.cos(this.latZero);
			cphi*=cphi;
			this.rc=Math.sqrt(1.0 - this.es) / (1.0 - this.es * sphi * sphi);
			this.c=Math.sqrt(1.0 + this.es * cphi * cphi / (1.0 - this.es));
			this.phicZero=Math.asin(sphi / this.c);
			this.ratexp=0.5 * this.c * this.e;
			this.k=Math.tan(0.5 * this.phicZero + ProjConstants.FORTPI) / (Math.pow(Math.tan(0.5 * this.latZero + ProjConstants.FORTPI), this.c) * ProjConstants.srat(this.e * sphi, this.ratexp));
		}

		override public function forward(p:ProjPoint):ProjPoint {
			var lon:Number=p.x;
			var lat:Number=p.y;

			p.y=2.0 * Math.atan(this.k * Math.pow(Math.tan(0.5 * lat + ProjConstants.FORTPI), this.c) * ProjConstants.srat(this.e * Math.sin(lat), this.ratexp)) - ProjConstants.HALF_PI;
			p.x=this.c * lon;
			return p;
		}

		override public function inverse(p:ProjPoint):ProjPoint {
			var DEL_TOL:Number=1e-14;
			var lon:Number=p.x / this.c;
			var lat:Number=p.y;
			var num:Number=Math.pow(Math.tan(0.5 * lat + ProjConstants.FORTPI) / this.k, 1. / this.c);
			for (var i:int=ProjConstants.MAX_ITER; i > 0; --i) {
				lat=2.0 * Math.atan(num * ProjConstants.srat(this.e * Math.sin(p.y), -0.5 * this.e)) - ProjConstants.HALF_PI;
				if (Math.abs(lat - p.y) < DEL_TOL)
					break;
				p.y=lat;
			}
			/* convergence failed */
			if (!i) {
				trace("gauss:inverse:convergence failed");
				return null;
			}
			p.x=lon;
			p.y=lat;
			return p;
		}

	}
}
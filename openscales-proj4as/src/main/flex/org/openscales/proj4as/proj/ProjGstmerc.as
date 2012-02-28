package org.openscales.proj4as.proj {
	import org.openscales.proj4as.ProjPoint;
	import org.openscales.proj4as.ProjConstants;
	import org.openscales.proj4as.Datum;

	public class ProjGstmerc extends AbstractProjProjection {

		private var cp:Number;
		private var lc:Number;
		private var nTwo:Number;
		private var rs:Number;
		private var xs:Number;
		private var ys:Number;

		public function ProjGstmerc(data:ProjParams) {
			super(data);
		}

		override public function init():void {
			// array of:  a, b, lon0, lat0, k0, x0, y0
			var temp:Number=this.b / this.a;
			this.e=Math.sqrt(1.0 - temp * temp);
			this.lc=this.longZero;
			this.rs=Math.sqrt(1.0 + this.e * this.e * Math.pow(Math.cos(this.latZero), 4.0) / (1.0 - this.e * this.e));
			var sinz:Number=Math.sin(this.latZero);
			var pc:Number=Math.asin(sinz / this.rs);
			var sinzpc:Number=Math.sin(pc);
			this.cp=ProjConstants.latiso(0.0, pc, sinzpc) - this.rs * ProjConstants.latiso(this.e, this.latZero, sinz);
			this.nTwo=this.kZero * this.a * Math.sqrt(1.0 - this.e * this.e) / (1.0 - this.e * this.e * sinz * sinz);
			this.xs=this.xZero;
			this.ys=this.yZero - this.nTwo * pc;

			if (!this.title)
				this.title="Gauss Schreiber transverse mercator";
		}


		// forward equations--mapping lat,long to x,y
		// -----------------------------------------------------------------
		override public function forward(p:ProjPoint):ProjPoint {
			var lon:Number=p.x;
			var lat:Number=p.y;

			var L:Number=this.rs * (lon - this.lc);
			var Ls:Number=this.cp + (this.rs * ProjConstants.latiso(this.e, lat, Math.sin(lat)));
			var latOne:Number=Math.asin(Math.sin(L) / ProjConstants.cosh(Ls));
			var LsOne:Number=ProjConstants.latiso(0.0, latOne, Math.sin(latOne));
			p.x=this.xs + (this.nTwo * LsOne);
			p.y=this.ys + (this.nTwo * Math.atan(ProjConstants.sinh(Ls) / Math.cos(L)));
			return p;
		}

		// inverse equations--mapping x,y to lat/long
		// -----------------------------------------------------------------
		override public function inverse(p:ProjPoint):ProjPoint {
			var x:Number=p.x;
			var y:Number=p.y;

			var L:Number=Math.atan(ProjConstants.sinh((x - this.xs) / this.nTwo) / Math.cos((y - this.ys) / this.nTwo));
			var lat:Number=Math.asin(Math.sin((y - this.ys) / this.nTwo) / ProjConstants.cosh((x - this.xs) / this.nTwo));
			var LC:Number=ProjConstants.latiso(0.0, lat, Math.sin(lat));
			p.x=this.lc + L / this.rs;
			p.y=ProjConstants.invlatiso(this.e, (LC - this.cp) / this.rs);
			return p;
		}


	}
}
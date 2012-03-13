package org.openscales.proj4as.proj {
	
	import org.openscales.proj4as.ProjPoint;
	import org.openscales.proj4as.ProjConstants;
	import org.openscales.proj4as.Datum;

	public class ProjEqc extends AbstractProjProjection {
		public function ProjEqc(data:ProjParams) {
			super(data);
		}

		override public function init():void {
			if (!this.xZero)
				this.xZero=0;
			if (!this.yZero)
				this.yZero=0;
			if (!this.latZero)
				this.latZero=0;
			if (!this.longZero)
				this.longZero=0;
			if (!this.lat_ts)
				this.lat_ts=0;
			if (!this.title)
				this.title="Equidistant Cylindrical (Plate Carre)";
			this.rc=Math.cos(this.lat_ts);
		}


		// forward equations--mapping lat,long to x,y
		// -----------------------------------------------------------------
		override public function forward(p:ProjPoint):ProjPoint {
			var lon:Number=p.x;
			var lat:Number=p.y;

			var dlon:Number=ProjConstants.adjust_lon(lon - this.longZero);
			var dlat:Number=ProjConstants.adjust_lat(lat - this.latZero);
			p.x=this.xZero + (this.a * dlon * this.rc);
			p.y=this.yZero + (this.a * dlat);
			return p;
		}

		// inverse equations--mapping x,y to lat/long
		// -----------------------------------------------------------------
		override public function inverse(p:ProjPoint):ProjPoint {
			var x:Number=p.x;
			var y:Number=p.y;

			p.x=ProjConstants.adjust_lon(this.longZero + ((x - this.xZero) / (this.a * this.rc)));
			p.y=ProjConstants.adjust_lat(this.latZero + ((y - this.yZero) / (this.a)));
			return p;
		}



	}
}
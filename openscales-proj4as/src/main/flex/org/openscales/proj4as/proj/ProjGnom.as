package org.openscales.proj4as.proj {
	
	import org.openscales.proj4as.Datum;
	import org.openscales.proj4as.ProjConstants;
	import org.openscales.proj4as.ProjPoint;
	
	
	public class ProjGnom extends AbstractProjProjection {
		private var sin_p14:Number;
		private var cos_p14:Number;
		private var infinity_dist:Number;
		
		public function ProjGnom(data:ProjParams) {
			super(data);
		}
		
		override public function init():void {
			this.sin_p14=Math.sin(this.latZero);
			this.cos_p14=Math.cos(this.latZero);
			// Approximation for projecting points to the horizon (infinity)
			this.infinity_dist = 1000 * this.a;
			this.rc = 1;
		}
			
		override public function forward(p:ProjPoint):ProjPoint {
			var sinphi:Number, cosphi:Number;	/* sin and cos value				*/
			var dlon:Number;		/* delta longitude value			*/
			var coslon:Number;		/* cos of longitude				*/
			var ksp:Number;		/* scale factor					*/
			var g:Number;		
			var x:Number, y:Number;
			var lon:Number=p.x;
			var lat:Number=p.y;	
			/* Forward equations
			-----------------*/
			dlon = ProjConstants.adjust_lon(lon - this.longZero);
			
			sinphi=Math.sin(lat);
			cosphi=Math.cos(lat);	
			
			coslon = Math.cos(dlon);
			g = this.sin_p14 * sinphi + this.cos_p14 * cosphi * coslon;
			ksp = 1.0;
			if ((g > 0) || (Math.abs(g) <= ProjConstants.EPSLN)) {
				x = this.xZero + this.a * ksp * cosphi * Math.sin(dlon) / g;
				y = this.yZero + this.a * ksp * (this.cos_p14 * sinphi - this.sin_p14 * cosphi * coslon) / g;
			} else {
				trace("orthoFwdPointError");
				
				// Point is in the opposing hemisphere and is unprojectable
				// We still need to return a reasonable point, so we project 
				// to infinity, on a bearing 
				// equivalent to the northern hemisphere equivalent
				// This is a reasonable approximation for short shapes and lines that 
				// straddle the horizon.
				
				x = this.xZero + this.infinity_dist * cosphi * Math.sin(dlon);
				y = this.yZero + this.infinity_dist * (this.cos_p14 * sinphi - this.sin_p14 * cosphi * coslon);
				
			}
			p.x=x;
			p.y=y;
			return p;
		}
		
		override public function inverse(p:ProjPoint):ProjPoint {
			var rh:Number;		/* Rho */
			var z:Number;		/* angle */
			var sinc:Number, cosc:Number;
			var c:Number;
			var lon:Number, lat:Number;
			
			/* Inverse equations
			-----------------*/
			p.x = (p.x - this.xZero) / this.a;
			p.y = (p.y - this.yZero) / this.a;
			
			p.x /= this.kZero;
			p.y /= this.kZero;
			
			if ( (rh = Math.sqrt(p.x * p.x + p.y * p.y)) ) {
				c = Math.atan2(rh, this.rc);
				sinc = Math.sin(c);
				cosc = Math.cos(c);
				
				lat = ProjConstants.asinz(cosc*this.sin_p14 + (p.y*sinc*this.cos_p14) / rh);
				lon = Math.atan2(p.x*sinc, rh*this.cos_p14*cosc - p.y*this.sin_p14*sinc);
				lon = ProjConstants.adjust_lon(this.longZero+lon);
			} else {
				lat = this.latZero;
				lon = this.longZero;
			}
			
			p.x=lon;
			p.y=lat;
			return p;
		}
		
		
	}
}
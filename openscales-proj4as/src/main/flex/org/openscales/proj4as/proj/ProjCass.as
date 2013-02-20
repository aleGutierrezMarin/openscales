package org.openscales.proj4as.proj {
	
	import org.openscales.proj4as.Datum;
	import org.openscales.proj4as.ProjConstants;
	import org.openscales.proj4as.ProjPoint;
	
	
	public class ProjCass extends AbstractProjProjection {
		private var e0:Number;
		private var e1:Number;
		private var e2:Number;
		private var e3:Number;
		public function ProjCass(data:ProjParams) {
			super(data);
		}
		
		override public function init():void {
			if (!this.sphere) {
				this.e0 = ProjConstants.e0fn(this.es);
				this.e1 = ProjConstants.e1fn(this.es);
				this.e2 = ProjConstants.e2fn(this.es);
				this.e3 = ProjConstants.e3fn(this.es);
				this.mlZero = this.a*ProjConstants.mlfn(this.e0,this.e1,this.e2,this.e3,this.latZero);
			}
		}
			
		override public function forward(p:ProjPoint):ProjPoint {
			var x:Number,y:Number;
			var lam:Number=p.x;
			var phi:Number=p.y;
			lam = ProjConstants.adjust_lon(lam - this.longZero);
			
			if (this.sphere) {
				x = this.a*Math.asin(Math.cos(phi) * Math.sin(lam));
				y = this.a*(Math.atan2(Math.tan(phi) , Math.cos(lam)) - this.latZero);
			} else {
				//ellipsoid
				var sinphi:Number = Math.sin(phi);
				var cosphi:Number = Math.cos(phi);
				var nl:Number = ProjConstants.gN(this.a,this.e,sinphi)
				var tl:Number = Math.tan(phi)*Math.tan(phi);
				var al:Number = lam*Math.cos(phi);
				var asq:Number = al*al;
				var cl:Number = this.es*cosphi*cosphi/(1.0-this.es);
				var ml:Number = this.a*ProjConstants.mlfn(this.e0,this.e1,this.e2,this.e3,phi);
				
				x = nl*al*(1.0-asq*tl*(1.0/6.0-(8.0-tl+8.0*cl)*asq/120.0));
				y = ml-this.mlZero + nl*sinphi/cosphi*asq*(0.5+(5.0-tl+6.0*cl)*asq/24.0);
				
				
			}
			
			p.x = x + this.xZero;
			p.y = y + this.yZero;
			return p;
		}
		
		override public function inverse(p:ProjPoint):ProjPoint {
			p.x -= this.xZero;
			p.y -= this.yZero;
			var x:Number = p.x/this.a;
			var y:Number = p.y/this.a;
			var phi:Number, lam:Number;
			
			if (this.sphere) {
				var dd:Number = y + this.latZero;
				phi = Math.asin(Math.sin(dd) * Math.cos(x));
				lam = Math.atan2(Math.tan(x), Math.cos(dd));
			} else {
				/* ellipsoid */
				var ml1:Number = this.mlZero/this.a + y;
				var phi1:Number = ProjConstants.imlfn(ml1, this.e0,this.e1,this.e2,this.e3);
				if (Math.abs(Math.abs(phi1)-ProjConstants.HALF_PI)<=ProjConstants.EPSLN){
					p.x=this.longZero;
					p.y=ProjConstants.HALF_PI;
					if (y<0.0){p.y*=-1.0;}
					return p;
				}
				var nl1:Number = ProjConstants.gN(this.a,this.e, Math.sin(phi1));
				
				var rl1:Number = nl1*nl1*nl1/this.a/this.a*(1.0-this.es);
				var tl1:Number = Math.pow(Math.tan(phi1),2.0);
				var dl:Number = x*this.a/nl1;
				var dsq:Number=dl*dl;
				phi = phi1-nl1*Math.tan(phi1)/rl1*dl*dl*(0.5-(1.0+3.0*tl1)*dl*dl/24.0);
				lam = dl*(1.0-dsq*(tl1/3.0+(1.0+3.0*tl1)*tl1*dsq/15.0))/Math.cos(phi1);
				
			} 
			
			p.x=ProjConstants.adjust_lon(lam+this.longZero);
			p.y=ProjConstants.adjust_lat(phi);
			return p;
		}
		
		
	}
}
package org.openscales.proj4as.proj {
	
	import org.openscales.proj4as.Datum;
	import org.openscales.proj4as.ProjConstants;
	import org.openscales.proj4as.ProjPoint;
	
	
	public class ProjCea extends AbstractProjProjection {
		public function ProjCea(data:ProjParams) {
			super(data);
		}
		
		override public function init():void {
			if (!this.sphere){
				this.kZero = ProjConstants.msfnz(this.e, Math.sin(this.lat_ts), Math.cos(this.lat_ts));
			}
		}
			
		override public function forward(p:ProjPoint):ProjPoint {
			var lon:Number=p.x;
			var lat:Number=p.y;
			var x:Number,y:Number;
			/* Forward equations
			-----------------*/
			var dlon:Number = ProjConstants.adjust_lon(lon -this.longZero);
			if (this.sphere){
				x = this.xZero + this.a * dlon * Math.cos(this.lat_ts);
				y = this.yZero + this.a * Math.sin(lat) / Math.cos(this.lat_ts);
			} else {
				var qs:Number = ProjConstants.qsfnz(this.e,Math.sin(lat),0.0);
				x = this.xZero + this.a*this.kZero*dlon;
				y = this.yZero + this.a*qs*0.5/this.kZero;
			}
			
			p.x=x;
			p.y=y;
			return p;
		}
		
		override public function inverse(p:ProjPoint):ProjPoint {
			p.x -= this.xZero;
			p.y -= this.yZero;
			var lon:Number, lat:Number;
			
			if (this.sphere){
				lon = ProjConstants.adjust_lon( this.longZero + (p.x / this.a) / Math.cos(this.lat_ts) );
				lat = Math.asin( (p.y/this.a) * Math.cos(this.lat_ts) );
			} else {
				lat=ProjConstants.iqsfnz(this.e,2.0*p.y*this.kZero/this.a);
				lon = ProjConstants.adjust_lon( this.longZero + p.x/(this.a*this.kZero));
			}
			
			p.x=lon;
			p.y=lat;
			return p;
		}
		
		
	}
}
package org.openscales.proj4as.proj {
	
	import org.openscales.proj4as.Datum;
	import org.openscales.proj4as.ProjConstants;
	import org.openscales.proj4as.ProjPoint;
	
	
	public class ProjPoly extends AbstractProjProjection {
		private var e0:Number;
		private var e1:Number;
		private var e2:Number;
		private var e3:Number;
		
		public function ProjPoly(data:ProjParams) {
			super(data);
		}
		
		override public function init():void {
			this.temp = this.b / this.a;
			this.es = 1.0 - Math.pow(this.temp,2);// devait etre dans tmerc.js mais n y est pas donc je commente sinon retour de valeurs nulles
			this.e = Math.sqrt(this.es);
			this.e0 = ProjConstants.e0fn(this.es);
			this.e1 = ProjConstants.e1fn(this.es);
			this.e2 = ProjConstants.e2fn(this.es);
			this.e3 = ProjConstants.e3fn(this.es);
			this.mlZero = this.a*ProjConstants.mlfn(this.e0, this.e1,this.e2, this.e3, this.latZero);//si que des zeros le calcul ne se fait pas
		}
			
		override public function forward(p:ProjPoint):ProjPoint {
			var lon:Number=p.x;
			var lat:Number=p.y;
			var x:Number,y:Number,el:Number;
			var dlon:Number=ProjConstants.adjust_lon(lon-this.longZero);
			el=dlon*Math.sin(lat);
			if (this.sphere){
				if (Math.abs(lat)<=ProjConstants.EPSLN){
					x=this.a*dlon;
					y=-1.0*this.a*this.latZero;
				} else {
					x=this.a*Math.sin(el)/Math.tan(lat);
					y=this.a*(ProjConstants.adjust_lat(lat-this.latZero)+(1.0-Math.cos(el))/Math.tan(lat));
				}
			} else {
				if (Math.abs(lat)<=ProjConstants.EPSLN){
					x=this.a*dlon;
					y=-1.0*this.mlZero;
				} else {
					var nl:Number =ProjConstants.gN(this.a, this.e,Math.sin(lat))/Math.tan(lat);
					x=nl*Math.sin(el);
					y=this.a*ProjConstants.mlfn(this.e0, this.e1,this.e2, this.e3, lat)-this.mlZero+nl*(1.0-Math.cos(el));
				}
				
			}
			p.x=x+this.xZero;
			p.y=y+this.yZero;   
			return p;
		}
		
		override public function inverse(p:ProjPoint):ProjPoint {
			var lon:Number,lat:Number,x:Number,y:Number;
			var al:Number,bl:Number;
			var phi:Number,dphi:Number;
			x=p.x-this.xZero;
			y=p.y-this.yZero;
			
			if (this.sphere){
				if (Math.abs(y+this.a*this.latZero)<=ProjConstants.EPSLN){
					lon=ProjConstants.adjust_lon(x/this.a+this.longZero);
					lat=0;
				} else {
					al = this.latZero + y/this.a;
					bl = x*x/this.a/this.a+al*al;
					phi = al;
					var tanphi:Number;
					for (var i:Number = ProjConstants.MAX_ITER; i ; --i){
						tanphi = Math.tan(phi);
						dphi = -1.0*(al*(phi*tanphi+1.0)-phi-0.5*(phi*phi+bl)*tanphi)/((phi-al)/tanphi-1.0);
						phi+=dphi;
						if (Math.abs(dphi)<=ProjConstants.EPSLN){
							lat=phi;
							break;
						}
					}
					lon=ProjConstants.adjust_lon(this.longZero+(Math.asin(x*Math.tan(phi)/this.a))/Math.sin(lat));
				}
			} else {
				if (Math.abs(y+this.mlZero)<=ProjConstants.EPSLN){
					lat=0;
					lon=ProjConstants.adjust_lon(this.longZero+x/this.a);
				} else {
					
					al=(this.mlZero+y)/this.a;
					bl=x*x/this.a/this.a+al*al;
					phi=al;
					var cl:Number,mln:Number,mlnp:Number,ma:Number;
					var con:Number;
					for (var j:Number = ProjConstants.MAX_ITER; j ; --j){
						con = this.e*Math.sin(phi);
						cl = Math.sqrt(1.0-con*con)*Math.tan(phi);
						mln = this.a*ProjConstants.mlfn(this.e0, this.e1,this.e2, this.e3, phi);
						mlnp = this.e0-2.0*this.e1*Math.cos(2.0*phi)+4.0*this.e2*Math.cos(4.0*phi)-6.0*this.e3*Math.cos(6.0*phi);
						ma=mln/this.a;
						dphi=(al*(cl*ma+1.0)-ma-0.5*cl*(ma*ma+bl))/(this.es*Math.sin(2.0*phi)*(ma*ma+bl-2.0*al*ma)/(4.0*cl)+(al-ma)*(cl*mlnp-2.0/Math.sin(2.0*phi))-mlnp);
						phi-=dphi;
						if (Math.abs(dphi)<=ProjConstants.EPSLN){
							lat=phi;
							break;
						}
					}
					
					//lat=phi4z(this.e,this.e0,this.e1,this.e2,this.e3,al,bl,0,0);
					cl=Math.sqrt(1-this.es*Math.pow(Math.sin(lat),2.0))*Math.tan(lat)
					lon=ProjConstants.adjust_lon(this.longZero+Math.asin(x*cl/this.a)/Math.sin(lat));
				}
			}
			
			p.x=lon;
			p.y=lat;
			return p;
		}
		
		
	}
}
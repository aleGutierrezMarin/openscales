package org.openscales.proj4as.proj {

	import org.openscales.proj4as.Datum;
	import org.openscales.proj4as.ProjConstants;
	import org.openscales.proj4as.ProjPoint;

	public class ProjAea extends AbstractProjProjection {
		public function ProjAea(data:ProjParams) {
			super(data);
		}

		override public function init():void {
			if (Math.abs(this.latOne + this.latTwo) < ProjConstants.EPSLN) {
				trace("aeaInitEqualLatitudes");
				return;
			}
			this.temp=this.b / this.a;
			this.es=1.0 - Math.pow(this.temp, 2);
			this.eThree=Math.sqrt(this.es);

			this.sin_po=Math.sin(this.latOne);
			this.cos_po=Math.cos(this.latOne);
			this.tOne=this.sin_po
			this.con=this.sin_po;
			this.msOne=ProjConstants.msfnz(this.eThree, this.sin_po, this.cos_po);
			this.qsOne=ProjConstants.qsfnz(this.eThree, this.sin_po, this.cos_po);

			this.sin_po=Math.sin(this.latTwo);
			this.cos_po=Math.cos(this.latTwo);
			this.tTwo=this.sin_po;
			
			if (this.sphere){
				if (Math.abs(this.latOne - this.latTwo) > ProjConstants.EPSLN) {
					this.nsZero=(this.tOne+this.tTwo)/2.0;
				} else {
					this.nsZero=this.tOne;
				}
				this.c=Math.pow(Math.cos(this.latOne),2.0)+2.0*this.nsZero*this.tOne;
				this.rh=this.a*Math.sqrt(this.c-2.0*this.nsZero*Math.sin(this.latZero))/this.nsZero;
			} else {
				this.msTwo=ProjConstants.msfnz(this.eThree, this.sin_po, this.cos_po);
				this.qsTwo=ProjConstants.qsfnz(this.eThree, this.sin_po, this.cos_po);
	
				this.sin_po=Math.sin(this.latZero);
				this.cos_po=Math.cos(this.latZero);
				this.tThree=this.sin_po;
				this.qsZero=ProjConstants.qsfnz(this.eThree, this.sin_po, this.cos_po);

				if (Math.abs(this.latOne - this.latTwo) > ProjConstants.EPSLN) {
					this.nsZero=(this.msOne * this.msOne - this.msTwo * this.msTwo) / (this.qsTwo - this.qsOne);
				} else {
					this.nsZero=this.con;
				}
				this.c=this.msOne * this.msOne + this.nsZero * this.qsOne;
				this.rh=this.a * Math.sqrt(this.c - this.nsZero * this.qsZero) / this.nsZero;
			}
		}

		/* Albers Conical Equal Area forward equations--mapping lat,long to x,y
		 -------------------------------------------------------------------*/
		override public function forward(p:ProjPoint):ProjPoint {
			var lon:Number=p.x;
			var lat:Number=p.y;

			this.sin_phi=Math.sin(lat);
			this.cos_phi=Math.cos(lat);
			
			var rh1:Number;
			var theta:Number;
			if (this.sphere){
				rh1=this.a*Math.sqrt(this.c-2.0*this.nsZero*Math.sin(lat))/this.nsZero;
			} else {
				var qs:Number=ProjConstants.qsfnz(this.eThree, this.sin_phi, this.cos_phi);
				rh1=this.a * Math.sqrt(this.c - this.nsZero * qs) / this.nsZero;
			}
			theta=this.nsZero * ProjConstants.adjust_lon(lon - this.longZero);
			var x:Number=rh1 * Math.sin(theta) + this.xZero;
			var y:Number=this.rh - rh1 * Math.cos(theta) + this.yZero;
			
			p.x=x;
			p.y=y;
			return p;

			
		}


		override public function inverse(p:ProjPoint):ProjPoint {
			var rh1:Number;
			var qs:Number;
			var con:Number;
			var theta:Number
			var lon:Number;
			var lat:Number;

			p.x-=this.xZero;
			p.y=this.rh - p.y + this.yZero;
			if (this.nsZero >= 0) {
				rh1=Math.sqrt(p.x * p.x + p.y * p.y);
				con=1.0;
			} else {
				rh1=-Math.sqrt(p.x * p.x + p.y * p.y);
				con=-1.0;
			}
			theta=0.0;
			if (rh1 != 0.0) {
				theta=Math.atan2(con * p.x, con * p.y);
			}
			con=rh1*this.nsZero/this.a;
			if (this.sphere){
				lat=Math.asin((this.c-con*con)/(2.0*this.nsZero));
			} else {
				qs=(this.c - con*con)/this.nsZero;
				lat= ProjConstants.iqsfnz(this.eThree, qs);
			}
			lon=ProjConstants.adjust_lon(theta / this.nsZero + this.longZero);
			p.x=lon;
			p.y=lat;
			return p;
		}

		/* Function to compute phi1, the latitude for the inverse of the
		   Albers Conical Equal-Area projection.
		 -------------------------------------------*/
		private function phi1z(eccent:Number, qs:Number):Number {
			var con:Number;
			var com:Number
			var dphi:Number;
			var phi:Number=ProjConstants.asinz(.5 * qs);
			if (eccent < ProjConstants.EPSLN)
				return phi;

			var eccnts:Number=eccent * eccent;
			for (var i:int=1; i <= 25; i++) {
				sinphi=Math.sin(phi);
				cosphi=Math.cos(phi);
				con=eccent * sinphi;
				com=1.0 - con * con;
				dphi=.5 * com * com / cosphi * (qs / (1.0 - eccnts) - sinphi / com + .5 / eccent * Math.log((1.0 - con) / (1.0 + con)));
				phi=phi + dphi;
				if (Math.abs(dphi) <= 1e-7)
					return phi;
			}
			trace("aea:phi1z:Convergence error");
			return 0;
		}


	}
}
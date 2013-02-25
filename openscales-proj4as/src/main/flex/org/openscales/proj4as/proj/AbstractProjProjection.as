package org.openscales.proj4as.proj {

	import org.openscales.proj4as.ProjPoint;

	/**
	 * Abtract projection that define most of variables used by projection implementations
	 */
	public class AbstractProjProjection extends ProjParams implements IProjection {
		protected var sinphi:Number;
		protected var cosphi:Number;
		protected var temp:Number;
		protected var eZero:Number;
		protected var eOne:Number;
		protected var eTwo:Number;
		protected var eThree:Number;
		protected var sin_po:Number;
		protected var cos_po:Number;
		protected var tOne:Number;
		protected var tTwo:Number;
		protected var tThree:Number;
		protected var con:Number;
		protected var msOne:Number;
		protected var msTwo:Number;
		protected var ns:Number;
		protected var nsZero:Number;
		protected var qsZero:Number;
		protected var qsOne:Number;
		protected var qsTwo:Number;
		protected var c:Number;
		protected var rh:Number;
		protected var cos_phi:Number;
		protected var sin_phi:Number;
		protected var g:Number;
		protected var ml:Number;
		protected var mlZero:Number;
		protected var mlOne:Number;
		protected var mlTwo:Number;
		protected var mode:int;

		protected var cos_pTwelve:Number;
		protected var sin_pTwelve:Number;

		protected var rc:Number;


		public function AbstractProjProjection(data:ProjParams) {
			this.extend(data);
		}

		public function init():void {

		}

		public function forward(p:ProjPoint):ProjPoint {
			return p;
		}

		public function inverse(p:ProjPoint):ProjPoint {
			return p;
		}

		protected function extend(source:ProjParams):void {

			this.title=source.title;
			this.projName=source.projName;
			this.units=source.units;
			this.datum=source.datum;
			this.datumCode=source.datumCode;
			this.datumName=source.datumName;
			this.nadgrids=source.nadgrids;
			this.ellps=source.ellps;
			this.a=source.a;
			this.b=source.b;
			this.aTwo=source.aTwo;
			this.bTwo=source.bTwo;
			this.e=source.e;
			this.es=source.es;
			this.epTwo=source.epTwo;
			this.rf=source.rf;
			this.longZero=source.longZero;
			this.longOne=source.longOne;
			this.longTwo=source.longTwo;
			this.latZero=source.latZero;
			this.latOne=source.latOne;
			this.latTwo=source.latTwo;
			this.lat_ts=source.lat_ts;
			this.alpha=source.alpha;
			this.longc=source.longc;
			this.xZero=source.xZero;
			this.yZero=source.yZero;
			this.kZero=source.kZero;
			this.k=source.k;
			this.R_A=source.R_A;
			this.zone=source.zone;
			this.utmSouth=source.utmSouth;
			this.to_meter=source.to_meter;
			this.from_greenwich=source.from_greenwich;
			this.datum_params=source.datum_params;
			this.sphere=source.sphere;
			this.ellipseName=source.ellipseName;
			this.no_rot=source.no_rot;
			this.no_off=source.no_off;

			this.srsCode=source.srsCode;
			this.srsAuth=source.srsAuth;
			this.srsProjNumber=source.srsProjNumber;

		}

	}



}
package org.openscales.proj4as {
	
	/**
	 * Proj4as main class, provide static methods to reproject points according to a specified 
	 * projection.
	 */
	public class Proj4as {

		static public const defaultDatum:String = 'WGS84';
		static public const WGS84:ProjProjection = new ProjProjection('WGS84');



		public function Proj4as() {
		}

		/**
		 * Reproject a point according to specified source and destination projections
		 * TODO : modify Proj4as in order to use return value OR inplace output parameter for reprojected point value 
		 * 
		 * @param source SRS code of the projection of the point passed as parameter
		 * @param dest SRS code of the destination projection to use for the transformation
		 * @param point point to reproject. Please notice that in current implementation, reprojected point is both
		 *        modified directly in the point parameter and provided as returned value
		 * @return the reprojected point
		 */
		public static function transform(source:ProjProjection, dest:ProjProjection, point:ProjPoint):ProjPoint {
			if (source == null || dest == null || point == null) {
				//trace("Parameters not created!");
				return null;
			}
			if(source == dest)
				return point;

			if (!source.readyToUse || !dest.readyToUse) {
				trace("Proj4as initialization for " + source.srsCode + " or " + dest.srsCode + " not yet complete");
				return point;
			}
			
			 
			 
			// Workaround for Spherical Mercator
			if ((source.srsProjNumber == "900913" && dest.datumCode != "WGS84") || (dest.srsProjNumber == "900913" && source.datumCode != "WGS84")) {
				var wgs84:ProjProjection = WGS84;
				transform(source, wgs84, point);
				source = wgs84;
			}

			// Transform source points to long/lat, if they aren't already.
			if (source.projName == "longlat") {
				point.x *= ProjConstants.D2R; // convert degrees to radians
				point.y *= ProjConstants.D2R;
			} else {
				if (source.to_meter) {
					point.x *= source.to_meter;
					point.y *= source.to_meter;
				}
				source.inverse(point); // Convert Cartesian to longlat
			}

			// Adjust for the prime meridian if necessary
			if (source.from_greenwich) {
				point.x += source.from_greenwich;
			}

			// Convert datums if needed, and if possible.
			point = datum_transform(source.datum, dest.datum, point);

			// Adjust for the prime meridian if necessary
			if (dest.from_greenwich) {
				point.x -= dest.from_greenwich;
			}

			if (dest.projName == "longlat") {
				// convert radians to decimal degrees
				point.x *= ProjConstants.R2D;
				point.y *= ProjConstants.R2D;
			} else { // else project
				dest.forward(point);
				if (dest.to_meter) {
					point.x /= dest.to_meter;
					point.y /= dest.to_meter;
				}
			}
			return point;
		}

		private static function datum_transform(source:Datum, dest:Datum, point:ProjPoint):ProjPoint {
			// Short cut if the datums are identical.
			if (source.compare_datums(dest)) {
				return point; // in this case, zero is sucess,
					// whereas cs_compare_datums returns 1 to indicate TRUE
					// confusing, should fix this
			}

			// Explicitly skip datum transform by setting 'datum=none' as parameter for either source or dest
			if (source.datum_type == ProjConstants.PJD_NODATUM || dest.datum_type == ProjConstants.PJD_NODATUM) {
				return point;
			}
            var src_a:Number = source.a;
            var src_es:Number = source.es;
            var dst_a:Number = dest.a;
            var dst_es:Number = dest.es;
                        
			var fallback:Number= source.datum_type;
			// If this datum requires grid shifts, then apply it to geodetic coordinates.
			if  (fallback == ProjConstants.PJD_GRIDSHIFT) {
				if (apply_gridshift(source, false, point )==0) {
					source.a = ProjConstants.SRS_WGS84_SEMIMAJOR;
					source.es = ProjConstants.SRS_WGS84_ESQUARED;
				} else {
					
					// try 3 or 7 params transformation or nothing ?
					if (!source.datum_params) {
						return point;
					}
					var wp:Number= 1.0;
					for (var i:Number= 0; i<source.datum_params.length; i++) {
						wp*= source.datum_params[i];
					}
					if (wp==0.0) {
						return point;
					}
					if (source.datum_params.length>3){
						fallback=ProjConstants.PJD_7PARAM;
					} else {
						fallback=ProjConstants.PJD_3PARAM;
					}
					 
					// CHECK_RETURN;
				}
			}

			if (dest.datum_type == ProjConstants.PJD_GRIDSHIFT) {
				dest.a = ProjConstants.SRS_WGS84_SEMIMAJOR;
				dest.es = ProjConstants.SRS_WGS84_ESQUARED;
			}

			// Do we need to go through geocentric coordinates?
			if (source.es != dest.es || source.a != dest.a || fallback == ProjConstants.PJD_3PARAM || fallback == ProjConstants.PJD_7PARAM || dest.datum_type == ProjConstants.PJD_3PARAM || dest.datum_type == ProjConstants.PJD_7PARAM) {

				// Convert to geocentric coordinates.
				source.geodetic_to_geocentric(point);
				// CHECK_RETURN;

				// Convert between datums
				if (source.datum_type == ProjConstants.PJD_3PARAM || source.datum_type == ProjConstants.PJD_7PARAM) {
					source.geocentric_to_wgs84(point);
						// CHECK_RETURN;
				}

				if (dest.datum_type == ProjConstants.PJD_3PARAM || dest.datum_type == ProjConstants.PJD_7PARAM) {
					dest.geocentric_from_wgs84(point);
						// CHECK_RETURN;
				}

				// Convert back to geodetic coordinates
				dest.geocentric_to_geodetic(point);
					// CHECK_RETURN;
			}

			// Apply grid shift to destination if required
			if (dest.datum_type == ProjConstants.PJD_GRIDSHIFT) {
					apply_gridshift( dest, true, point);
					// CHECK_RETURN;
			}
			return point;
		}

		/**
		 * Unit transformation according to source and destination projection. Implementation has been
		 * done pragmatically, so it basicaly works in OpenScales core use cases, but there may be some
		 * remaining issues. 
		 */
		
		public static function apply_gridshift(srs:Datum,inverse:Boolean,point:ProjPoint):Number{
			
			if (srs.grids==null || srs.grids.length==0) {
				return -38;
			}
			var input:Object= {"x":point.x, "y":point.y};
			var output:Object= {"x":Number.NaN, "y":Number.NaN};
			/* keep trying till we find a table that works */
			var onlyMandatoryGrids:Boolean= false;
			for (var i:Number= 0; i<srs.grids.length; i++) {
				var gi:Object= srs.grids[i];
				onlyMandatoryGrids= gi.mandatory;
				var ct:Object= gi.grid;
				if (ct==null) {
					if (gi.mandatory) {
						trace("unable to find '"+gi.name+"' grid.");
						return -48;
					}
					continue;//optional grid
				} 
				/* skip tables that don't match our point at all.  */
				var epsilon:Number= (Math.abs(ct.del[1])+Math.abs(ct.del[0]))/10000.0;
				if( ct.ll[1]-epsilon>input.y || ct.ll[0]-epsilon>input.x ||
					ct.ll[1]+(ct.lim[1]-1)*ct.del[1]+epsilon<input.y ||
					ct.ll[0]+(ct.lim[0]-1)*ct.del[0]+epsilon<input.x ) {
					continue;
				}
				
				output= ProjConstants.nad_cvt(input, inverse, ct);
				if (!isNaN(output.x)) {
					break;
				}
			}
			if (isNaN(output.x)) {
				if (!onlyMandatoryGrids) {
					trace("failed to find a grid shift table for location '"+
						input.x*ProjConstants.R2D+" "+input.y*ProjConstants.R2D+
						" tried: '"+srs.nadgrids+"'");
					return -48;
				}
				return -1;//FIXME: no shift applied ...
			}
			point.x= output.x;
			point.y= output.y;
			return 0;
			
		}
		public static function unit_transform(source:ProjProjection, dest:ProjProjection, value:Number):Number {
			if (source == null || dest == null || isNaN(value)) {
				//trace("Parameters not created!");
				return NaN;
			}

			if (source.projParams.units == dest.projParams.units) {
				//trace("Proj4s the projection are the same unit");
				return value;
			}
			// FixMe: how to transform the unit ? how to manage the difference of the two dimensions ?
			var resProj:ProjPoint = new ProjPoint(value, value);
			var origProj:ProjPoint = new ProjPoint(0, 0);
			resProj = Proj4as.transform(source, dest, resProj);
			origProj = Proj4as.transform(source, dest, origProj);
			var x2:Number = Math.pow(resProj.x - origProj.x, 2);
			var y2:Number = Math.pow(resProj.y - origProj.y, 2);
			var temp:Number = Math.sqrt((x2 + y2) / 2);
			return temp;
		}

	}
}

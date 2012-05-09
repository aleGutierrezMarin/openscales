package org.openscales.core.format
{
	import org.openscales.core.utils.Trace;
	import org.openscales.proj4as.ProjProjection;

	/**
	 * Base class for format reading/writing a variety of formats.
	 * Subclasses of Format are expected to have read and write methods.
	 */
	public class Format
	{
		
		protected var _internalProjection:ProjProjection = null;
		protected var _externalProjection:ProjProjection = null;
		
		public function Format() {
			// Nothing to do
		}
		
		public function read(data:Object):Object {
			Trace.warn("Read not implemented.");
			return null;
		}
		
		public function write(features:Object):Object {
			Trace.warn("Write not implemented.");
			return null;
		}
		
		public function get internalProjection():ProjProjection {
			return this._internalProjection;
		}
		
		public function set internalProjection(value:*):void {
			if(value is ProjProjection)
				this._internalProjection = value as ProjProjection;
			else if(value is String)
				this._internalProjection = ProjProjection.getProjProjection(value as String);
			else
				this._internalProjection = null;
		}
		
		public function get externalProjection():ProjProjection {
			return this._externalProjection;
		}
		
		public function set externalProjection(value:*):void {
			if(value is ProjProjection)
				this._externalProjection = value as ProjProjection;
			else if(value is String)
				this._externalProjection = ProjProjection.getProjProjection(value as String);
			else
				this._externalProjection = null;
		}
		
	}
}

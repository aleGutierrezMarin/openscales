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
		/**
		 *getter for internalProjection
		 * use setInternalProjection in order to set the projection
		 */
		public function get internalProjection():ProjProjection {
			return this._internalProjection;
		}
		
		/**
		 * Setter for internalProjection
		 * 
		 * It set the projection if it is a String or a ProjProjection, and it set the projection to
		 * null otherwise
		 * @param a String or a ProjProjection as an Object
		*/
		public function setInternalProjection(value:Object):void {
			if(value is ProjProjection)
				this._internalProjection = value as ProjProjection;
			else if(value is String)
				this._internalProjection = ProjProjection.getProjProjection(value as String);
			else
				this._internalProjection = null;
		}
		/**
		 * The external projection
		 * use setExternalProjection in order to set the projection
		 */
		public function get externalProjection():ProjProjection {
			return this._externalProjection;
		}
		/**
		 * Setter for externalProjection
		 * 
		 * It set the projection if it is a String or a ProjProjection, and it set the projection to
		 * null otherwise
		 * 
		 * @param a String or a ProjProjection as an Object
		 */	
		public function setExternalProjection(value:Object):void {
			if(value is ProjProjection)
				this._externalProjection = value as ProjProjection;
			else if(value is String)
				this._externalProjection = ProjProjection.getProjProjection(value as String);
			else
				this._externalProjection = null;
		}
		
	}
}

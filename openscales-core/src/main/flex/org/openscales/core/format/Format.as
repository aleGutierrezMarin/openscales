package org.openscales.core.format
{
	import org.openscales.core.utils.Trace;

	/**
	 * Base class for format reading/writing a variety of formats.
	 * Subclasses of Format are expected to have read and write methods.
	 */
	public class Format
	{
		
		protected var _internalProjection:String = null;
		protected var _externalProjection:String = null;
		
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
		
		public function get internalProjection():String {
			return this._internalProjection;
		}
		
		public function set internalProjection(value:String):void {
			this._internalProjection = value;
		}
		
		public function get externalProjection():String {
			return this._externalProjection;
		}
		
		public function set externalProjection(value:String):void {
			this._externalProjection = value;
		}
		
	}
}

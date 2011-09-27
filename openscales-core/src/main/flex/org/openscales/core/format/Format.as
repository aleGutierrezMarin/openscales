package org.openscales.core.format
{
	import org.openscales.core.utils.Trace;

	/**
	 * Base class for format reading/writing a variety of formats.
	 * Subclasses of Format are expected to have read and write methods.
	 */
	public class Format
	{
		
		protected var _internalProjSrsCode:String = null;
		protected var _externalProjSrsCode:String = null;
		
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
		
		public function get internalProjSrsCode():String {
			return this._internalProjSrsCode;
		}
		
		public function set internalProjSrsCode(value:String):void {
			this._internalProjSrsCode = value;
		}
		
		public function get externalProjSrsCode():String {
			return this._externalProjSrsCode;
		}
		
		public function set externalProjSrsCode(value:String):void {
			this._externalProjSrsCode = value;
		}
		
	}
}

package org.openscales.core.format
{
	import org.openscales.core.Trace;

	public class FilerEncodingFormat extends Format
	{
		public function FilerEncodingFormat()
		{
			super();
		}
		
		
		override public function read(data:Object):Object {
			Trace.warn("Read not implemented.");
			return null;
		}
		
		override public function write(features:Object):Object {
			Trace.warn("Write not implemented.");
			return null;
		}
		
		
	}
}
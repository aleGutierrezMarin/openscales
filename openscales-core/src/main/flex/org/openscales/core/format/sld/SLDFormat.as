package org.openscales.core.format.sld
{
	import org.openscales.core.style.Style;

	public class SLDFormat
	{
		public function SLDFormat()
		{
		}
		
		/**
		 * convert a sld xml to a list of style
		 */
		public function sldToStyles(sld:XML):Vector.<Style> {
			return null;
		}
		
		/**
		 * convert a list of style to a sld xml
		 */
		public function stylesToSld(styles:Vector.<Style>):XML {
			return null;
		}
		
		/**
		 * merge a list of style with a sld xml
		 */
		public function merge(styles:Vector.<Style>, sld:XML):XML {
			var result:XML = new XML(sld);
			var generated:XML = this.stylesToSld(styles);
			
			return result;
		}
	}
}
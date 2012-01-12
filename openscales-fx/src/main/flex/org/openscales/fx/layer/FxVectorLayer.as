package org.openscales.fx.layer
{
	import org.openscales.core.feature.Feature;
	import org.openscales.core.format.Format;
	import org.openscales.core.layer.VectorLayer;
	import org.openscales.core.style.Style;
	import org.openscales.proj4as.ProjProjection;
	
	/**
	 * <p>FeatureLayer Flex wrapper.</p>
	 * <p>To use it, declare a &lt;FeatureLayer /&gt; MXML component using xmlns="http://openscales.org"</p>
	 */
	public class FxVectorLayer extends FxLayer
	{
		public function FxVectorLayer() {
			super();
		}
		
		override public function init():void {
			this._layer = new VectorLayer(this._layerIdentifier);
		}
		
		public function get style():Style{
			return (this._layer as VectorLayer).style;
		}
		
		public function set style(value:Style):void{
			if (this._layer) {
				(this._layer as VectorLayer).style = value; 
			}
		}
		
		public function get features():Vector.<Feature>
		{
			if(this._layer != null)
				return (this._layer as VectorLayer).features;
			return null;
		}
		
		public function get data():XML{
			return (this._layer as VectorLayer).data;
		}
		
		public function set data(value:XML):void{
			(this._layer as VectorLayer).data = value;
		}
		
		public function get editable():Boolean{
			return (this._layer as VectorLayer).editable;
		}
		/*public function set editable(value:Boolean):void {
			if (this._layer) {
				(this._layer as VectorLayer).editable = value; 
			}
		}*/
		
		public function get edited():Boolean{
			return (this._layer as VectorLayer).edited;
		}
		
		/**
		 * Return the data of the layer in the specified format.
		 * Use the write method of the given format to return data
		 */
		public function getFormatExport(format:Format, extProj:ProjProjection):Object
		{
			return (this._layer as VectorLayer).getFormatExport(format, extProj);
		}
		
		/**
		 * Export the layer in the given Format and write it on the filesystem with the
		 * specified file name.
		 * Use the write method of the given format to write the file
		 */
		public function saveFormatExport(format:Format, fileName:String, extProj:ProjProjection):void
		{
			(this._layer as VectorLayer).saveFormatExport(format, fileName, extProj);
		}
	}		
}
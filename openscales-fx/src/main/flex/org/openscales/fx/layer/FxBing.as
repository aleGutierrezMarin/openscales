package org.openscales.fx.layer
{
	import org.openscales.core.layer.Bing;
	import org.openscales.core.layer.Layer;

	public class FxBing extends FxTMS
	{
		
		/**
		 * @private
		 * The layer identifier.  Any non-birdseye imageryType
		 * from http://msdn.microsoft.com/en-us/library/ff701716.aspx can be
		 * used.
		 * Default is "Road".
		 */
		private var _imagerySet:String = "Road";

		/**
		 * @private
		 * bing api key
		 */
		private var _key:String = null;
		
		/**
		 * Optional url parameters for the Get Imagery Metadata request
		 * as described here: http://msdn.microsoft.com/en-us/library/ff701716.aspx
		 */
		private var _metadataParams:String = null
		
		public function FxBing()
		{
			this._layer = null;
			super();
		}
		
		/**
		 * Bing api key
		 */
		public function get key():String
		{
			return _key;
		}
		
		/**
		 * @private
		 */
		public function set key(value:String):void
		{
			_key = value;
		}
		
		/**
		 * The layer identifier.  Any non-birdseye imageryType
		 * from http://msdn.microsoft.com/en-us/library/ff701716.aspx can be
		 * used.
		 * @default Road.
		 */
		public function get imagerySet():String
		{
			return _imagerySet;
		}
		/**
		 * @private
		 */
		public function set imagerySet(value:String):void
		{
			_imagerySet = value;
		}
		
		/**
		 * Optional url parameters for the Get Imagery Metadata request
		 * as described here: http://msdn.microsoft.com/en-us/library/ff701716.aspx
		 */
		public function get metadataParams():String
		{
			return _metadataParams;
		}
		/**
		 * @private
		 */
		public function set metadataParams(value:String):void
		{
			_metadataParams = value;
		}
		
		override public function configureLayer():Layer {
			this._layer = new Bing(this._key,this._imagerySet);
			(this._layer as Bing).metadataParams = this._metadataParams;
			return super.configureLayer();
		}
	}
}
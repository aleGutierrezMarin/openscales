package org.openscales.core.layer
{
	import org.openscales.core.feature.Feature;

	/**
	 * A simple VectorLayer used as an empty layer for drawings
	 */
	public class DrawingsLayer extends VectorLayer
	{
		public function DrawingsLayer(identifier:String = "")
		{
			super(identifier);
			this.editable = true;
			this.edited = true;
			this._initialized = true;
		}
		
		override public function addFeature(feature:Feature, dispatchFeatureEvent:Boolean=true, reproject:Boolean=true):void
		{
			if (this._initialized)
			{
				this.edited = true;
			}
			super.addFeature(feature, dispatchFeatureEvent, reproject);
		}
	}
}
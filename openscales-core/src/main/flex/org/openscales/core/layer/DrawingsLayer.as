package org.openscales.core.layer
{
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
		}
	}
}
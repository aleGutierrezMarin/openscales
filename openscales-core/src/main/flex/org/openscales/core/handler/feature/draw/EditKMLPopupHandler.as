package org.openscales.core.handler.feature.draw
{
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayCollection;
	
	import org.openscales.core.Map;
	import org.openscales.core.feature.Feature;
	import org.openscales.core.handler.Handler;
	import org.openscales.core.layer.VectorLayer;
	
	public class EditKMLPopupHandler extends Handler
	{
		
		/**
		 * Target layer of the handler.
		 * The handler will take effect only on this layer
		 */
		private var _drawLayer:VectorLayer = null;
		
		/**
		 * The feature clicked on 
		 */
		private var _feature:Feature;
		
		
		/**
		 * Flag that says if we are in style edition mode
		 */
		private var _onEditStyle:Boolean = false;
		
		/**
		 * URLS of the defaults icons to use in the style editor 
		 */
		private var _iconURLArray:ArrayCollection = new ArrayCollection(["http://openscales.org/img/pictos/openscalesCirclePicto.png",
			"http://openscales.org/img/pictos/openscalesCrossPicto.png",
			"http://openscales.org/img/pictos/openscalesDefaultPicto.png",
			"http://openscales.org/img/pictos/openscalesDiamondPicto.png"]);
		
		
		// Constructor
		public function EditKMLPopupHandler(map:Map=null, active:Boolean=false)
		{
			super(map, active);
		}
		
		public function saveFeatureAttributes(title:String, description:String):void {
			if(this._feature != null) {
				this._feature.attributes["title"] = title;
				this._feature.attributes["description"] = description;
			}
		}
		
		//Getter Setter
		
		/**
		 * The selected feature
		 */
		public function get selectedFeature():Feature
		{
			return this._feature;
		}
		
		/**
		 * The selected feature
		 */
		public function set selectedFeature(value:Feature):void
		{
			this._feature = value;
		}
		
		/**
		 * Target layer of the handler.
		 * The handler will take effect only on this layer
		 */
		public function get drawLayer():VectorLayer {
			return this._drawLayer;
		}
		
		/**
		 * @private
		 */
		public function set drawLayer(value:VectorLayer):void {
			this._drawLayer = value;
		}
		
		/**
		 * URLS of the defaults icons to use in the style editor 
		 */
		public function get iconURLArray():ArrayCollection
		{
			return this._iconURLArray;
		}
		
		/**
		 * @private
		 */
		public function set iconURLArray(value:ArrayCollection):void
		{
			this._iconURLArray = value;
		}
		
		public function get onEditStyle():Boolean
		{
			return this._onEditStyle;
		}
		
		public function set onEditStyle(value:Boolean):void
		{
			this._onEditStyle = value;
		}

	}
}
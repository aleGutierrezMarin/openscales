package org.openscales.core.handler.feature.draw
{
	import flash.events.MouseEvent;
	
	import org.openscales.core.Map;
	import org.openscales.core.basetypes.maps.HashMap;
	import org.openscales.core.feature.Feature;
	import org.openscales.core.feature.LineStringFeature;
	import org.openscales.core.feature.MultiLineStringFeature;
	import org.openscales.core.feature.MultiPointFeature;
	import org.openscales.core.feature.MultiPolygonFeature;
	import org.openscales.core.feature.PointFeature;
	import org.openscales.core.feature.PolygonFeature;
	import org.openscales.core.handler.Handler;
	import org.openscales.core.layer.VectorLayer;
	import org.openscales.core.style.Rule;
	import org.openscales.core.style.Style;
	
	public class EditKMLStyleHandler extends Handler
	{
		
		/**
		 * Target layer of the handler.
		 * The handler will take effect only on this layer
		 */
		private var _drawLayer:VectorLayer = null;
		
		/**
		 * Method that will be called for style edition passing the feature to edit
		 */
		private var _styleSelectionCallback:Function;
		
		/**
		 * Clone of the saved style that can be used to restore style
		 */
		private var _savedOriginStyle:Style;
		
		/**
		 * Change the preview mode. 
		 * It can be :
		 *  - "all" : on all the feature that shares the same style 
		 *  - "selected" : on the selected feature
		 *  - "typeselected" : on all the feature of the same type than the selected feature (Point, Polygon, Line)
		 * @default : all
		 */
		private var _targetFeatures:String = "all";
		
		/**
		 * Reference to the shared style
		 * Used to handle to targetFeature swtiching
		 */
		private var _referenceToSharedStyle:Style;
		
		/**
		 * Object that will store the features of their associated style on typeselected
		 * style edition
		 */
		private var _featuresStyleStorage:HashMap;
		
		/**
		 * The feature clicked on 
		 */
		private var _feature:Feature;
		
		
		// Constructor
		public function EditKMLStyleHandler(map:Map=null, active:Boolean=false)
		{
			super(map, active);
		}
		
		
		// Methods
		/**
		 * Apply the new style acording to preview mode
		 */
		public function applyNewStyle():void
		{
			
		}
		
		/**
		 * Change the preview mode. 
		 * It can be :
		 *  - "all" : on all the feature that shares the same style 
		 *  - "selected" : on the selected feature
		 *  - "typeselected" : on all the feature of the same type than the selected feature (Point, Polygon, Line)
		 * @default : all
		 */
		public function changePreviewMode(targetFeatures:String):void
		{
			if (targetFeatures == "all" || targetFeatures == "selected" || targetFeatures == "typeselected")
			{
				this._targetFeatures = targetFeatures;
			}
		}
		
		/**
		 * @inheritdoc
		 */
		override protected function registerListeners():void
		{
			if(this.map)
			{
				this.map.addEventListener(MouseEvent.MOUSE_DOWN, this.onMouseDown);
				if(this.map.stage)
					this.map.stage.addEventListener(MouseEvent.MOUSE_UP, this.onMouseUp);
			}
		}
		
		/**
		 * @inheritdoc
		 */
		override protected function unregisterListeners():void
		{
			if(this.map)
			{
				this.map.removeEventListener(MouseEvent.MOUSE_DOWN, this.onMouseDown);
				if(this.map.stage)
					this.map.stage.removeEventListener(MouseEvent.MOUSE_UP, this.onMouseUp);
			}
		}
		
		
		// Callback
		
		/**
		 * Revert all the changes made on the actual style
		 */
		public function cancelChanges():void
		{
			if (this._targetFeatures == "selected")
			{
				this._feature.style = _referenceToSharedStyle;
			}
			else if (this._targetFeatures == "all")
			{
				if(this._savedOriginStyle.rules != null){
					this._feature.style.rules  = this._savedOriginStyle.rules;
				}
			}
			else if (this._targetFeatures == "typeselected")
			{
				var keysArray:Array = this._featuresStyleStorage.getKeys();
				var keyArrayLength:Number = keysArray.length;
				for (var i:int = 0; i < keyArrayLength; ++i)
				{
					(keysArray[i] as Feature).style = this._featuresStyleStorage.getValue(keysArray[i]) as Style;
				}
			}
			this._referenceToSharedStyle = null;
			this._savedOriginStyle = null;
			this._featuresStyleStorage = new HashMap();
		}
		
		protected function onMouseDown(event:MouseEvent):void
		{
			if(event.target is Feature)
			{
				
			}
		}
		
		protected function onMouseUp(event:MouseEvent):void
		{
			if(event.target is Feature)
			{
				this._feature = event.target as Feature;
				
				if (this._feature.layer != this._drawLayer)
					return;
				
				this._savedOriginStyle = this._feature.style.clone();
				this._referenceToSharedStyle = this._feature.style;
				if (this._targetFeatures == "selected")
				{
					this._feature.style = this._feature.style.clone();
				}
				else if(this._targetFeatures == "typeselected")
				{
					var featureLength:Number;
					var i:int;
					this._featuresStyleStorage = new HashMap();
					if (this._feature is PointFeature || this._feature is MultiPointFeature)
					{
						featureLength = this._drawLayer.features.length;
						for ( i=0; i < featureLength; ++i)
						{
							if (this._drawLayer.features[i] is PointFeature || this._drawLayer.features[i] is MultiPointFeature)
							{
								this._featuresStyleStorage.put(this._drawLayer.features[i], this._drawLayer.features[i].style);
								this._drawLayer.features[i].style = this._feature.style;
							}
						}
					}
					if (this._feature is LineStringFeature || this._feature is MultiLineStringFeature)
					{
						featureLength = this._drawLayer.features.length;
						for ( i=0; i < featureLength; ++i)
						{
							if (this._drawLayer.features[i] is LineStringFeature || this._drawLayer.features[i] is MultiLineStringFeature)
							{
								this._featuresStyleStorage.put(this._drawLayer.features[i], this._drawLayer.features[i].style);
								this._drawLayer.features[i].style = this._feature.style;
							}
						}
					}
					if (this._feature is PolygonFeature || this._feature is MultiPolygonFeature)
					{
						featureLength = this._drawLayer.features.length;
						for ( i=0; i < featureLength; ++i)
						{
							if (this._drawLayer.features[i] is PolygonFeature || this._drawLayer.features[i] is MultiPolygonFeature)
							{
								this._featuresStyleStorage.put(this._drawLayer.features[i], this._drawLayer.features[i].style);
								this._drawLayer.features[i].style = this._feature.style;
							}
						}
					}
				}
				this.styleSelectionCallback(this._feature);
			}
		}
		
		//Getter Setter
		
		/**
		 * The preview mode. 
		 * It can be :
		 *  - "all" : on all the feature that shares the same style 
		 *  - "selected" : on the selected feature
		 *  - "typeselected" : on all the feature of the same type than the selected feature (Point, Polygon, Line)
		 * @default : all
		 * 
		 * If you whant to change this value, use changePreviewMode(String) method
		 */
		public function get targetFeatures():String
		{
			return this._targetFeatures;
		}
		
		/**
		 * Method that will be called for style edition passing the feature to edit
		 */
		public function get styleSelectionCallback():Function
		{
			return this._styleSelectionCallback;
		}
		
		/**
		 * @private
		 */
		public function set styleSelectionCallback(value:Function):void
		{
			this._styleSelectionCallback = value;	
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
		
		
	}
}
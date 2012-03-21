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
		
		/**
		 * Boolean that says if the style has been edited
		 */
		private var _styleChanged:Boolean = false;
		
		/**
		 * The default point style to apply to the features
		 */
		private var _defaultPointStyle:Style = Style.getDefaultPointStyle();
		
		/**
		 * The default line style to apply to the features
		 */
		private var _defaultLineStyle:Style = Style.getDefaultLineStyle();
		
		/**
		 * The default polygon style to apply to the features
		 */
		private var _defaultPolygonStyle:Style = Style.getDefaultPolygonStyle();
		
		
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
			if (targetFeatures == this._targetFeatures)
				return;
			var cloneStyle:Style;
			if (targetFeatures == "all" || targetFeatures == "selected" || targetFeatures == "typeselected")
			{
				if (this._targetFeatures == "all")
				{
					if (targetFeatures == "selected")
					{
						cloneStyle = this._feature.style.clone();
						if (this._savedOriginStyle && this._savedOriginStyle.rules && this._savedOriginStyle.rules[0])
						{
							this._feature.style.rules[0] = this._savedOriginStyle.rules[0].clone();
						}
						this.actualizeFeature();
						this.enableSelectedMode();
						this._feature.style = cloneStyle;
					}
					else if (targetFeatures == "typeselected")
					{
						this.enableTypeSelectedMode();
						this.actualizeFeature();
					}
				}
				if (this._targetFeatures == "selected")
				{
					if (targetFeatures == "all")
					{
						if (this._referenceToSharedStyle)
						{
							this._referenceToSharedStyle.rules[0] = this._feature.style.rules[0].clone();
							this._feature.style = this._referenceToSharedStyle;
						}
						this.actualizeFeature();
					}
					else if (targetFeatures == "typeselected")
					{
						if (this._referenceToSharedStyle)
						{
							this._referenceToSharedStyle.rules[0] = this._feature.style.rules[0].clone();
							this._feature.style = this._referenceToSharedStyle;
						}
						this.enableTypeSelectedMode();
						this.actualizeFeature();
						
					}
				}
				if (this._targetFeatures == "typeselected")
				{
					if (targetFeatures == "selected")
					{
						this.restoreTypeSelectedMode();
						cloneStyle = this._feature.style.clone();
						if (this._savedOriginStyle && this._savedOriginStyle.rules && this._savedOriginStyle.rules[0])
						{
							this._feature.style.rules[0] = this._savedOriginStyle.rules[0].clone();
						}
						this.actualizeFeature();
						this.enableSelectedMode();
						this._feature.style = cloneStyle;					
					}
					else if (targetFeatures == "all")
					{
						cloneStyle = this._savedOriginStyle;
						this.restoreTypeSelectedMode();
						this.enableAllMode();
						this._savedOriginStyle = cloneStyle;
						this.actualizeFeature();
					}
				}
				this._targetFeatures = targetFeatures;
				this.actualizeFeature();
			}
		}
		
		/**
		 * Apply the default style specified in  editKMLStyleHandler class to se selected preview mode
		 */
		public function applyDefaultStyle():void
		{
			var i:int;
			var featureLength:Number;
			this.validateChanges();
			if (this.targetFeatures == "selected")
			{
				if (this._feature is PointFeature || this._feature is MultiPointFeature)
					this._feature.style = this.defaultPointStyle;
				else if (this._feature is LineStringFeature || this._feature is MultiLineStringFeature)
					this._feature.style = this.defaultLineStyle;
				else if (this._feature is PolygonFeature || this._feature is MultiPolygonFeature)
					this._feature.style = this.defaultPolygonStyle;
				this._savedOriginStyle = this._feature.style.clone();
				this.enableSelectedMode();
			}
			else if(this.targetFeatures == "all")
			{
				var compStyle:Style = this._feature.style;
				featureLength = this.drawLayer.features.length;
				for (i = 0; i < featureLength; ++i)
				{
					if (this.drawLayer.features[i].style == compStyle)
					{
						if (this.drawLayer.features[i] is PointFeature || this.drawLayer.features[i] is MultiPointFeature)
							this.drawLayer.features[i].style = this.defaultPointStyle;
						else if (this.drawLayer.features[i] is LineStringFeature || this.drawLayer.features[i] is MultiLineStringFeature)
							this.drawLayer.features[i].style = this.defaultLineStyle;
						else if (this.drawLayer.features[i] is PolygonFeature || this.drawLayer.features[i] is MultiPolygonFeature)
							this.drawLayer.features[i].style = this.defaultPolygonStyle;
					}
				}
				this._savedOriginStyle = this._feature.style.clone();
				this.enableAllMode();
			}
			else if(this.targetFeatures == "typeselected")
			{
				var array:Array = this._featuresStyleStorage.getKeys();
				var arrayLength:Number = array.length;
				
				for (i = 0; i < arrayLength; ++i)
				{
					if (array[i] is PointFeature || array[i] is MultiPointFeature)
						(array[i] as Feature).style = this.defaultPointStyle;
					else if (array[i] is LineStringFeature || array[i] is MultiLineStringFeature)
						(array[i] as Feature).style = this.defaultLineStyle;
					else if (array[i] is PolygonFeature || array[i] is MultiPolygonFeature)
						(array[i] as Feature).style = this.defaultPolygonStyle;
				}
				this.enableTypeSelectedMode();
			}
			this.actualizeFeature();
			this._styleChanged = false;
			
			
		}
		
		/**
		 * Validate the style change
		 */
		public function validateChanges():void
		{
			if (!this._feature)
				return;
			
			if ((this._feature.style == this._defaultLineStyle||
				this._feature.style == this._defaultPointStyle ||
				this._feature.style == this._defaultPolygonStyle) && styleChanged)
			{
				var i:int;
				var featureLength:Number;
				var compStyle:Style = this._feature.style;
				var clonedStyle:Style = this._feature.style.clone();
				if (targetFeatures == "all")
				{
					featureLength = this.drawLayer.features.length;
					for (i = 0; i < featureLength; ++i)
					{
						if (this.drawLayer.features[i].style == compStyle)
						{
							this.drawLayer.features[i].style = clonedStyle;
						}
					}
				}
				else if(targetFeatures == "typeSelected")
				{
					var array:Array = this._featuresStyleStorage.getKeys();
					var arrayLength:Number = array.length;
					
					for (i = 0; i < arrayLength; ++i)
					{
						(array[i] as Feature).style= clonedStyle;
					}
				}
				compStyle.rules[0] = this._savedOriginStyle.rules[0].clone();
			}
			this._referenceToSharedStyle = null;
			this._savedOriginStyle = null;
		}
		
		/**
		 * Redraw the features according to the previewMode
		 */
		public function actualizeFeature():void
		{
			var i:int;
			var featureLength:Number;
			this._styleChanged = true;
			if (this._targetFeatures == "all")
			{
				featureLength = this.drawLayer.features.length;
				for (i = 0; i < featureLength; ++i)
				{
					if (this.drawLayer.features[i].style == this._feature.style)
					{
						this.drawLayer.features[i].draw();
					}
				}
			}
			else if (targetFeatures == "selected")
			{
				this._feature.draw();
				
			}
			else if (targetFeatures == "typeselected")
			{
				var array:Array = this._featuresStyleStorage.getKeys();
				var arrayLength:Number = array.length;
				
				for (i = 0; i < arrayLength; ++i)
				{
					(array[i] as Feature).draw();
				}
			}
		}
		
		/**
		 * Revert all the changes made on the actual style
		 */
		public function cancelChanges():void
		{
			if (this._targetFeatures == "selected")
			{
				this._feature.style = _referenceToSharedStyle;
				this._referenceToSharedStyle = null;
			}
			else if (this._targetFeatures == "all")
			{
				
				if(this._savedOriginStyle && this._savedOriginStyle.rules != null && this._savedOriginStyle.rules[0] != null){
					this._feature.style.rules[0]  = this._savedOriginStyle.rules[0].clone();
				}
			}
			else if (this._targetFeatures == "typeselected")
			{
				this.restoreTypeSelectedMode();
			}
			this.actualizeFeature();
			this._styleChanged = false;
		}
		
		
		/**
		 * @inheritdoc
		 */
		override protected function registerListeners():void
		{
			if(this.map)
			{
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
				if(this.map.stage)
					this.map.stage.removeEventListener(MouseEvent.MOUSE_UP, this.onMouseUp);
			}
		}
		
		/**
		 * Restores the styles of each features ont the typeSelectedMode
		 */
		private function restoreTypeSelectedMode():void
		{
			var keysArray:Array = this._featuresStyleStorage.getKeys();
			var keyArrayLength:Number = keysArray.length;
			for (var i:int = 0; i < keyArrayLength; ++i)
			{
				(keysArray[i] as Feature).style = this._featuresStyleStorage.getValue(keysArray[i]) as Style;
			}
		}
		
		/**
		 * Enable the selected Mode
		 */
		private function enableSelectedMode():void
		{
			this._referenceToSharedStyle = this._feature.style;
			this._feature.style = this._feature.style.clone();
		}
		
		/**
		 * Enable the type selected Mode
		 */
		private function enableTypeSelectedMode():void
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
		
		/**
		 * Enable the all mode
		 */
		private function enableAllMode():void
		{
			if (this._referenceToSharedStyle)
			{
				this._feature.style = this._referenceToSharedStyle;
			}
		}

		// Callback
		
		/**
		 * Callback for feature selection
		 */
		protected function onMouseUp(event:MouseEvent):void
		{
			if(event.target is Feature || event.target.parent is Feature)
			{
				this.validateChanges();
				if (event.target is Feature)
				{
					this._feature = event.target as Feature;
				}
				else
				{
					this._feature = event.target.parent as Feature;
				}
				
				if (this._feature.layer != this._drawLayer)
					return;
				
				this._savedOriginStyle = this._feature.style.clone();
				
				if (this._targetFeatures == "selected")
				{
					this.enableSelectedMode();
				}
				else if(this._targetFeatures == "typeselected")
				{
					this.enableTypeSelectedMode();
				}else
				{
					this.enableAllMode();
				}
				this.styleSelectionCallback(this._feature);
				this._styleChanged = false;
				
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
		
		/**
		 * Boolean that says if the style has been edited
		 */
		public function get styleChanged():Boolean
		{
			return this._styleChanged;
		}
		
		/**
		 * @private
		 */
		public function set styleChanged(value:Boolean):void
		{
			this._styleChanged = value;
		}
		
		/**
		 * The default point style to apply to the features
		 */
		public function get defaultPointStyle():Style
		{
			return this._defaultPointStyle;
		}
		
		/**
		 * @private
		 */
		public function set defaultPointStyle(value:Style):void
		{
			this._defaultPointStyle = value;
		}
		
		/**
		 * The default line style to apply to the features
		 */
		public function get defaultLineStyle():Style
		{
			return this._defaultLineStyle;
		}
		
		/**
		 * @private
		 */
		public function set defaultLineStyle(value:Style):void
		{
			this._defaultLineStyle = value;
		}
		
		/**
		 * The default polygon style to apply to the features
		 */
		public function get defaultPolygonStyle():Style
		{
			return this._defaultPolygonStyle;
		}
		
		/**
		 * @private
		 */
		public function set defaultPolygonStyle(value:Style):void
		{
			this._defaultPolygonStyle = value;
		}
	}
}
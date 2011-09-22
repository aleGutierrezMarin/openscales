package org.openscales.core.layer
{
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.utils.getQualifiedClassName;
	
	import org.openscales.core.Map;
	import org.openscales.core.basetypes.Resolution;
	import org.openscales.core.events.FeatureEvent;
	import org.openscales.core.events.LayerEvent;
	import org.openscales.core.events.MapEvent;
	import org.openscales.core.feature.Feature;
	import org.openscales.core.style.Style;
	import org.openscales.geometry.basetypes.Bounds;
	
	/**
	 * Layer that display features stored as child element
	 */
	public class VectorLayer extends Layer
	{
		/**
		 * The display projection defined by displayProjSrsCode is the
		 * projection of the features on the map.
		 * For performance reasons, the features of the layer are reprojected
		 * when they are added to the layer and not only for the display. 
		 */
		private var _displayProjSrsCode:String = null;
		
		private var _featuresBbox:Bounds = null;
		
		private var _style:Style = null;
		
		private var _geometryType:String = null;
		
		private var _selectedFeatures:Vector.<String> = null;
		
		private var _isInEditionMode:Boolean=false;
		
		private var _featuresID:Vector.<String> = new Vector.<String>();
		
		private var _data:XML = null;
		
		private var _idPoint:uint = 0;
		private var _idPath:uint = 0;
		private var _idPolygon:uint = 0;
		private var _idLabel:uint = 0;
		private var _attributesVal:Array = new Array();
		private var _attributesId:Array = new Array();

		public function VectorLayer(name:String)
		{
			super(name);
			this._displayProjSrsCode = this.projSrsCode;
			this.style = new Style();
			this.geometryType = null;
			this.selectedFeatures = new Vector.<String>();
			
			// By default no range defined for feature layers
			this.minResolution = new Resolution(0,this.projSrsCode);
			this.maxResolution = new Resolution(Infinity,this.projSrsCode);
			
			// Make drag smooth even with a lot of points
			this.cacheAsBitmap = true;
		}
		
		override public function get available():Boolean {
			return super.available;
		}
		
		override public function destroy():void {
			super.destroy();  
			this.reset();
			this._displayProjSrsCode = null;
			this.style = null;
			this.geometryType = null;
			this.selectedFeatures = null;
			this.featuresBbox = null;
		}
		
		override public function redraw(fullRedraw:Boolean = false	):void {
			if (this.map == null)
				return;
			
			this.clear();
			if(this.available && this.visible){
				this.draw();
			}
		}
		
		// Clear layer and children graphics
		override public function clear():void {
			var child:Sprite = null;
			var child2:Shape = null;
			var numChild:int = this.numChildren;
			var i:int;
			var j:int;
			var numChild2:int;
			for(i=0; i<numChild; ++i) {
				child = this.getChildAt(i) as Sprite;
				if (child) {
					child.graphics.clear();
					//Cleanup child subchildren (ex children of pointfeatures)
					numChild2 = child.numChildren;
					for(j=0; j<numChild2; ++j){
						child2 = child.getChildAt(j) as Shape;
						if (child2) {
							child2.graphics.clear();
						}
					}
				}
			}
			this.graphics.clear();
		}
		
		private function updateCurrentProjection(evt:MapEvent = null):void {
			if ((this.map) && (this._displayProjSrsCode != this.map.projection)) {
				if (this.features.length > 0) {	
					for each (var f:Feature in this.features) {
						f.geometry.transform(this._displayProjSrsCode, this.map.projection);
					}
					this._displayProjSrsCode = this.map.projection;
					this.redraw();
				} else {
					this._displayProjSrsCode = this.map.projection;
				}
			}
		}
		
		override public function set map(map:Map):void {
			if (this.map != null) {
				this.map.removeEventListener(MapEvent.PROJECTION_CHANGED, this.updateCurrentProjection);
			}
			super.map = map;
			if (this.map != null) {
				this.updateCurrentProjection();
				this.map.addEventListener(MapEvent.PROJECTION_CHANGED, this.updateCurrentProjection);
				// Ugly trick due to the fact we can't set the size of and empty Sprite
				this.graphics.drawRect(0,0,map.size.w,map.size.h);
				this.width = map.size.w;
				this.height = map.size.h;
			}
		}
		
		/**
		 * Add Features to the layer.
		 *
		 * @param features array
		 */
		public function addFeatures(features:Vector.<Feature>, reproject:Boolean=true):void {
			// Dispatch an event before the features are added
			var fevt:FeatureEvent = null;
			if (this.map) {
				fevt = new FeatureEvent(FeatureEvent.FEATURE_PRE_INSERT, null);
				fevt.features = features;
				this.map.dispatchEvent(fevt);
			}
			
			var i:int;
			var j:int = features.length
			for (i=0; i<j; i++) {
				this.addFeature(features[i], false, reproject);
			}
			
			// Dispatch an event with all the features added
			if (this.map) {
				fevt = new FeatureEvent(FeatureEvent.FEATURE_INSERT, null);
				fevt.features = features;
				this.map.dispatchEvent(fevt);
			}
		}
		
		/**
		 * Add Feature to the layer.
		 *
		 * @param feature The feature to add
		 */
		public function addFeature(feature:Feature, dispatchFeatureEvent:Boolean=true, reproject:Boolean=true):void {
			if (this._featuresID.indexOf(feature.name)!=-1) {
				return;
			}
			this._featuresID.push(feature.name);
			
			// Check if the feature may be added to this layer
			var vectorfeature:Feature = feature;
			
			if (this.geometryType &&
				(getQualifiedClassName(vectorfeature.geometry) != this.geometryType)) {
				var throwStr:String = "addFeatures : component should be an " + this.geometryType +"and it is : " + getQualifiedClassName(vectorfeature.geometry);
				throw throwStr;
			}
			
			// If needed dispatch a PRE_INSERT event before the feature is added
			var fevt:FeatureEvent = null;
			if (dispatchFeatureEvent && this.map) {
				fevt = new FeatureEvent(FeatureEvent.FEATURE_PRE_INSERT, feature);
				this.map.dispatchEvent(fevt);
			}
			
			// Reprojection if needed
			if (reproject && (this.map) && (this.projSrsCode != this._displayProjSrsCode)) {
				feature.geometry.transform(this.projSrsCode, this._displayProjSrsCode);
			}
			
			// Add the feature to the layer
			feature.layer = this;
			//test
			feature.x = -feature.layer.x;
			feature.y = -feature.layer.y;
			this.addChild(feature);
			// Reset the BBOX of the features
			this._featuresBbox = null;
			
			// Render the feature
			if (this.map) {
				feature.draw();
			}
			
			// If needed, dispatch an event with the feature added
			if (dispatchFeatureEvent && this.map) {
				fevt = new FeatureEvent(FeatureEvent.FEATURE_INSERT, feature);
				this.map.dispatchEvent(fevt);
			}
		}
		
		public function resetFeaturesPosition():void
		{
			var nbChildren:int = this.numChildren;
			var o:DisplayObject;
			for(var i:uint=0 ; i<nbChildren ; ++i) {
				o = this.getChildAt(i);
				if (o is Feature) {
					(o as Feature).x = 0;
					(o as Feature).y = 0;
				}
			}
		}
		
		override public function reset():void {
			var deleted:Boolean = false;
			this._featuresID = new Vector.<String>();
			var i:int = this.numChildren-1;
			for(i;i>-1;i--) {
				if(this.getChildAt(i) is Feature) {
					this.removeChildAt(i);
					deleted=true;
				}
			}
			if (deleted && this.map) {
				var fevt:FeatureEvent = new FeatureEvent(FeatureEvent.FEATURE_DELETING, null);
				fevt.features = features;
				this.map.dispatchEvent(fevt);
			}
			this._featuresBbox = null;
		}
		
		override protected function draw():void {
			var nbChildren:int = this.numChildren;
			var o:DisplayObject;
			for(var i:uint=0 ; i<nbChildren; ++i) {
				o = this.getChildAt(i);
				if (o is Feature) {
					(o as Feature).draw();
				}
			}
		}
		
		public function removeFeatures(features:Vector.<Feature>):void {
			var i:int = features.length-1;
			for (i; i > -1; --i)
				this.removeFeature(features[i], false);
			// Dispatch an event with all the features removed
			if (this.map) {
				var fevt:FeatureEvent = new FeatureEvent(FeatureEvent.FEATURE_DELETING, null);
				fevt.features = features;
				this.map.dispatchEvent(fevt);
			}
		}
		
		public function removeFeature(feature:Feature, dispatchFeatureEvent:Boolean=true):void {
			if (feature == null) {
				return;
			}
			var i:int = this._featuresID.indexOf(feature.name);
			if (i == -1) {
				return;
			}
			this._featuresID.splice(i,1);
			
			var j:int = this.numChildren;
			for(i=0; i<j; ++i) {
				if (this.getChildAt(i) == feature) {
					this.removeChildAt(i);
					break;
				}
			}
			i = this.selectedFeatures.indexOf(feature);
			if (i != -1){
				this.selectedFeatures.splice(i,1);
			}
			// If needed, dispatch an event with the feature added
			if (dispatchFeatureEvent && this.map) {
				var fevt:FeatureEvent = new FeatureEvent(FeatureEvent.FEATURE_DELETING, feature);
				this.map.dispatchEvent(fevt);
			}
			this._featuresBbox=null;
		}
		
		public function get featuresID():Vector.<String> {
			var _features:Vector.<String> = new Vector.<String>(this._featuresID.length);
			var i:uint = 0;
			var s:String;
			for each(s in this._featuresID) {
				_features[i]=s;
				++i;
			}
			return _features;
		}
		
		// Getters and setters
		public function get features():Vector.<Feature> {
			var _features:Vector.<Feature> = new Vector.<Feature>();
			var nbChildren:int = this.numChildren;
			var o:DisplayObject;
			for(var i:uint=0 ; i<nbChildren; ++i) {
				o = this.getChildAt(i);
				if (o is Feature) {
					_features.push(o);
				}
			}
			return _features;
		}
		
		private function computeFeaturesBbox():void {
			var features:Vector.<Feature> = this.features;
			var i:uint = features.length;
			if (i==0) {
				this._featuresBbox=null;
				return;
			}
			this._featuresBbox = features[0].geometry.bounds.clone();
			for(var j:uint=1; j<i; ++j) {
				var tmpBounds:Bounds = this._featuresBbox.extendFromBounds(features[j].geometry.bounds.clone());
				if (tmpBounds.projSrsCode != this._featuresBbox.projSrsCode)
				{
					tmpBounds = tmpBounds.reprojectTo(this._featuresBbox.projSrsCode);
				}
				this._featuresBbox = tmpBounds; 
			}
		}
		
		public function get featuresBbox():Bounds {
			if (this._featuresBbox==null) {
				this.computeFeaturesBbox();
			}
			return this._featuresBbox;
		}
		
		public function set featuresBbox(value:Bounds):void {
			this._featuresBbox = value;
		}
		
		public function get selectedFeatures():Vector.<String> {
			return this._selectedFeatures;
		}
		
		public function set selectedFeatures(value:Vector.<String>):void {
			this._selectedFeatures = value;
		}
		
		public function get style():Style {
			return this._style;
		}
		
		public function set style(value:Style):void {
			this._style = value;
			this.redraw(true);
		}
		
		public function get geometryType():String {
			return this._geometryType;
		}
		
		public function set geometryType(value:String):void {
			this._geometryType = value;
		}
		
		public function get inEditionMode():Boolean {
			return this._isInEditionMode;
		}
		
		public function set inEditionMode(value:Boolean):void {
			this._isInEditionMode = value;
		}
		
		override public function set projSrsCode(value:String):void {
			super.projSrsCode = value;
			this._displayProjSrsCode = this.projSrsCode;
			// TODO: Why changing the _displayProjSrsCode ? It is dependant on the baselayer's projection, not on the layer's projection.
			// But if true, shouldn't we call this.updateCurrentProjection(); ?
		}
		
		/**
		 * If the VectorLayer is made from locale source : the XML data 
		 */
		public function get data():XML
		{
			return _data;
		}
		
		public function set data(value:XML):void
		{
			_data = value;
		}
		
		/**
		 * 
		 */
		public function get idPoint():uint{
			return this._idPoint;
		}
		public function set idPoint(value:uint):void{
			this._idPoint = value;
		}
		
		/**
		 * 
		 */
		public function get idPath():uint{
			return this._idPath;
		}
		public function set idPath(value:uint):void{
			this._idPath = value;
		}
		
		/**
		 * 
		 */
		public function get idPolygon():uint{
			return this._idPolygon;
		}
		public function set idPolygon(value:uint):void{
			this._idPolygon = value;
		}
		
		/**
		 * 
		 */
		public function get idLabel():uint{
			return this._idLabel;
		}
		public function set idLabel(value:uint):void{
			this._idLabel = value;
		}
		
		public function get attributesId():Array{
			return this._attributesId;
		}
		public function set attributesId(value:Array):void{
			this._attributesId = value;
		}
		public function get attributesVal():Array{
			return this._attributesVal;
		}
		public function set attributesVal(value:Array):void{
			this._attributesVal = value;
		}
	}
}

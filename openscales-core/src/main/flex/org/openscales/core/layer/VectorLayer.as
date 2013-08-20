package org.openscales.core.layer
{
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.FileReference;
	import flash.utils.getQualifiedClassName;
	
	import org.openscales.core.Map;
	import org.openscales.core.basetypes.Resolution;
	import org.openscales.core.events.FeatureEvent;
	import org.openscales.core.events.LayerEvent;
	import org.openscales.core.events.MapEvent;
	import org.openscales.core.feature.Feature;
	import org.openscales.core.format.Format;
	import org.openscales.core.format.KMLFormat;
	import org.openscales.core.style.Style;
	import org.openscales.core.utils.Trace;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Pixel;
	import org.openscales.proj4as.ProjProjection;
	
	
	/** 
	 * @eventType org.openscales.core.events.FeatureEvent.FEATURE_PRE_INSERT
	 */ 
	[Event(name="openscales.feature.preinsert", type="org.openscales.core.events.FeatureEvent")]
	
	/** 
	 * @eventType org.openscales.core.events.FeatureEvent.FEATURE_INSERT
	 */ 
	[Event(name="openscales.feature.insert", type="org.openscales.core.events.FeatureEvent")]
	
	/** 
	 * @eventType org.openscales.core.events.FeatureEvent.FEATURE_DELETING
	 */ 
	[Event(name="openscales.feature.deleting", type="org.openscales.core.events.FeatureEvent")]
	
	
	
	
	/**
	 * Layer that display features stored as child element
	 */
	public class VectorLayer extends Layer
	{		
		/**
		 * The display projection defined by displayProjection is the
		 * projection of the features on the map.
		 * For performance reasons, the features of the layer are reprojected
		 * when they are added to the layer and not only for the display. 
		 */
		private var _displayProjection:ProjProjection = null;
		
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
		private var _attributesId:Vector.<String> = new Vector.<String>();
		private var _initInDrawingToolbar:Boolean = false;
		private var _initOutDrawingToolbar:Boolean = false;
		private var _editable:Boolean = false;
		private var _edited:Boolean = false;
		protected var _previousCenter:Location = null;
		private var _lastReloadedCenter:Location;
		private var _lastReloadedResolution:Resolution;
		
		protected var _previousResolution:Resolution = null;

		public function VectorLayer(identifier:String)
		{
			super(identifier);
			this._displayProjection = this.projection;
			this._style = new Style();
			this._geometryType = null;
			this._selectedFeatures = new Vector.<String>();
			
			// By default no range defined for feature layers
			this.minResolution = new Resolution(0,this.projection);
			this.maxResolution = new Resolution(Infinity,this.projection);
			
			// Make drag smooth even with a lot of points
			this.cacheAsBitmap = true;
		}
		
		override public function supportsProjection(compareProj:*):Boolean
		{
			//A Vector Layer is able to be reprojected in any projection. So, it supports all projections
			return true;
		}
		
		override public function destroy():void {
			super.destroy();  
			this.reset();
			this._displayProjection = null;
			this._style = null;
			this._geometryType = null;
			this._selectedFeatures = null;
			this._featuresBbox = null;
		}
		
		override public function redraw(fullRedraw:Boolean = false):void {
			
			if (this.map == null)
				return;
			
			if(this.aggregate){
				this.visible = this.aggregate.shouldIBeVisible(this,this.map.resolution);
			}
			
			
			if (!this.available || !this.visible)
			{
				this.clear();
				this._initialized = false;
				return;
			}
			
			var centerChangedCache:Boolean = this._centerChanged;
			var resolutionChangedCache:Boolean = this._resolutionChanged;
			var projectionChangedCache:Boolean = this._projectionChanged;
			var mapReloadCache:Boolean = this._mapReload;
			this._centerChanged = false;
			this._projectionChanged = false;
			this._resolutionChanged = false;
			this._mapReload = false;
			if (fullRedraw || mapReloadCache)
			{
				this.clear();
			}
			if (!this._initialized || fullRedraw || mapReloadCache)
			{
				this.x = 0;
				this.y = 0;
				this.scaleX = 1;
				this.scaleY = 1;
				this._lastReloadedCenter = this.map.center.clone();
				this._lastReloadedResolution = this.map.resolution;
				this.draw();
				this._previousResolution = this.map.resolution;
				this._previousCenter = this.map.center.clone();
				this._initialized = true;
				return;
			}
			
			if (resolutionChangedCache)
			{
				if (!this._previousResolution)
				{
					this._previousResolution = this.map.resolution;
				}
				this.cacheAsBitmap = false;
				var ratio:Number = this._previousResolution.value / this.map.resolution.value;
				this.scaleLayer(ratio, new Pixel(this.map.size.w/2, this.map.size.h/2));
				this._previousResolution = this.map.resolution;
				resolutionChangedCache = false;
				this.cacheAsBitmap = true;
			}
			
			if (centerChangedCache)
			{
				if (!this._previousCenter)
				{
					this._previousCenter = this.map.center.clone();
				}
				var deltaLon:Number = this.map.center.lon - this._previousCenter.lon;
				var deltaLat:Number = this.map.center.lat - this._previousCenter.lat;
				var deltaX:Number = deltaLon/this.map.resolution.value;
				var deltaY:Number = deltaLat/this.map.resolution.value;
				
				this.x = this.x - deltaX;
				this.y = this.y + deltaY;
				this._previousCenter = this.map.center.clone();
				centerChangedCache = false;
			}
		}
		
		
		/**
		 * Return a Pixel wich is the passed-in lonlat, translated into layer pixel.
		 */
		public function getLayerPxForLastReloadedStateFromLocation(loc:Location):Pixel{
			var extent:Bounds = null;
			var lonlat:Location;
			var res:Resolution;
			if (!map && this.map.projection)
				return null;
			if (this._lastReloadedCenter)
				lonlat = this._lastReloadedCenter.clone();
			else
				lonlat = this.map.center.clone();
			if (this._lastReloadedResolution)
				res = this._lastReloadedResolution;
			else
				res = this.map.resolution;
			if (lonlat != null) {
				if(lonlat.projection != this.map.projection)
					lonlat = lonlat.reprojectTo(this.map.projection);
				if (res != null && this.map.size)
				{
					if (res.projection != this.map.projection)
						res = res.reprojectTo(this.map.projection);
					
					var w_deg:Number = this.map.size.w * res.value;
					var h_deg:Number = this.map.size.h * res.value;
					
					extent = new Bounds(lonlat.lon - w_deg / 2,
						lonlat.lat - h_deg / 2,
						lonlat.lon + w_deg / 2,
						lonlat.lat + h_deg / 2,
						lonlat.projection);
				}
			}			
			var px:Pixel = null;
			px = new Pixel((loc.lon - extent.left) / res.value, (extent.top - loc.lat) / res.value);	
			return px;
			
			
		}
		
		/**
		 * @private
		 * 
		 * Scales this layer.
		 * 
		 * @param scale Coefficient (reltive to current scale) to which the layer will be scaled 
		 * @param offSet Pixel where the scaling should start ([0,0] by default)
		 */ 
		protected function scaleLayer(scale:Number, offSet:Pixel = null):void
		{
			if (offSet == null)
			{
				offSet = new Pixel(0, 0);
			}
			var temporaryScale:Number = this.scaleX * scale;
			this.scaleX = this.scaleY = temporaryScale;
			this.x -= (offSet.x - this.x) * (scale - 1);
			this.y -= (offSet.y - this.y) * (scale - 1);
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
			if ((this.map) && (this._displayProjection != this.map.projection)) {
				if (this.features && this.features.length > 0) {	
					for each (var f:Feature in this.features) {
						f.reprojectTo(this.map.projection);
					}
					this._displayProjection = this.map.projection;
					this.redraw();
				} else {
					this._displayProjection = this.map.projection;
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
			
			if (this.geometryType &&
				(getQualifiedClassName(feature.geometry) != this.geometryType)) {
				var throwStr:String = "addFeatures : component should be an " + this.geometryType +"and it is : " + getQualifiedClassName(feature.geometry);
				throw throwStr;
			}
			
			// If needed dispatch a PRE_INSERT event before the feature is added
			var fevt:FeatureEvent = null;
			if (dispatchFeatureEvent && this.map) {
				fevt = new FeatureEvent(FeatureEvent.FEATURE_PRE_INSERT, feature);
				this.map.dispatchEvent(fevt);
			}
			
			// Reprojection if needed
			if (reproject && (this.map) && (this.projection != this._displayProjection)) {
				feature.reprojectTo(this._displayProjection)
			}
			
			// Add the feature to the layer
			feature.layer = this;
			//test
			feature.x = -feature.layer.x;
			feature.y = -feature.layer.y;
			this.addChild(feature);
			// Reset the BBOX of the features
			this._featuresBbox = null;
			
			
			if(feature.attributes) {
				for (var key:String in feature.attributes) {
					var found:Boolean = false;
					for(var i:uint = this.attributesId.length; (i>0 && !found); --i)
						if(this.attributesId[i-1]==key)
							found = true;
					if(!found)
						this.attributesId.push(key);
				}
			}
			
			// Render the feature
			if (this.map && this.available) {
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
		/**
		 * The list of features contained by this layer
		 */ 
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
			if (!features)
			{
				this._featuresBbox=null;
				return;
			}
				
			var i:uint = features.length;
			if (i==0) {
				this._featuresBbox=null;
				return;
			}
			this._featuresBbox = features[0].geometry.bounds.clone();
			for(var j:uint=1; j<i; ++j) {
				var tmpBounds:Bounds = this._featuresBbox.extendFromBounds(features[j].geometry.bounds.clone());
				if (tmpBounds.projection != this._featuresBbox.projection)
				{
					tmpBounds = tmpBounds.reprojectTo(this._featuresBbox.projection);
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
		
		public function get attributesId():Vector.<String>{
			return this._attributesId;
		}
		public function set attributesId(value:Vector.<String>):void{
			this._attributesId = value;
		}
		
		public function get initInDrawingToolbar():Boolean{
			return this._initInDrawingToolbar;
		}
		public function set initInDrawingToolbar(value:Boolean):void{
			this._initInDrawingToolbar = value;
		}
		public function get initOutDrawingToolbar():Boolean{
			return this._initOutDrawingToolbar;
		}
		public function set initOutDrawingToolbar(value:Boolean):void{
			this._initOutDrawingToolbar = value;
		}
		public function get editable():Boolean{
			return _editable;
		}
		
		public function set editable(value:Boolean):void{
			_editable = value;
		}
		
		
		/**
		 * Boolean that describe if the layer have been modified using the drawing tools.
		 */
		public function get edited():Boolean
		{
			return this._edited;
		}
		
		/**
		 * @private
		 */
		public function set edited(value:Boolean):void
		{
			var bufferedValue:Boolean = this._edited;
			this._edited = value;
			if (value != bufferedValue && this.map)
			{
				var evt:LayerEvent = new LayerEvent(LayerEvent.LAYER_EDITED, this);
				evt.isEdited = value;
				this.map.dispatchEvent(evt);				
			}
		}
		
		
		/**
		 * Return the data of the layer in the specified format.
		 * Use the write method of the given format to return data
		 * The features will be exported in the given ProjProjection, 
		 * if no projProjection is specified the features will be exported in the layer Projection
		 */
		public function getFormatExport(format:Format, exProj:ProjProjection = null):Object
		{
			if (this.features.length == 0 && format is KMLFormat)
			{
				return (format as KMLFormat).writeEmptyKmlFil(this.displayedName);
			}
			if (!exProj)
			{
				return format.write(this.features);
			}
			else
			{
				var featuresLength:Number = this.features.length;
				var extFeatures:Vector.<Feature> = new Vector.<Feature>(featuresLength);
				for(var i:int = 0; i<featuresLength; ++i)
				{
					
					extFeatures[i]=this.features[i].clone();
					extFeatures[i].layer = this;
					extFeatures[i].attributes = this.features[i].attributes;
					//extFeatures[i].geometry.projection = this.projection;
					if (exProj != this.features[i].projection)
						extFeatures[i].geometry.transform(exProj);
				}
				var res:Object = format.write(extFeatures);
				for(i = 0; i<featuresLength; ++i)
					extFeatures.pop().destroy();
				return res;
			}
		}
		
		/**
		 * Export the layer in the given Format and write it on the filesystem with the
		 * specified file name.
		 * Use the write method of the given format to write the file
		 * The features will be exported in the given ProjProjection, 
		 * if no projProjection is specified the features will be exported in the layer Projection
		 */
		public function saveFormatExport(format:Format, fileName:String, exProj:ProjProjection = null):void
		{
			var datas:Object = this.getFormatExport(format, exProj);

			var fileReference:FileReference;
			//create the FileReference instance
			fileReference = new FileReference();
			
			//listen for the file has been saved
			fileReference.addEventListener(Event.COMPLETE, onFileSave);
			
			//listen for when then cancel out of the save dialog
			fileReference.addEventListener(Event.CANCEL,onCancel);
			
			//listen for any errors that occur while writing the file
			fileReference.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			
			//open a native save file dialog, using the default file name
			fileReference.save(datas, fileName);
		}
		
		/**
		 * called once the fihg sle has been saved
		 */
		private function onFileSave(e:Event):void
		{

		}
		
		/**
		 * called if the user cancels out of the file save dialog
		 */
		private function onCancel(e:Event):void
		{
		}
		
		/**
		 * called if an error occurs while saving the file
		 */
		private function onSaveError(e:IOErrorEvent):void
		{
			Trace.info("Error Saving File : " + e.text);
		}

		
	}
}

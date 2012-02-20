package org.openscales.fx.control.routing
{
	import flash.sampler.NewObjectSample;
	
	import mx.collections.ArrayCollection;
	
	import org.openscales.core.Map;
	import org.openscales.core.basetypes.linkedlist.LinkedList;
	import org.openscales.core.basetypes.linkedlist.LinkedListFeatureNode;
	import org.openscales.core.feature.Feature;
	import org.openscales.core.feature.LineStringFeature;
	import org.openscales.core.feature.PointFeature;
	import org.openscales.core.handler.IHandler;
	import org.openscales.core.layer.VectorLayer;
	import org.openscales.core.routing.RoutingEngine;
	import org.openscales.core.routing.result.RoutingResult;
	import org.openscales.core.style.Style;
	import org.openscales.fx.control.skin.DefaultRoutingSkin;
	import org.openscales.geometry.LineString;
	import org.openscales.geometry.basetypes.Location;
	
	import spark.components.supportClasses.SkinnableComponent;
	
	/**
	 * Routing control
	 * Skinnable component, default skin is DefaultRoutingSkin
	 */
	public class Routing extends SkinnableComponent implements IHandler
	{
		/**
		 * Arraycollection containing routing indications
		 */
		[SkinPart(required="true")]
		public var routingResult:ArrayCollection;
		
		private var _map:Map = null;
		private var _active:Boolean = true;
		private var _layer:VectorLayer = null;
		private var _instantRouting:Boolean = true;
		private var _pointFeatureList:Vector.<PointFeature>;
		private var _resultFeature:LineStringFeature;
		private var _routingEngine:RoutingEngine = null;
		
		public function Routing()
		{
			super();
			this._layer = new VectorLayer("");
			this._layer.displayInLayerManager = false;
			this._pointFeatureList = new Vector.<PointFeature>();
			setStyle("skinClass", DefaultRoutingSkin);
		}
		
		/**
		 * The map that is controlled by this handler
		 */
		public function get map():Map {
			return this._map;
		}
		/**
		 * @private
		 */
		public function set map(value:Map):void{
			if(this._map && this._active)
				this._map.removeLayer(this._layer);
			this._map = value;
			if(this._map && this._active)
				this._map.addLayer(this._layer);
		}
		/**
		 * Usually used to register or unregister event listeners
		 */
		public function get active():Boolean{
			return this._active;
		}
		/**
		 * @private
		 */
		public function set active(value:Boolean):void{
			if(this._map && this._active)
				this._map.removeLayer(this._layer);
			this._active = value;
			if(this._map && this._active)
				this._map.addLayer(this._layer);
		}
		/**
		 * indicates if the routing should be perform after each feature insertion
		 */
		public function get instantRouting():Boolean
		{
			return _instantRouting;
		}
		/**
		 * @private
		 */
		public function set instantRouting(value:Boolean):void
		{
			_instantRouting = value;
		}
		/**
		 * clear
		 */
		public function clear():void {
			var i:uint = this._pointFeatureList.length;
			for(;i>0;--i)
				this._pointFeatureList.pop();
			this._resultFeature.destroy();
			this._resultFeature = null;
			this._layer.reset();
		}
		/**
		 * add a feature
		 */
		public function addFeature(feature:PointFeature):void {
			this._pointFeatureList.push(feature);
			this._layer.addFeature(feature);
			if(this._instantRouting)
				this.computeRoute();
		}
		
		/**
		 * call routing engine
		 */
		public function computeRoute():void {
			if(!this._routingEngine)
				return;
			var i:uint = this._pointFeatureList.length;
			if(i<2)
				return;
			var j:uint = 0;
			var locs:Vector.<Location> = new Vector.<Location>();
			for(;j<i;++j)
				locs.push(this._pointFeatureList[j].lonlat.reprojectTo("EPSG:4326"));
			this._routingEngine.computeRoute(this.onResult,locs);
		}
		public function onResult(results:Vector.<RoutingResult>):void {
			if(this._resultFeature)
				this._layer.removeFeature(this._resultFeature);
			
			if(results.length>0) {
				var result:RoutingResult = results[0];
				this._resultFeature = new LineStringFeature(new LineString(new Vector.<Number>()),null,Style.getDefaultLineStyle());
				var i:uint = result.itinerary.length;
				var j:uint = 0;
				var loc:Location;
				for(;j<i;++j) {
					loc = result.itinerary[j].reprojectTo("EPSG:4326");
					this._resultFeature.lineString.components.push(loc.lon,loc.lat);
				}
				this._layer.addFeature(this._resultFeature);
			}
		}

		public function get routingEngine():RoutingEngine
		{
			return _routingEngine;
		}

		public function set routingEngine(value:RoutingEngine):void
		{
			_routingEngine = value;
		}

	}
}
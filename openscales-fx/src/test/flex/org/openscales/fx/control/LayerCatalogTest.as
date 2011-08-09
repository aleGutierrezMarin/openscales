package org.openscales.fx.control {
	import flash.events.Event;
	
	import mx.core.FlexGlobals;
	import mx.events.FlexEvent;
	
	import org.flexunit.asserts.*;
	import org.flexunit.async.Async;
	import org.openscales.core.layer.Layer;
	
	import spark.components.Application;
	
	public class LayerCatalogTest {
		
		public function LayerCatalogTest(){
			this._catalog = new LayerCatalog();
		}
		
		private var _catalog:LayerCatalog;
		
		private var _layers:Vector.<Layer>;
		
		[Before(async)]
		public function createLayerCatalog():void{
			// Given a layer catalog
			
			Async.proceedOnEvent(this,this._catalog,FlexEvent.CREATION_COMPLETE);
			(FlexGlobals.topLevelApplication as Application).addElement(this._catalog);
			
			// And this catalog has 3 layers
			this._layers = new Vector.<Layer>();
			this._layers.push(new Layer('Layer 1'));
			this._layers.push(new Layer('Layer 2'));
			this._layers.push(new Layer('Layer 3'));
			this._catalog.layers = this._layers;
		}
		
		[After]
		public function removeCatalog():void{
			if(FlexGlobals && FlexGlobals.topLevelApplication && (FlexGlobals.topLevelApplication is Application))
				(FlexGlobals.topLevelApplication as Application).removeElement(this._catalog);
		}
		
		/**
		 * Validates that all layers are being displayed :
		 * 
		 *  Given a LayerCatalog
		 *  And this catalog has 3 layers
		 *  Then all three layers are displayed
		 */
		[Test]
		public function shouldDisplayEveryLayerWhenNoFilterIsDefined():void{
			
			
			
			// Then all three layers are displayed
			displayedIteration : for each(var layer:Layer in this._catalog.layerList.dataProvider.toArray()){
				
				for each(var originalLayer:Layer in this._layers){
					
					if(originalLayer == layer){
						
						continue displayedIteration;
					}
				}
				
				fail('Layer not found in displayed layers' + layer);
			}
		}
		
		/**
		 * Validates that catalog displays only layers that match the filter :
		 * 
		 *  Given a LayerCatalog
		 *  And this catalog has 3 layers
		 *  When a filter is applied to the catalog
		 *  Then only layers matching the filter are displayed
		 */
		[Test]
		public function shouldFilterDisplayedLayersWhenFilterIsSet():void{
			
			// When a filter is applied to the catalog
			this._catalog.filter = function(layer:Layer):Boolean{
				
				return layer.name == 'Layer 2';
			};
			
			// Then all three layers are displayed
			assertEquals('Incorrect number of layers',1,this._catalog.layerList.dataProvider.length);
			assertEquals('Incorrect layer name','Layer 2',(this._catalog.layerList.dataProvider.getItemAt(0) as Layer).name);
		}
		
		/**
		 * Validates that catalog displays only that match the filter when a new list of layer is set to the catalog
		 * 
		 *  Given a LayerCatalog
		 *  And this catalog has 3 layers
		 *  And a filter is applied to the catalog
		 *  When a new list of layers is set
		 *  Then only layers matching the filter are displayed
		 */
		[Test]
		public function shouldFilterDisplayedLayersWhenLayersAreSet():void{
			
			// And a filter is applied to the catalog
			this._catalog.filter = function(layer:Layer):Boolean{
				
				return layer.name == 'Some layer';
			};
			
			// When a new list of layers is set
			var newLayers:Vector.<Layer> = new Vector.<Layer>();
			newLayers.push(new Layer('Some layer'));
			newLayers.push(new Layer('Another layer'));
			this._catalog.layers = newLayers;
			
			// Then only layers matching the filter are displayed
			//assertEquals('Incorrect number of layers',1,this._catalog.layerList.dataProvider.length);
			//assertEquals('Incorrect layer name','Some layer',(this._catalog.layerList.dataProvider.getItemAt(0) as Layer).name);
		}
	}
}
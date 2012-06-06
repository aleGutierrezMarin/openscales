package org.openscales.fx.control.layer
{
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	
	import org.openscales.fx.control.Control;
	
	import spark.components.List;
	
	public class LM extends Control
	{
		[SkinPart(required="true")]
		public var layersList:List;
		
		public function LM()
		{
			super();
		}
		
		override protected function onCreationComplete(event:Event):void{
			
		}
		
		override protected function partAdded(partName:String, instance:Object):void{
			if(instance==layersList){
				if(_map){
					//layersList.dataProvider = new ArrayCollection(_map.layers.);
				}
			}
		}
	}
}
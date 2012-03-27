package org.openscales.fx.configuration
{
	import mx.containers.Canvas;
	import mx.containers.Panel;
	import mx.core.IVisualElementContainer;
	
	import org.openscales.core.Map;
	import org.openscales.core.utils.Trace;
	import org.openscales.core.configuration.Configuration;
	import org.openscales.fx.FxMap;
	import org.openscales.fx.control.Control;
	import org.openscales.fx.control.FxControl;
	import org.openscales.fx.control.FxOverviewMap;
	import org.openscales.fx.control.Pan;
	import org.openscales.fx.control.Zoom;
	import org.openscales.fx.control.ZoomBox;
	import org.openscales.fx.control.layer.LayerManager;
	
	/**
	 * Extend default Configuration manager in order to be able to parse Flex specific components
	 * like Flex PanZoom components ...
	 */
	public class FxConfiguration extends Configuration
	{
		protected var _fxMap:FxMap;
		
		public function FxConfiguration(config:XML=null,fxMap:FxMap = null)
		{
			super(config);
			_fxMap = fxMap;
		}
		
		/**
		 * One this configuration manager has been added to a map, call this function to parse
		 * XML file previously defined (config setter) and configure the map.
		 */
		override public function configure():void {
			super.configure();
			this.middleFxConfigure();
			
		}
		
		/**
		 * Add Flex based controls to the FxMap, since a Flex component can't be displayed
		 * in a pure ActionScript Sprite based Map
		 */
		public function middleFxConfigure():void {
			
			for each (var xmlControl:XML in controls){
				var control:Control = parseFxControl(xmlControl);
				if(control != null){
					control.map = map;
					if(_fxMap) {
						_fxMap.addElement(control);
					} else {
						Trace.log("fxmap is null so does not add the control");
					} 
				}
			}                      
		}
		
		/**
		 * Parse Flex specific controls
		 */
		protected function parseFxControl(xmlNode:XML):Control {
			var control:Control = null;
			
			if(xmlNode.name() == "Pan"){
				var fxPan:Pan = new Pan();
				if(String(xmlNode.@id) != ""){
					fxPan.id = String(xmlNode.@id);
				}	 			
				if(String(xmlNode.@x) != ""){
					fxPan.x = Number(xmlNode.@x);
				}
				if(String(xmlNode.@y) != ""){
					fxPan.y = Number(xmlNode.@y);
				}
				if(String(xmlNode.@width) != ""){
					fxPan.width = Number(xmlNode.@width);
				}
				if(String(xmlNode.@height) != ""){
					fxPan.height = Number(xmlNode.@height);
				}
				control = fxPan;  
			}
				
			else if(xmlNode.name() == "Zoom"){
				var fxZoom:Zoom = new Zoom();
				if(String(xmlNode.@id) != ""){
					fxZoom.id = String(xmlNode.@id);
				}
				if(String(xmlNode.@x) != ""){
					fxZoom.x = Number(xmlNode.@x);
				}
				if(String(xmlNode.@y) != ""){
					fxZoom.y = Number(xmlNode.@y);
				}
				if(String(xmlNode.@width) != ""){
					fxZoom.width = Number(xmlNode.@width);
				}
				if(String(xmlNode.@height) != ""){
					fxZoom.height = Number(xmlNode.@height);
				}
				control = fxZoom;
			}
				
			else if(xmlNode.name() == "ZoomBox"){
				var fxZoomBox:ZoomBox = new ZoomBox();
				if(String(xmlNode.@id) != ""){
					fxZoomBox.id = String(xmlNode.@id);
				}
				if(String(xmlNode.@x) != ""){
					fxZoomBox.x = Number(xmlNode.@x);
				}
				if(String(xmlNode.@y) != ""){
					fxZoomBox.y = Number(xmlNode.@y);
				}
				if(String(xmlNode.@width) != ""){
					fxZoomBox.width = Number(xmlNode.@width);
				}
				if(String(xmlNode.@height) != ""){
					fxZoomBox.height = Number(xmlNode.@height);
				}
				control = fxZoomBox; 
			}
				
				//FIX ME : because asynchrone, we need to wait the creation complete on FXMap before setting the map		 					
			else if(xmlNode.name() == "Overview"){
				var fxOverview:FxOverviewMap = new FxOverviewMap();
				if(String(xmlNode.@id) != ""){
					fxOverview.id = String(xmlNode.@id);
				}
				if(String(xmlNode.@x) != ""){
					fxOverview.x = Number(xmlNode.@x);
				}
				if(String(xmlNode.@y) != ""){
					fxOverview.y = Number(xmlNode.@y);
				}
				if(String(xmlNode.@width) != ""){
					fxOverview.width = Number(xmlNode.@width);
				}
				if(String(xmlNode.@height) != ""){
					fxOverview.height = Number(xmlNode.@height);
				}
				control = fxOverview as Control;
			}  
				
				//FIX ME : because asynchrone, we need to wait the creation complete of the others flex component before setting the map		 					
			else if(xmlNode.name() == "LayerManager"){
				var fxLayerSwitcher:LayerManager = new LayerManager();
				if(String(xmlNode.@id) != ""){
					fxLayerSwitcher.id = String(xmlNode.@id);
				}
				if(String(xmlNode.@x) != ""){
					fxLayerSwitcher.x = Number(xmlNode.@x);
				}
				if(String(xmlNode.@y) != ""){
					fxLayerSwitcher.y = Number(xmlNode.@y);
				}
				if(String(xmlNode.@width) != ""){
					fxLayerSwitcher.width = Number(xmlNode.@width);
				}
				if(String(xmlNode.@height) != ""){
					fxLayerSwitcher.height = Number(xmlNode.@height);
				}
				control = fxLayerSwitcher;
				
			}
			return control;
		}
		
	}
}
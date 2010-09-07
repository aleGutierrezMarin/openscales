package org.openscales.fx.configuration
{
	import mx.containers.Canvas;
	import mx.containers.Panel;
	import mx.core.IVisualElementContainer;
	
	import org.openscales.component.control.Control;
	import org.openscales.component.control.OverviewMap;
	import org.openscales.component.control.Pan;
	import org.openscales.component.control.Zoom;
	import org.openscales.component.control.ZoomBox;
	import org.openscales.component.control.layer.LayerSwitcher;
	import org.openscales.core.Map;
	import org.openscales.core.Trace;
	import org.openscales.core.configuration.Configuration;

	public class FxConfiguration extends Configuration
	{
		
		public function FxConfiguration(config:XML=null)
		{
			super(config);
		}
		
		override public function configureMap(map:Map):void {
                  super.configureMap(map);
                  this.middleFxConfigureMap(map);
                  
        }
            
          public function middleFxConfigureMap(map:Map):void {
           
                  //add controls
                  for each (var xmlControl:XML in controls){
                        var control:Control = parseFxControl(xmlControl, map);
                        if(control != null){
                          control.map = map;
                          if(map.parent.parent && map.parent.parent as IVisualElementContainer) {
                              (map.parent.parent as IVisualElementContainer).addElement(control);
                          } else {
                              Trace.log("map.parent is null so does not add the control");
                          } 
                        }
                  }                      
            }
		
		protected function parseFxControl(xmlNode:XML, map:Map):Control {
		 	var control:Control = null;
		 					 					
	 		if(xmlNode.name() == "FxPan"){
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
	 			 		
	 		else if(xmlNode.name() == "FxZoom"){
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
	 		
	 		else if(xmlNode.name() == "FxZoomBox"){
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
	 		else if(xmlNode.name() == "FxOveriew"){
	 			var fxOverview:OverviewMap = new OverviewMap();
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
	 			control = fxOverview; 
	 		}  
	 		
			//FIX ME : because asynchrone, we need to wait the creation complete of the others flex component before setting the map		 					
	 		else if(xmlNode.name() == "FxLayerSwitcher"){
	 			var fxLayerSwitcher:LayerSwitcher = new LayerSwitcher();
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
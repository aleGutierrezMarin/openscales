package org.openscales.component.control.layer
{
	import flash.events.MouseEvent;
	import flash.utils.getQualifiedClassName;
	
	import mx.accessibility.ButtonAccImpl;
	import mx.binding.utils.BindingUtils;
	import mx.binding.utils.ChangeWatcher;
	import mx.controls.Image;
	import mx.core.ButtonAsset;
	import mx.core.IDataRenderer;
	import mx.core.IVisualElement;
	import mx.events.DragEvent;
	import mx.events.FlexEvent;
	import mx.events.PropertyChangeEvent;
	import mx.skins.halo.ButtonSkin;
	
	import org.openscales.basetypes.Bounds;
	import org.openscales.core.Map;
	import org.openscales.core.Trace;
	import org.openscales.core.events.LayerEvent;
	import org.openscales.core.layer.Layer;
	import org.openscales.core.layer.ogc.WFS;
	
	import spark.components.Button;
	import spark.components.CheckBox;
	import spark.components.Group;
	import spark.components.HGroup;
	import spark.components.HSlider;
	import spark.components.Label;
	import spark.components.List;
	import spark.components.RadioButton;
	import spark.components.RadioButtonGroup;
	import spark.components.VGroup;
	
	
	public class SingleLayerRenderer extends VGroup implements IDataRenderer
	{
		[Bindable]
		private var hasCapabilities:Boolean = false;
		
		[Bindable]
		[Embed(source="/assets/images/cross.swf")]
		private var _btnMouvement:Class;
		
		[Bindable]
		[Embed(source="/assets/images/ArrowUp.swf")]
		private var _btnUp:Class;
		
		[Bindable]
		[Embed(source="/assets/images/ArrowDown.swf")]
		private var _btnDown:Class;
		
		private var labelLayer:Label;
		private var _layer:Layer;
		
		private var overlayList:List = new List();
		private var ArrowUp:Image;
		private var ArrowDown:Image;
		private var deleteButton:Image;
		private var label:Label;
		private var opacityControl:HSlider;
		private var displayControl:Group;
		private var ls:LayerSwitcher = null;
		public function SingleLayerRenderer()
		{
			super();
			
			var _hgroup:HGroup = new HGroup();
			this.addElement(_hgroup);
			displayControl = new Group();
			displayControl.width = 100;
			_hgroup.addElement(displayControl);
			ArrowUp = new Image();
			ArrowUp.source = new _btnUp();
			ArrowUp.name = "ArrowUp";
			ArrowUp.buttonMode = true;
			//ArrowUp.click = this.changeLayerOrder(event)
			displayControl.addElement(ArrowUp);
			ArrowDown = new Image();
			ArrowDown.source = new _btnUp();
			ArrowDown.name = "ArrowUp";
			ArrowDown.buttonMode = true;
			//ArrowDown.click = this.changeLayerOrder(event)
			displayControl.addElement(ArrowDown);
			
			deleteButton = new Image();
			deleteButton.source = new _btnMouvement();
			deleteButton.width = 20;
			deleteButton.height = 10;
			deleteButton.buttonMode = true;
			//deleteButton.click = deleteLayer(event)
			displayControl.addElement(deleteButton);
			
			var grp:VGroup = new VGroup();
			_hgroup.addElement(grp);
			label = new Label();
			_hgroup.addElement(label);
			opacityControl = new HSlider();
			opacityControl.width = 100;
			opacityControl.height = 5;
			opacityControl.minimum = 0;
			opacityControl.maximum = 100;
			opacityControl.snapInterval = 0.5;
			//change="layerOpacity(event)"
			//liveDragging="true"
			//mouseDown="onDrag(event)"
			_hgroup.addElement(opacityControl);
			opacityControl.addEventListener(FlexEvent.UPDATE_COMPLETE,layerOpacity);
		}
		
		/**
		 * Get the layer that the List into the LayerSwitcher.mxml send to display it
		 *
		 * @return return the layer
		 */
		private function get layer():Layer {
			return this._layer;
		}
		
		private function get layerSwitcher():LayerSwitcher {
			if(this.ls!=null)
				return this.ls;
			if(this.parent
				&& this.parent.parent
				&& this.parent.parent.parent
				&& this.parent.parent.parent.parent
				&& this.parent.parent.parent.parent.parent
				&& this.parent.parent.parent.parent.parent.parent
				&& this.parent.parent.parent.parent.parent.parent.parent
				&& this.parent.parent.parent.parent.parent.parent.parent is LayerSwitcher) {
				this.ls = this.parent.parent.parent.parent.parent.parent.parent as LayerSwitcher;
			}
			return this.ls;
		}
		/**
		 * Change the layer visibility
		 *
		 * @param event Change event
		 */
		public function layerVisible(event:MouseEvent):void{
			layer.visible = !layer.visible;
			
			// If the layer was uncheck from the beggining, he hadn't load yet so we need
			// to redraw it to load it.
			if(layer.visible){
				layer.redraw();
			}
		} 
		
		/**
		 * Change the opacity of the layer
		 *
		 * @param event event send by a slide
		 */
		public function layerOpacity(event:Event):void
		{
			layer.alpha = (event.target as HSlider).value/100;
			if(layer.alpha == 0)
			{
				labelLayer.setStyle("color",0xA8A8A8);
			}
			else
			{
				labelLayer.setStyle("color",0x000000);
			}
		}
		
		/**
		 * Delete the layer on the map
		 *
		 * @param event Click event
		 */
		public function deleteLayer(event:MouseEvent):void {
			_layer.map.removeLayer(_layer);
		}
		
		
		public function inOutRange(event:LayerEvent):void {
			if(event.layer.isBaseLayer == false)
			{
				var component:IVisualElement = displayControl.getElementAt(0);
				if(component is CheckBox)
				{
					if(event.type == LayerEvent.LAYER_OUT_RANGE)
					{     
						(component as CheckBox).enabled = false;
					}
					else
					{
						(component as CheckBox).enabled = true;
						event.layer.visible = (component as CheckBox).selected; 
					}
				}
				
			}
		}
		
		/**
		 * Get the data
		 *
		 * @return value
		 */
		public function get data():Object {
			return _layer;
		}
		/**
		 * Set the data
		 *
		 * @param value
		 */
		public function set data(value:Object):void {
			_layer = value as Layer;
			
			if((_layer != null) && (displayControl != null))
			{
				_layer.map.addEventListener(LayerEvent.LAYER_IN_RANGE,inOutRange);
				_layer.map.addEventListener(LayerEvent.LAYER_OUT_RANGE,inOutRange);
				
				displayControl.removeAllElements();
				opacityControl.value = _layer.alpha*100;
				
				if(_layer.isBaseLayer == true)//if the layer is a base layer
				{
					ArrowUp.visible = false;
					ArrowUp.enabled = false;
					ArrowDown.visible = false;
					ArrowDown.enabled = false;
					var radioButton:RadioButton = new RadioButton();
					radioButton.id = this.layer.name;
					radioButton.percentHeight = 100;
					radioButton.percentWidth = 100;
					radioButton.label = _layer.name;
					radioButton.selected = _layer.visible;
					displayControl.addElement(radioButton);
					
				}
				else {
					labelLayer = new Label();
					labelLayer.text = this.layer.name;
					labelLayer.percentWidth = 100;
					displayControl.addElement(labelLayer);
					if(this.layerSwitcher!=null) {
						if(this.layerSwitcher.overlayArray.length<=1) {
							ArrowUp.enabled = false;
							ArrowUp.alpha = 0.3;
							ArrowDown.enabled = false;
							ArrowDown.alpha = 0.3;
							ArrowUp.removeEventListener(MouseEvent.CLICK,changeLayerOrder);
							ArrowDown.removeEventListener(MouseEvent.CLICK,changeLayerOrder);
						}
						else {
							ArrowUp.enabled = true;
							ArrowUp.alpha = 1;
							ArrowDown.enabled = true;
							ArrowDown.alpha = 1;
							ArrowUp.addEventListener(MouseEvent.CLICK,changeLayerOrder);
							ArrowDown.addEventListener(MouseEvent.CLICK,changeLayerOrder);
						}
					}
				}					
			}
		}
		
		/**
		 * Center the map on the layer
		 *
		 * @param event Click event
		 */
		private function setLayerExtent(event:MouseEvent):void
		{
			var bounds:Bounds = _layer.maxExtent;
			if (bounds != null) {
				_layer.map.zoomToExtent(bounds);
			}
		}
		
		private function onDrag(event:Event):void {
			event.stopPropagation();
		}
		
		public function changeLayerOrder(event:MouseEvent):void {
			var numBaseLayer:int = (this.parent.parent.parent.parent as LayerSwitcher).baseLayerArray.length;
			var numOverlays:int = (this.parent.parent.parent.parent as LayerSwitcher).overlayArray.length;
			
			if((event.currentTarget as Image).name == "ArrowUp") //if we drag and drop the layer down
			{
				if(this.layer.zindex+1 <= numBaseLayer+numOverlays-1)
				{
					this.layer.zindex = this.layer.zindex + 1;
				}  
			}
			if((event.currentTarget as Image).name == "ArrowDown")     //if we drag and drop the layer up
			{
				if(this.layer.zindex-1 > numBaseLayer-1)
				{
					this.layer.zindex = this.layer.zindex - 1;
				}
				
			} 
			this.layer.map.dispatchEvent(new LayerEvent(LayerEvent.LAYER_CHANGED,this.layer));
		}
	}
}
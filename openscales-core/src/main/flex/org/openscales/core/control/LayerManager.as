package org.openscales.core.control
{
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import org.openscales.core.Map;
	import org.openscales.core.control.ui.Arrow;
	import org.openscales.core.control.ui.Button;
	import org.openscales.core.control.ui.CheckBox;
	import org.openscales.core.control.ui.RadioButton;
	import org.openscales.core.control.ui.SliderHorizontal;
	import org.openscales.core.control.ui.SliderVertical;
	import org.openscales.core.events.LayerEvent;
	import org.openscales.core.events.LayerManagerEvent;
	import org.openscales.core.events.MapEvent;
	import org.openscales.core.layer.Layer;
	import org.openscales.geometry.basetypes.Pixel;
	

	/**
	 * Create a layerSwitcher that display all the layer load on the map
	 */
	public class LayerManager extends Control
	{

		private var _activeColor:uint = 0x00008B;
		private var _textColor:uint = 0xFFFFFF;
		private var _textOffset:int=35;

		private var _minimized:Boolean = true;

		private var _minimizeButton:Button = null;

		private var _maximizeButton:Button = null;

		private var _slideHorizontalTemp:SliderHorizontal = null;

		private var _slideVerticalTemp:SliderVertical = null;

		private var _percentageTextFieldTemp:TextField = null;

		private var _layerSwitcherState:String;

		[Embed(source="/assets/images/layer-switcher-maximize.png")]
		private var _layerSwitcherMaximizeImg:Class;

		[Embed(source="/assets/images/layer-switcher-minimize.png")]
		private var _layerSwitcherMinimizeImg:Class;

		/**
		 * LayerSwitcher constructor
		 *
		 * @param position
		 */
		public function LayerManager(position:Pixel = null) {
			super(position);

			this._minimizeButton = new Button("minimize", new _layerSwitcherMinimizeImg(), this.position.add(-18,0));
			this._maximizeButton = new Button("maximize", new _layerSwitcherMaximizeImg(), this.position.add(-18,0));
		}

		/**
		 * Hide the LayerSwitcher
		 */
		override public function destroy():void {

			this._minimizeButton.removeEventListener(MouseEvent.CLICK, minMaxButtonClick);
			this._maximizeButton.removeEventListener(MouseEvent.CLICK, minMaxButtonClick);
			this.map.removeEventListener(LayerEvent.LAYER_ADDED, this.layerUpdated);
			this.map.removeEventListener(LayerEvent.LAYER_CHANGED, this.layerUpdated);
			this.map.removeEventListener(LayerEvent.LAYER_REMOVED, this.layerUpdated);
			this.map.removeEventListener(LayerEvent.LAYER_CHANGED_ORDER, this.layerUpdated);
			this.map.removeEventListener(LayerEvent.LAYER_OPACITY_CHANGED, this.layerUpdated);
			this.map.removeEventListener(LayerEvent.LAYER_VISIBLE_CHANGED, this.layerUpdated);
			this.map.removeEventListener(LayerEvent.LAYER_DISPLAY_IN_LAYERMANAGER_CHANGED, this.layerUpdated);

			super.destroy();
		}

		/**
		 * Resize the map
		 *
		 * @param event MapEvent
		 */
		override public function resize(event:MapEvent):void {
			this.x = this.map.size.w/2;
			this.y = 0;

			super.resize(event);
		}


		/**
		 * Get the existing map
		 *
		 * @param map
		 */
		override public function set map(map:Map):void {
			super.map = map;

			this.x = this.map.size.w/2;
			this.y = 0;

			this._minimizeButton.addEventListener(MouseEvent.CLICK, minMaxButtonClick); 
			this._maximizeButton.addEventListener(MouseEvent.CLICK, minMaxButtonClick);


			this.map.addEventListener(LayerEvent.LAYER_ADDED, this.layerUpdated);
			this.map.addEventListener(LayerEvent.LAYER_CHANGED, this.layerUpdated);
			this.map.addEventListener(LayerEvent.LAYER_REMOVED, this.layerUpdated);
			this.map.addEventListener(LayerEvent.LAYER_CHANGED_ORDER, this.layerUpdated);
			this.map.addEventListener(LayerEvent.LAYER_OPACITY_CHANGED, this.layerUpdated);
			this.map.addEventListener(LayerEvent.LAYER_VISIBLE_CHANGED, this.layerUpdated);
			this.map.addEventListener(LayerEvent.LAYER_DISPLAY_IN_LAYERMANAGER_CHANGED, this.layerUpdated);
		}

		/**
		 * Show the LayerSwitcher
		 */
		override public function draw():void {
			super.draw();

			this._minimizeButton.x = this.position.add(-18,0).x;
			this._minimizeButton.y = this.position.add(-18,0).y;

			this._maximizeButton.x = this.position.add(-18,0).x;
			this._maximizeButton.y = this.position.add(-18,0).y;
			this.y=0;
			//if the layerswitcher is hide
			if(_minimized) {
				this.addChild(_maximizeButton);//button to show the layerswitcher
				this.alpha = 0.7;
				this._layerSwitcherState = "Close";

			} else { //draw the layerswitcher
				this.graphics.beginFill(this._activeColor);
				this.graphics.drawRoundRectComplex(this.position.x-200,this.position.y,200,300, 20, 0, 20, 0);
				this.graphics.endFill();
				this.alpha = 0.7;

				var titleFormat:TextFormat = new TextFormat();
				titleFormat.bold = true;
				titleFormat.size = 11;
				titleFormat.color = this._textColor;
				titleFormat.font = "Verdana";

				var contentFormat:TextFormat = new TextFormat();
				contentFormat.size = 11;
				contentFormat.color = this._textColor;
				contentFormat.font = "Verdana";
				
				var k:int;
				var l:int;
				var resultPercentage:int;
				var positionX:Number
				var y:uint = 0;
				
				// count overlays
				var oCount:Number = 0;
				
				var layerArray:Vector.<Layer> = this.map.layers;
				var i:int=layerArray.length-1;
				var layer:Layer;
				for(i;i>=0;--i) {
					layer = layerArray[i];
					if(!layer.isFixed) {
						oCount++;
					}
				}
				if (oCount > 0)	{
					var overlayTextField:TextField = new TextField();
					overlayTextField.text="Layers";
					overlayTextField.setTextFormat(titleFormat);
					overlayTextField.x = this.position.x - 180;
					overlayTextField.y = y;
					overlayTextField.width = 80;
					overlayTextField.height = 50;
					this.addChild(overlayTextField);
				}
				
				// Display overlays
				i=layerArray.length-1;
				var layerTextField:TextField;
				var first:Boolean=false;
				for(i;i>=0;--i) {
					layer = layerArray[i];
					if(!layer.isFixed && layer.displayInLayerManager) {
						if(first)
						{
							y+=this._textOffset-25;
							first = false;
						}
						else
						{
							y+=this._textOffset+5;
						}
						layerTextField = new TextField();
						layerTextField.text=layer.displayedName;
						layerTextField.setTextFormat(contentFormat);
						layerTextField.x = this.position.x - 170;
						layerTextField.y = y;
						layerTextField.height = 20;
						layerTextField.width = 120;

						var percentageTextField:TextField = new TextField();
						percentageTextField.name = "percentage"+i;
						percentageTextField.setTextFormat(contentFormat);
						percentageTextField.x = this.position.x - 45;
						percentageTextField.y = y+22;
						percentageTextField.height = 20;
						percentageTextField.width = 50;

						var slideHorizontalButtonO:SliderHorizontal = new SliderHorizontal("slide horizontal"+i,this.position.add(-130,y+23),layer.displayedName);
						var slideVerticalButtonO:SliderVertical = new SliderVertical("slide vertical"+i,this.position.add(-55,y+26),layer.displayedName);

						if(layer.alpha == 1)
						{
							percentageTextField.text="100%";							
						}
						else
						{
							k = slideHorizontalButtonO.x+1;
							l = k+(slideHorizontalButtonO.width)-1;					
							positionX = ((l-k)*(layer.alpha)) + k;
							resultPercentage = (layer.alpha)*100;

							slideVerticalButtonO.x = positionX;
							percentageTextField.text=resultPercentage.toString()+"%";
						}
						slideVerticalButtonO.width = 5;
						percentageTextField.textColor = 0xffffff;
						slideVerticalButtonO.addEventListener(MouseEvent.MOUSE_DOWN,SlideMouseClick);
						slideHorizontalButtonO.addEventListener(MouseEvent.CLICK,SlideHorizontalClick);

						var check:CheckBox = new CheckBox(this.position.add(-185,y+2),layer.displayedName);
						if(!layer.visible)
						{							
							check.status = false;					
						}
						check.width=12;
						check.height=12;
						check.addEventListener(MouseEvent.CLICK,CheckButtonClick);	

						var arrowUpO:Arrow = new Arrow(this.position.add(-175,y+23),layer.displayedName,"UP")
						var arrowDownO:Arrow = new Arrow(this.position.add(-174,y+31),layer.displayedName,"DOWN")
						arrowUpO.height=7;
						arrowDownO.height=7;
						arrowUpO.addEventListener(MouseEvent.CLICK,ArrowClick);
						arrowDownO.addEventListener(MouseEvent.CLICK,ArrowClick);


						this.addChild(slideHorizontalButtonO);	
						this.addChild(slideVerticalButtonO);	
						this.addChild(check);
						this.addChild(layerTextField);
						this.addChild(percentageTextField);
						this.addChild(arrowUpO);
						this.addChild(arrowDownO);

					}
				} 
				if(this._layerSwitcherState == "Close")//add a tween effect
				{
					this.alpha = 0.7;
					this._layerSwitcherState = "Open";
				}

				this.addEventListener(MouseEvent.MOUSE_DOWN,layerswitcherStopPropagation);
				this.addChild(_minimizeButton);
			}
			
			if(this.stage) this.stage.focus = this.map;

		}

		/**
		 * Refresh the layerswitcher when a layer is add, remove or update
		 *
		 * @param event LayerEvent
		 */
		private function layerUpdated(event:LayerEvent):void {
			if (event.type == LayerEvent.LAYER_REMOVED) {
				event.layer.destroy();
			}
			this.draw();
		}

		/**
		 * Hide or Show the layerswitcher
		 *
		 * @param event MouseEvent
		 */
		private function minMaxButtonClick(event:MouseEvent):void 
		{
			this.minimized = !this.minimized;
		}
		
		public function set minimized(value:Boolean):void
		{
			this._minimized = value;
			this.draw();
			var evt:MapEvent = new MapEvent(MapEvent.COMPONENT_CHANGED, this._map);
			evt.componentName = "LayerManager";
			evt.componentIconified = this._minimized;
			this.map.dispatchEvent(evt);
		}
		
		public function get minimized():Boolean
		{
			return this._minimized;	
		}

		/**
		 * Change overlays visibility
		 *
		 * @param event MouseEvent send by a checkbox
		 */
		private function CheckButtonClick(event:MouseEvent):void
		{
			var eventLayer:Layer = this.map.getLayerByIdentifier((event.target as CheckBox).layerName);
			if((event.target as CheckBox).status)
			{
				(event.target as CheckBox).status = false;
				eventLayer.visible = false;
			}
			else
			{
				(event.target as CheckBox).status = true;
				eventLayer.visible = true;
				eventLayer.redraw();
			}
		}

		/**
		 * Change the layer opacity and animate the slider
		 *
		 * @param event MouseEvent send by the horizontal Slider
		 */
		private function SlideHorizontalClick(event:MouseEvent):void
		{					
			var childIndex:String = (event.target as Button).name;
			childIndex = childIndex.substring(16,17);

			_slideHorizontalTemp = (event.target as SliderHorizontal);
			_slideVerticalTemp = (this.getChildByName("slide vertical"+childIndex)) as SliderVertical;

			var k:int = _slideHorizontalTemp.x+1;
			var l:int = k+(_slideHorizontalTemp.width)-1;

			//change the position of the vertical Slide to the click do by the user
			_slideVerticalTemp.x = mouseX;

			//calulate the layer opacity
			var resultAlpha:Number = (mouseX/(l-k)) - (k/(l-k))
			var resultPercentage:int = resultAlpha*100;
			var eventLayer:Layer = this.map.getLayerByIdentifier(_slideVerticalTemp.layerName);
			eventLayer.alpha = resultAlpha;

			_percentageTextFieldTemp = this.getChildByName("percentage"+childIndex) as TextField;
			_percentageTextFieldTemp.textColor = 0xffffff;
			_percentageTextFieldTemp.text = resultPercentage.toString()+"%";

			// Stop propagation in order to avoid map move
			event.stopPropagation();

		}

		/**
		 * Active a move event
		 *
		 * @param event MouseEvent send by the vertical Slider
		 */
		private function SlideMouseClick(event:MouseEvent):void
		{		
			var childIndex:String = (event.target as Button).name;
			childIndex = childIndex.substring(14,15);

			_slideVerticalTemp = (event.target as SliderVertical);
			_slideHorizontalTemp = (this.getChildByName("slide horizontal"+childIndex)) as SliderHorizontal;

			_slideHorizontalTemp.addEventListener(MouseEvent.MOUSE_MOVE,SlideMouseMove);
			this.map.addEventListener(MouseEvent.MOUSE_UP,SlideMouseUp);

			// Stop propagation in order to avoid map move
			event.stopPropagation();

		}


		/**
		 * Change the layer opacity and animate the slider
		 *
		 * @param event MouseEvent send by the vertical Slider
		 */
		private function SlideMouseMove(event:MouseEvent):void
		{			
			var k:int = _slideHorizontalTemp.x+1;
			var l:int = k+(_slideHorizontalTemp.width)-1;
			_slideVerticalTemp.x = mouseX; 

			var resultAlpha:Number = (mouseX/(l-k)) - (k/(l-k))
			var resultPercentage:int = resultAlpha*100;
			var eventLayer:Layer = this.map.getLayerByIdentifier(_slideVerticalTemp.layerName);
			eventLayer.alpha = resultAlpha;

			var childIndex:String = _slideVerticalTemp.name;
			childIndex = childIndex.substring(14,15);
			_percentageTextFieldTemp = this.getChildByName("percentage"+childIndex) as TextField;
			_percentageTextFieldTemp.textColor = 0xffffff;
			_percentageTextFieldTemp.text = resultPercentage.toString()+"%";


			// Stop propagation in order to avoid map move
			event.stopPropagation();


		}

		/**
		 * stop the move event
		 *
		 * @param event MouseEvent send by the vertical Slider
		 */
		private function SlideMouseUp(event:MouseEvent):void
		{
			_slideHorizontalTemp.removeEventListener(MouseEvent.MOUSE_MOVE,SlideMouseMove);
			this.map.removeEventListener(MouseEvent.MOUSE_UP,SlideMouseUp);
		}

		/**
		 * Change the layer order
		 *
		 * @param event MouseEvent send by an arrow
		 */
		private function ArrowClick(event:MouseEvent):void
		{
			var layer:Layer = this.map.getLayerByIdentifier((event.target as Arrow).layerName);
			var numLayersOverlays:int = 0;

			//count of layers
			for(var i:int=0;i<this.map.layers.length;i++)
			{
				var layerLength:Layer = this.map.layers[i] as Layer;
				numLayersOverlays++;
			}

			var numBaseLayer:int = this.map.layers.length - numLayersOverlays;

			if((event.target as Arrow).state == "DOWN")//test the arrow clicked
			{
				if((layer.zindex-1)>numBaseLayer - 1)
				{
					layer.zindex = layer.zindex-1;
					this._map.dispatchEvent(new LayerEvent(LayerEvent.LAYER_MOVED_DOWN,layer));
				}	
			}
			else
			{
				if((layer.zindex+1)<=(this.map.layers.length-1))
				{
					layer.zindex = layer.zindex+1;
					this._map.dispatchEvent(new LayerEvent(LayerEvent.LAYER_MOVED_UP,layer));
				}	
			}
			this.draw();//refresh the layerswitcher
		}


		/**
		 * stop the propagation of the event which allow pannning the map
		 *
		 * @param event Click event
		 */
		private function layerswitcherStopPropagation(event:MouseEvent):void
		{
			event.stopPropagation();
		}

	}
}


package org.openscales.core.control
{
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import org.openscales.core.Map;
	import org.openscales.geometry.basetypes.Pixel;
	import org.openscales.geometry.basetypes.Size;
	import org.openscales.core.control.ui.Button;
	
	/**
	 * Control showing some arrows to be able to pan the map and zoom in/out.
	 * This Zoom class represents a component to add to the map.
	 * 
	 * @example The following code describe how to add a Zoom on a map : 
	 * 
	 * <listing version="3.0">
	 *   var theMap = Map();
	 *   theMap.addControl(new Zoom());
	 * </listing>
	 * 
	 * @author ajard
	 */
	public class Zoom extends Control
	{
		
		private var _slideFactor:int = 50;
		
		/**
		 * @private
		 * The list of buttons of this pan component
		 * @default 50
		 */
		private var _buttons:Vector.<Button> = null;
		
		[Embed(source="/assets/images/zoom-plus-mini.png")]
		protected var zoomPlusMiniImg:Class;
		
		[Embed(source="/assets/images/zoom-minus-mini.png")]
		protected var zoomMinusMiniImg:Class;
		
		[Embed(source="/assets/images/zoom-world-mini.png")]
		protected var zoomWorldMiniImg:Class;
		
		[Embed(source="/assets/images/slider.png")]
		protected var sliderImg:Class;
		
		[Embed(source="/assets/images/zoombar.png")]
		protected var zoombarImg:Class;
		
		public function Zoom(position:Pixel = null)
		{
			super(position);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function destroy():void {
			super.destroy();
			while(this.buttons.length) {
				var btn:Button = this.buttons.shift();
				btn.removeEventListener(MouseEvent.CLICK, this.click);
				btn.removeEventListener(MouseEvent.DOUBLE_CLICK, this.doubleClick);
			}
			this.buttons = null;
			this.position = null;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function draw():void {
			super.draw();
			
			var px:Pixel = this.position;
			
			// place the controls
			this.buttons = new Vector.<Button>();
			
			var sz:Size = new Size(18,18);
			
			var centered:Pixel = new Pixel(this.x+sz.w/2, this.y);
			px.y = centered.y+sz.h;
			this.addButton("zoomin", new zoomPlusMiniImg(), centered.add(0, sz.h*3+5), sz);
			this.addButton("zoomworld", new zoomWorldMiniImg(), centered.add(0, sz.h*4+5), sz);
			this.addButton("zoomout", new zoomMinusMiniImg(), centered.add(0, sz.h*5+5), sz);
			
		}
		
		/**
		 * Add a button as child of the pan component and add it on the buttons list.
		 * The button is also linked to MouseEvent.CLICK and MouseEvent.DOUBLE_CLICK
		 *
		 * @param name The name of the component on the flash scene (mandatory)
		 * @param image The bitmap linked to the button display (mandatory)
		 * @param xy The position of the button on the scene (mandatory)
		 * @param sz The size for the button on the scene (mandatory)
		 * @param alt The html alt parameter 
		 */
		public function addButton(name:String, image:Bitmap, xy:Pixel, sz:Size, alt:String = null):void {
			
			var btn:Button = new Button(name, image, xy, sz);
			
			this.addChild(btn);
			
			btn.addEventListener(MouseEvent.CLICK, this.click);
			btn.addEventListener(MouseEvent.DOUBLE_CLICK, this.doubleClick);
			
			this.buttons.push(btn);
		}
		
		//Events
		/**
		 * Handle double-click event.
		 * No action to do for this component so stop the propagation of the event.
		 * 
		 * @param evt The event received
		 * @return false
		 * 
		 */
		public function doubleClick(evt:Event):Boolean {
			evt.stopPropagation();
			return false;
		}
		
		/**
		 * Handle click event.
		 * Switch on the button click and do the linked action (pan in the good orientation)
		 * 
		 * @param evt The event received (return if not MouseEvent)
		 * 
		 */
		public function click(evt:Event):void {
			if (!(evt.type == MouseEvent.CLICK)) return;
			
			var btn:Button = evt.currentTarget as Button;
			
			switch (btn.name) {
				case "zoomin": 
					this.map.zoom++; 
					break;
				case "zoomout": 
					this.map.zoom--; 
					break;
				case "zoomworld": 
					this.map.zoomToMaxExtent(); 
					break;
			}
		}
		
		//Getters and setters.
		/**
		 * The list of buttons of this pan component
		 */
		public function get slideFactor():int {
			return this._slideFactor;   
		}
		
		/**
		 * @private
		 */
		public function set slideFactor(value:int):void {
			this._slideFactor = value;   
		}
		
		public function get buttons():Vector.<Button> {
			return this._buttons;   
		}
		
		public function set buttons(value:Vector.<Button>):void {
			this._buttons = value;   
		}
		
	}
}











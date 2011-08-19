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
	 * Control showing some arrows to be able to pan the map
	 * This Pan class represents a component to add to the map.
	 * 
	 * @example The following code describe how to add a pan on a map : 
	 * 
	 * <listing version="3.0">
	 *   var theMap = Map();
	 *   theMap.addControl(new Pan());
	 * </listing>
	 * 
	 * @author ajard 
	 */
	public class Pan extends Control
	{
		/**
		 * @private
		 * The slide factor of the slider
		 * @default 50
		 */
		private var _slideFactor:int = 50;
		
		/**
		 * @private
		 * The list of buttons of this pan component
		 * @default null
		 */
		private var _buttons:Vector.<Button> = null;
		
		[Embed(source="/assets/images/north-mini.png")]
		protected var northMiniImg:Class;
		
		[Embed(source="/assets/images/west-mini.png")]
		protected var westMiniImg:Class;
		
		[Embed(source="/assets/images/east-mini.png")]
		protected var eastMiniImg:Class;
		
		[Embed(source="/assets/images/south-mini.png")]
		protected var southMiniImg:Class;
		
		public function Pan(position:Pixel = null)
		{
			super(position);
		}
		
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
		
		
		override public function draw():void {
			super.draw();
			
			var px:Pixel = this.position;
			
			// place the controls
			this.buttons = new Vector.<Button>();
			
			var sz:Size = new Size(18,18);
			
			var centered:Pixel = new Pixel(this.x+sz.w/2, this.y);
			
			this.addButton("panup", new northMiniImg(), centered, sz);
			px.y = centered.y+sz.h;
			this.addButton("panleft", new westMiniImg(), px, sz);
			this.addButton("panright", new eastMiniImg(), px.add(sz.w, 0), sz);
			this.addButton("pandown", new southMiniImg(), centered.add(0, sz.h*2), sz);	
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
				case "panup": 
					this.map.pan(0, -100);
					break;
				case "pandown": 
					this.map.pan(0, 100);
					break;
				case "panleft": 
					this.map.pan(-100, 0);
					break;
				case "panright": 
					this.map.pan(100, 0);
					break;
			}
		}
		
		//Getters and setters.
		
		public function get slideFactor():int {
			return this._slideFactor;   
		}
		
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



	


		
	



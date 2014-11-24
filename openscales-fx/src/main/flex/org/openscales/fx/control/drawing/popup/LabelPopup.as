package org.openscales.fx.control.drawing.popup
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	
	import org.openscales.core.Map;
	
	import spark.components.Button;
	import spark.components.HGroup;
	import spark.components.Label;
	import spark.components.TextInput;
	import spark.components.TitleWindow;
	import spark.components.VGroup;

	public class LabelPopup extends TitleWindow
	{
		private var _text:TextInput = new TextInput();
		private var _callback:Function = new Function();
		
		/**
		 * Constructor
		 */
		public function LabelPopup(map:Map, callback:Function, text:String = null)
		{
			var vGroup:VGroup = new VGroup();
			var okButton:Button = new Button();
			
			// Define the popup properties
			var x:uint = map.width / 2;
			var y:uint = map.height / 2;
			this.height = 100;
			this.width = 200;
			this.title = "Your label :";
			vGroup.height = this.height;
			vGroup.width = this.width;
			vGroup.paddingTop = 5;
			vGroup.paddingLeft = 5;
			this.addElement(vGroup);
			if(text != null)
				this._text.text = text;
			vGroup.addElement(this._text);
			okButton.label = "OK";
			vGroup.addElement(okButton);
			
			// Register events
			okButton.addEventListener(MouseEvent.CLICK, okClick);
			this.addEventListener(CloseEvent.CLOSE,closeClick);
			
			// Store the callback
			this._callback = callback;
			
			// Display the popup
			PopUpManager.addPopUp(this, map, true);
			this.x = x;
			this.y = y;
			//this._text.setFocus();
		}
		
		/**
		 * This function is called when the close button is clicked
		 */
		public function closeClick(evt:Event):void
		{
			PopUpManager.removePopUp(this);
		}
		
		/**
		 * This function is called when the ok button is clicked
		 */
		public function okClick(evt:MouseEvent):void
		{
			this._callback(this._text.text);
			PopUpManager.removePopUp(this);
		}
	}
}
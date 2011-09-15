package org.openscales.core.popup
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
			var hGroup:HGroup = new HGroup();
			var vGroup:VGroup = new VGroup();
			var okButton:Button = new Button();
			var cancelButton:Button = new Button();
			
			// Define the popup properties
			this.x = map.width / 2;
			this.y = map.height / 2;
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
			vGroup.addElement(hGroup);
			okButton.label = "OK";
			cancelButton.label = "Cancel";
			hGroup.addElement(okButton);
			hGroup.addElement(cancelButton);
			
			// Register events
			okButton.addEventListener(MouseEvent.CLICK, okClick);
			cancelButton.addEventListener(MouseEvent.CLICK, cancelClick);
			this.addEventListener(CloseEvent.CLOSE,cancelClick);
			
			// Store the callback
			this._callback = callback;
			
			// Display the popup
			PopUpManager.addPopUp(this, map, true);
		}
		
		/**
		 * This function is called when the cancel button or the close button is clicked
		 */
		public function cancelClick(evt:Event):void
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
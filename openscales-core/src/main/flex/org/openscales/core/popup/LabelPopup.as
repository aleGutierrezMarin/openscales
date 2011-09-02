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
		/**
		 * 
		 */
		private var _text:TextInput = new TextInput();
		
		/**
		 * 
		 */
		private var _onClose:Function = new Function();
		
		/**
		 * Constructor
		 */
		public function LabelPopup(map:Map, onClose:Function, text:String=null)
		{
			var vg:VGroup = new VGroup();
			var hg1:HGroup = new HGroup();
			var hg2:HGroup = new HGroup();
			var okButton:Button = new Button();
			var cancelButton:Button = new Button();
			
			// Define the popup properties
			this.x = map.width / 2;
			this.y = map.height / 2;
			this.height = 100;
			this.width = 200;
			this.title = "Your label :";
			okButton.label = "OK";
			cancelButton.label = "Cancel";
			vg.verticalCenter = 2;
			vg.horizontalCenter = 3;
			if(text != null)
				this._text.text = text;
			
			this.addElement(vg);
			vg.addElement(hg1);
			vg.addElement(hg2);
			hg1.addElement(this._text);
			hg2.addElement(okButton);
			hg2.addElement(cancelButton);
			
			// Register events
			okButton.addEventListener(MouseEvent.CLICK, okClick);
			cancelButton.addEventListener(MouseEvent.CLICK, cancelClick);
			this.addEventListener(CloseEvent.CLOSE,cancelClick);
			this._onClose = onClose;
			
			// Display the popup
			PopUpManager.addPopUp(this, map, true);
		}
		
		public function cancelClick(evt:Event):void
		{
			PopUpManager.removePopUp(this);
		}
		
		public function okClick(evt:MouseEvent):void
		{
			this._onClose(this._text.text);
			PopUpManager.removePopUp(this);
		}
	}
}
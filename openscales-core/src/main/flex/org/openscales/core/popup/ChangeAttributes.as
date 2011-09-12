package org.openscales.core.popup
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	
	import org.openscales.core.Map;
	
	import spark.components.Button;
	import spark.components.HGroup;
	import spark.components.Label;
	import spark.components.TextArea;
	import spark.components.TextInput;
	import spark.components.TitleWindow;
	import spark.components.VGroup;
	import spark.layouts.VerticalLayout;
	
	public class ChangeAttributes extends TitleWindow
	{
		private var _callback:Function;
		private var _textInputArray:Array = new Array();
		
		/**
		 * Constructor
		 */
		public function ChangeAttributes(map:Map, attributes:Array, values:Array, callback:Function)
		{
			var hGroup:HGroup = new HGroup();
			var vGroup1:VGroup = new VGroup();
			var vGroup2:VGroup = new VGroup();
			var okButton:Button = new Button();
			var lb:Label;
			var ti:TextInput;
			
			// Define the popup properties
			this.x = map.width / 2;
			this.y = map.height / 2;
			this.height = 300;
			this.width = 400;
			this.title = "Change attributes";
			hGroup.height = this.height;
			hGroup.width = this.width;
			hGroup.clipAndEnableScrolling = true;
			this.addElement(hGroup);
			hGroup.addElement(vGroup1);
			hGroup.addElement(vGroup2);
			
			for(var i:uint = 0; i < attributes.length; i++){
				
				lb = new Label();
				lb.text = attributes[i];
				vGroup1.addElement(lb);
				ti = new TextInput();
				ti.text = values[i];
				vGroup2.addElement(ti);
				_textInputArray.push(ti);
			}
			
			okButton.label = "OK";
			vGroup1.addElement(okButton);
			
			// Register events
			this.addEventListener(CloseEvent.CLOSE, closeClick);
			okButton.addEventListener(MouseEvent.CLICK, okClick);
			this._callback = callback;
			
			// Display the popup
			PopUpManager.addPopUp(this, map, true);
		}
		
		/**
		 * This function is called when the close button is clicked
		 */
		private function closeClick(evt:Event):void
		{
			PopUpManager.removePopUp(this);
		}
		
		/**
		 * This function is called when the ok button is clicked
		 */
		private function okClick(evt:MouseEvent):void
		{
			this._callback(_textInputArray);
			PopUpManager.removePopUp(this);
		}
	}
}
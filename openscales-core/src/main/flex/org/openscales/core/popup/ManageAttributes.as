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
	
	public class ManageAttributes extends TitleWindow
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
		public function ManageAttributes(map:Map, onClose:Function)
		{
			var vg:VGroup = new VGroup();
			var hg1:HGroup = new HGroup();
			var hg2:HGroup = new HGroup();
			var addButton:Button = new Button();
			var deleteButton:Button = new Button();
			
			// Define the popup properties
			this.x = map.width / 2;
			this.y = map.height / 2;
			this.height = 100;
			this.width = 200;
			this.title = "Manage attributes";
			addButton.label = "add";
			deleteButton.label = "delete";
			vg.verticalCenter = 2;
			vg.horizontalCenter = 3;
			this.addElement(vg);
			vg.addElement(hg1);
			vg.addElement(hg2);
			hg1.addElement(this._text);
			hg2.addElement(addButton);
			hg2.addElement(deleteButton);
			
			// Register events
			addButton.addEventListener(MouseEvent.CLICK, addClick);
			deleteButton.addEventListener(MouseEvent.CLICK, deleteClick);
			this.addEventListener(CloseEvent.CLOSE, closeClick);
			this._onClose = onClose;
			
			// Display the popup
			PopUpManager.addPopUp(this, map, true);
		}
		
		public function deleteClick(evt:MouseEvent):void
		{
			PopUpManager.removePopUp(this);
			this._onClose(this._text.text, false);
		}
		
		public function addClick(evt:MouseEvent):void
		{
			PopUpManager.removePopUp(this);
			this._onClose(this._text.text, true);
		}
		
		public function closeClick(evt:Event):void
		{
			PopUpManager.removePopUp(this);
		}
	}
}
package org.openscales.core.popup
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayCollection;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	
	import org.openscales.core.Map;
	
	import spark.components.Button;
	import spark.components.HGroup;
	import spark.components.Label;
	import spark.components.List;
	import spark.components.TextInput;
	import spark.components.TitleWindow;
	import spark.components.VGroup;
	
	public class ManageAttributes extends TitleWindow
	{
		private var _textInput:TextInput = new TextInput();
		private var _list:List = new List();
		private var _callback:Function;
		private var _attributes:Array;
		
		/**
		 * Constructor
		 */
		public function ManageAttributes(map:Map, attributes:Array, callback:Function)
		{
			var hGroup:HGroup = new HGroup();
			var vGroup:VGroup = new VGroup();
			var addButton:Button = new Button();
			var deleteButton:Button = new Button();
			
			// Define the popup properties
			var x:uint = map.width / 2;
			var y:uint = map.height / 2;
			this.height = 260;
			this.width = 180;
			this.title = "Manage attributes";
			hGroup.height = this.height;
			hGroup.width = this.width;
			hGroup.paddingTop = 5;
			hGroup.paddingLeft = 5;
			this.addElement(hGroup);
			hGroup.addElement(vGroup);
			vGroup.addElement(this._textInput);
			addButton.label = "add";
			vGroup.addElement(addButton);
			vGroup.addElement(new Label());
			vGroup.addElement(this._list);
			deleteButton.label = "delete";
			vGroup.addElement(deleteButton);
			
			this._list.dataProvider = new ArrayCollection();
			for(var i:uint = 0; i < attributes.length; i++)
				this._list.dataProvider.addItem(attributes[i]);
			
			// Register events
			addButton.addEventListener(MouseEvent.CLICK, addClick);
			deleteButton.addEventListener(MouseEvent.CLICK, deleteClick);
			this.addEventListener(CloseEvent.CLOSE, closeClick);
			
			this._callback = callback;
			this._attributes = attributes;
			
			// Display the popup
			PopUpManager.addPopUp(this, map, true);
			this.x = x;
			this.y = y;
		}
		
		/**
		 * This function is called when the delete button is clicked
		 */
		public function deleteClick(evt:MouseEvent):void
		{
			for(var i:uint = 0; i < this._attributes.length; i++){
				if(this._attributes[i] == this._list.selectedItem){
					this._list.dataProvider.removeItemAt(i);
					this._attributes.splice(i,1);
					this._callback(this._attributes[i], "delete");
					return;
				}
			}
		}
		
		/**
		 * This function is called when the add button is clicked
		 */
		public function addClick(evt:MouseEvent):void
		{
			if(this._textInput.text == null || this._textInput.text == "")
				return;
			
			for(var i:uint = 0; i < this._attributes.length; i++)
				if(this._attributes[i] == this._textInput.text)
					return;
			
			this._list.dataProvider.addItem(this._textInput.text);
			this._attributes.push(this._textInput.text);
			this._callback(this._textInput.text, "add");
			this._textInput.text = null;
		}
		
		/**
		 * This function is called when the close button is clicked
		 */
		public function closeClick(evt:Event):void
		{
			PopUpManager.removePopUp(this);
		}
	}
}
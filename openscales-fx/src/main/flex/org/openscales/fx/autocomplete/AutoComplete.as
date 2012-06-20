package org.openscales.fx.autocomplete
{
	
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ListCollectionView;
	import mx.collections.Sort;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	import mx.events.FlexEvent;
	import mx.events.FlexMouseEvent;
	import mx.events.SandboxMouseEvent;
	
	import org.openscales.fx.autocomplete.event.AutoCompleteEvent;
	
	import spark.components.Group;
	import spark.components.List;
	import spark.components.PopUpAnchor;
	import spark.components.TextInput;
	import spark.components.supportClasses.SkinnableComponent;
	import spark.events.TextOperationEvent;
	
	[Event (name="select", type="org.openscales.fx.autocomplete.event.AutoCompleteEvent")]
	
	[Event (name="enter", type="mx.events.FlexEvent")]
	
	[Event (name="change", type="spark.events.TextOperationEvent")]
	
	public class AutoComplete extends SkinnableComponent
	{
		
		public function AutoComplete()
		{
			super();
			this.mouseEnabled = true;
			this.setStyle("skinClass", Class(AutoCompleteSkin));
			this.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut)
			collection.addEventListener(CollectionEvent.COLLECTION_CHANGE, collectionChange)
			
		}
		
		public var maxRows:Number = 6;
		public var minChars:Number = 3;
		public var prefixOnly:Boolean = true;
		public var requireSelection:Boolean = false;
		public var countryCodeSelected:String = "";
		
		private var _mouseClickListCallback:Function = temporaryClickCallback;
		
		[SkinPart(required="true",type="spark.components.Group")]
		public var dropDown:Group;
		[SkinPart(required="true",type="spark.components.PopUpAnchor")]
		public var popUp:PopUpAnchor;
		[SkinPart(required="true",type="spark.components.List")]
		public var list:List;
		[SkinPart(required="true",type="spark.components.TextInput")]
		public var inputTxt:TextInput;
		
		public function set mouseClickListCallback(value:Function):void
		{
			this._mouseClickListCallback = value;
		}
		
		public function get mouseClickListCallback():Function
		{
			return this._mouseClickListCallback;
		}
		
		override protected function partAdded(partName:String, instance:Object) : void{
			super.partAdded(partName, instance)
			
			if (instance==inputTxt){
				inputTxt.addEventListener(FocusEvent.FOCUS_OUT, _focusOutHandler)
				inputTxt.addEventListener(FocusEvent.FOCUS_IN, _focusInHandler)
				inputTxt.addEventListener(MouseEvent.CLICK, _focusInHandler)
				inputTxt.addEventListener(TextOperationEvent.CHANGE, onChange);
				inputTxt.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
				inputTxt.addEventListener(FlexEvent.ENTER, enter)
				inputTxt.text = _text;
			}
			if (instance==list){
				list.dataProvider = collection;
				list.labelField = labelField;
				list.labelFunction = labelFunction;
				list.addEventListener(FlexEvent.CREATION_COMPLETE, addClickListener);
				list.focusEnabled = false;
				list.requireSelection = requireSelection;
			}
			if (instance==dropDown){
				dropDown.addEventListener(FlexMouseEvent.MOUSE_DOWN_OUTSIDE, mouseOutsideHandler);	
				dropDown.addEventListener(FlexMouseEvent.MOUSE_WHEEL_OUTSIDE, mouseOutsideHandler);				
				dropDown.addEventListener(SandboxMouseEvent.MOUSE_DOWN_SOMEWHERE, mouseOutsideHandler);
				dropDown.addEventListener(SandboxMouseEvent.MOUSE_WHEEL_SOMEWHERE, mouseOutsideHandler);
			}
		}
		
		private var collection:ListCollectionView = new ArrayCollection();
		
		public function set dataProvider(value:Object):void{
			if (value is Array)
				collection = new ArrayCollection(value as Array);
			else if (value is ListCollectionView){
				collection = value as ListCollectionView;
				collection.addEventListener(CollectionEvent.COLLECTION_CHANGE, collectionChange)
			}
			
			if (list) list.dataProvider = collection;
			
			filterData();
		}
		public function get dataProvider():Object { return collection; }
		
		private function collectionChange(event:CollectionEvent):void{
			if (event.kind == CollectionEventKind.RESET || event.kind == CollectionEventKind.ADD)
				filterData();
		}
		
		private var _text:String = "";
		
		public function set text(t:String):void{
			_text = t;
			if (inputTxt) inputTxt.text = t;
		}
		public function get text():String{
			return _text;
		}
		
		private var _labelField : String;
		public function set labelField(field:String) : void	{
			_labelField = field; 
			if (list) list.labelField = field 
		}
		public function get labelField():String { return _labelField };
		
		public function set labelFunction(func:Function) : void	{
			_labelFunction = func; 
			if (list) list.labelFunction = func 
		}
		public function get labelFunction() : Function	{ return _labelFunction; }
		
		private var _labelFunction:Function;
		
		public var returnField:String;
		
		public function get selectedItem() : Object	{ return _selectedItem; }
		
		public function set selectedItem(item:Object):void {
			_selectedItem = item;
			//inputTxt.text = returnFunction(item);
			text = returnFunction(item)
		}
		
		private var _selectedItem:Object;
		
		public function get selectedIndex() : int { return _selectedIndex; }
		private var _selectedIndex : int = -1;
		
		private function onChange(event:TextOperationEvent):void{
			_text = inputTxt.text;
			this.countryCodeSelected = "";
			filterData()
			
			if (text.length>=minChars) filterData();
			
			dispatchEvent(event);
		}
		
		public function filterData():void{
			if (!this.focusManager || this.focusManager.getFocus()!=inputTxt) return;
			
			if (!popUp) return;
			
			// Nothing to filter or sort: autocompletion service does it
			/*collection.filterFunction = filterFunction;
			var customSort:Sort = new Sort();
			customSort.compareFunction = sortFunction;
			collection.sort = customSort;
			collection.refresh();*/
			if ((text=="" || collection.length==0 || _text.length < 3) && !forceOpen ){
				popUp.displayPopUp = false
			}
			else {
				popUp.displayPopUp = true
				if (requireSelection)
					list.selectedIndex = 0;
				else
					list.selectedIndex = -1;
				list.dataGroup.verticalScrollPosition = 0
				list.dataGroup.horizontalScrollPosition = 0
				list.height = Math.min(maxRows, collection.length) * 22 + 2 ;
				list.validateNow();
			}
		}
		
		// default filter function 
		
		public function filterFunction(item:Object):Boolean{
			var label:String = itemToLabel(item).toLowerCase();
			// prefix mode
			if (prefixOnly){
				if (label.search(text.toLowerCase()) == 0) 
					return true;
				else 
					return false
			}
				// infix mode
			else {
				if (label.search(text.toLowerCase()) != -1) return true;
			}
			return false;
			
		}
		
		public function itemToLabel(item:Object):String
		{
			if (item == null) return "";
			
			if (labelFunction != null)
				return labelFunction(item);
			else if (labelField && item[labelField])
				return item[labelField];
			else
				return item[0].toString();
		}
		
		private function returnFunction(item:Object):String{
			if (item == null) return "";
			
			if (returnField)
				return item[returnField];
			else
				return itemToLabel(item);
		}
		
		// default sorting - alphabetically ascending
		
		public var sortFunction:Function = defaultSortFunction;
		
		public function defaultSortFunction(item1:Object, item2:Object, fields:Array=null):int{
			var label1:String = itemToLabel(item1);
			var label2:String = itemToLabel(item2);
			if (label1<label2) 
				return -1;
			else if (label1==label2) 
				return 0;
			else 
				return 1;
			
		}
		
		private function onKeyDown(event: KeyboardEvent) : void{
			
			if (popUp.displayPopUp){
				switch (event.keyCode){
					case Keyboard.UP:
					case Keyboard.DOWN:
					case Keyboard.END:
					case Keyboard.HOME:
					case Keyboard.PAGE_UP:
					case Keyboard.PAGE_DOWN:
						inputTxt.selectRange(text.length, text.length)
						list.dispatchEvent(event)
						break;
					case Keyboard.ENTER:
						acceptCompletion();
						break;
					case Keyboard.TAB:
						if (requireSelection)
							acceptCompletion();
						else
							popUp.displayPopUp = false
						break;
					case Keyboard.ESCAPE:
						popUp.displayPopUp = false
						break;
					default:
						break;
				}
			}
		}
		
		private function enter(event:FlexEvent):void{
			if (popUp.displayPopUp && list.selectedIndex>-1) return;
			dispatchEvent(event)
		}
		
		// this is a workaround to reset the Mouse cursor
		
		private function onMouseOut(event:MouseEvent):void{
			Mouse.cursor = MouseCursor.AUTO;
		}
		
		public function acceptCompletion() : void
		{
			if (list.selectedIndex >= 0 && collection.length>0)
			{
				
				_selectedIndex = list.selectedIndex
				_selectedItem = collection.getItemAt(_selectedIndex)
				
				text = returnFunction(_selectedItem)
				countryCodeSelected = _selectedItem[1];
				inputTxt.selectRange(inputTxt.text.length, inputTxt.text.length)
				
				var e:AutoCompleteEvent = new AutoCompleteEvent("select", _selectedItem)
				this.dispatchEvent(e)
			}
			else {
				_selectedIndex = list.selectedIndex = -1
				_selectedItem = null
			}
			
			popUp.displayPopUp = false
			
		}	
		
		public var forceOpen:Boolean = false;
		
		private function _focusInHandler(event:Event):void{
			if (forceOpen){
				filterData();
			}
		}
		
		private function _focusOutHandler(event:FocusEvent):void{
			close(event)
			
			if (collection.length==0){
				_selectedIndex = -1;
				_selectedItem = null;
			}
		}
		
		private function mouseOutsideHandler(event:Event):void{
			if (event is FlexMouseEvent){
				var e:FlexMouseEvent = event as FlexMouseEvent;
				if (inputTxt.hitTestPoint(e.stageX, e.stageY)) return;
			}
			
			close(event);
		}
		
		private function close(event:Event):void{
			this.collection.removeAll();
			popUp.displayPopUp = false;
		}
		
		private function addClickListener(event:Event):void{
			list.dataGroup.addEventListener(MouseEvent.CLICK, listItemClick)
		}
		
		private function listItemClick(event: MouseEvent) : void
		{
			acceptCompletion();
			event.stopPropagation();
			this._mouseClickListCallback.apply();
		}
		
		public function temporaryClickCallback():void
		{
			
		}
		
		override public function set enabled(value:Boolean) : void{
			super.enabled = value;
			if (inputTxt) inputTxt.enabled = value;
		}
		
	}
	
}
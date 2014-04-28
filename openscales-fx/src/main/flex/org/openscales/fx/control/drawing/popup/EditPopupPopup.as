package org.openscales.fx.control.drawing.popup
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.events.FlexEvent;
	import mx.managers.PopUpManager;
	
	import org.openscales.core.events.I18NEvent;
	import org.openscales.core.feature.Feature;
	import org.openscales.core.handler.feature.draw.EditKMLPopupHandler;
	import org.openscales.core.i18n.Catalog;
	import org.openscales.core.utils.StringUtils;
	import org.openscales.fx.control.Control;
	
	import spark.components.Button;
	import spark.components.TextArea;
	import spark.components.TextInput;
	import spark.components.TitleWindow;
	
	public class EditPopupPopup extends Control
	{
		[SkinPart(required="true")]
		public var titleInput:TextInput;
		
		[SkinPart(required="true")]
		public var descriptionInput:TextArea;
		
		[SkinPart(required="true")]
		public var saveButton:Button;
		
		
		private var _targetFeature:Feature;
		
		private var _handler:EditKMLPopupHandler;
		
		private var _titleBaseText:String = "";
		private var _descriptionBaseText:String = "";

		
		public function EditPopupPopup()
		{
			super();
			this.addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
		}
		
		/**
		 * Configures the popup
		 */ 
		override protected function onCreationComplete(event:Event):void {
			this.localize();
			if(this.titleInput && this.descriptionInput) {
				this.titleInput.prompt = this.getTitlePrompt();
				this.descriptionInput.prompt = this.getDescriptionPrompt();
			}
		}
		
		public function getTitlePrompt():String {
			return (this._targetFeature == null || isEmpty(this._targetFeature.attributes["title"])) ? this._titleBaseText : this._targetFeature.attributes["title"];
		}
		
		public function getDescriptionPrompt():String {
			return (this._targetFeature == null ||isEmpty(this._targetFeature.attributes["description"])) ? this._descriptionBaseText : this._targetFeature.attributes["description"];
		}
		
		/**
		 * @inheritDoc
		 */ 
		override protected function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			if(instance == titleInput){
				titleInput.prompt = this.getTitlePrompt();
			}
			else if(instance == descriptionInput){
				descriptionInput.prompt = this.getDescriptionPrompt();
			}
			else if(instance == saveButton){
				this.saveButton.addEventListener(MouseEvent.CLICK, onSaveClick);
			}
		}
		
		/**
		 * Feature holding the style to edit
		 */
		public function get targetFeature():Feature
		{
			return this._targetFeature;
			
		}
		
		/**
		 * @private
		 */
		public function set targetFeature(value:Feature):void
		{
			this._targetFeature = value;
			if (this._handler)
				this._handler.selectedFeature = this._targetFeature;
		}
		
		/**
		 * The editKMLStyleHandler that provide methods to manipulate style edition
		 */
		public function get handler():EditKMLPopupHandler
		{
			return this._handler;
		}
		
		/**
		 * @private
		 */
		public function set handler(value:EditKMLPopupHandler):void
		{
			this._handler = value;
			this._handler.selectedFeature = this._targetFeature;
			localize();
			if(this._handler.map){
				this._map = this._handler.map;
				this._handler.map.addEventListener(I18NEvent.LOCALE_CHANGED, localize);
			}
		}
		
		private function isEmpty(string:String):Boolean {
			return StringUtils.isEmpty(string);
		}
		
		public function onSaveClick(event:Event=null):void {
			if(!isEmpty(this.titleInput.text) && !isEmpty(this.descriptionInput.text)) {  
				this._handler.saveFeatureAttributes(this.titleInput.text, this.descriptionInput.text);
			}
			this.close();
		}
		
		/**
		 * Method to close the title window
		 */
		public function close():void
		{
			this._targetFeature = null;
			PopUpManager.removePopUp(this);
		}
		
		/**
		 * @private
		 */ 
		protected function localize(event:I18NEvent=null):void{
			// label editor
			this._titleBaseText = Catalog.getLocalizationForKey("editPopup.titlePrompt");
			this._descriptionBaseText = Catalog.getLocalizationForKey("editPopup.descriptionPrompt");
		}
	}
}
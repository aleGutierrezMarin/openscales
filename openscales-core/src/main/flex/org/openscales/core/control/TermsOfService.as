package org.openscales.core.control
{
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import org.openscales.geometry.basetypes.Pixel;
	
	/**
	 * Instances of TermsOfService are used to present link to the Terms of Service presentation page 
	 * 
	 * This TermsOfService class represents a component to add to the map.
	 * 
	 * @example The following code describe how to add a TermsOfService on a map : 
	 * 
	 * <listing version="3.0">
	 *   var theMap = geoportal.Map();
	 *   theMap.addComponent(new TermsOfService());
	 * </listing>
	 *
	 * @author ajard
	 */ 
	
	public class TermsOfService extends Control
	{	
		/**
		 * @private
		 * @default null
		 * The text of the terms of service.
		 */ 
		private var _label:String = null;
		
		/**
		 * @private
		 * @default null
		 * The url to the page where terms of Service are explained.
		 */ 
		private var _url:String = null;
		
		/**
		 * @private
		 * @default null
		 * The TextField to display the Terms Of Service text.
		 */ 
		private var _textField:TextField = null;
		
		
		/**
		 * Constructor of the class TermsOfService.
		 * 
		 * @param url The url to the page where terms of Service are explained (mandatory)
		 * @param label The Terms of service text to display
		 * @param position The Pixel position of the copyright textField
		 */ 
		// TODO : use english label by default (i18n)
		public function TermsOfService(url:String, label:String = null, position:Pixel = null) 
		{
			super(position);
			
			this._url = url;
			this._label = label;
			
			this._textField = new TextField();
			this._textField.width = 200;
			this._textField.htmlText = "<a href='"+this._url+"' target='_blank'>"+this._label+"</a>";
			
			var textFieldFormat:TextFormat = new TextFormat();
			textFieldFormat.size = 11;
			textFieldFormat.color = 0x0F0F0F;
			textFieldFormat.font = "Verdana";
			this._textField.setTextFormat(textFieldFormat);
		}
		
		/**
		 * @inheritDoc
		 * 
		 * Remove the component from the map and remove reference on object.
		 */
		override public function destroy():void {
			super.destroy();
			
			this._label = null;
			this._url = null;
			this._textField = null;
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function draw():void 
		{
			super.draw();
			this.addChild(this._textField);
		}
		
		/**
		 * Change the text of the terms of service when the lang is changed.
		 * 
		 * @param event The changeLang event (to get the new current language)
		 * @return void
		 */
		// TODO : change general event to changeLang event
		// Events
		public function onChangeLang(event:Event):void
		{
			
		}
		
		
		//Getters and setters
		/**
		 * The text of the terms of service.
		 */	
		public function get label():String 
		{
			return this._label;
		}
		/**
		 * @private
		 */
		
		public function set label(label:String):void 
		{
			this._label = label;
		}
		
		/**
		 * The url to the page where terms of Service are explained.
		 */
		public function get url():String 
		{
			return this._url;
		}
		/**
		 * @private
		 */
		public function set url(url:String):void 
		{
			this._url = url;
		}
		
		/**
		 * TextField component to display the Terms of service text.
		 */
		public function get textField():TextField
		{
			return this._textField;
		}
		/**
		 * @private
		 */
		public function set textField(textField:TextField):void 
		{
			this._textField = textField;
		}
	}
}
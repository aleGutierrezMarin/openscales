package org.openscales.core.control
{
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import org.openscales.geometry.basetypes.Pixel;
	
	/**
	 * Instances of Copyright are used to present copyright with © symbol.
	 * 
	 * This Copyright class represents a component to add to the map.
	 * 
	 * @example The following code describe how to add a copyright on a map : 
	 * 
	 * <listing version="3.0">
	 *   var theMap = geoportal.Map();
	 *   theMap.addComponent(new Copyright("openscales 2008-2011"));
	 * </listing>
	 *
	 * @author ajard
	 */ 
	
	public class Copyright extends Control
	{
		
		/**
		 * @private
		 * 
		 * Provider label for the copyright.
		 */ 
		private var _copyright:String = null;
		
		/**
		 * @private 
		 * 
		 * TextField component to display the copyright label.
		 */
		private var _textField:TextField = null;

		
		/**
		 * Constructor of the class Copyright.
		 * 
		 * @param copyright The copyright label (mandatory)
		 * @param position The Pixel position of the copyright textField
		 */ 
		public function Copyright(copyright:String, 
								  position:Pixel = null) 
		{	
			super(position);
			
			this._copyright = copyright;
			
			this._textField = new TextField();
			this._textField.width = 200;
			this._textField.text = "©"+this._copyright;
			
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
			
			this._copyright = null;
			this._textField = null;
		}
		
		/**
		 * @inheritDoc
		 * 
		 * Display the copyright component on the map.
		 */
		override public function draw():void 
		{
			super.draw();
			this.addChild(this._textField);
		}
		
		//Getters and setters
		/**
		 * Copyright label to display after © symbol.
		 * 
		 * @return The string value of copyright 
		 */
		public function get copyright():String 
		{
			return this._copyright;
		}
		/**
		 * @private
		 */
		public function set copyright(copyright:String):void 
		{
			this._copyright = copyright;
		}
		
		/**
		 * TextField component to display the copyright label.
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
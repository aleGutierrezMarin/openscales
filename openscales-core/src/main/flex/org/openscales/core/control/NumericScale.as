package org.openscales.core.control
{
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import org.openscales.core.Map;
	import org.openscales.core.events.LayerEvent;
	import org.openscales.core.events.MapEvent;
	import org.openscales.geometry.basetypes.Pixel;
	import org.openscales.geometry.basetypes.Unit;
	import org.openscales.proj4as.ProjProjection;
	
	/**
	 * Control showing the current numeric scale value of the map.
	 * Display a simple label with the numeric scale value.	
	 * 
	 * @author ajard
	 */
	public class NumericScale extends Control
	{
		/**
		 * The default fixed round for scale precision
		 */
		public static var DEFAULT_FIXED_ROUND:uint=0;
		
		/**
		 * @private
		 * The value of the current numeric scale
		 * @default 1
		 */
		private var _value:Number = 1;
		
		/**
		 * @private
		 * The Textfield where the numeric scale is displayed
		 * @default null
		 */
		private var _textField:TextField = null;

		
		/**
		 * Constructor of the class NumericScale.
		 * Call the constructor of the parent class (Control).
		 */ 
		public function NumericScale(position:Pixel=null)
		{
			super(position);
			
			this._textField = new TextField();
			this._textField.width = 200;
			
			var textFieldFormat:TextFormat = new TextFormat();
			textFieldFormat.size = 11;
			textFieldFormat.color = 0x0F0F0F;
			textFieldFormat.font = "Verdana";
			this._textField.setTextFormat(textFieldFormat);
		}
	
		
		/**
		 * Update the value of the numeric scale.
		 * The new numeric scale is obtain by Unit.getScaleFrom resolution with the current resolution and the current baseLayer unit.
		 */
		public function update():void
		{
			// TODO : Where can I Take the DPI now that no base layer exists
			/*this._value = Unit.getScaleFromResolution(this._map.resolution.resolutionValue,
				ProjProjection.getProjProjection(this._map.projection).projParams.units,
				this._map.baseLayer.dpi);
			
			this._textField.text = "1 / "+this._value.toFixed(NumericScale.DEFAULT_FIXED_ROUND);*/
		}	
		
		/**
		 * Draw this component on the current stage.
		 * AddChild
		 */
		override public function draw():void	
		{
			super.draw();
			this.update();
			this.addChild(this._textField);
		}
		
		/**
		 * Destroy this control : remove listener and set object to null
		 */
		override public function destroy():void	
		{
			if(this._map!=null)
			{
				this._map.removeEventListener(MapEvent.MOVE_END,this.updateScale);
				this._map.removeEventListener(LayerEvent.BASE_LAYER_CHANGED,this.updateScale);
			}
			
			this._textField = null;
			super.destroy();
		}
		
		// Event
		/**
		 * Update the value of the numeric scale when a zoom occur or a base layer is changed.
		 * @param event The event received
		 */
		public function updateScale(event:Event):void
		{
			this.update();
		}
		
		/**
		 * Assign the current map to this control
		 * 
		 * Get the initial valeur of the map numeric scale.
		 * Add event listener for map zoomed.
		 * 
		 * @param value The map to set
		 */
		override public function set map(value:Map):void 
		{
			if (this._map != null) 
			{
				this._map.removeEventListener(MapEvent.MOVE_END,this.updateScale);
				this._map.removeEventListener(LayerEvent.BASE_LAYER_CHANGED,this.updateScale);
			}
			super._map = value;
			if(value!=null) 
			{
				this._map.addEventListener(MapEvent.MOVE_END,this.updateScale);
				this._map.addEventListener(LayerEvent.BASE_LAYER_CHANGED,this.updateScale);
			}
		}
	
		/**
		 * The value of the current numeric scale
		 * @default 0
		 */
		public function get value():Number
		{
			return _value;
		}
		
		/**
		 * @private
		 */
		public function set value(value:Number):void
		{
			_value = value;
		}
		
		/**
		 * The Textfield where the numeric scale is displayed
		 * @default null
		 */
		public function get textField():TextField
		{
			return _textField;
		}
		
		/**
		 * @private
		 */
		public function set textField(value:TextField):void
		{
			_textField = value;
		}
	}
}
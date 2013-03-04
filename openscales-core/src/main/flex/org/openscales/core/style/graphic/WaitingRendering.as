package org.openscales.core.style.graphic
{
	import flash.display.Sprite;

	internal class WaitingRendering
	{
		private var _sprite:Sprite;
		private var _size:Number;
		
		public function WaitingRendering(sprite:Sprite,size:Number)
		{
			this._sprite = sprite;
			this._size = size;
		}

		public function get sprite():Sprite
		{
			return _sprite;
		}

		public function get size():Number
		{
			return _size;
		}
		
		public function destroy():void {
			this._sprite = null;
		}
	}
}
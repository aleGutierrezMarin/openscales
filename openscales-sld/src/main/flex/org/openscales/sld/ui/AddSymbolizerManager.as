package org.openscales.sld.ui
{
	import mx.core.IFlexDisplayObject;
	import mx.managers.IFocusManagerContainer;
	
	import spark.components.supportClasses.SkinnableComponent;
	
	public class AddSymbolizerManager extends SkinnableComponent implements IFocusManagerContainer
	{
		
		private var _onSymbolizerAdd:Function = null;
		
		public function AddSymbolizerManager()
		{
			super();
		}
		
		public function get defaultButton():IFlexDisplayObject
		{
			return null;
		}
		
		public function set defaultButton(value:IFlexDisplayObject):void
		{
		}

		public function get onSymbolizerAdd():Function
		{
			return _onSymbolizerAdd;
		}

		public function set onSymbolizerAdd(value:Function):void
		{
			_onSymbolizerAdd = value;
		}

	}
}
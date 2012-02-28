package org.openscales.core.format.sld.model
{
	public class StyledLayerDescriptor
	{
		private var _name:String = null;
		private var _title:String = null;
		private var _abstract:String = null;
		private var _namedLayer:Vector.<NamedLayer> = null;
		
		public function StyledLayerDescriptor()
		{
		}

		public function get name():String
		{
			return _name;
		}

		public function set name(value:String):void
		{
			_name = value;
		}

		public function get title():String
		{
			return _title;
		}

		public function set title(value:String):void
		{
			_title = value;
		}

		public function get abstract():String
		{
			return _abstract;
		}

		public function set abstract(value:String):void
		{
			_abstract = value;
		}

		public function get namedLayer():Vector.<NamedLayer>
		{
			return _namedLayer;
		}

		public function set namedLayer(value:Vector.<NamedLayer>):void
		{
			_namedLayer = value;
		}

	}
}
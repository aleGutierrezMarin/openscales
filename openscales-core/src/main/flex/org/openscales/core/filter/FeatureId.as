package org.openscales.core.filter
{
	import org.openscales.core.feature.Feature;
	
	public class FeatureId implements IFilter
	{
		private var _fids:Vector.<String>;
		
		public function FeatureId(fids:Vector.<String>)
		{
			this._fids = fids;
		}
		
		public function matches(feature:Feature):Boolean
		{
			if(!this.fids || this.fids.length==0)
				return false;
			
			for (var i:uint=0, len:uint=this.fids.length; i<len; i++) {
				var fid:String = feature.attributes["fid"] || feature.attributes["fid"];
				if (fid == this.fids[i]) {
					return true;
				}
			}
			return false;
		}
		
		public function clone():IFilter
		{
			//TODO
			return null;
		}
		
		public function get sld():String
		{
			//TODO
			return null;
		}
		
		public function set sld(sld:String):void
		{
			//TODO
		}

		/**
		 * Feature Ids to evaluate this rule against.
		 */
		public function get fids():Vector.<String>
		{
			return _fids;
		}

		/**
		 * @private
		 */
		public function set fids(value:Vector.<String>):void
		{
			_fids = value;
		}

	}
}
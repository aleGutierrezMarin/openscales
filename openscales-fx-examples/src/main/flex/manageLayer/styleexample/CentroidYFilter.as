package manageLayer.styleexample {
	import org.openscales.core.feature.Feature;
	import org.openscales.core.filter.IFilter;
	
	public class CentroidYFilter implements IFilter
	{
		private var min:Number = 0;
		private var max:Number = 0;
		
		public function CentroidYFilter(min:Number, max:Number) {
			this.min = min;
			this.max = max;
		}
		
		public function matches(feature:Feature):Boolean {
			var centroidY:Number = parseFloat(feature.attributes["y_centroid"]);
			return (centroidY > min && centroidY <= max);
		}
		
		public function clone():IFilter{
			var centroidYFilter:CentroidYFilter = new CentroidYFilter(this.min,this.max);
			return centroidYFilter;
		}
		
	}
}
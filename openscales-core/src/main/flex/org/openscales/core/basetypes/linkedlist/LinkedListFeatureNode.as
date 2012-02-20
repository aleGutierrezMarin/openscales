package org.openscales.core.basetypes.linkedlist
{
	import org.openscales.core.feature.Feature;

	/**
	 * LinkedListFeatureNode
	 * Linked list node that contain a feature
	 *
	 * @author slopez
	 */
	public class LinkedListFeatureNode extends AbstractLinkedListNode
	{
		private var _feature:Feature = null;
		/**
		 * @param the feature to include in the node
		 */
		public function LinkedListFeatureNode(feature:Feature)
		{
			super();
			this._feature = feature;
		}
		/**
		 * the feature included in the node
		 */
		public function get feature():Feature
		{
			return _feature;
		}
		/**
		 * @inheritDoc
		 */
		override public function equals(o:Object):Boolean {
			return (o is Feature && o == this._feature);
		}
		/**
		 * @inheritDoc
		 */
		override public function clear():void {
			this._feature = null;
			super.clear();
		}

	}
}
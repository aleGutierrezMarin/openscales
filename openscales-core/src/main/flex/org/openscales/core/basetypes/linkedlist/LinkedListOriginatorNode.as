package org.openscales.core.basetypes.linkedlist
{
	import flash.display.Bitmap;
	
	import org.openscales.core.layer.originator.DataOriginator;
	
	/**
	 * LinkedListBitmapNode interface
	 * Linked list node that contain a bitmap and a DataOriginator
	 *
	 * @author ajard
	 */
	
	public class LinkedListOriginatorNode extends LinkedListBitmapNode
	{
		/**
		 * @private
		 * @default null
		 * The DataOriginator linked to the bitmap.
		 */
		private var _originator:DataOriginator = null;
		
		/**
		 * Constructor of the class LinkedListOriginatorNode.
		 * 
		 * @param originator The DataOriginator linked to this node (mandatory)
		 * @param bitmap The bitmap corresponding to the originator logo (mandatory)
		 * @param uid The id of the node (generate a unique id if not given)
		 */ 
		public function LinkedListOriginatorNode(originator:DataOriginator, bitmap:Bitmap, uid:String=null)
		{
			super(bitmap, uid);
			
			this._originator = originator;
		}
		
		/**
		 * The DataOriginator linked to the bitmap.
		 */
		public function get originator():DataOriginator
		{
			return this._originator;
		}
		/**
		 * @private
		 */
		public function set originator(originator:DataOriginator):void 
		{
			this._originator = originator;
		}
		
		/**
		 * the originator's bitmap
		 */
		public function set bitmap(value:Bitmap):void {
			this._bitmap = value;
		}
		/**
		 * @inheritDoc
		 */
		override public function equals(o:Object):Boolean {
			return (o is DataOriginator && o == this._originator);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function clear():void {
			this._originator = null;
			super.clear();
		}
	}
}
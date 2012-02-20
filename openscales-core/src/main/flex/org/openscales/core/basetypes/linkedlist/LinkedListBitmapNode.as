package org.openscales.core.basetypes.linkedlist
{
	import flash.display.Bitmap;
	
	import org.openscales.core.utils.UID;

	/**
	 * LinkedListBitmapNode interface
	 * Linked list node that contain a bitmap
	 *
	 * @author slopez
	 */
	public class LinkedListBitmapNode extends AbstractLinkedListNode
	{
		/**
		 * the bitmap contained in the node
		 */
		protected var _bitmap:Bitmap

		/**
		 * @param data the Bitmap included in the node
		 * @param uid the uid associated to the bitmap
		 */
		public function LinkedListBitmapNode(data:Bitmap, uid:String=null) {
			if (uid!=null && uid.length>0) {
				this.uid = uid;
			} else {
				this.uid = UID.gen_uid();
			}
			this._bitmap = data;
		}
		/**
		 * the bitmap contained in the node
		 */
		public function get bitmap():Bitmap {
			return this._bitmap;
		}
		/**
		 * @inheritDoc
		 */
		override public function equals(o:Object):Boolean {
			return (o is Bitmap && o == this._bitmap);
		}
		/**
		 * @inheritDoc
		 */
		override public function clear():void {
			this._bitmap = null;
			super.clear();
		}
		
	}
}
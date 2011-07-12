package org.openscales.core.basetypes.trees
{
	/**
	 * Generic tree implementation defining a nodeWidth value of "2".
	 * Nothing else of the nodeValue is specific to a binary tree.
	 * This class must be used as the mother class for all the trees.
	 * Linked lists are also specific trees with a nodeWidth value of "1".
	 *
	 * @author aba
	 */
	public class BinaryTree implements ITree
	{
		
		/*static*/ public function get nodeWidth():uint {
			return 2;
		}
		
		private var _root:ITreeNode = null;
		
		/**
		 * Constructor
		 */
		public function BinaryTree() {
			// nothing to do
		}
		
		public function get root():ITreeNode {
			return this._root;
		}
		public function set root(value:ITreeNode):void {
			if (this.root) {
				this.destroy();
			}
			this._root = value;
		}
		
		public function get depth():uint {
			return (this.root) ? this.root.depth : 0;
		}
		
		public function clear():void {
			this.root = null;
		}
		
		public function destroy():void {
			if (this.root) {
				this.root.destroy();
				this.clear();
			}
		}
		
		public function equals(tree:ITree):Boolean {
			if (this.root) {
				return this.root.equals(tree.root);
			} else {
				return (tree.root == null);
			}
		}
		
	}
}
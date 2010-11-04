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
			if (value == this.root) {
				return;
			}
			// Check the validity of the container of the node
			if ((value != null) && (value.container != this)) {
				throw new ArgumentError("ArgumentError: the node must have this tree as its container");
				return;
			}
			// If needed, destroy the previous tree
			if (this.root != null) {
				this.destroy();
			}
			// Update the root of the tree
			this._root = value;
		}
		
		public function get depth():uint {
			return (this.root==null) ? 0 : this.root.depth;
		}
		
		public function clear():void {
			this._root = null; // Do not use the setter of root, the tree must NOT be destroyed in this case
		}
		
		public function destroy():void {
			if (this.root != null) {
				this.root.destroy();
			}
			this.clear();
		}
		
		public function equals(tree:ITree):Boolean {
			if (this.root != null) {
				return this.root.equals(tree.root);
			} else {
				return (tree.root == null);
			}
		}
		
	}
}
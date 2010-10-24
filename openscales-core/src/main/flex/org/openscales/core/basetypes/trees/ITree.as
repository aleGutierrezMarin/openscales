package org.openscales.core.basetypes.trees
{
	/**
	 * Tree interface.
	 * Interface describing a generic tree.
	 *
	 * @author aba
	 */
	public interface ITree
	{
		
		/**
		 * Maximum number of children for each node (>0)
		 */
		/*static*/ function get nodeWidth():uint;
		
		/**
		 * Root of the tree
		 */
		function get root():ITreeNode;
		function set root(value:ITreeNode):void;
		
		/**
		 * Depth of the tree
		 */
		function get depth():uint;
		
		/**
		 * Cleanup the tree
		 */
		function clear():void;
		
		/**
		 * Test the equality of this tree with a given tree
		 * @param tree a tree with which to compare this node
		 */
		function equals(tree:ITree):Boolean;
		
	}
}

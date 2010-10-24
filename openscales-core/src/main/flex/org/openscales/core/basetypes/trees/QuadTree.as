package org.openscales.core.basetypes.trees
{
	/**
	 * A QuadTree is a tree with 4 children organised like this:
	 *  - [0]: top-left
	 *  - [1]: top-right
	 *  - [2]: bottom-right
	 *  - [3]: bottom-left
	 *
	 * @author aba
	 */
	public class QuadTree extends BinaryTree
	{
		
		/*static*/ override public function get nodeWidth():uint {
			return 4;
		}
		
		public function QuadTree() {
			super();
		}
		
	}
}
package org.openscales.fx.control
{
	import org.openscales.fx.control.skin.IconButtonSkin;
	
	import spark.components.Button;
	
	[Style(name="icon",type="*")]
	[Style(name="iconOver",type="*")]
	[Style(name="iconDown",type="*")]
	[Style(name="labelVisible",type="Boolean")]
	
		
	/**
	 * Since Flex 4 does not provide builtin button capable to display an Icon,
	 * we provide it in OpenScales
	 */
	public class IconButton extends Button
	{
		public function IconButton()
		{
			super();
			this.buttonMode = true;
			setStyle("skinClass", IconButtonSkin);
		}
	}
}
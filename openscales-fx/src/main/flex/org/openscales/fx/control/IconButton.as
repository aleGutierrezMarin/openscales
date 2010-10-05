package org.openscales.fx.control
{
	import org.openscales.fx.skin.IconButtonSkin;
	
	import spark.components.Button;
	
	[Style(name="icon",type="*")]
	
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
package org.openscales.component.control
{
	import spark.components.Button;
	
	//icons
	[Style(name="icon",type="*")]
	
	[Style(name="iconWidth",type="Number")]
	[Style(name="iconHeight",type="Number")]
	
	//paddings
	[Style(name="paddingLeft",type="Number")]
	[Style(name="paddingRight",type="Number")]
	[Style(name="paddingTop",type="Number")]
	[Style(name="paddingBottom",type="Number")]
	public class IconButton extends Button
	{
		public function IconButton()
		{
			super();
		}
	}
}
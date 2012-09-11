// Copyright � 2007. Adobe Systems Incorporated. All Rights Reserved.
package fl.transitions 
{ 
import flash.display.*;

/**
 * The Rotate class rotates the movie clip object. This effect requires the
 * following parameters:
 * <ul><li><code>ccw</code>: A boolean value: <code>false</code> for clockwise rotation; 
 * <code>true</code> for counter-clockwise rotation.</li>
 * <li><code>degrees</code>: An integer that indicates the number of degrees the object is to be rotated. The recommended range is 1 to 9999. For example, a degrees setting of <code>1080</code> would rotate the object completely three times.</li></ul>
 * <p>For example, the following code uses the Rotate transition for the movie clip 
 * instance <code>img1_mc</code>:</p>
 * <listing>
 * import fl.transitions.~~;
 * import fl.transitions.easing.~~;
 *    
 * TransitionManager.start(img1_mc, {type:Rotate, direction:Transition.IN, duration:3, easing:Strong.easeInOut, ccw:false, degrees:720});
 * </listing>
 * @playerversion Flash 9
 * @langversion 3.0
 * @keyword Rotate, Transitions
 * @see fl.transitions.TransitionManager
 */     
public class Rotate extends Transition 
{

    /**
     * @private
     */  
	override public function get type():Class
	{
		return Rotate;
	}
	//public var type:Object = Rotate;
	//public var className:String = "Rotate";

    /**
     * @private
     */     
	protected var _rotationFinal:Number = NaN;

    /**
     * @private
     */  
	protected var _degrees:Number = 360;
	//protected var _ccw:Boolean;

    /**
     * @private
     */  
	function Rotate(content:MovieClip, transParams:Object, manager:TransitionManager) 
	{
		super(content, transParams, manager);
		if (isNaN(this._rotationFinal)) 
			this._rotationFinal = this.manager.contentAppearance.rotation;
		if (transParams.degrees) 
			this._degrees = transParams.degrees;
		// XOR: if ccw or direction (but not both) is true, need to invert the degrees
		if (transParams.ccw ^ this.direction) this._degrees *= -1;
	}

    /**
     * @private
     */  
	override protected function _render(p:Number):void 
	{
		this._content.rotation = this._rotationFinal - this._degrees * (1-p);
	}

}	
}
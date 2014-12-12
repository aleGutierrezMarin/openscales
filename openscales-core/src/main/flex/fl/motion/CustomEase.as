// Copyright � 2007. Adobe Systems Incorporated. All Rights Reserved.
package fl.motion
{
import flash.geom.Point;	
	
[DefaultProperty("points")]	

/**
 * The CustomEase class is used to modify specific properties of the easing behavior of a motion tween as
 * the tween progresses over time. 
 * A custom easing curve is composed of one or more cubic Bezier curves.
 * You can apply the custom easing curve to all properties at once, 
 * or you can define different curves for different properties.
 * <p>The implementation of this class parallels the Flash CS3 Custom Ease In/Ease Out dialog box. Flash CS3
 * displays a graph in the Custom Ease In/Ease Out dialog box representing the degree of motion over time. 
 * The horizontal axis represents frames, and the vertical axis represents the percent of change of a property
 * through the progression of the tween. The first keyframe is represented as 0%, and the last keyframe is 
 * represented as 100%. The slope of the graph's curve represents the rate of change of the object. When the 
 * curve is <code>horizontal</code> (no slope), the velocity is zero; when the curve is <code>vertical</code>, an instantaneous rate of 
 * change occurs.</p>
 * @playerversion Flash 9.0.28.0
 * @langversion 3.0
 * @keyword Ease, Copy Motion as ActionScript    
 * @see ../../motionXSD.html Motion XML Elements 
 */
public class CustomEase implements ITween
{
    /**
      * An ordered collection of points in the custom easing curve.
      * Each item in the array is a <code>flash.geom.Point</code> instance.
      * The x and y properties of each point are normalized to fall between <code>0</code> and <code>1</code>,
      * where <code>0</code> is the value of the animation property at the beginning of the tween,
      * and <code>1</code> is the value at the end of the tween.
      * The first and last points of the curve are not included in the array
      * because the first point is locked to the starting value defined by the current keyframe,
      * and the last point is locked to the ending value defined by the next keyframe. 
      * On the custom easing curve, these points correspond to values of (0, 0) and (1, 1), respectively.
      * @playerversion Flash 9.0.28.0
      * @langversion 3.0
      * @keyword Ease, points, Copy Motion as ActionScript      
      * @see flash.geom.Point
      *  
      */
	[ArrayElementType("flash.geom.Point")]
	public var points:Array;

    /**
     * @private
     */
    private var firstNode:Point;

    /**
     * @private
     */
	private var lastNode:Point;

    /**
     * @private
     */
	private var _target:String = '';


    /**
     * The name of the animation property to target.
     * @default ""
     * @playerversion Flash 9.0.28.0
     * @langversion 3.0
     * @keyword Animation, target, Copy Motion as ActionScript      
     * @see fl.motion.ITween#target     
     */
	public function get target():String
	{
		return this._target;
	}

    /**
     * @private (setter)
     */
	public function set target(value:String):void
	{
		this._target = value;
	}


    /**
     * Constructor for CustomEase instances.
     *
     * @param xml Optional E4X XML object defining a CustomEase in Motion XML format.
     * @playerversion Flash 9.0.28.0
     * @langversion 3.0
     * @keyword CustomEase, Copy Motion as ActionScript
     */
	function CustomEase(xml:XML=null)
	{
		this.points = [];
		this.parseXML(xml);
		this.firstNode = new Point(0, 0);
		this.lastNode = new Point(1, 1);
	}
	
	/**
     * @private
     */
	private function parseXML(xml:XML=null):CustomEase
	{
		if (!xml) return this;
		
		if (xml.@target.length())
			this.target = xml.@target;
		
		var elements:XMLList = xml.elements();
		for each (var child:XML in elements)
		{
			this.points.push(new Point(Number(child.@x), Number(child.@y)));
		}
		
		return this;
	}


    /**
     * Calculates an interpolated value for a numerical property of animation,
     * using a custom easing curve. 
     * The percent value is read from the CustomEase instance's <code>points</code> property,
     * rather than being passed into the method.
     * Using the property value allows the function signature to match the ITween interface.
     *
     * @param time The time value, which must lie between <code>0</code> and <code>duration</code>, inclusive.
     * You can choose any unit (for example. frames, seconds, milliseconds), 
     * but your choice must match the <code>duration</code> unit.
	 *
     * @param begin The value of the animation property at the start of the tween, when time is 0.
     *
     * @param change The change in the value of the animation property over the course of the tween. 
     * The value can be positive or negative. For example, if an object rotates from 90 to 60 degrees, the <code>change</code> is <code>-30</code>.
     *
     * @param duration The length of time for the tween. This value must be greater than zero.
     * You can choose any unit (for example, frames, seconds, milliseconds), 
     * but your choice must match the <code>time</code> unit.
     *
     * @return The interpolated value at the specified time.
     * @playerversion Flash 9.0.28.0
     * @langversion 3.0
     * @keyword CustomEase, Copy Motion as ActionScript  
     * @see #points
     */
	public function getValue(time:Number, begin:Number, change:Number, duration:Number):Number
	{	
		if (duration <= 0) return NaN;
		var percent:Number = time/duration;
		if (percent <= 0) return begin;
		if (percent >= 1) return begin+change; 

		var pts:Array = [this.firstNode].concat(this.points);
		pts.push(this.lastNode);
		var easedPercent:Number = getYForPercent(percent, pts);
		return begin + easedPercent*change;
	}
		
	/**
     * @private
     */
   	internal static function getYForPercent(percent:Number, pts:Array):Number
	{
		var bez0:BezierSegment = new BezierSegment(pts[0], pts[1], pts[2], pts[3]);
		var beziers:Array = [bez0];
		for (var i:int=3; i<pts.length-3; i+=3)
		{
			beziers.push(new BezierSegment(pts[i], pts[i+1], pts[i+2], pts[i+3]));
		}

		var theRightBez:BezierSegment = bez0;
		if (pts.length >= 5)
		{
			// find the Bezier that contains the x value
			for (var bi:int=0; bi<beziers.length; bi++)
			{
				var bez:BezierSegment = beziers[bi];
				if (bez.a.x <= percent && percent <= bez.d.x)
				{
					theRightBez = bez;
					break;
				}
			}
		}
		var easedPercent:Number = theRightBez.getYForX(percent);		
		return easedPercent;
	}

	
}
}

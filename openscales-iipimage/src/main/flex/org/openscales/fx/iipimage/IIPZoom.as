package org.openscales.fx.iipimage
{

import caurina.transitions.Tweener;

import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.MouseEvent;
import flash.events.SecurityErrorEvent;
import flash.filters.GlowFilter;
import flash.geom.Rectangle;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.utils.setTimeout;

import org.openzoom.flash.components.MultiScaleImage;
import org.openzoom.flash.components.Spinner;
import org.openzoom.flash.descriptors.IMultiScaleImageDescriptor;
import org.openzoom.flash.descriptors.iip.IIPImageDescriptor;
import org.openzoom.flash.utils.ExternalMouseWheel;
import org.openzoom.flash.utils.math.clamp;
import org.openzoom.flash.viewport.constraints.CenterConstraint;
import org.openzoom.flash.viewport.constraints.CompositeConstraint;
import org.openzoom.flash.viewport.constraints.ScaleConstraint;
import org.openzoom.flash.viewport.constraints.VisibilityConstraint;
import org.openzoom.flash.viewport.constraints.ZoomConstraint;
import org.openzoom.flash.viewport.controllers.ContextMenuController;
import org.openzoom.flash.viewport.controllers.KeyboardController;
import org.openzoom.flash.viewport.controllers.MouseController;
import org.openzoom.flash.viewport.transformers.TweenerTransformer;

/**
 * @private
 * 
 * IIPImage client based on IIPZoom client and Openzoom SDK
 * 
 * @see http://iipimage.sourceforge.net/documentation/iipzoom/
 * @see http://www.openzoom.org/
 *  
 */
public class IIPZoom extends Sprite
{
    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------

    private static const DEFAULT_LOAD_TIMEOUT:uint = 100
    private static const DEFAULT_MAX_SCALE_FACTOR:Number = 1.1
    private static const DEFAULT_VISIBILITY_RATIO:Number = 0.5
  

    private static const DEFAULT_VIEWPORT_BOUNDS:String = "0, 0, 1, 1"

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     * Constructor.
     */
    public function IIPZoom()
    {
        addEventListener(Event.ADDED_TO_STAGE,
                         initialize,
                         false, 0, true)
    }

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    // UI
    private var image:MultiScaleImage

    private var navigator:SceneNavigator
	
    private var _server:String
	
    private var _im:String
	
	private var _tmpWidth:Number;
	private var _tmpHeight:Number;
	private var _navigationEnabled:Boolean= false;
	
    private static var loader:URLLoader

    //--------------------------------------------------------------------------
    //
    //  Methods: Initialization
    //
    //--------------------------------------------------------------------------

    /**
     * @private
     */
    private function initializeStage():void
    {
        if (stage)
        {
            // Enable mouse wheel support for browsers
            // on Mac OS as well as Safari on Windows
            ExternalMouseWheel.initialize(stage)

            // Configure stage
            stage.align = StageAlign.TOP_LEFT
            stage.scaleMode = StageScaleMode.NO_SCALE
            stage.addEventListener(Event.RESIZE,
                                   stage_resizeHandler,
                                   false, 0, true)
        }
    }

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     * @private
     */
    private function loadSource():void
    {
		if(!_im || !_server || _im.length==0 || _server.length==0) return;
        
		try
        {			
		    var request:URLRequest = new URLRequest( IIPImageDescriptor.getMetaDataURL(_im,_server) )
		    loader = new URLLoader();
	
            try {
				loader.load(request);
		    }
		   	catch (error:SecurityError)
	        {
				trace("A SecurityError has occurred.");
		    }

	    loader.addEventListener(Event.COMPLETE, metaDataLoaded)
	    loader.addEventListener(IOErrorEvent.IO_ERROR, showSad)

        }
        catch (error:Error) // Security error
        {
            showSad()
        }
    }

    private function metaDataLoaded(event:Event):void
    {
		if(loader.data == null || loader.data === undefined) return;
		
		image.source = IIPImageDescriptor.fromBasicInfo( loader.data, _im, _server )
	
		if( !image.source ){
			showSad()
			return
		}

		createNavigation()
    }


    //--------------------------------------------------------------------------
    //
    //  Methods: Children
    //
    //--------------------------------------------------------------------------

    /**
     * @private
     */
    private function createChildren():void
    {
        if (!image)
            createImage()
    }


    /**
     * @private
     */
    private function createImage():void
    {
        image = new MultiScaleImage()
		image.setActualSize(_tmpWidth?_tmpWidth:image.width,_tmpHeight?_tmpHeight:image.height);			
			
        configureTransformer(image)
        configureControllers(image)
        configureListeners(image)

        addChild(image)
    }

    /**
     * @private
     */ 
    private function createNavigation():void
    {
		
		
		var width:uint = parent.width / 6
		var height:uint = (width / image.source.width) * image.source.height
	
		var url:String = image.source.getCVT(width)
		navigator = new SceneNavigator(width,height,url)
		navigator.viewport = image.viewport
	
		navigator.y = 10
		navigator.x = parent.width - navigator.width - 10
	
		if(_navigationEnabled)addChild( navigator )
    }

	public function set navigationEnabled(value:Boolean):void{
		_navigationEnabled = value;
		if(!navigator) return;
		else{
			if(value){
				addChild(navigator);
			}else{
				removeChild(navigator);
			}
		}
	}
	
	public function get navigationEnabled():Boolean{
		return _navigationEnabled;
	}

    //--------------------------------------------------------------------------
    //
    //  Methods: Image configuration
    //
    //--------------------------------------------------------------------------

    /**
     * @private
     */
    private function configureTransformer(image:MultiScaleImage):void
    {
        image.transformer = new TweenerTransformer()
    }

    /**
     * @private
     */
    private function configureControllers(image:MultiScaleImage):void
    {
        var mouseController:MouseController = new MouseController()


        image.controllers = [mouseController]
    }

    /**
     * @private
     */
    private function configureConstraints(image:MultiScaleImage):void
    {
        // Prevent image from zooming out
        var zoomConstraint:ZoomConstraint = new ZoomConstraint()
            zoomConstraint.minZoom = 1

        // Center at minimum zoom level
        var centerConstraint:CenterConstraint = new CenterConstraint()

        // Prevent from zooming in more than the original size of the image
        var scaleConstraint:ScaleConstraint = new ScaleConstraint()

        var imageWidth:Number
        var imageHeight:Number
        var defaultDimension:Number = image.sceneWidth

        if (image.source && image.source is IMultiScaleImageDescriptor)
        {
            var descriptor:IMultiScaleImageDescriptor
            descriptor = IMultiScaleImageDescriptor(image.source)
            imageWidth = descriptor.width
            imageHeight = descriptor.height
            var maxScale:Number = Math.max(imageWidth / defaultDimension,
                                           imageHeight / defaultDimension)
            scaleConstraint.maxScale = DEFAULT_MAX_SCALE_FACTOR * maxScale
        }

        // Prevent image from disappearing from the viewport
        var visibilityConstraint:VisibilityConstraint = new VisibilityConstraint()
            visibilityConstraint.visibilityRatio = DEFAULT_VISIBILITY_RATIO

        // Chain all constraints together
        var compositeContraint:CompositeConstraint = new CompositeConstraint()
            compositeContraint.constraints = [centerConstraint,
                                              visibilityConstraint,
                                              zoomConstraint,
                                              scaleConstraint]
        // Apply constraints
        image.constraint = compositeContraint
    }

    /**
     * @private
     */
    private function configureListeners(image:MultiScaleImage):void
    {   
        image.addEventListener(Event.COMPLETE,
                               image_completeHandler,
                               false, 0, true)
        image.addEventListener(IOErrorEvent.IO_ERROR,
                               image_ioErrorHandler,
                               false, 0, true)
        image.addEventListener(SecurityErrorEvent.SECURITY_ERROR,
                               image_securityErrorHandler,
                               false, 0, true)
    }

    //--------------------------------------------------------------------------
    //
    //  Methods: Layout
    //
    //--------------------------------------------------------------------------

    /**
     * @private
     */
    internal function layout():void
    {
		if (navigator)
		{
			if(this.contains(navigator))this.removeChild(navigator);
			createNavigation();
		}
    }

    //--------------------------------------------------------------------------
    //
    //  Methods: Internal
    //
    //--------------------------------------------------------------------------

    /**
     * @private
     */
    private function showSad(event:Event=null):void
    {
	
    }

    //--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------

    /**
     * @private
     */
    private function initialize(event:Event):void
    {
        if(!stage)return;
		
		// Tweener _autoAlpha property
        //DisplayShortcuts.init()

        initializeStage()

        createChildren()
        layout()

        if (loaderInfo.url.indexOf("file://") == 0)
            setTimeout(loadSource, DEFAULT_LOAD_TIMEOUT) // Workaround for FF on Mac OS X
        else
            loadSource()
    }

	private function reset():void{
		if(navigator && contains(navigator))removeChild(navigator);
		if(image && contains(image))removeChild(image);
		navigator = null;
		image = null;
		initialize(null);
	}
	
    /**
     * @private
     */
    private function stage_resizeHandler(event:Event):void
    {
        layout()
    }

	/**
	 * Zoom in the displayed image
	 * 
	 * @param coef Zooming coefficient
	 */ 
	public function zoomIn(coef:Number=1.6):void{
		if (image)
			image.viewport.zoom *= coef
	}
	
	/**
	 * Zoom out the displayed image
	 * 
	 * @param coef Zooming coefficient
	 */ 
	public function zoomOut(coef:Number=0.3):void{
		if (image)
			image.viewport.zoom *= coef
	}
	
	public function panUp(factor:Number=0.1):void{
		if(image){
			image.viewport.panBy(0, -image.viewportHeight*factor);
		}
	}
	
	public function panDown(factor:Number=0.1):void{
		if(image){
			image.viewport.panBy(0, image.viewportHeight*factor);
		}
	}
	
	public function panRight(factor:Number=0.1):void{
		if(image){
			image.viewport.panBy(image.viewportWidth*factor, 0);
		}
	}
	
	public function panLeft(factor:Number=0.1):void{
		if(image){
			image.viewport.panBy(-image.viewportWidth*factor, 0);
		}
	}
	
	public function showAll():void{
		if(image){
			image.viewport.showAll();
		}
	}
	
	
    /**
     * @private
     */
    private function zoomInButtonHandler(event:MouseEvent):void
    {
       zoomIn();
    }

	
	
    /**
     * @private
     */
    private function zoomOutButtonHandler(event:MouseEvent):void
    {
        zoomOut();
    }


	
	/**
     * @private
     */
    private function resetButton_mouseDownHandler(event:MouseEvent):void
    {
       showAll();
    }
    //--------------------------------------------------------------------------
    //
    //  Event handlers: Image
    //
    //--------------------------------------------------------------------------

    /**
     * @private
     */
    private function image_completeHandler(event:Event):void
    {
        // Viewport bounds
        var bounds:Rectangle = getViewportBoundsParameter()
        image.viewport.fitToBounds(bounds, 1.0, true)

        configureConstraints(image)
        
        // Important that this happens after attachment
        layout()
    }

    /**
     * @private
     */
    private function image_ioErrorHandler(event:IOErrorEvent):void
    {
        showSad()
        layout()
    }

    /**
     * @private
     */
    private function image_securityErrorHandler(event:SecurityErrorEvent):void
    {
        showSad()
        layout()
    }

    //--------------------------------------------------------------------------
    //
    //  Methods: Parameters
    //
    //--------------------------------------------------------------------------

    /**
     * @private
     */
    private function getParameter(name:String, defaultValue:*):*
    {
        if (loaderInfo.parameters.hasOwnProperty(name))
        {
            var value:* = loaderInfo.parameters[name];
            return value;
        }

        return defaultValue
    }

    /**
     * @private
     */
    private function getViewportBoundsParameter():Rectangle
    {
        var boundsParameterString:String = DEFAULT_VIEWPORT_BOUNDS;

        var boundsParameter:Array = boundsParameterString.split(",")

        var bounds:Rectangle = new Rectangle()
        bounds.x = clamp(parseFloat(boundsParameter[0]), 0, 1)
        bounds.y = clamp(parseFloat(boundsParameter[1]), 0, 1)
        bounds.width = clamp(parseFloat(boundsParameter[2]), 0, 1)
        bounds.height = clamp(parseFloat(boundsParameter[3]), 0, 1)

        return bounds
    }
	
	override public function set width(value:Number):void{
		if(this.image)this.image.setActualSize(value,this.image.height);
		_tmpWidth = value;
	}
	
	override public function set height(value:Number):void{
		if(this.image)this.image.setActualSize(this.image.height,value);
		_tmpHeight = value;
	}

	/**
	 * IIP Server URL
	 */
	public function get server():String
	{
		return _server;
	}

	/**
	 * @private
	 */
	public function set server(value:String):void
	{
		_server = value;
		reset();
	}

	/**
	 * Image file name
	 */
	public function get im():String
	{
		return _im;
	}

	/**
	 * @private
	 */
	public function set im(value:String):void
	{
		_im = value;
		reset();
	}

	
}

}

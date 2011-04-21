package org.openscales.core.control
{
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.utils.Timer;
	
	import org.openscales.core.Map;
	import org.openscales.core.basetypes.linkedlist.LinkedList;
	import org.openscales.core.basetypes.linkedlist.LinkedListOriginatorNode;
	import org.openscales.core.control.ui.Button;
	import org.openscales.core.events.OriginatorEvent;
	import org.openscales.core.layer.originator.DataOriginator;
	import org.openscales.core.request.DataRequest;
	import org.openscales.geometry.basetypes.Pixel;
	
	/**
	 * Instance of DataOriginatorsDisplay is used to display the differents logos of originators of current layers in the map.
	 * 
	 * The list of orignators in this component is a DataOriginators
	 * This DataOriginatorsDisplay class represents a display component for originators of layers in a map.
	 * 
	 * This class is closed to LogoRotator (which display logos one by one).
	 * The difference consist in the number of display logo which can be paramater and the link to DataOriginators
	 * 
	 * @author ajard
	 */ 
	
	public class DataOriginatorsDisplay extends Control
	{
		/**
		 * @default 2000
		 * The default value for rotation cycle.
		 */
		public static var DEFAULT_ROTATION_CYCLE:uint=2000;
		
		/**
		 * @default 2000
		 * The default value for rotation cycle.
		 */
		public static var DEFAULT_SPACING:uint=1;
		
		/**
		 * @private
		 * @default null
		 * The list of current originators to display on the map.
		 */
		private var _dataOriginators:DataOriginators = null;
		
		/**
		 * @private
		 * @default 1
		 * Number of logos displayed at the same time on the map.
		 */
		private var _logoNumber:Number = 1;
		
		/**
		 * @private
		 * @default null
		 * LinkedLiist where the bitmap logos are stored
		 */
		private var _linkedList:LinkedList = null;
		
		/**
		 * @private
		 * @default null
		 * LinkedLiist where bitmap to remove but currently displayed are srored
		 */
		private var _removedOriginatorList:Vector.<DataOriginator> = null;
		
		/**
		 * @private
		 * @default null
		 * The fisrt logo originator displayed on the current part of the list of logo
		 */
		private var _currentOriginator:LinkedListOriginatorNode = null;
		
		/**
		 * @private
		 * @default null
		 * The timer use to rotate the display of logos.
		 */
		private var _timer:Timer = null;
		
		/**
		 * @private
		 * @default DEFAULT_ROTATION_CYCLE
		 * The time between two rotations.
		 */
		private var _delay:Number = DataOriginatorsDisplay.DEFAULT_ROTATION_CYCLE;
		
		/**
		 * @private
		 * @default DEFAULT_SPACING
		 * The spacing between two logos displayed at the same time.
		 */
		private var _spacing:Number = DataOriginatorsDisplay.DEFAULT_SPACING;
		
		
		/**
		 * Constructor of the class DataOriginatorsDisplay.
		 * 
		 * This DataOriginatorsDisplay contains a DataOriginators which contains the current 
		 * list of originators to be displayed
		 * 
		 * @param logoNumber Number of logos display at the same time on the map.
		 * @param position Indicates the position of this component in the current stage.
		 */ 
		public function DataOriginatorsDisplay(logoNumber:Number = 1, position:Pixel = null)
		{
			super(position);
			this._logoNumber = logoNumber;
			this._dataOriginators = new DataOriginators(position);
			this._linkedList = new LinkedList();
			this._removedOriginatorList = new Vector.<DataOriginator>();
			
			this.addEventListener(OriginatorEvent.ORIGINATOR_REMOVE_FROM_DISPLAY, this.manageRemoveOriginatorList);
		}
		
		/**
		 * @inheritDoc
		 * 
		 * Remove the bitmap from the list and remove the listener for the timer.
		 */
		// TODO
		override public function destroy():void {
			
			super.destroy();
			
			this.removeEventListener(OriginatorEvent.ORIGINATOR_REMOVE_FROM_DISPLAY, this.manageRemoveOriginatorList);
			
			
			if(this._timer!=null) {
				this._timer.stop();
				this._timer.removeEventListener(TimerEvent.TIMER,this.changeDisplay);
				this._timer = null;
			}
			if(this._currentOriginator!=null) {
				this.removeChild(this._currentOriginator.bitmap());
				this._currentOriginator = null;
			}
			if(this._linkedList!=null) {
				this._linkedList.clear();
				this._linkedList = null;
			}
			
			// TODO remove the displayed logos
			
		}
		
		/**
		 * @inheritDoc
		 * 
		 * Display the DataOriginatorsDispaly component on the map : display part of the list of logo 
		 * (according to the logoNumber given) and rotate each given delay
		 */
		override public function draw():void {

			if(this._timer!=null)
				return;
			
			this._timer = new Timer(this._delay,0);
			// change the display when the delay is spent
			this._timer.addEventListener(TimerEvent.TIMER,this.changeDisplay);
			this._timer.start();
		}
		
		/**
		 * Get all the originators defined in the DataOriginators list and add theirs logos in the component.
		 * This function is called when the map of this component is set
		 */
		public function synchroniseWithDataOriginators():void
		{
			var i:uint = 0;
			var j:uint = this._dataOriginators.originators.length;
			
			// add an OriginatorNode for each originator in the DataOriginators list
			for (; i<j; ++i) 
			{
				addOriginator(this._dataOriginators.originators[i]);
			}
		}
		
		/**
		 * @private
		 * Add a new logo in the current stage.
		 * Create a new Button with the bitmap logo
		 * Add a listener on this button to detect mouse click
		 *
		 * @param originator The originator node of the logo to add
		 * @param position The position of this button
		 */
		 private function addLogoButton(originatorNode:LinkedListOriginatorNode, position:Pixel):void
		 {
			 var btn:Button = new Button(originatorNode.originator.name, originatorNode.bitmap(), position);
			 btn.addEventListener(MouseEvent.CLICK, this.onClick);
			 
			 this.addChild(btn);
		 }
		 
		 /**
		  * @private
		  * Remove logo button from the stage.
		  * Remove the listener on this button
		  *
		  * @param originator The originator node of the logo to remove
		  */
		 private function removeLogoButton(originatorNode:LinkedListOriginatorNode):void
		 { 
			// get the corresponding button
			var btn:Button = this.getChildByName(originatorNode.originator.name) as Button;
			 
			trace("btn "+btn.name);
			
			btn.removeEventListener(MouseEvent.CLICK, this.onClick);
			this.removeChild(btn);
			 
			// event : not display any more (to delete the originator if asked)
			this.dispatchEvent(new OriginatorEvent(OriginatorEvent.ORIGINATOR_REMOVE_FROM_DISPLAY, originatorNode.originator));
		 }
		
		/**
		 * Add a new Orginator in the list.
		 * Load its bitmap logo.
		 * When the bitmap is load, call the completeLoading function to insert the component in the linkedList
		 * 
		 * @param The originator to add.
		 */
		public function addOriginator(originator:DataOriginator):void
		{
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, this.completeLoading);
			loader.name = originator.name;
			
			var request:URLRequest = new URLRequest(originator.urlPicture);
			loader.load(request);
		}
		
		/**
		 * Check if the given originator is curretly display or not
		 * Return true if the DataOriginator is display
		 * Otherwise return false
		 */
		public function isDisplayed(originator:DataOriginator):Boolean
		{
			var i:uint;
			var j:uint = this._logoNumber;
			var tmpOriginator:LinkedListOriginatorNode = this._currentOriginator;
			
			if( tmpOriginator != null )
			{
				if( this._linkedList.size < this._logoNumber )
				{
					j = this._linkedList.size;
				}
				
				for (; i<j; ++i) 
				{
					if( tmpOriginator.originator == originator )
					{
						return true;
					}
					tmpOriginator = tmpOriginator.nextNode as LinkedListOriginatorNode;
				}
			}
			return false;
		}
		
		/**
		 * Remove an originator in the list.
		 * If the originator is currently displayed add it on the removeList
		 * 
		 * @param The originator to remove.
		 */
		public function removeOriginator(originator:DataOriginator):void
		{
			if(isDisplayed(originator))
			{
				// to delete it when not displayed
				this._removedOriginatorList.push(originator);
			}
			else
			{
				this.linkedList.remove(originator.name);
			}
		}
		
		
		
		// Events
		/**
		 * Add a the logo originator loaded in the linkedList.
		 * Get the Data originator in the DataOriginators list by its name.
		 * Add the originator at the en of the linkedList.
		 * 
		 * @param The event of complete loading.
		 */
		private function completeLoading(event:Event):void 
		{
			var name:String = event.target.loader.name;
			var bmp:Bitmap = Bitmap(event.target.loader.content);
			bmp.addEventListener(MouseEvent.CLICK, this.onClick);
			
			trace("Loading OK "+name);
			
			// get the DataOriginator linked to this bitmap and urlPicture :
			var originator:DataOriginator = this._dataOriginators.findOriginatorByName(name);
			
			if(originator!=null)
			{
				this._linkedList.insertTail(new LinkedListOriginatorNode(originator,bmp,originator.name));
			}
		}
		
		/**
		 * Call when an originatorEvent.ORIGINATOR_ADDED occur
		 * The new originator bitmap logo is add at the enf of the list of logos
		 * 
		 * @param event The OriginatorEvent received.
		 */
		// TODO
		public function onOriginatorAdded(event:OriginatorEvent):void
		{
			trace("originator added");
			
			// add to the list :
			addOriginator(event.originator);
		}
		
		/**
		 * Call when an originatorEvent.ORIGINATOR_REMOVED occur
		 * The originator bitmap logo is removed from the list once its not display
		 * 
		 * @param event The OriginatorEvent received.
		 */
		// TODO
		public function onOriginatorRemoved(event:OriginatorEvent):void
		{
			trace("originator removed");
			removeOriginator(event.originator);
		}
		
		/**
		 * This function check if the originator of the evet wait for remove and in this case remove it
		 * 
		 * This function is called when a logo is removed from the map. 
		 * If the not displayed logo is on the remove list it is removed.
		 * 
		 * @param event The OriginatorEvent.ORIGINATOR_REMOVE_FROM_DISPLAY received
		 */
		private function manageRemoveOriginatorList(event:OriginatorEvent):void
		{
			// if originator waiting for remove
			if( this._removedOriginatorList.length > 0 )
			{
				var i:uint = 0;
				var j:uint = this._removedOriginatorList.length;
				
				for (; i<j; ++i) 
				{
					if( this._removedOriginatorList[i] == event.originator )
					{
						this._removedOriginatorList.splice(i, 1);
						this.linkedList.remove(event.originator.name);
						return;
					}
				}
			}
		}
		
		
		/**
		 * Get the following originator logo of the current (this._currentOriginator)
		 * If its the end of the list go back to the head
		 * 
		 * @param originator The LinkedListOriginatorNode to get the following
		 * @return the following OriginatorNode
		 */
		private function getFollowing(originator:LinkedListOriginatorNode):LinkedListOriginatorNode
		{
			if(originator != this._linkedList.tail)
			{
				return originator.nextNode as LinkedListOriginatorNode;
			}
			else
			{
				return this._linkedList.head as LinkedListOriginatorNode;
			}
		}
		
		
		/**
		 * Change the logos display (debauce delay betewen two changes is spent)
		 * 
		 * @param event The event received.
		 */
		// TODO
		private function changeDisplay(event:Event):void
		{
			// to progress on the list wihtout changing the current Originator
			var tmpOriginator:LinkedListOriginatorNode;
			
			var listSize:Number = this._linkedList.size;
			var i:uint;
			var j:uint;
			var currentPosition:Pixel = position;
			
			
			if(listSize>0) 
			{
				// not the fisrt time
				if( this._currentOriginator != null )
				{
					if(listSize >= this._logoNumber)
					{
						// remove the given number of logos
						i = 0;
						for (; i<this._logoNumber; ++i) 
						{
							/// this.removeChild(this._currentOriginator.bitmap());
							removeLogoButton(this._currentOriginator);
							
							// the following logo (head if current is tail)
							this._currentOriginator = getFollowing(this._currentOriginator);
						}
						
						// add new logos to display
						i = 0;		
						tmpOriginator = this._currentOriginator;
						for (; i<this._logoNumber; ++i) 
						{
							tmpOriginator.bitmap().x = currentPosition.x;

							addLogoButton(tmpOriginator, currentPosition);
							
							currentPosition.x += tmpOriginator.bitmap().width + this._spacing;
							// the following logo (head if current is tail)
							tmpOriginator = getFollowing(tmpOriginator);
						}
					}
					else // less than given logoNumber
					{
						// no change
					}
				}
				else
				{
					this._currentOriginator = this._linkedList.head as LinkedListOriginatorNode;
					tmpOriginator = this._currentOriginator;
					
					if(listSize >= this._logoNumber)
					{
						j = this._logoNumber;
					}
					else
					{
						j = listSize;
					}
					
					// add new logos to display
					i = 0;
					for (; i<j; ++i) 
					{
						tmpOriginator.bitmap().x = currentPosition.x;

						addLogoButton(tmpOriginator, currentPosition);			
						currentPosition.x += tmpOriginator.bitmap().width + this._spacing;
						
						// the following logo (head if current is tail)
						tmpOriginator = getFollowing(tmpOriginator);
					}
				}
			}
		}
		
		/**
		 * Call when the user click on a logo.
		 * 
		 * @param event The click event received.
		 */
		private function onClick(event:Event):void
		{
			if (!(event.type == MouseEvent.CLICK)) return;
			
			var btn:Button = event.currentTarget as Button;

			var originatorClick:DataOriginator = this._dataOriginators.findOriginatorByName(btn.name);
			if(originatorClick!=null)
			{
				// open a new page with the originator url
				var targetURL:URLRequest = new URLRequest(originatorClick.url);
				navigateToURL(targetURL);
			}
			
		}
		
		// getters / setters
		/**
		 * Set the map linked to this DataOriginatorsDisplay control
		 * Also add the DataOriginators contains by this class as a control on the map
		 * 
		 * @param map The current map linked to this component.
		 */
		override public function set map(map:Map):void 
		{
			super._map = map;
			
			// add the DataOriginators as a control in the map
			this._map.addControl(this._dataOriginators);
			
			// add listener to add / remove Originators
			this._dataOriginators.addEventListener(OriginatorEvent.ORIGINATOR_ADDED, this.onOriginatorAdded);
			this._dataOriginators.addEventListener(OriginatorEvent.ORIGINATOR_REMOVED, this.onOriginatorRemoved);
			
			// create logos for each originator in the DataOriginators list
			synchroniseWithDataOriginators();
		}
		
		/**
		 * The list of current originators to display on the map.
		 */
		public function get dataOriginators():DataOriginators
		{
			return this._dataOriginators;
		}
		
		/**
		 * @private
		 */
		public function set dataOriginators(dataOriginators:DataOriginators):void
		{
			this._dataOriginators = dataOriginators;
		}
		
		/**
		 * Number of logos displayed at the same time on the map.
		 */
		public function get logoNumber():Number
		{
			return this._logoNumber;
		}
		
		/**
		 * @private
		 */
		public function set logoNumber(logoNumber:Number):void
		{
			this._logoNumber = logoNumber;
		}
		
		/**
		 * LinkedLiist where the bitmap logos are stored.
		 */
		public function get linkedList():LinkedList
		{
			return this._linkedList;
		}
		
		/**
		 * @private
		 */
		public function set linkedList(linkedList:LinkedList):void
		{
			this._linkedList = linkedList;
		}

		/**
		 * The LinkedListBitmapNode of a logo (corresponding to a logo load on a bitmap).
		 */
		public function get currentOriginator():LinkedListOriginatorNode
		{
			return this._currentOriginator;
		}
		
		/**
		 * @private
		 */
		public function set currentOriginator(currentOriginator:LinkedListOriginatorNode):void
		{
			this._currentOriginator = currentOriginator;
		}
		
		/**
		 * The timer use to rotate the display of logos.
		 */
		public function get timer():Timer
		{
			return this._timer;
		}
		
		/**
		 * @private
		 */
		public function set timer(timer:Timer):void
		{
			this._timer = timer;
		}
		
		/**
		 * The time between two rotations.
		 */
		public function get delay():Number
		{
			return this._delay;
		}
		
		/**
		 * @private
		 */
		public function set delay(delay:Number):void
		{
			this._delay = delay;
		}
		
		/**
		 * The time between two rotations.
		 */
		public function get spacing():Number
		{
			return this._spacing;
		}
		
		/**
		 * @private
		 */
		public function set spacing(spacing:Number):void
		{
			this._spacing = spacing;
		}

	}
}
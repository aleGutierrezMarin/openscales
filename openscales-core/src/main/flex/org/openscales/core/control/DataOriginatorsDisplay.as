package org.openscales.core.control
{
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
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
		 * @default 30
		 * The default value for rotation cycle.
		 */
		public static var DEFAULT_SPACING:uint=30;
		
		/**
		 * @default 50
		 * The default value for rotation cycle.
		 */
		public static var DEFAULT_LOGO_WIDTH:uint=50;	
		
		/**
		 * @default 50
		 * The default value for rotation cycle.
		 */
		public static var DEFAULT_LOGO_HEIGHT:uint=50;
		
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
		 * LinkedLiist to store originator to remove at the next change
		 */
		private var _removeOriginatorList:Vector.<DataOriginator> = null;
		
		/**
		 * @private
		 * @default null
		 * LinkedLiist to store originator to add at the next change
		 */
		private var _addOriginatorList:Vector.<DataOriginator> = null;
		
		/**
		 * @private
		 * @default null
		 * The fisrt logo originator displayed on the current part of the list of logo
		 */
		private var _currentOriginator:LinkedListOriginatorNode = null;
		
		/**
		 * @private
		 * @default null
		 * The timer to control the delay between two displays.
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
		 * @private
		 * @default DEFAULT_LOGO_WIDTH
		 * The width of all displayed logos.
		 */
		private var _logoWidth:Number = DataOriginatorsDisplay.DEFAULT_LOGO_WIDTH;
			
		/**
		 * @private
		 * @default DEFAULT_LOGO_HEIGHT
		 * The height of all displayed logos.
		 */
		private var _logoHeight:Number = DataOriginatorsDisplay.DEFAULT_LOGO_HEIGHT;
		
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
			this._removeOriginatorList = new Vector.<DataOriginator>();
			this._addOriginatorList = new Vector.<DataOriginator>();
		}
		
		/**
		 * @inheritDoc
		 * 
		 * Remove the bitmap from the list and remove the listener for the timer.
		 */
		override public function destroy():void {
			
			super.destroy();
			
			if(this._timer!=null) 
			{
				this._timer.stop();
				this._timer.removeEventListener(TimerEvent.TIMER,this.changeDisplay);
				this._timer = null;
			}
			if(this._currentOriginator!=null) 
			{
				var i:uint = 0;
				var listSize:uint = this._linkedList.size;
				var j:uint = (listSize < this._logoNumber) ? listSize : this._logoNumber;
				
				for(; i<j; ++i)
				{
					this.removeChild(this._currentOriginator.bitmap);
					this._currentOriginator = this.getFollowing(this._currentOriginator);
				}
				this._currentOriginator = null;
			}
			if(this._linkedList!=null) {
				this._linkedList.clear();
				this._linkedList = null;
			}
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
			 var btn:Button = new Button(originatorNode.originator.name, originatorNode.bitmap, position);
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

			if( btn != null)
			{
				btn.removeEventListener(MouseEvent.CLICK, this.onClick);
				this.removeChild(btn);
				
			}
		 }
		
		/**
		 * @private
		 * Add a new Orginator in the list.
		 * Load its bitmap logo.
		 * When the bitmap is load, call the completeLoading function to insert the component in the linkedList
		 * 
		 * @param The originator to add.
		 */
		private function addOriginator(originator:DataOriginator):void
		{
			// if not already on the linked list
			if(this._linkedList.getIndex(originator.name)==-1)
			{
				this._linkedList.insertTail(new LinkedListOriginatorNode(originator,null,originator.name));
				originator.getImage(this.completeLoading);
			}
		}
		
		/**
		 * @private
		 * Check if the given originator is in the given list
		 * 
		 * @param originator The searched originator
		 * @param list The list where the originator is searched
		 * 
		 * @return true if the originator is infd in the list, false otherwise
		 */
		private function isOnTheList(originator:DataOriginator, list:Vector.<DataOriginator>):Boolean
		{
			var i:uint = 0;
			var j:uint = list.length;
			
			for(; i<j; ++i)
			{
				if(list[i] == originator)
				{
					return true;
				}
			}
			return false;
		}
			
		/**
		 * @private
		 * Delete a DataOriginator from a given list
		 * 
		 * @param originator The DataOriginator to remove
		 * @param list The list where the originator has to be removed
		 */
		private function removeFromList(originator:DataOriginator, list:Vector.<DataOriginator>):void
		{
			var i:uint = 0;
			var j:uint = list.length;
			
			for(; i<j; ++i)
			{
				if(list[i] == originator)
				{
					list.splice(i, 1);
					return;
				}
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
		private function completeLoading(dataOriginator:DataOriginator,event:Event):void 
		{
			if(!dataOriginator || !event)
				return;
			var i:int = this._linkedList.getIndex(dataOriginator.name);
			if(i==-1)
				return;
				
			var name:String = dataOriginator.name;
			var loaderInfo:LoaderInfo = event.target as LoaderInfo;
			var loader:Loader = loaderInfo.loader as Loader;
			var bmp:Bitmap = Bitmap(loader.content);
			bmp.addEventListener(MouseEvent.CLICK, this.onClick);
			bmp.width = this._logoWidth;
			bmp.height = this._logoHeight;
			
			(this._linkedList[i] as LinkedListOriginatorNode).bitmap = bmp;
		}
		
		/**
		 * @private
		 * Call when an originatorEvent.ORIGINATOR_ADDED occur
		 * The originator is stored in the addOriginatorList
		 * 
		 * @param event The OriginatorEvent received.
		 */
		private function onOriginatorAdded(event:OriginatorEvent):void
		{	
			// if not already in the add list :
			if(!this.isOnTheList(event.originator, this._addOriginatorList))
			{
				// if remove asked cancel it :
				if( this.isOnTheList(event.originator, this._removeOriginatorList ))
				{
					this.removeFromList(event.originator, this._removeOriginatorList);
				}
				this._addOriginatorList.push(event.originator);
			}
		}
		
		/**
		 * @private
		 * Call when an originatorEvent.ORIGINATOR_REMOVED occur
		 * The originator is stored in the removeOriginatorList
		 * 
		 * @param event The OriginatorEvent received.
		 */
		private function onOriginatorRemoved(event:OriginatorEvent):void
		{
			// if not already in the remove list :
			if(!this.isOnTheList(event.originator, this._removeOriginatorList))
			{
				// if add asked cancel it :
				if( this.isOnTheList(event.originator, this._addOriginatorList ))
				{
					this.removeFromList(event.originator, this._addOriginatorList);
				}
				this._removeOriginatorList.push(event.originator);
			}
		}
		
		/**
		 * This function check if originators are on waiting lists for add or remove.
		 *
		 * This function has to be called before a new display to be sure that the list is updated.
		 * This function is called when no logo are displayed. 
		 * 
		 */
		private function manageWaitingOriginatorList():void
		{
			var i:uint;
			var j:uint;
			
			// if originator waiting for remove
			if( this._removeOriginatorList.length > 0 )
			{
				i = 0;
				j = this._removeOriginatorList.length;

				for (; i<j; ++i) 
				{
					// if the current is deleted
					if( this._removeOriginatorList[i] == this._currentOriginator.originator )
					{
						this._currentOriginator = getPrevious(this._currentOriginator);
					}
					this.linkedList.remove(this._removeOriginatorList[i].name);
				}
				// clear the waiting list
				this._removeOriginatorList.splice(0,j);
			}
			
			// if originator waiting for add
			if( this._addOriginatorList.length > 0 )
			{
				i = 0;
				j = this._addOriginatorList.length;
				
				for (; i<j; ++i) 
				{
					this.addOriginator(this._addOriginatorList[i]);
				}
				// clear the waiting list
				this._addOriginatorList.splice(0,j);
			}
			
		}
		
		
		/**
		 * Get the following originator logo (after the originator givenn in paramters)
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
		 * Get the previous originator logo (before the originator givenn in paramters)
		 * If its the head of the list go to the tail
		 * 
		 * @param originator The LinkedListOriginatorNode to get the following
		 * @return the following OriginatorNode
		 */
		private function getPrevious(originator:LinkedListOriginatorNode):LinkedListOriginatorNode
		{
			if(originator != this._linkedList.head)
			{
				return originator.previousNode as LinkedListOriginatorNode;
			}
			else
			{
				return this._linkedList.tail as LinkedListOriginatorNode;
			}
		}
		
		/**
		 * @private
		 * Change the current originator to the following one according to the _logoNumber 
		 * if the LinkedList size is superior than the given logoNumber.
		 * Else, no chnage
		 */
		private function moveToNextCurrent():void
		{
			if( this._linkedList.size > this._logoNumber )
			{
				var i:uint = 0;
				for(; i<this._logoNumber; ++i)
				{
					this._currentOriginator = getFollowing(this._currentOriginator);
				}
			}
		}
		
		/**
		 * Change the logos display (because delay betewen two changes is spent)
		 * 
		 * @param event The event received.
		 */
		public function changeDisplay(event:Event):void
		{	
			var listSize:Number = this._linkedList.size;
			
			if(listSize>0) 
			{
				// to progress on the list wihtout changing the current Originator
				var tmpOriginator:LinkedListOriginatorNode = this._currentOriginator;
				
				var i:uint = 0;
				var max:uint = this._linkedList.size;
				// if enought logo display logoNumber, else display the number max of logo in the list		
				var j:uint = (listSize < this._logoNumber) ? listSize : this._logoNumber;
				var currentPosition:Pixel = position;
				
				// first time : first init
				if(tmpOriginator == null)
				{
					this._currentOriginator = this._linkedList.head as LinkedListOriginatorNode;
					tmpOriginator = this._currentOriginator;
					
					// add new logos to display
					i = 0;
					while ( i<j && max>0 ) {
						--max;
						if(!tmpOriginator.bitmap)
							continue;
						++i;
						tmpOriginator.bitmap.x = currentPosition.x;
						
						addLogoButton(tmpOriginator, currentPosition);			
						currentPosition.x += this._spacing;
						// the following logo (head if current is tail)
						tmpOriginator = getFollowing(tmpOriginator);
					}
				}
				else
				{
					// remove current logo from the scene
					i = 0;
					while ( i<j && max<0 ) {
						--max;
						if(!tmpOriginator.bitmap)
							continue;
						++i;
						/// this.removeChild(this._currentOriginator.bitmap());
						removeLogoButton(tmpOriginator);
						
						// the following logo (head if current is tail)
						tmpOriginator = getFollowing(tmpOriginator);
					}
					
					// remove oiginator if necessary while no originator display
					this.manageWaitingOriginatorList();	
					
					// update j with the new linkedList size
					if( listSize != this._linkedList.size )
					{
						listSize = this._linkedList.size;
						j = (listSize < this._logoNumber) ? listSize : this._logoNumber;;
					}
				
					// change this._currentOriginator
					this.moveToNextCurrent();
					
					// add new logos to display
					i = 0;		
					tmpOriginator = this._currentOriginator;
					i = 0;
					while ( i<j && max<0 ) {
						--max;
						if(!tmpOriginator.bitmap)
							continue;
						++i;
						tmpOriginator.bitmap.x = currentPosition.x;
						
						addLogoButton(tmpOriginator, currentPosition);
						
						currentPosition.x += this._spacing;
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
		 * LinkedLiist to store originator to remove at the next change
		 */
		public function get removeOriginatorList():Vector.<DataOriginator>
		{
			return this._removeOriginatorList;
		}
		/**
		 * @private
		 */
		public function set removeOriginatorList(removeOriginatorList:Vector.<DataOriginator>):void
		{
			this._removeOriginatorList = removeOriginatorList;
		}
		
		/**
		 * LinkedLiist to store originator to add at the next change
		 */
		public function get addOriginatorList():Vector.<DataOriginator>
		{
			return this._addOriginatorList;
		}
		/**
		 * @private
		 */
		public function set addOriginatorList(addOriginatorList:Vector.<DataOriginator>):void
		{
			this._addOriginatorList = addOriginatorList;
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
		
		/**
		 * The width of all displayed logos.
		 */
		public function get logoWidth():Number
		{
			return this._logoWidth;
		}
		
		/**
		 * @private
		 */
		public function set logoWidth(spacing:Number):void
		{
			this._logoWidth = logoWidth;
		}
		
		/**
		 * The height of all displayed logos.
		 */
		public function get logoHeight():Number
		{
			return this._logoHeight;
		}
		
		/**
		 * @private
		 */
		public function set logoHeight(spacing:Number):void
		{
			this._logoHeight = logoHeight;
		}
	}
}
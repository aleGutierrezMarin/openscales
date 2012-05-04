package org.openscales.core.control
{
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import org.openscales.core.basetypes.linkedlist.LinkedList;
	import org.openscales.core.basetypes.linkedlist.LinkedListBitmapNode;
	import org.openscales.core.request.DataRequest;
	import org.openscales.geometry.basetypes.Pixel;
	
	/**
	 * Control allowing display of alternating logo
	 */
	public class LogoRotator extends Control
	{
		public static var DEFAULT_ROTATION_CYCLE:uint=2000;
		private var _ll:LinkedList = null;
		private var _dn:LinkedListBitmapNode = null;
		private var _tm:Timer = null;
		private var _dr:Number = LogoRotator.DEFAULT_ROTATION_CYCLE;
		
		/**
		 * Constructor
		 * @param position:Pixel the position of the control
		 */
		public function LogoRotator(position:Pixel=null)
		{
			super(position);
			this._ll = new LinkedList();
		}
		
		/**
		 * getter of the ttl between to logo
		 * @return Number the ttl
		 */
		public function get ttl():Number {
			return this._dr;
		}
		/**
		 * setter of the ttl between to logo
		 * @param v:Number the ttl
		 */
		public function set ttl(v:Number):void {
			this._dr = v;
			if(this._tm!=null) {
				this._tm.stop();
				this._tm.reset();
				this._tm.delay = this._dr;
				this._tm.start();
			}
		}
		
		/**
		 * add a new logo represented by a url
		 * @param url:String the url of the logo
		 */
		public function addUrlLogo(url:String):void {
			var _req:DataRequest;
			_req = new DataRequest(url, updateImages);
			_req.proxy = this.map.getProxy(url);
			_req.send();
		}
		
		/**
		 * add a new logo represented by a bitmap
		 * @param bmp:Bitmap the bitmap
		 */
		public function addBitmapLogo(bmp:Bitmap):void {
			this._ll.insertTail(new LinkedListBitmapNode(bmp));
		}
		
		private function updateImages(e:Event):void {
			var _url:String = e.target.loader.name;
			var _bmp:Bitmap = Bitmap(e.target.loader.content);
			this._ll.insertTail(new LinkedListBitmapNode(_bmp,_url));
		}
		
		private function rotate(e:Event):void {
			if(this._ll.size>0) {
				if(this._dn == null || this._dn == this._ll.tail) {
					if(this._dn!=null)
						this.removeChild(this._dn.bitmap);
					this._dn = this._ll.head as LinkedListBitmapNode;
					this.addChild(this._dn.bitmap);
				} else {
					if(this._ll.size>1) {
						this.removeChild(this._dn.bitmap);
						this._dn = this._dn.nextNode as LinkedListBitmapNode;
						this.addChild(this._dn.bitmap);
					}
				}
			}
		}
		
		override public function destroy():void {
			super.destroy();
			if(this._tm!=null) {
				this._tm.stop();
				this._tm.removeEventListener(TimerEvent.TIMER,this.rotate);
				this._tm = null;
			}
			if(this._dn!=null) {
				this.removeChild(this._dn.bitmap);
				this._dn = null;
			}
			if(this._ll!=null) {
				this._ll.clear();
				this._ll = null;
			}
		}
		
		override public function draw():void {
			if(this._tm!=null)
				return;
			this._tm = new Timer(this._dr,0);
			this._tm.addEventListener(TimerEvent.TIMER,this.rotate);
			this._tm.start();
		}

	}
}
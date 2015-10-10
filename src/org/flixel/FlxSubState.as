package org.flixel
{
	import org.flixel.FlxState;

	/**
	 * @author andreas
	 */
	public class FlxSubState extends FlxState
	{
		//Default background color is transparent
		public function FlxSubState(isBlocking:Boolean)
		{
			super();
			_isBlocking = isBlocking;
		}
		
		private var _isBlocking:Boolean;
		public function get isBlocking():Boolean { return _isBlocking; }
		public function set isBlocking(value:Boolean):void { _isBlocking = value; } 
		
		//Use the already existing protected variable "_bgColor"
		private var _bgColor:uint;
		public function get bgColor():uint { return this._bgColor; }
		public function set bgColor(value:uint):void {	this._bgColor = value; }
			
		override public function draw() : void 
		{
			//Draw background
			if(cameras == null) { cameras = FlxG.cameras; }
			var i:uint = 0;
			var l:uint = cameras.length;
			while(i < l)
			{
				var camera:FlxCamera = cameras[i++];
				camera.fill(this.bgColor);
			}
			
			//Now draw all children
			super.draw();
		}
		
		//This looks ugly. :(
		internal var parentState:FlxState;
		public function get isSubState():Boolean { return Boolean(parentState); }
		
		public function close():void
		{
			if (parentState)
				parentState.subStateCloseHandler();
			else
				trace("Missing parent from this state! Do something!!");
		}
	}
}
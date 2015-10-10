package  
{
	import flash.display.DisplayObject;
	import org.flixel.*;
	
	/**
	 * ...
	 * @author ...
	 */
	public class FlashObject extends FlxBasic 
	{
		/**
		 * sometimes it's easier working with directly with the flash object in question.
		 */
		public var object:DisplayObject;
		/**
		 * The basic speed of this object.
		 */
		public var velocity:FlxPoint;
		/**
		 * How fast the speed of this object is changing.
		 * Useful for smooth movement and gravity.
		 */
		public var acceleration:FlxPoint;
		/**
		 * This isn't drag exactly, more like deceleration that is only applied
		 * when acceleration is not affecting the sprite.
		 */
		public var drag:FlxPoint;
		/**
		 * If you are using <code>acceleration</code>, you can use <code>maxVelocity</code> with it
		 * to cap the speed automatically (very useful!).
		 */
		public var maxVelocity:FlxPoint;
		
		/**
		 * DON'T FORGET to add this to a parent object or the stage as well as the display list.
		 * That way destroy will be called when you switch states :)
		 */
		public function FlashObject(X:Number, Y:Number)
		{
			super();
			velocity = new FlxPoint();
			acceleration = new FlxPoint();
			drag = new FlxPoint();
			maxVelocity = new FlxPoint(10000, 10000);
			this.x = X;
			this.y = Y;
			FlxG.flashObjects.addChild(object); //adds the text in front of the camera, but behind the debugger and other layers.
		}
		
		override public function update():void
		{
			updateMotion();
		}
		
		/**
		 * copied from FlxObject
		 * @author CC
		 */
		protected function updateMotion():void
		{
			var delta:Number;
			var velocityDelta:Number;
			
			velocityDelta = (FlxU.computeVelocity(velocity.x,acceleration.x,drag.x,maxVelocity.x) - velocity.x)/2;
			velocity.x += velocityDelta;
			delta = velocity.x*FlxG.elapsed;
			velocity.x += velocityDelta;
			x += delta;
			
			velocityDelta = (FlxU.computeVelocity(velocity.y,acceleration.y,drag.y,maxVelocity.y) - velocity.y)/2;
			velocity.y += velocityDelta;
			delta = velocity.y*FlxG.elapsed;
			velocity.y += velocityDelta;
			y += delta;
		}
		
		override public function destroy():void
		{
			object.parent.removeChild(object);
			velocity = null;
			acceleration = null;
			drag = null;
			maxVelocity = null;
			object = null;
			super.destroy();
		}
		
		//since it's not an FlxObject, all coordinates have to be adjusted relative to camera zoom.
		public function get x():Number
		{return object.x / FlxG.camera.zoom;}
		public function set x(X:Number):void
		{object.x = X * FlxG.camera.zoom;}
		
		public function get y():Number
		{return object.y / FlxG.camera.zoom;}
		public function set y(Y:Number):void
		{object.y = Y * FlxG.camera.zoom; } 
		
		public function get alpha():Number
		{return object.alpha;}
		public function set alpha(Alpha:Number):void
		{object.alpha = Alpha; }
		
		public function get width():Number
		{return object.width / FlxG.camera.zoom;}
		public function set width(Width:Number):void
		{object.width = Width * FlxG.camera.zoom; }
		
		public function get height():Number
		{return object.height / FlxG.camera.zoom;}
		public function set height(Height:Number):void
		{object.height = Height * FlxG.camera.zoom;}
	}

}
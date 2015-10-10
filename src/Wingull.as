package  
{
	import org.flixel.*;
	/**
	 * ...
	 * @author ...
	 */
	public class Wingull extends FlxSprite
	{
		private var wasOnScreen:Boolean;
		
		public function Wingull(X:Number, Y:Number)
		{
			this.x = X;
			this.y = Y;
			wasOnScreen = false;
			loadGraphic(Sources.ImgWingull, true, false, 48, 48);
			offset.x = 5;
			offset.y = 13;
			width = 38;
			height = 18;
			addAnimation("explode", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 14], 24);
			addAnimationCallback(animationCallback);
			velocity.x = -30;
		}
		
		override public function update():void
		{
			super.update();
			
			var isOnScreen:Boolean = onScreen();
			if (isOnScreen && !wasOnScreen)
				FlxG.play(Sources.Mp3birdCry);
			wasOnScreen = isOnScreen;
		}
		
		override public function kill():void 
		{
			play("explode");
			FlxG.play(Sources.Mp3explosion2);
			this.solid = this.alive = false;
		}
		
		private function animationCallback(name:String, frameIndex:uint, frameNumber:uint):void
		{
			if (name == "explode" && frameIndex == 15)
				super.kill();
		}
		
	}

}
package  
{
	import org.flixel.*;
	import flash.display.Bitmap;
	
	/**
	 * ...
	 * @author ...
	 */
	public class StartScreenState extends FlxState 
	{
		private var background:Bitmap;
		private var waitCounter:Number;
		
		override public function create():void 
		{
			waitCounter = 0;
			
			background = new Sources.ImgStartScreen;
			FlxG.flashObjects.addChild(background);
			
			if (FlxG.music == null)
				FlxG.music = new FlxSound();
			FlxG.music.survive = true;
			FlxG.music.loadEmbedded(Sources.Mp3startScreen).play();
		}
		
		override public function update():void
		{
			waitCounter += FlxG.elapsed;
			if (waitCounter >= 2.3 && FlxG.keys.any() && background.alpha >= 1)
			{
				background.alpha -= 0.01;
				FlxG.music.fadeOut(1);
			}	
				
			if (background.alpha < 1 && background.alpha > 0)
				background.alpha -= FlxG.elapsed;
			else if (background.alpha <= 0)
				FlxG.switchState(new IntroState);
		}
		
		override public function destroy():void
		{
			FlxG.flashObjects.removeChild(background);
		}
		
	}

}
package  
{
	import org.flixel.*;
	import org.flixel.plugin.photonstorm.FlxSpecialFX;
	import org.flixel.plugin.photonstorm.FX.GlitchFX;
	import flash.geom.Point;
	
	/**
	 * @author CC
	 */
	public class GlitchScreen
	{
		public var canvas:FlxSprite;
		private var glitch:GlitchFX;
		
		public function GlitchScreen()
		{
			if (FlxG.getPlugin(FlxSpecialFX) == null)
				FlxG.addPlugin(new FlxSpecialFX());
			glitch = FlxSpecialFX.glitch();
			var screenShot:FlxSprite = new FlxSprite(-2).makeGraphic(FlxG.width, FlxG.height, 0xffffffff, true);
			screenShot.pixels.copyPixels(FlxG.camera.buffer, FlxG.camera.buffer.rect, new Point);
			canvas = glitch.createFromFlxSprite(screenShot, 6, 2);
			glitch.start(2);
			FlxG.music.pause();
			FlxG.music.exists = false;
			FlxG.play(Sources.Mp3actualNoiseItMade);
		}
		
		public function stop():void
		{
			glitch.stop();
			canvas.exists = false;
		}
		
	}

}
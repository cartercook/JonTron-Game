package  
{
	import org.flixel.*;
	
	/**
	 * hud element in the top-right corner counting from 9 to 0 in the JonTron font
	 * in a blatant nod to yoshi's island.
	 * @author CC
	 */
	public class CountDown extends FlxSprite 
	{
		
		public function CountDown() 
		{
			super();
			loadGraphic(Sources.ImgNumbers, true, false, 48, 48)
			addAnimation('decrease', [9, 8, 7, 6, 5, 4, 3, 2, 1, 0], 1);
			scrollFactor.x = scrollFactor.y = 0; //hud element, no moving.
			x = FlxG.width - width - 6; //offset from screen corners by 6 pixels
			y = 6;
			this.kill();
		}
		
		override public function revive():void
		{
			this.play('decrease', true);
			super.revive();
		}
		
	}

}
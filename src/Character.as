package  
{
	import org.flixel.FlxSprite;
	
	/**
	 * base of moving sprites - player and enemies. Contains a bunch of shared
	 * functions and things, as well as an index for z-sorting.
	 * @author CC
	 */
	public class Character extends FlxSprite 
	{
		internal var _damageText:FlxGroup;
		internal var _timerManager:TimerManager;
		
		public function Character(X:Number=0, Y:Number=0, SimpleGraphic:Class=null) 
		{
			super(X, Y, SimpleGraphic);
			
		}
		
	}

}
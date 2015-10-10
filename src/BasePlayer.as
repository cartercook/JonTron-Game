package  
{
	import org.flixel.*;
	
	/**
	 * important stuuf that no player can go without!!!
	 * @author CC
	 */
	public class BasePlayer extends FlxSprite 
	{
		/**
		 * while the player is calling update(), vulnerabileTime will count down until it reaches zero.
		 */
		public var vulnerableTime:Number;
		public var controllable:Boolean;
		protected var _pressOrder:Array;
		protected var speed:Number;
		
		public function BasePlayer()
		{
			vulnerableTime = 0;
			controllable = true;
			_pressOrder = new Array(0, 0, 0, 0);
			speed = 75;
		}
		
		/**
		 * This function stores the most recent arrowkey presses in the _pressOrder array, and keeps its length at 4.
		 */
		protected function sortKeyPress(): void
		{
			sortKeyPressHelper(FlxG.keys.UP || FlxG.keys.W, UP);
			sortKeyPressHelper(FlxG.keys.DOWN || FlxG.keys.S, DOWN);
			sortKeyPressHelper(FlxG.keys.LEFT || FlxG.keys.A, LEFT);
			sortKeyPressHelper(FlxG.keys.RIGHT || FlxG.keys.D, RIGHT);
		}
		
		private function sortKeyPressHelper(keyPressed:Boolean, Direction:int):void
		{
			var index:int = _pressOrder.indexOf(Direction);
			var i:int; //Flash is pissy and doesn't let you declare multiples of the same index variable
			if (keyPressed) //if up arrow pressed 
			{
				if (index < 0) //if Direction isn't in pressOrder
				{
					for (i = _pressOrder.length - 1; i > 0; i--)
						_pressOrder[i] = _pressOrder[i - 1]; //move all _pressOrder entries to make space
					_pressOrder[0] = Direction; //insert Direction at the bottom
				}
			}
			else if (index >= 0)
			{
				for (i = index + 1; i < _pressOrder.length; i++)
					_pressOrder[i - 1] = _pressOrder[i];
				_pressOrder[_pressOrder.length - 1] = 0;
			}
		}
		
	}
}
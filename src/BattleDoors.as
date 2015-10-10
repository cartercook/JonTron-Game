package  
{
	import org.flixel.*;
	
	/**
	 * @author CC
	 */
	public class BattleDoors extends FlxGroup 
	{
		public var leftDoor:FlxSprite;
		public var rightDoor:FlxSprite;
		private var counter:int;
		
		public function BattleDoors() 
		{
			super();
			counter = 0;
			
			leftDoor = new FlxSprite(-FlxG.width / 2, 0, Sources.ImgBattleDoor);
			rightDoor = new FlxSprite(FlxG.width).loadGraphic(Sources.ImgBattleDoor, false, true);
			rightDoor.facing = FlxObject.LEFT;
			leftDoor.scrollFactor.x = rightDoor.scrollFactor.y = 0;
			rightDoor.scrollFactor.x = leftDoor.scrollFactor.y = 0;
			leftDoor.elasticity = rightDoor.elasticity = 0.3;
			leftDoor.ID = 0;
			leftDoor.velocity.x = rightDoor.velocity.x = 0;
			leftDoor.acceleration.x = 1200;
			rightDoor.acceleration.x = -1200;
			add(leftDoor);
			add(rightDoor);
		}
		
		public function collisionCallback(Object1:FlxObject, Object2:FlxObject): void
		{
			counter++;
			if (counter == 1)
				FlxG.play(Sources.Mp3battleDoorSlam);
			else if (counter == 2)
			{
				leftDoor.acceleration.x = rightDoor.acceleration.x = 0;
				leftDoor.velocity.x = rightDoor.velocity.x = 0;
				new FlxTimer().start(0.5, 1);
			}
		}
	}

}
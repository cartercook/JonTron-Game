package  
{
	import org.flixel.*;
	import org.flixelPP.FlxSpritePP;
	
	public class JonShip extends FlxSpritePP
	{
		public var vulnerable:Boolean;
		public var controllable:Boolean;
		private var elapsed:Number;
		public var speed:Number;
		
		public function JonShip()
		{
			//set variables
			controllable = true;
			vulnerable = true;
			speed = 75;
			elapsed = 0;
			
			loadGraphic(Sources.ImgRocket, true, false, 80, 52);
			addAnimation('drawShoot', [1, 2, 3, 4, 5], 18, false);
			addAnimation('shoot', [2, 3, 4, 5], 18, false);
			addAnimation('stowGun', [1, 0], 12, false);
			addAnimation('explode', [7, 8, 9, 10, 11, 12], 10);
		}
		
		override public function update():void
		{
			if (controllable)
			{
				//reset player speed after every update
				velocity.x = 0;
				velocity.y = 0;
				
				var right:Boolean = (FlxG.keys.RIGHT || FlxG.keys.D);
				var left:Boolean = (FlxG.keys.LEFT || FlxG.keys.A);
				var up:Boolean = (FlxG.keys.UP || FlxG.keys.W);
				var down:Boolean = (FlxG.keys.DOWN || FlxG.keys.S);
				var verticalTouch:Boolean = isTouching(UP | DOWN)
				var horizontalTouch:Boolean = isTouching(LEFT | RIGHT)
				
				//this is done without this.velocty because it interferes with the gravity sequence in spaceState
				if (left && right)
				{} //velocity.x = 0
				else if (left && (up || down))
				{
					if (verticalTouch)
						x += -speed * FlxG.elapsed; //compensates for touching walls
					else
						x += ( -speed / Math.SQRT2) * FlxG.elapsed; //75^2 = x^2 + x^2, x = 75 / Math.sqrt(2);
				}
				else if (right && (up || down))
				{
					if (verticalTouch)
						x += speed * FlxG.elapsed;
					else
						x += (speed / Math.SQRT2) * FlxG.elapsed;
				}
				else if (left)
					x += -speed * FlxG.elapsed;
				else if (right)
					x += speed * FlxG.elapsed;
				
				if (up && down) //now determine y velocity
				{}
				else if (up && (left || right))
				{
					if (horizontalTouch)
						y += -speed * FlxG.elapsed;
					else
						y += ( -speed / Math.SQRT2) * FlxG.elapsed;
				}
				else if (down && (left || right))
				{
					if (horizontalTouch)
						y += speed * FlxG.elapsed;
					else
						y += (speed / Math.SQRT2) * FlxG.elapsed;	
				}
				else if (up)
					y += -speed * FlxG.elapsed;
				else if (down)
					y += speed * FlxG.elapsed;
			}
			
			//slowly increase speed over time
			if (speed < 150)
				speed += (75 * FlxG.elapsed) / (60 * 4.5);
			
			//updates flashing animation
			if (!vulnerable && controllable)
			{
				elapsed += FlxG.elapsed;
				if (elapsed >= 0.125)
				{
					elapsed = 0;
					visible = !visible;
				}
			}
			else if (vulnerable && !visible)
				visible = true;
		}
		
		override public function kill():void
		{
			alive = false;
			speed = 75;
		}
	}
}
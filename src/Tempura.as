package  
{
	import org.flixel.*;
	import org.flixel.plugin.photonstorm.FlxCollision;
	
	/**
	 * @author CC
	 */
	public class Tempura extends FlxSprite
	{
		
		public function Tempura(X:Number, Y:Number, Facing:uint = FlxObject.RIGHT, useShrimpGraphic:Boolean = true)
		{
			var graphic:Class;
			if (useShrimpGraphic)
				graphic = Sources.ImgShrimp;
			else
				graphic = Sources.ImgOnionRing;
			super(X, Y, graphic);
			
			this.facing = Facing;
			if (facing == LEFT)
				this.velocity.x = -50;
			else if (facing == RIGHT)
				this.velocity.x = 50;
			
			this.acceleration.y = 370;
		}
		
		override public function update():void
		{
			if (this.alive)
			{
				if (this.isTouching(DOWN))
					this.velocity.y = -120;
				if (this.isTouching(LEFT))
				{
					this.facing = RIGHT;
					this.velocity.x = 50;
				}
				else if (this.isTouching(RIGHT))
				{
					this.facing = LEFT
					this.velocity.x = -50;
				}
			}
		}
		
		public function hitPlayer(player:Jon):Boolean
		{
			if (player.velocity.y > 0)
			{
				player.jump();
				this.alive = false;
				this.velocity.x = 0;
				
				//resize sprite and hitbox
				this.scale.y = 0.4;
				this.height = frameHeight * scale.y;
				this.offset.y = frameHeight * 0.5 * (1 - scale.y);
				this.scale.x = 1.4;
				this.width = frameWidth * scale.x;
				this.offset.x = frameWidth * 0.5 * (1 - scale.x);
				this.y += frameHeight - height;
				return false;
			}
			return true;
		}
		
	}

}
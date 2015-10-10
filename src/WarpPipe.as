package  
{
	import org.flixel.*;
	
	/**
	 * 
	 * @author CC
	 */
	public class WarpPipe extends FlxSprite
	{
		private var player:Jon;
		
		public function WarpPipe(X:Number, Y:Number, Player:Jon)
		{
			super(X, Y, Sources.ImgSMWpipe);
			this.player = Player;
			this.elasticity = 1;
			this.immovable = true;
		}
		
		override public function update():void
		{
			FlxG.collide(player, this, collisionCallback);
		}
		
		private function collisionCallback(obj1:FlxObject, obj2:FlxObject):void
		{
			if (player.y + player.height <= this.y)
				player.jump();
			if (this.velocity.x == 0)
			{
				if (player.getMidpoint().x <= this.getMidpoint().x)
				{
					this.velocity.x = 100;
					this.skew.x = 0.25;
				}
				else
				{
					this.velocity.x = -100;
					this.skew.x = -0.25;
				}
			}
			else
			{
				if (player.y + player.height <= this.y)
				{
					this.velocity.x = 0;
					this.skew.x = 0;
				}
				else
					player.kill();
			}
		}
		
	}

}
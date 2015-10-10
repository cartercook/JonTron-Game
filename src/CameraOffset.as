package
{
	import org.flixel.*;
	
	public class CameraOffset extends FlxObject
	{
		public var Xoffset:Number;
		public var Yoffset:Number;
		private var player:Jon;
		
		public function CameraOffset(Player:Jon, Xoffset:Number, Yoffset:Number)
		{
			this.player = Player;
			this.Xoffset = Xoffset;
			this.Yoffset = Yoffset;
			super(player.x, player.y);
			kill();
		}
		
		override public function update():void
		{
			var midpoint:FlxPoint = player.getMidpoint();
			if (this.y < midpoint.y)
			{
				this.Yoffset += 150 * FlxG.elapsed;
				this.x = midpoint.x;
				this.y = midpoint.y + Yoffset;
				if (this.y >= midpoint.y)
				{
					FlxG.camera.follow(player);
					this.kill();
				}
			}
			
			trace(x, y);
			
			/*if(player.getPlatformerMode())
			{
				if (this.y != player.y + Yoffset)
				{
					if (this.y < player.y + Yoffset)
						this.velocity.y = -1;
					else
					{
						this.y = player.y + Yoffset;
						this.velocity.y = 0;
					}
					if (this.x != player.x + Xoffset)
					{
						if (this.x < player.x + Xoffset)
							this.velocity.x = 1;
						else
						{
							this.x = player.x + Xoffset;
							this.velocity.x = 0;
						}
					}
				}
				else
				{
					if (this.y < player.y)
						this.velocity.y = 1;
					else
						this.velocity.y = 0;
					if (this.x > player.x)
						this.velocity.x = -1;
					else
						this.velocity.x = 0;
				}
			}
			else
			{
				var midpoint:FlxPoint = player.getMidpoint();
				this.x = midpoint.x;
				this.y = midpoint.y;
			}*/
		}
		
		override public function revive():void
		{
			var midpoint:FlxPoint = player.getMidpoint();
			this.Yoffset = (FlxG.camera.scroll.y + FlxG.height / 2) - midpoint.y;
			this.Xoffset = (FlxG.camera.scroll.x + FlxG.width / 2) - midpoint.x;
			this.y = player.y + Yoffset;
			this.x = player.x + Xoffset;
			trace(x, y);
			super.revive();
			FlxG.camera.follow(this);
		}
	}
}
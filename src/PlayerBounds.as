package  
{
	import org.flixel.*;
	
	/**
	 * creates 16 pixel wide FlxTiles around the stage
	 * @author ...
	 */
	public class PlayerBounds extends FlxGroup 
	{
		public var area:FlxRect;
		public function PlayerBounds(LeftBound:Number = 0, TopBound:Number = 0, RightBound:Number = NaN, BottomBound:Number = NaN)
		{
			super();
			
			if (isNaN(RightBound))
				RightBound = FlxG.width;
			if (isNaN(BottomBound))
				BottomBound = FlxG.height;
			area = new FlxRect(LeftBound - 16, TopBound - 16,  RightBound - LeftBound + 32, BottomBound - TopBound + 32);
			
			var leftBlock:FlxTileblock = new FlxTileblock(LeftBound - 16, TopBound, 16, BottomBound - TopBound);
			leftBlock.allowCollisions = FlxObject.LEFT;
			add(leftBlock);
			
			var rightBlock:FlxTileblock = new FlxTileblock(RightBound, TopBound, 16, BottomBound - TopBound);
			leftBlock.allowCollisions = FlxObject.WALL;
			add(rightBlock);
			
			var topBlock:FlxTileblock = new FlxTileblock(LeftBound, TopBound - 16, RightBound - LeftBound, 16);
			topBlock.allowCollisions = FlxObject.DOWN;
			add(topBlock);
			
			var bottomBlock:FlxTileblock = new FlxTileblock(LeftBound, BottomBound, RightBound - LeftBound, 16);
			bottomBlock.allowCollisions = FlxObject.UP;
			add(bottomBlock);
		}
	}

}
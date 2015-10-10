//Code generated with DAME. http://www.dambots.com

package
{
	import org.flixel.*;
	public class BaseLevel
	{
		public var masterLayer:FlxGroup = new FlxGroup;

		public var mainLayer:FlxTilemap;

		public var boundsMinX:int;
		public var boundsMinY:int;
		public var boundsMaxX:int;
		public var boundsMaxY:int;

		public function BaseLevel() { }

		/**
		 * modded from the flexelSimple lua exporter. set frameHeight/Width = null
		 * if your sprite isn't animated.
		 * 
		 * @param	graphic		The image you want to use.
		 * @param	group		The group you want to add it to
		 * @param	x
		 * @param	y
		 * @param	offsetX		displaces the bounding box (not the sprite) horizontally
		 * @param	offsetY		displaces the bounding box (not the sprite) vertically
		 * @param	boundWidth	bounding box width, NaN = default value
		 * @param	boundHeight	bounding box height, NaN = default value
		 * @param	flipped		whether or not to flip the graphic
		 * @param	frameWidth	for animated sprites only, NaN = no animation
		 * @param	frameHeight	for animated sprites only, NaN = no animation
		 */
		public function addSpriteToLayer(graphic:Class, group:FlxGroup, x:Number, y:Number, offsetX:Number=0, offsetY:Number=0, boundWidth:Number=NaN, boundHeight:Number=NaN, flipped:Boolean=false, frameWidth:Number=NaN, frameHeight:Number=NaN):FlxBasic
		{
			var obj:FlxSprite;
			if (isNaN(frameHeight) || isNaN(frameWidth))
				obj = new FlxSprite(x, y, graphic);
			else
				obj = new FlxSprite(x, y).loadGraphic(graphic, true, false, frameWidth, frameHeight);
			obj.x += offsetX;
			obj.y += offsetY;
			obj.offset.x = offsetX;
			obj.offset.y = offsetY;
			if (!isNaN(boundWidth))
				obj.width = boundWidth;
			if (!isNaN(boundHeight))
				obj.height = boundHeight;
			obj.immovable = true;
			// Only override the facing value if the class didn't change it from the default.
			if( obj.facing == FlxObject.RIGHT )
				obj.facing = flipped ? FlxObject.LEFT : FlxObject.RIGHT;
			if (graphic == Sources.ImgHouse2 || graphic == Sources.ImgHouseBig || graphic == Sources.ImgHouse1)
			{
				var house:FlxGroup = new FlxGroup;
				var door:FlxObject;
				if (graphic == Sources.ImgHouse1)
				{
					door = new FlxSprite(obj.x - obj.offset.x + 6, obj.y - obj.offset.y + 56, Sources.ImgDoor);
					door.height += 2;
				}
				else if (graphic == Sources.ImgHouseBig)
				{
					door = new FlxObject(obj.x - obj.offset.x + 61, obj.y - obj.offset.y + 67, 16, 15);
				}
				else if (graphic == Sources.ImgHouse2)
				{
					door = new FlxSprite(obj.x - obj.offset.x + 32, obj.y - obj.offset.y + 56, Sources.ImgDoor);
					door.height += 2;
				}
				door.immovable = true;
				house.add(obj);
				house.add(door);
				group.add(house);
				return house;
			}
			group.add(obj);
			return obj;
		}

		public function addSpritesForLayerGroup1Zsort(onAddCallback:Function = null):void { }
		public function addSpritesForLayerGroup1front(onAddCallback:Function = null):void { }
	}
}

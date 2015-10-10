//Code generated with DAME. http://www.dambots.com

package 
{
	import org.flixel.*;
	public class Level_OverWorld extends BaseLevel
	{
		//Embedded media...
		[Embed(source="mapCSV_Group1_Map.csv", mimeType="application/octet-stream")] public var CSV_Group1Map:Class;
		[Embed(source="tileset.png")] public var Img_Group1Map:Class;

		//Tilemaps
		public var layerGroup1Map:FlxTilemap;

		//Sprites
		public var Group1ZsortGroup:FlxGroup = new FlxGroup;
		public var Group1frontGroup:FlxGroup = new FlxGroup;


		public function Level_OverWorld(addToStage:Boolean = true, onAddSpritesCallback:Function = null)
		{
			// Generate maps.
			layerGroup1Map = new FlxTilemap;
			layerGroup1Map.loadMap(new CSV_Group1Map, Img_Group1Map, 16,16, FlxTilemap.OFF, 0, 1, 320);
			layerGroup1Map.x = 0;
			layerGroup1Map.y = 0;
			layerGroup1Map.scrollFactor.x = 1;
			layerGroup1Map.scrollFactor.y = 1;

			//Add layers to the master group in correct order.
			masterLayer.add(layerGroup1Map);
			masterLayer.add(Group1ZsortGroup);
			masterLayer.add(Group1frontGroup);


			if ( addToStage )
			{
				addSpritesForLayerGroup1Zsort(onAddSpritesCallback);
				addSpritesForLayerGroup1front(onAddSpritesCallback);
				FlxG.state.add(masterLayer);
			}

			boundsMinX = 0;
			boundsMinY = 0;
			boundsMaxX = 976;
			boundsMaxY = 2400;

		}

		override public function addSpritesForLayerGroup1Zsort(onAddCallback:Function = null):void
		{
			addSpriteToLayer(Sources.ImgHouseBig, Group1ZsortGroup, 115, 1147, 1, 24, 141, 58);//"houseBig"
			addSpriteToLayer(Sources.ImgHouseBig, Group1ZsortGroup, 307, 1147, 1, 24, 141, 58);//"houseBig"
			addSpriteToLayer(Sources.ImgStore, Group1ZsortGroup, 561, 1151, 3, 50, 87, 57);//"store"
			addSpriteToLayer(Sources.ImgBrokenArwing, Group1ZsortGroup, 338, 941, 7, 55, 18, 8);//"brokenArwing"
		}

		override public function addSpritesForLayerGroup1front(onAddCallback:Function = null):void
		{
			
		}


	}
}

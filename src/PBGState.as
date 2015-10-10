package  
{
	import org.flixel.*;
	
	/**
	 * 
	 * @author CC
	 */
	public class PBGState extends FlxState 
	{
		private var jacques:Jacques;
		private var playerBounds:PlayerBounds;
		private var player:Jon;
		private var pbg:FlxSprite;
		private var objectBounds:FlxGroup;
		private var textbox:TextBox;
		private var applesAndGrapes:FlashBitmap;
		
		override public function create():void
		{
			super.create();
			FlxG.bgColor = 0xff000000;
			
			var background:FlxSprite = new FlxSprite(0, 0, Sources.ImgPbgHouse);
			background.x = FlxG.width / 2 - background.width / 2;
			background.y = FlxG.height / 2 - background.height / 2;
			add(background);
			
			playerBounds = new PlayerBounds(background.x, background.y + 16, background.x + background.width - 1, background.y + background.height - 1);
			add(playerBounds);
			
			objectBounds = new FlxGroup;
			add(objectBounds);
			
			addObjectBounds(71, 30, 19, 67); //left bookshelf
			addObjectBounds(179, 77, 20, 67); //right bookshelf
			addObjectBounds(184, 44, 13, 21); //side table
			addObjectBounds(119, 158, 33, 2, false); //door
			addObjectBounds(115, 41, 47, 19); //table
			addObjectBounds(133, 60, 12, 15); //chair
			function addObjectBounds(boundX:Number, boundY:Number, boundWidth:Number, boundHeight:Number, tangible:Boolean=true):void
			{
				var newBound:FlxObject = new FlxObject(boundX, boundY, boundWidth, boundHeight);
				newBound.immovable = true;
				newBound.solid = tangible;
				objectBounds.add(newBound);
			}
			
			jacques = new Jacques(true, true);
			jacques.x = 179;
			jacques.y = 39;
			jacques.immovable = true;
			add(jacques);
			
			pbg = new FlxSprite(90, 90).loadGraphic(Sources.ImgPBG, true, true, 18, 25);
			pbg.facing = FlxObject.LEFT;
			pbg.frame = 0;
			pbg.immovable = true;
			objectBounds.add(pbg);
			
			player = new Jon();
			player.x = 127;
			player.y = FlxG.height - 40;
			player.play('idleUp');
			add(player);
			
			applesAndGrapes = new FlashBitmap(0, 0, Sources.ImgApplesAndGrapes, 0.05, 0.05);
			FlxG.flashObjects.addChild(applesAndGrapes.object);
			applesAndGrapes.object.visible = false;
			add(applesAndGrapes);
			
			if (FlxG.music == null)
				FlxG.music = new FlxSound();
			FlxG.music.loadEmbedded(Sources.Mp3houseIntro);
			FlxG.music.survive = true;
			FlxG.music.play();
			new FlxTimer().start((new Sources.Mp3houseIntro).length / 1000, 1, eventTimer, timerManager);
			
			textbox = new TextBox;
			add(textbox);
		}
		
		override public function update():void
		{
			if (!FlxG.paused)
			{
				super.update();
				FlxG.collide(player, playerBounds);
				FlxG.collide(player, objectBounds);
				if (FlxG.keys.justPressed("SPACE"))
				{
					if (player.inFrontOf(pbg))
					{
						pbg.frame = 1;
						pbg.facing = FlxObject.RIGHT;
						player.play("itemGet");
						applesAndGrapes.x = pbg.x - 5;
						applesAndGrapes.y = pbg.y - applesAndGrapes.height - 2;
						applesAndGrapes.object.visible = true;
						textbox.display("Jon got Apples and Grapes~! (x6)", null, null, Sources.Mp3normalBootsFanfare, true);
						new FlxTimer().start((new Sources.Mp3normalBootsFanfare).length/1000, 1, eventTimer, timerManager); //duration of item fanfare
					}
					else if (jacques.alive && player.inFrontOf(objectBounds.members[2]))
					{
						FlxG.play(Sources.Mp3warp);
						jacques.alive = false;
						jacques.play("warp");
					}
					else if (player.inFrontOf(objectBounds.members[0]) && objectBounds.members[0].y + objectBounds.members[0].height <= player.y)
					{
						textbox.display("It's a framed copy of The Legend of Zelda: Dumberdon Sword.");
					}
				}
				if (player.inFrontOf(objectBounds.members[3])) //le door
				{
					FlxG.switchState(new OverWorld);
				}
			}
			else
			{
				timerManager.update();
				textbox.update();
			}
		}
		
		private function eventTimer(Timer:FlxTimer=null):void
		{
			if (Timer == null)
				return
			else if (Timer.time == (new Sources.Mp3houseIntro).length / 1000)
				FlxG.playMusic(Sources.Mp3house); //intro ditty is finished, commence song loop.
			else if (Timer.time == (new Sources.Mp3normalBootsFanfare).length / 1000)
			{
				pbg.frame = 0;
				player.play("idleHorizontal");
				applesAndGrapes.object.visible = false;
			}
		}
		
	}

}
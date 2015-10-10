package
{
	import flash.media.Camera;
	import org.flixel.*;
	import org.flixel.plugin.photonstorm.FlxGradient;
	import org.flixel.plugin.photonstorm.FlxCollision;
	import flash.ui.Mouse;
	import org.flixel.system.FlxReplay;
	
	/**
	 * TODO:
		 * Combat MAJOR LAG. Seperate the map into smaller groups, and make sorts/collisions dependent on platformerMode.
		 * reposition battlemenu background and players to be on street-level.
	 * 
	 * @author CC
	 */
	public class OverWorld extends FlxState
	{
		/**
		 * -1 means already encountered. Static because we don't want it to replay after a switchState 
		 */
		private var level:Level_OverWorld;
		private var player:Jon;
		private var playerBounds:PlayerBounds;
		private var jacques:Jacques;
		private var camOff:CameraOffset;
		private var revealGradient:FlxSprite;
		private var revealSpeed:Number;
		private var gate:FlxSprite;
		private var jonDoor:FlxSprite;
		private var jackDenninger:JackDenninger;
		private var denningerDoor:FlxSprite;
		private var pbgDoor:FlxSprite;
		private var lamp:FlxSprite;
		private var wasOverlapping:Boolean;
		private var countDown:CountDown;
		private var textbox:TextBox;
		private var enemy:Enemy;
		private var shrimp:Tempura;
		
		public function OverWorld(PlayIntro:Boolean=false):void
		{
			playIntro = PlayIntro;
		}
		
		override public function create():void
		{
			//set variables
			wasOverlapping = false;
			
			//essential shit
			super.create();
			if (FlxG.prevState == FakeLoadState)
				Mouse.show();
			level = new Level_OverWorld;
			FlxG.camera.setBounds(level.boundsMinX, level.boundsMinY, level.boundsMaxX, level.boundsMaxY);
			FlxG.bgColor = 0xff0075ff; //for super mario sky colour
			
			//add interactive objects
			gate = level.addSpriteToLayer(Sources.ImgGate, level.Group1ZsortGroup, 480, 893, 0, 64, 64, 2, false, 64, 67) as FlxSprite;
			jonDoor = (level.addSpriteToLayer(Sources.ImgHouse2, level.Group1ZsortGroup, 144, 971, 2, 44, 73, 30) as FlxGroup).members[1];
			if (FlxG.prevState == HomeState)
				jonDoor.visible = false; //open door
			denningerDoor = (level.addSpriteToLayer(Sources.ImgHouse1, level.Group1ZsortGroup, 11, 971, 2, 44, 73, 30) as FlxGroup).members[1];
			pbgDoor = (level.addSpriteToLayer(Sources.ImgHouse1, level.Group1ZsortGroup, 603, 980, 2, 44, 73, 30) as FlxGroup).members[1];
			
			jacques = new Jacques(false);
			add(jacques);
			
			shrimp = new Tempura(800, 466);
			add(shrimp);
			
			player = new Jon;
			player.x = 176;//600;
			player.y = 1045; //500
			FlxG.camera.follow(player);
			level.Group1ZsortGroup.add(player);
			
			camOff = new CameraOffset(player, 0, 0);
			add(camOff);
			
			playerBounds = new PlayerBounds(level.boundsMinX, level.boundsMinY, level.boundsMaxX, level.boundsMaxY);
			FlxG.worldBounds = playerBounds.area;
			level.masterLayer.add(playerBounds);
			
			textbox = new TextBox;
			jackDenninger = new JackDenninger(denningerDoor.x + 1, denningerDoor.y + denningerDoor.height - 21, player, textbox)
			level.Group1ZsortGroup.add(jackDenninger);
			
			lamp = (level.addSpriteToLayer(Sources.ImgLampPost, level.Group1frontGroup, 638, 479, 0, -20, 13, 62, false, 22, 42) as FlxSprite);
			lamp.solid = false;
			
			if (playIntro)
			{
				if (FlxG.music == null)
					FlxG.music = new FlxSound();
				FlxG.music.loadEmbedded(Sources.Mp3okamiSFX);
				FlxG.music.survive = true;
				FlxG.music.play();
				new FlxTimer().start((new Sources.Mp3okamiSFX).length/1000, 1, eventTimer);
				revealGradient = new FlxSprite(0, 0, Sources.ImgRevealGradient);
				revealGradient.x = player.getMidpoint().x - revealGradient.width / 2;
				revealGradient.y = player.getMidpoint().y - revealGradient.height / 2;
				revealSpeed = 0;
				level.Group1frontGroup.add(revealGradient);
			}
			else //don't play intro
			{
				if (FlxG.music != null)
				{
					FlxG.music.fadeOut(1);
					var musicTimer:FlxTimer = new FlxTimer().start(1, 1, eventTimer, timerManager);
				}
				else
					FlxG.playMusic(Sources.Mp3emulatedEuphoria, 0.75);
			}
			
			//HUD elements
			countDown = new CountDown;
			add(countDown);
			
			add(textbox);
			
			var background:FlxSprite = new FlxSprite().loadGraphic(Sources.ImgParkBackground, true, false, 330, 190);
			background.addAnimation('sway', [0, 1, 2, 3], 2, true);
			background.play('sway');
			
			level.Group1ZsortGroup.members.sort(ZsortHandler); //links to my custom Z-sort handler
		}
		
		override public function update():void
		{
			if (!FlxG.paused)
			{
				//essential game shit
				super.update();
				FlxG.collide(player, level.masterLayer);
				FlxG.collide(shrimp, level.layerGroup1Map);
				FlxG.collide(shrimp, playerBounds);
				FlxG.collide(jacques, level.layerGroup1Map);
				
				//handles turning platformerMode on/off
				var isOverlapping:Boolean = player.overlaps(lamp);
				if (wasOverlapping && !isOverlapping)
				{
					if (player.x > lamp.x && !player.getPlatformerMode())
					{
						player.setPlatformerMode(true);
						lamp.frame = 1;
						FlxG.play(Sources.Mp3sonic3bell);
					}
					else if (player.x < lamp.x && player.getPlatformerMode())
					{
						player.setPlatformerMode(false);
						lamp.frame = 0;
						FlxG.play(Sources.Mp3sonic3bellBackwards);
					}
				}
				wasOverlapping = isOverlapping;
				
				if (player.getPlatformerMode())
				{
					if (shrimp.alive && FlxCollision.pixelPerfectCheck(player, shrimp))
						if (shrimp.hitPlayer(player))
						{
							jacques.flyAround(player);
							player.vulnerableTime = Infinity;
						}
					if (!isNaN(jacques.flyHeight) && FlxG.overlap(player, jacques))
					{
						jacques.reset(0, 0);
						player.vulnerableTime = 0;
						player.visible = true;
					}
					
					//seamlessly set new cameraBounds once the camera is higher than the bottommost bound
					if (FlxG.camera.scroll.y + FlxG.height <= 544 && FlxG.camera.bounds.bottom != 544)
					{
						FlxG.camera.setBounds(level.boundsMinX, level.boundsMinY, level.boundsMaxX, 544);
						FlxG.camera.deadzone.make((FlxG.width - player.width) / 2, FlxG.width / 4, player.width, FlxG.height / 2);
					}
				}
				else //platformerMode == false
				{
					if (FlxG.camera.bounds.bottom == 544) //readjust camera if we have just switched
					{
						camOff.revive();
						FlxG.camera.setBounds(level.boundsMinX, level.boundsMinY, level.boundsMaxX, level.boundsMaxY);
					}
					
					//Z-sort player and static objects
					sortPlayer();
					
					//in-level events
					if (player.inFrontOf(jonDoor))
						FlxG.switchState(new HomeState);
					else if (player.inFrontOf(pbgDoor))
						FlxG.switchState(new PBGState);
					else if (player.inFrontOf(denningerDoor))
					{
						if (JackDenninger.cutscenePhase == 0)
							JackDenninger.cutscenePhase = 1;
						if (FlxG.keys.justPressed('SPACE'))
						{
							//play lock sound
						}
					}
					//the rest of the cutscenes are in JackDenninger's update loop
					
					else if (player.inFrontOf(gate) && FlxG.keys.justPressed('SPACE'))
					{
						gate.frame = 1;
						gate.solid = false;
					}
					
					//handles overWorld intro
					if (revealGradient != null)
					{
						revealGradient.scale.x = revealGradient.scale.y = Math.pow(2, (revealSpeed += FlxG.elapsed) * 0.7) - 0.5; //exponential growth
						if (revealSpeed >= 2)
						{
							revealGradient.alpha -= FlxG.elapsed / 3.5;
							if (revealGradient.alpha <= 0)
							{
								level.Group1frontGroup.remove(revealGradient, true);
								revealGradient = null;
							}
						}
					} 
				}
			}
			else //FlxG.pause == true
			{
				textbox.update();
				player.postUpdate();
			}
		}
		
		private function sortPlayer():void
		{
			var index:int = level.Group1ZsortGroup.members.indexOf(player);
			var temp:Object;
			if (index > 0)
				findNext(-1); //this func is declared at the bottom
			while (index > 0 && temp.y + temp.height > player.y) //while the first-drawn object is lower on screen than player
			{
				FlxU.swap(level.Group1ZsortGroup.members, --index); //switch places and move index down one
				findNext(-1);
			}
			if (index < level.Group1ZsortGroup.length - 1)
				findNext(1);
			while (index < level.Group1ZsortGroup.length - 1 && player.y >= temp.y + temp.height) // while the first drawn player is lower than the second drawn object 
			{
				FlxU.swap(level.Group1ZsortGroup.members, index++);//index = swap(index, 0); //switch places and move up one
				findNext(1);
			}
			
			function findNext(direction:int):void
			{
				temp = level.Group1ZsortGroup.members[index + direction];
				while (temp is FlxGroup)
					temp = temp['members'][0]; //use the first entry as reference. For houses with doors
			}
		}
		
		private function eventTimer(Timer:FlxTimer=null):void
		{
			if (Timer == null)
				return;
			switch(Timer.time)
			{
				case 1:
					FlxG.playMusic(Sources.Mp3emulatedEuphoria, 0.75);
				break;
				
				case (new Sources.Mp3okamiSFX).length / 1000:
				if (JackDenninger.cutscenePhase <= 0)
					FlxG.playMusic(Sources.Mp3emulatedEuphoria, 0.75);
				break;
			}
		}
		
		/**
		 * Helper function for the Zsort process.
		 * 
		 * @param 	Obj1	The first object being sorted.
		 * @param	Obj2	The second object being sorted.
		 * 
		 * @return	An integer value: -1 (Obj1 before Obj2), 0 (same), or 1 (Obj1 after Obj2).
		 */
		private function ZsortHandler(Obj1:FlxBasic,Obj2:FlxBasic):int
		{ 
			while (Obj1 is FlxGroup)
				Obj1 = Obj1['members'][0]; //use the first entry as reference. For houses with doors
			while (Obj2 is FlxGroup)
				Obj2 = Obj2['members'][0];
			if (Obj1 is Jon)
			{
				if (Obj1['y'] < Obj2['y'] + Obj2['height'])
					return -1;
				else
					return 1;
			}
			else if (Obj2 is Jon)
			{
				if (Obj1['y'] + Obj1['height'] <= Obj2['y'])
					return -1;
				else
					return 1;
			}
			else if(Obj1['y'] + Obj1['height'] < Obj2['y'] + Obj2['height'])
				return -1;
			else if(Obj1['y'] + Obj1['height'] > Obj2['y'] + Obj2['height'])
				return 1;
			return 0;
		}
		
	}

}
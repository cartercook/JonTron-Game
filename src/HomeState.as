package
{
	import org.flixel.*;
	
	/**
	 * My idea of JonTron's house. Very derivative, I know.
	 * 
	 * put 2 second darkness wait in, shorten fade and introduce music earlier.
	 * fix Jacques heart animation.
	 * 
	 * @author Carter
	 */
	public class HomeState extends FlxState
	{
		private var player:Jon;
		private var playerBounds:PlayerBounds;
		private var jacques:Jacques;
		private var birdStand:FlxSprite;
		private var objectBounds:FlxGroup;
		private var textbox:TextBox;
		
		public function HomeState(PlayIntro:Boolean=false):void
		{
			playIntro = PlayIntro;
		}
		
		override public function create():void
		{
			super.create();
			FlxG.bgColor = 0xff000000;
			
			var background:FlxSprite = new FlxSprite(0, 0, Sources.ImgJonHouseInterior);
			background.x = FlxG.width / 2 - background.width / 2;
			background.y = FlxG.height / 2 - background.height / 2;
			add(background);
			
			playerBounds = new PlayerBounds(background.x, background.y + 16, background.x + background.width, background.y + background.height);
			add(playerBounds);
			
			//objects are added in this order to prevent jacques being in front of the cage
			objectBounds = new FlxGroup;
			add(objectBounds);
			birdStand = new FlxSprite(168, 40, Sources.ImgBirdStand);
			birdStand.immovable = true;
			objectBounds.add(birdStand);
			if (!Jacques.haveJacques)
			{
				jacques = new Jacques(true);
				jacques.x = 164;
				jacques.y = 43;
				add(jacques);
			}
			var birdCage:FlxSprite = new FlxSprite(168, 40, Sources.ImgBirdCage);
			birdCage.immovable = true;
			add(birdCage);
			
			addObjectBounds(71, 31, 16, 32, true); //PC
			addObjectBounds(119, 95, 16, 32, true); //TV & console
			addObjectBounds(152, 32, 14, 15, false); //left window
			addObjectBounds(167, 127, 16, 31, true); //plant
			addObjectBounds(119, 158, 33, 2, false); //door
			addObjectBounds(87, 39, 32, 24, true); //table
			addObjectBounds(72, 127, 15, 10, true); //upper bedpost
			addObjectBounds(72, 151, 15, 8, true); //lower bedpost
			function addObjectBounds(boundX:Number, boundY:Number, boundWidth:Number, boundHeight:Number, tangible:Boolean=true):void
			{
				var newBound:FlxObject = new FlxObject(boundX, boundY, boundWidth, boundHeight);
				newBound.immovable = true;
				newBound.solid = tangible;
				objectBounds.add(newBound);
			}
			
			player = new Jon();
			if (playIntro)
			{
				player.x = 71;
				player.y = 137;
				player.play('sleep');
				player.controllable = false;
				
				if (FlxG.prevState == SpaceState) //play morning intro.
				{
					FlxG.camera.visible = false;
					new FlxTimer().start(2, 1, eventTimer, timerManager);
				}
				else //post-death intro
				{
					FlxG.flash(0xff000000, 2, eventTimer);
				}
				playIntro = false;
			}
			else //player has come in from outside. No intro.
			{
				player.x = 127;
				player.y = FlxG.height - 40;
				player.play('idleUp');
				if (FlxG.music == null)
					FlxG.music = new FlxSound();
				FlxG.music.loadEmbedded(Sources.Mp3houseIntro);
				FlxG.music.survive = true;
				FlxG.music.play();
				new FlxTimer().start((new Sources.Mp3houseIntro).length/1000, 1, eventTimer, timerManager);
			}
			add(player);
			
			//so that jonTron appears behind the his bedsheets.
			var bedsheet:FlxSprite = new FlxSprite(71, 135, Sources.ImgBedsheet);
			add(bedsheet);
			
			textbox = new TextBox;
			add(textbox);
		}
		
		override public function update():void
		{
			if (!FlxG.paused)
			{	
				super.update(); // This must come before collide statements, otherwise you get wierd rubbery collisions.
				
				FlxG.collide(player, objectBounds);
				FlxG.collide(player, playerBounds);
				
				if (FlxG.keys.justPressed("SPACE"))
				{
					if (player.inFrontOf(objectBounds.members[1]))
						textbox.display("Jon booted up MS-DOS.\nAh, what wonderous and youthful days of gaming.\nAlmost puts a tear in my eye.  :')", null, null, Sources.Mp3bootUp, false);
					else if (player.inFrontOf(objectBounds.members[2]))
						textbox.display("Jon put Kings Quest in the VCR holder.\nHaaly shit~! Dem greephics~!!", null, null, Sources.Mp3VCRslot);
					else if (player.inFrontOf(objectBounds.members[3]))
						textbox.display('Jon gazed over beyond the horizon and asked himself,%\n“What If~?~.~.”\n\n(Jon is a bit over dramatic sometimes)');
					else if (player.inFrontOf(objectBounds.members[4]))
						textbox.display("There is a note on one of the branches~.\n\n\n“press the spacebar to interact with%\nOh. You already figured it out~.”%")
					else if (player.inFrontOf(birdStand) && !Jacques.haveJacques)
					{
						player.play("itemGet"); //jon holds up Jacques
						jacques.x = player.x - 11;
						jacques.y = player.y - 22;
						remove(jacques, true); //moves jacques to be visibly in front of player
						add(jacques);
						jacques.play('love');
						Jacques.haveJacques = true;
						BattleMenu.moves.push("Laser");
						textbox.display("Jon found 1 Jacques!", jacques, null, Sources.Mp3itemGet, true);
						new FlxTimer().start((new Sources.Mp3itemGet).length/1000, 1, eventTimer, timerManager); //duration of item fanfare
					}
				}
				if (player.inFrontOf(objectBounds.members[5])) //Go on now, go! Walk out the door!
				{
					if (FlxG.prevState == SpaceState)
						FlxG.switchState(new FakeLoadState(true));
					else if (FlxG.prevState == FakeLoadState)
						FlxG.switchState(new FakeLoadState(false));
					else
						FlxG.switchState(new OverWorld);
				}
			}
			else
			{
				timerManager.update();
				textbox.update();
			}
			
		}
		
		/**
		 * Handles event sequences using a timer to count the duration of each event.
		 * 
		 * @param	Timer	some bullshit you have to pass into every onTimer function
		 */
		private function eventTimer(Timer:FlxTimer = null):void
		{
			if (Timer == null) //FlxG.flash is finished.
			{
				player.play('blink');
				new FlxTimer().start(41 / 12, 1, eventTimer, timerManager); //duration of 'blink' animation, 41 frames/(12 frames/second).
				return;
			}
			
			switch(Timer.time)
			{
			case 2:
				FlxG.camera.visible = true;
				FlxG.flash(0xff000000, 6.5, eventTimer);
				if (FlxG.music == null)
					FlxG.music = new FlxSound();
				FlxG.music.survive = true;
				FlxG.music.loadEmbedded(Sources.Mp3morning).play();
				break;
			case 41/12: //blink animation is finished.
				player.controllable = true;
				if (FlxG.music != null)
					FlxG.music.exists = true;
				FlxG.music.loadEmbedded(Sources.Mp3houseIntro);
				FlxG.music.survive = true;
				FlxG.music.play();
				Timer.start((new Sources.Mp3houseIntro).length/1000, 1, eventTimer, timerManager);
				break;
			case (new Sources.Mp3houseIntro).length / 1000:
				FlxG.playMusic(Sources.Mp3house); //intro ditty is finished, commence song loop.
				break;
			case (new Sources.Mp3itemGet).length / 1000: //itemGet jingle is finished. Stow Jacques.
				player.play("idleDown");
				remove(jacques);
				break;
			}
		}
		
	}
}
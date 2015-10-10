package 
{
	
	import org.flixel.*;
	import flash.ui.Mouse;

	/**
	 * This is a parody of the sonic '06 loading screen, and other ambiguous loading symbols.
	 * 
	 * @author Carter
	 */
	public class FakeLoadState extends FlxState
	{
		private var player:Jon;
		private var beachBall:FlxSprite;
		private var arrow:FlxSprite;
		private var arrowTimer:FlxTimer;
		private var nowLoading:Enemy;
		private var loadingGhost:FlxSprite;
		private var carpet:FlxSprite;
		private var walls:FlxGroup;
		private var playerBounds:PlayerBounds;
		
		public function FakeLoadState(PlayIntro:Boolean=false):void
		{
			playIntro = PlayIntro;
		}
		
		override public function create():void
		{	
			//for testing purposes, creates a sound object if there is none.
			if (FlxG.music == null)
				FlxG.music = new FlxSound;
			
			//prevents timers from running when super.update isn't being called
			super.create();
			
			//put enemy in bottom-left corner
			nowLoading = new NowLoading(FlxG.width - 130, FlxG.height - 40);
			add(nowLoading);
			
			playerBounds = new PlayerBounds( -16, -16, FlxG.width + 16, FlxG.height + 17);
			add(playerBounds);
			FlxG.worldBounds = playerBounds.area;
			
			//prepare the the player and door depending on playIntro
			carpet = new FlxSprite(FlxG.width / 2 - 16, 55, Sources.ImgCarpet);
			carpet.height /= 4;
			player = new Jon;
			player.x = FlxG.width / 2 - player.width / 2;
			if (playIntro) //leave the door up for the intro
			{
				FlxG.music.stop();
				player.controllable = false;
				carpet.y = -carpet.frameHeight;
				player.y = carpet.y + 6;
				new FlxTimer().start(3, 1, eventTimer, timerManager);
			}
			else //spawn carpet and player onscreen
			{
				FlxG.music.fadeOut(1);
				new FlxTimer().start(1, 1, eventTimer, timerManager);
				player.y = 61;
			}
			add(carpet);
			add(player);
			
			//prevent the player from walking north past the carpet
			walls = new FlxGroup;
			walls.add(new FlxTileblock(-16, 0, FlxG.width / 2 - 6, 70));
			walls.add(new FlxTileblock(FlxG.width / 2 + 22, 0, FlxG.width / 2 - 6, 70));
			add(walls);
			
			//identical to nowLoading, used to create the special effect 
			loadingGhost = new FlxSprite(FlxG.width - 130, FlxG.height - 40, Sources.ImgNowLoading);
			loadingGhost.exists = false;
			add(loadingGhost);
			
			//periodically whizzes across the screen
			arrow = new FlxSprite( -56, FlxG.height - 42, Sources.ImgLoadArrows);
			arrow.velocity.x = 600;
			arrowTimer = new FlxTimer().start(1.73, Infinity, eventTimer, timerManager);
			add(arrow);
			
			//briefly replaces your mouse cursor
			Mouse.hide();
			beachBall = new FlxSprite().loadGraphic(Sources.ImgBeachball, true, false, 20, 20);
			beachBall.scale.x = beachBall.scale.y = 2/3;
			beachBall.addAnimation("spin", [0, 1, 2, 3, 4, 5], 24, true);
			beachBall.play("spin");
			add(beachBall);
		}
		
		override public function update():void
		{
			super.update();
			
			// make beachball follow the mouse around
			beachBall.x = FlxG.mouse.x - beachBall.width / 2;
			beachBall.y = FlxG.mouse.y - beachBall.height / 2;
			
			FlxG.collide(player, walls);
			FlxG.collide(player, playerBounds);
			
			if (player.inFrontOf(carpet))
			{
				Mouse.show();
				FlxG.switchState(new HomeState(false));
			}
			if (FlxG.overlap(player, nowLoading.sprite) && player.vulnerableTime <= 0)
			{
				this.setSubState(new BattleMenu(nowLoading, new FlxSprite(0, 0, Sources.ImgMicrochipBackground), true), exitBattleCallback);
			}
			//the following bullshit is to animate the loading screen
			if (!loadingGhost.exists)
			{
				if (FlxG.overlap(arrow, nowLoading))
					loadingGhost.exists = true;
			}
			else
			{
				loadingGhost.scale.x += FlxG.elapsed / 2.912;
				loadingGhost.scale.y += FlxG.elapsed / 3.072;
				loadingGhost.alpha -= FlxG.elapsed/0.64;
				if (loadingGhost.alpha <= 0)
				{
					loadingGhost.alpha = loadingGhost.scale.x = loadingGhost.scale.y = 1;
					loadingGhost.exists = false;
				}
			}
			
			//likewise, this bullshit keeps Jon on the carpet and stops it from flying off at the end of its path.
			if (carpet.velocity.y > 0)
			{
				player.y = carpet.y + 6;
				if (carpet.y >= 55)
				{
					carpet.y = 55;
					carpet.velocity.y = 0;
					player.controllable = true;
					new FlxTimer().start(1, 1, eventTimer, timerManager);
				}
			}
		}
		
		private function eventTimer(Timer:FlxTimer=null):void
		{
			if (Timer == null)
				return;
			switch(Timer.time)
			{
				case 1:
					FlxG.playMusic(Sources.Mp3howlingWind);
					break;
				case 1.73:
					arrow.x = -56; //reset the arrow to cross the screen.
					break;
				case 3:
					FlxG.play(Sources.Mp3doorFall);
					carpet.velocity.y = 170;
					break;
			}
		}
		
		/**
		 * This is a callback function passed into exitBattle to indicate whether or not player
		 * has run from battle.
		 * @param	something necessary but useless parameter built into FlxSubState
		 * @param	subState ibid
		 * @param	reason why the battle was exited. In this case, "run".
		 */
		private function exitBattleCallback(something:*, subState:FlxSubState):void
		{
			player.vulnerableTime = 3.5; //give the player a 3.5 second getaway time
		}
	
	}
	
}
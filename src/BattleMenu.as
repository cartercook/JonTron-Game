package  
{
	import org.flixel.*;
	import org.flixel.plugin.photonstorm.FlxSpecialFX;
	import org.flixel.plugin.photonstorm.FX.GlitchFX;
	import org.flixel.plugin.photonstorm.FlxGradient;
	import org.flixel.plugin.photonstorm.FlxBar;
	import flash.geom.Point;
	import flash.display.Sprite;
	import flash.display.Bitmap;
	import fl.transitions.Tween;
	import fl.transitions.TweenEvent;
	import fl.transitions.easing.None;
	
	/**
	 * because changing the state would erase everything in that state, battleMenu has to be added on top of the state.
	 * it works pretty much the same way as TextBox, except that it picks up the player
	 * and enemy objects and drops them into itself, then returns them to their original positions once it's done.
	 * 
	 * TODO:
		 * use reset-less switchstate fade
		 * add player/enemy positions as parameters to adjust for particular backgrounds.
	 * 
	 * @author Carter
	 */
	public class BattleMenu extends FlxSubState
	{
		public static var controllable:Boolean; //whether or not you can move the pointer around
		/**
		 * holds a list of the moves you have gained from leveling up so far.
		 */
		public static var moves:Array = new Array("Punch");
		private var _moveList:FlxGroup; //a copy of the above that holds the TextFields of all Jon's moves
		
		//sprites and their hand variables
		private var _background:FlxSprite;
		private var _stage:FlxGroup;
		private var _box:FlxSprite;
		private var _boxBackground:FlxSprite;
		private var _healthBar:FlxBar;
		private var _pointer:FlxSprite; //hand graphic
		private var _pointerIndex:int; //which move the pointer is on
		private var _player:Jon;
		private var _laserGroup:FlxGroup;
		private var _enemy:Enemy;
		private var _enemyPos:FlxPoint;
		private var _music:FlxSound;
		private var _glitchScreen:GlitchScreen;
		private var _battleDoors:BattleDoors;
		
		//flash objects
		private var _textContainer:Sprite;
		private var _palm:FlashBitmap;
		private var _fist:FlashBitmap;
		private var _tween:Tween;
		private var _dialogue:FlashText;
		
		/**
		 * 
		 * @param	Enemy			pass the enemy P1 has touched
		 * @param	Background		an FlxSprite (can be animated) that is centered in the background
		 * @param	PlayGlitchIntro	default intro is the door-close one
		 */
		public function BattleMenu(enemy:Enemy, Background:FlxSprite, PlayGlitchIntro:Boolean=false)
		{
			super(true);
			
			//assign variables to parameters
			_enemy = enemy;
			_background = Background;
			playIntro = PlayGlitchIntro;
		}
		
		override public function create():void
		{
			trace(((new Sources.Mp3lololol).length / 1000) - (0.06 + 0.24 + 0.20 + 0.33 + 0.46 + 0.44));
			
			//set all variables
			_pointerIndex = 0;
			controllable = false;
			
			//holds everything behind the intro screen so it can be easily hidden
			_stage = new FlxGroup();
			_stage.exists = false;
			add(_stage);
			
			//hides the FlxState behind the background
			_background.x = FlxG.width / 2 - _background.width / 2;
			_background.y = FlxG.height / 2 - _background.height / 2;
			_background.scrollFactor.x = _background.scrollFactor.y = 0;
			_stage.add(_background);
			
			//create the player but don't add him until battleMenu is displayed
			_player = new Jon;
			_player.x = 45;
			_player.y = FlxG.height * 0.4 - _player.height / 2;
			_player.controllable = false;
			_player.facing = FlxObject.RIGHT;
			_player.play('idleFight');
			_stage.add(_player);
			
			//fed into the class by a constructor parameter. x and y are set in display().
			_enemyPos = new FlxPoint(_enemy.x, _enemy.y);
			_enemy.playIdleAnim = true;
			_stage.add(_enemy);
			
			//contains the lasers that shoot out of Jaques' face PEW PEW PEW
			_laserGroup = new FlxGroup();
			_stage.add(_laserGroup);
			
			//Create the health bar & attach it to Jon
			_healthBar = new FlxBar(_player.x - 16, _player.y - 28, FlxBar.FILL_LEFT_TO_RIGHT, 48, 5, _player, "health", 0, _player.maxHealth, true);
			_healthBar.createImageBar(Sources.ImgHealthBarBackground, Sources.ImgHealthBar);
			_healthBar.trackParent(-16, -28);
			_stage.add(_healthBar);
			
			//create the box
			_box = new FlxSprite(0, 0, Sources.ImgTextBox);
			_box.x = FlxG.width / 2 - _box.width / 2;
			_box.y = FlxG.height - _box.height;
			_box.scrollFactor.x = _box.scrollFactor.y = 0; //so that it doesn't move relative to the camera
			_boxBackground = FlxGradient.createGradientFlxSprite(_box.width - 12, _box.height - 10, [0xff4D5CB8, 0xff000B52], 3);
			_boxBackground.scrollFactor.x = _boxBackground.scrollFactor.y = 0;
			_boxBackground.x = _box.x + 6;
			_boxBackground.y = _box.y + 6;
			_stage.add(_boxBackground);
			_stage.add(_box);
			
			//hide flash objects below intro graphic
			FlxG.flashObjects.visible = false;
			
			//container object for flash text for easy displaying/hiding.
			_textContainer = new Sprite();
			FlxG.flashObjects.addChild(_textContainer);
			
			//Flixel pixelates sprites, that's why these are bitmaps
			var scale:Number = 13 / 32;
			_palm = new FlashBitmap(FlxG.width, -4, Sources.ImgPalm, scale, scale);
			_fist = new FlashBitmap(FlxG.width, 0, Sources.ImgFist, scale, scale);
			FlxG.flashObjects.addChild(_palm.object);
			add(_palm); //so that destroy is called automatically when state is destroyed.
			FlxG.flashObjects.addChild(_fist.object);
			add(_fist);
			_tween = new Tween(_palm, 'x', None.easeNone, FlxG.width, FlxG.width - _palm.width, 0.2, true);
			_tween.stop();
			_tween.addEventListener(TweenEvent.MOTION_FINISH, attackTween);
			
			//Now entering sketchy flash-text territory. FlxText is blurry and shitty, there's no way around it.
			_dialogue = new ScrollText(_box.x + 15, _box.y + 11, "", _box.width - 30, _box.height - 22, 0xffffff);
			FlxG.flashObjects.addChild(_dialogue.field);
			_enemy.dialogue = this._dialogue; //this is hackish but it works (fuck you OOP!)
			add(_dialogue);
			
			//lays out all the moves you have acquired so far.
			_moveList = new FlxGroup(8); //max 8 members
			for (var i:int = 0; i < moves.length; i++)
			{
				if (i < 4)
					_moveList.members[i] = new FlashText(_box.x + 60, _box.y + 7 + i * 12, moves[i], 54, 12);
				else
					_moveList.members[i] = new FlashText(_box.x + 170, _box.y + 7 + (i - 4) * 12, moves[i], 54, 12);
				_textContainer.addChild(_moveList.members[i].field);
			}
			var bail:FlashText = new FlashText(_box.x + 170, _box.y + 43, "Bail", 54, 12);
			_moveList.add(bail); //place Bail in bottom right-hand corner
			_textContainer.addChild(bail.field);
			add(_moveList);
			
			//old thyme hand graphic for selecting moves
			_pointer = new FlxSprite(0, 0, Sources.ImgPointingHand);
			_pointer.x = _moveList.members[0].x - _pointer.width - 1;
			_pointer.y = _moveList.members[0].y + 1;
			_pointer.scrollFactor.x = _pointer.scrollFactor.y = 0;
			_stage.add(_pointer);
			
			//These are like curtains covering the stage
			if (playIntro) //sets up the glitch intro & fade
			{
				_glitchScreen = new GlitchScreen;
				add(_glitchScreen.canvas);
				FlxG.fade(0xff000000, 1.5, display);
			}
			else //sets up that door-close intro
			{
				_battleDoors = new BattleDoors;
				add(_battleDoors);
				new FlxTimer().start(1.284, 1, display, timerManager);
			}
		}
		
		/**
		 * code for selecting moves and running the battle sequence in general.
		 */
		override public function update():void
		{
			if (!FlxG.paused)
			{
				//update statements, collide statements, you know the drill
				super.update();
				if (_battleDoors != null)
					FlxG.collide(_battleDoors.leftDoor, _battleDoors.rightDoor, _battleDoors.collisionCallback);
				
				//handles controls
				if (controllable)
				{
					//check for newly pressed keys
					var up:Boolean = (FlxG.keys.justPressed("UP") || FlxG.keys.justPressed("W"));
					var down:Boolean = (FlxG.keys.justPressed("DOWN") || FlxG.keys.justPressed("S"));
					var right:Boolean = (FlxG.keys.justPressed("RIGHT") || FlxG.keys.justPressed("D"));
					var left:Boolean = (FlxG.keys.justPressed("LEFT") || FlxG.keys.justPressed("A"));
					
					//handles spacebar presses
					if (FlxG.keys.justPressed("SPACE"))
					{
						if (_moveList.members[_pointerIndex].text == "Bail")
						{
							_player.play('scoot');
							new FlxTimer().start(1 / 8, 1, eventTimer, timerManager);
						}
						else if (_moveList.members[_pointerIndex].text == "Punch")
							attackTween();
						else if (_moveList.members[_pointerIndex].text == "Laser")
						{
							_player.play('showLaser');
							new FlxMegaTimer([3/9,0.06,0.24,0.20,0.33,0.46,0.44,0.255,2/9], shootLasers, timerManager);
						}
						controllable = false;
					}
					
					//handles arrowkeys
					else if (up || down || left || right)
					{
						FlxG.play(Sources.Mp3blipSelect, 0.4);
						var length:uint = _moveList.members.length;
						if (up)
						{
							if (_pointerIndex > 0)
								_pointerIndex--;
							else
								_pointerIndex = length - 1;
						}
						if (down)
						{
							if (_pointerIndex < length - 1)
								_pointerIndex++;
							else
								_pointerIndex = 0;
						}
						if (left)
						{
							if(_pointerIndex - 3 > 0)
								_pointerIndex -= 4;
							else if (_pointerIndex + 4 < length)
								_pointerIndex += 4;
							else if (length <= 4)
								_pointerIndex = 0;
							else
								_pointerIndex = length - 1;
						}
						if (right)
						{
							if (_pointerIndex + 4 < length)
								_pointerIndex += 4;
							else if (_pointerIndex - 3 > 0)
								_pointerIndex -= 4;
							else
								_pointerIndex = length - 1;
						}
						_pointer.x = _moveList.members[_pointerIndex].x - _pointer.width - 1;
						_pointer.y = _moveList.members[_pointerIndex].y + 1;
					}
				}
				
				//handles dialogue
				else if (_enemy.attackFinished) //!controllable
				{
					if (FlxG.keys.justPressed("SPACE"))
					{
						_dialogue.text = "";
						_enemy.attackFinished = false;
						controllable = true;
					}
				}
				
				//when controllable, controls are visible. Else, invisible.
				if (_moveList != controllable)
					_textContainer.visible = _pointer.exists = controllable;
			}
			else
			{
				_player.postUpdate(); //for death sequence
			}
		}
		
		private function attackTween(event:TweenEvent=null):void
		{
			if (event == null)
			{
				_tween.start(); //begins the punches
				_player.play('punch');
				new FlxTimer().start(1, 1, eventTimer, timerManager);
				return;
			}
			_tween.yoyo(); //is called for every one
			if (_tween.obj == _palm && _palm.x < FlxG.width) //palm has hit (is at end of tween)
			{
				_enemy.hurt(0);
				FlxG.play(Sources.Mp3slap, 2);
			}
			else if (_tween.obj == _palm && _palm.x >= FlxG.width) //palm is resting offstage
				_tween.obj = _fist; //now apply tween to fist
			else if (_tween.obj == _fist && _fist.x < FlxG.width) //fist has hit (is at end of tween)
			{
				_enemy.hurt(0);
				FlxG.play(Sources.Mp3punch);
			}
			else if (_tween.obj == _fist && _fist.x >= FlxG.width) //fist is resting offstage
			{
				_tween.obj = _palm;
				_tween.stop();
				if (_enemy.alive)
					_enemy.attack(_player);
			}
		}
		
		private function shootLasers(Timer:FlxTimer = null):void
		{
			if (Timer == null)
				return;
			
			switch (Timer.currentLoop)
			{
			case 1:
				FlxG.play(Sources.Mp3lololol); 
				break;
			case 2:
			case 3:
			case 4:
			case 5:
			case 6:
			case 7:
				//make + shoot a laser
				var laser:FlxSprite = new FlxSprite(_player.x - 2, _player.y - 13).makeGraphic(80, 1, 0xffff0000);
				laser.origin.x = 0; //now it will rotate about the left corner
				var topAngle:Number;
				if (_enemy.y <= laser.y)
					topAngle = FlxU.getAngle(new FlxPoint(laser.x, laser.y), new FlxPoint(_enemy.x, _enemy.y));
				else
					topAngle = FlxU.getAngle(new FlxPoint(laser.x, laser.y), new FlxPoint(_enemy.x + _enemy.width, _enemy.y));
				laser.angle = topAngle - 90 + FlxG.random() * (FlxU.getAngle(new FlxPoint(laser.x, laser.y), new FlxPoint(_enemy.x, _enemy.y + _enemy.height)) - topAngle);
				laser.velocity.x = -500 * Math.sin((laser.angle - 90) * (Math.PI / 180));
				laser.velocity.y = 500 * Math.cos((laser.angle - 90) * (Math.PI / 180));
				_laserGroup.add(laser);
				break;
			case 8:
				_player.play('hideLaser');
				_enemy.hurt(4);
				break;
			case 9:
				_player.play('idleFight');
				if (_enemy.alive)
					_enemy.attack(_player);
				break;
			}
		}
		
		private function eventTimer(Timer:FlxTimer=null): void
		{
			if (Timer == null)
			{
				exitBattle();
				return;
			}
			
			switch(Timer.time)
			{
			case 1 / 8:
				FlxG.play(Sources.Mp3woohoo);
				_player.play('run');
				_player.facing = FlxObject.LEFT;
				_player.velocity.x = -60;
				Timer.start(0.7, 1, eventTimer, timerManager);
				break;
			case 0.7:
				FlxG.fade(0xffffffff, 1, eventTimer, true);
				break;
			case 1:
				_player.play('idleFight');
				break;
			}
		}
		
		private function display(Timer:FlxTimer = null):void
		{
			if (playIntro)
			{
				FlxG.camera.stopFX(); //clear the fade
				_glitchScreen.stop(); //to not leave this running behind the battlemenu
			}
			else
			{	//open doors
				_battleDoors.leftDoor.acceleration.x = -2000;
				_battleDoors.rightDoor.acceleration.x = 2000;
			}
			
			//this is here baecause the glitch canvas is a bit delayed, and shows one frame of the enemy out of place before becoming visible
			_enemy.x = FlxG.width - 59 - _enemy.width / 2;
			_enemy.y = FlxG.height * 0.4 - _enemy.height / 2;
			
			_stage.exists = true; //ditto
			
			//make menu visible and play music.
			FlxG.music.pause();
			FlxG.music.exists = false;
			_music = FlxG.play(Sources.Mp3backsteinhaus, 0.65, true, false);
			FlxG.flashObjects.visible = true;
			controllable = true;
		}
		
		/**
		 * tidies everything to be used in the current FlxState
		 * NOTE: this.close() calls this.destroy()
		 */
		private function exitBattle():void
		{
			_enemy.x = _enemyPos.x;
			_enemy.y = _enemyPos.y;
			_enemy.playIdleAnim = false;
			_stage.remove(_enemy); //otherwise _enemy is destroyed with the battleMenu
			
			//hide the battleMenu, cut the music.
			_music.stop();
			FlxG.music.exists = true;
			FlxG.music.play();
			_player.vulnerableTime = 3.5;
			this.close();
		}
		
		/**
		 * without this, all this is re-added to FlxG.flashObjects every time BattleMenu() is called.
		 */
		override public function destroy():void
		{
			FlxSpecialFX.clear();
			super.destroy();
			FlxG.flashObjects.removeChild(_textContainer);
			FlxG.flashObjects.visible = true; //just in case
			_tween.removeEventListener(TweenEvent.MOTION_FINISH, attackTween);
		}
		
	}

}
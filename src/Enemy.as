package  
{
	import org.flixel.*;
	import org.flixel.plugin.TimerManager;
	
	/**
	 * A base class for all enemies. Never instantiate this class itself, just extend it
	 * and write your own attack function and add additional FlxSprites as members.
	 * @author CC
	 */
	public class Enemy extends FlxGroup
	{
		public var sprite:FlxSprite;
		public var attackFinished:Boolean; //tacky shit I threw in to communicate with the battleMenu
		public var switchState:FlxState; //state to switch to upon winning (null = no switch)
		internal var _damageText:FlxGroup;
		internal var _timerManager:TimerManager;
		
		public var playIdleAnim:Boolean;
		private var _animY:Number; //used to animate the enemy
		private var _animCounter:Number;
		internal var _phrases:Array;
		internal var _phraseIndex:int; 
		
		internal var _player:Jon;
		internal var glowLight:FlxSprite;
		internal var killTimer:FlxTimer;
		
		public var dialogue:FlashText;
		
		public function Enemy(Graphic:Class, X:Number=0, Y:Number=0, Animated:Boolean=false,Reverse:Boolean=false,Width:uint=0,Height:uint=0,Unique:Boolean=false)
		{
			attackFinished = false;
			switchState = null;
			playIdleAnim = false;
			_animY = 0;
			_animCounter = 0;
			_phraseIndex = -1;
			
			_damageText = new FlxGroup;
			add(_damageText);
			_timerManager = new TimerManager;
			add(_timerManager);
			
			sprite = new FlxSprite(X, Y, Graphic);
			add(sprite);
			
			glowLight = new FlxSprite(0, 0, Sources.ImgGlowLight);
			glowLight.alpha = 0;
			glowLight.exists = false;
			add(glowLight);
			
			killTimer = new FlxTimer();
			killTimer.finished = true;
		}
		
		override public function update():void
		{
			super.update();
			
			//update idle animation
			if (playIdleAnim)
			{
				_animCounter += FlxG.elapsed;
				if (_animCounter >= 1)
				{
					_animCounter = 0;
					this.y += Math.pow( -1, _animY++);
				}
			}
			
			//update kill sequence
			if (glowLight.exists)
			{
				if (killTimer.ID == 1)
				{
					glowLight.alpha += FlxG.elapsed / 1.3;
					if (glowLight.alpha >= 1)
						killTimer.ID = 2;
				}
				if (killTimer.ID == 2)
					for (var i:int; i < members.length; i++)
						if (members[i] is FlxSprite)
							members[i]['alpha'] -= FlxG.elapsed / 1.3;
			}
		}
		
		private function eventTimer(Timer:FlxTimer=null):void
		{
			if (Timer == null)
			{
				FlxG.switchState(switchState);
				return;
			}
			
			switch (Timer.time)
			{
			case 0.1:
				if (sprite.color == 0xffff00)
				{
					sprite.x++;
					sprite.y--;
					sprite.color = 0xffffff;
				}
				else if (sprite.color == 0xff0000)
				{
					if (Timer.ID == 1)
					{
						sprite.y += 4;
						Timer.ID = 2;
						Timer.start(0.1, 1, eventTimer, _timerManager);
					}
					else if (Timer.ID == 2)
					{
						sprite.y -= 2;
						sprite.color = 0xffffff;
					}
				}
				break;
			case 1: //disappear the damage text
				_damageText.remove(_damageText.members[Timer.ID] as FlashText).destroy();
				break;
			case 2.6:
				FlxG.fade(0xff000000, 1.8, eventTimer); //prepare to exit battlemenu
				break;
			}
		}
		
		/**
		 * this function exists to be overridden BUT NOT TO BE SUPER'D.
		 * @param	Player	pass in an instance of the player so that Enemy knows
		 * his/her x & y coordinates.
		 */
		 public function attack(Player:Jon):void
		{
			
		}
		
		public function hurt(Damage:Number):void
		{
			sprite.health -= Damage;
			if (sprite.health <= 0)
				kill();
			else
			{
				var colour:uint;
				if (Damage / 6 <= 0.5) //6 = maxHealth
				{	
					colour = (1 - 2 * (Damage/6)) * 0xff; //white component 
					colour = 0xff0000 + (colour<<8) + colour; // increases from white to red with damage
				}
				else //decreases from red to black with damage
					colour = uint(2 * (-Damage/6 + 1) * 0xff)<<16;
				var newText:FlashText = new FlashText(x + width / 2, y - 14, String(Damage), NaN, NaN, colour);
				FlxG.flashObjects.addChild(newText.field);
				var randomHeight:int = 60 + FlxG.random() * 11;
				newText.velocity.y = -randomHeight;
				newText.acceleration.y = 2 * randomHeight;
				_damageText.add(newText);
				var textTimer:FlxTimer = new FlxTimer().start(1, 1, eventTimer, _timerManager); //to clear the ascending damage text
				textTimer.ID = _damageText.members.indexOf(newText); //to recall location of object in eventTimer function
				
				var hurtTimer:FlxTimer = new FlxTimer().start(0.1, 1, eventTimer, _timerManager);
				if (Damage <= 1)
				{
					sprite.color = 0xffff00;
					sprite.x--;
					sprite.y++;
				}
				else
				{
					FlxG.play(Sources.Mp3hitHurt2);
					sprite.color = 0xff0000;
					sprite.x++;
					sprite.y -= 2;
					hurtTimer.ID = 1;
				}
			}
		}
		
		override public function kill():void
		{
			BattleMenu.controllable = false;
			this.alive = false;
			if (killTimer.finished)
			{
				killTimer.start(2.6, 1, eventTimer, _timerManager);
				killTimer.ID = 1;
				FlxG.play(Sources.Mp3disappear);
				glowLight.x = sprite.getMidpoint().x - glowLight.width / 2;
				glowLight.y = sprite.getMidpoint().y - glowLight.height / 2;
				glowLight.exists = true;
			}
		}
		
		public function getPhrase():String
		{
			if (_phraseIndex >= _phrases.length - 1)
			{
				FlxU.shuffle(_phrases, _phrases.length * 4, true);
				_phraseIndex = 0;
				for (var i:int = 0; i < _phrases.length; i++)
				{
					trace (_phrases[i].string);
				}
			}
			return _phrases[++_phraseIndex].string;
		}
		
		//a fuckton of get/set staements to make this FlxGroup behave like an FlxSprite
		public function get x():Number
		{return sprite.x;}
		public function set x(X:Number):void
		{sprite.x = X;}
		
		public function get y():Number
		{return sprite.y;}
		public function set y(Y:Number):void
		{sprite.y = Y;}
		
		public function get width():Number
		{return sprite.width;}
		public function set width(Width:Number):void
		{sprite.width = Width;}
		
		public function get height():Number
		{return sprite.height;}
		public function set height(Height:Number):void
		{sprite.height = Height;}
		
		public function get color():uint
		{return sprite.color;}
		public function set color(Color:uint):void
		{sprite.color = Color; }
		
	}

}
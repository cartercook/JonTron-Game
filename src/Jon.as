package  
{
	import org.flixel.*;
	import org.flixel.plugin.TimerManager;
	/**
	 * this is my player class. Just assign him to a variable and the controls are built right in!
	 * TODO: fix jon's walk cycle continuing after dialogue box opens
	 * @author Carter
	 */
	public class Jon extends BasePlayer
	{
		/**
		 * used with get/set functions.
		 */
		private var platformerMode:Boolean;
		public var maxHealth:Number;
		private var _faceOrder:FlxPoint = new FlxPoint(NaN, NaN); //keeps track of facing direction.
		private var _timerManager:TimerManager;
		private var _elapsed:Number;
		private var _damageText:FlxGroup;
		private var gravity:Number;
		private var localDrag:Number;
		
		/**
		 * substantiates the player. Pair this with the PlayerBounds class to keep him from walking off the screen.
		 */
		public function Jon()
		{
			super();
			
			//set variables
			
			
			_timerManager = new TimerManager();
			_elapsed = 0;
			_damageText = new FlxGroup;
			
			platformerMode = false;
			speed = 100;
			maxVelocity.x = 1.5 * speed;
			localDrag = 2.5 * speed; //stop jon from siding across the ground
			gravity = 720;
			
			loadGraphic(Sources.ImgPlayer, true, true, 64, 28);
			height = 8;
			width = 16;
			offset.y = 20;
			offset.x = 24;
			health = maxHealth = 16;
			addAnimation('idleDown', [1]);
			addAnimation('idleUp', [2]);
			addAnimation('idleHorizontal', [0]);
			addAnimation('walkLR', [3, 4, 5, 4], 7);
			addAnimation('walkDown', [6, 7, 8, 7], 7);
			addAnimation('walkUp', [9, 10, 11, 10], 7);
			addAnimation('sleep', [12]);
			addAnimation('itemGet', [13]);
			addAnimation('blink', [12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 12, 1, 1, 12, 1, 1, 1, 1, 12, 1, 1, 1, 1],  12, false);
			addAnimation('idleFight', [14, 15], 42 / 17);
			addAnimation('die', [16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 17, 17, 17, 17, 16, 16, 16, 18, 18, 20, 20, 20, 20, 18, 18, 18, 18, 20, 20, 20, 20, 19, 19, 19, 19, 21], 4, false);
			addAnimation('showLaser', [22, 23, 24], 9, false);
			addAnimation('hideLaser', [23, 22], 9, false);
			addAnimation('scoot', [25], 8, false);
			addAnimation('run', [26, 27, 28, 27], 7);
			addAnimation('punch', [15, 29, 15, 31], 4, false);
			addAnimation('jump', [32]);
			addAnimation('fall', [33]);
			play('idleDown');
		}
		
		/**
		 * the control scheme is set up so that every arrow key pressed is saved into
		 * an array. The most recent one pressed is at array[0], but when it's released
		 * the next one held down takes control. This prevents the character from walking
		 * diagonally or in 2 directions at once and animating improperly.
		 */
		override public function update():void
		{
			_damageText.update();
			_timerManager.update();
			
			if (controllable)
			{
				var right:Boolean = (FlxG.keys.RIGHT || FlxG.keys.D);
				var left:Boolean = (FlxG.keys.LEFT || FlxG.keys.A);
				var up:Boolean = (FlxG.keys.UP || FlxG.keys.W);
				
				//sets Jon's animation to idle after the the pause button is pressed and released. Must be run before sortKeyPress()
				if (!platformerMode && _pressOrder[0] != 0 && !(right || (FlxG.keys.DOWN || FlxG.keys.S) || left || up))
				{
					if (_pressOrder[0] == RIGHT || _pressOrder[0] == LEFT) //LEFT or RIGHT
						play("idleHorizontal");
					if (_pressOrder[0] == UP)
						play("idleUp");
					if (_pressOrder[0] == DOWN)
						play("idleDown");
				}
				
				sortKeyPress();
				
				if (platformerMode)
				{
					var leftIndex:int = _pressOrder.indexOf(LEFT);
					var rightIndex:int = _pressOrder.indexOf(RIGHT);
					var onGround:Boolean = isTouching(DOWN);
					
					var Drag:Number = localDrag * FlxG.elapsed; //stop jon from siding across the ground
					if (onGround)
						Drag *= 2;
					if (rightIndex > leftIndex)
					{
						if (onGround)
							play('walkLR');
						if (velocity.x < 0) //apply drag manually since FlxU.computeVelocity only does it when accleration = 0
							velocity.x += Drag;
						acceleration.x = 6*speed; //velocity.x = maxVelocity;
						facing = RIGHT;
						_faceOrder.y = NaN;
						_faceOrder.x = this.x + this.width + 1;
					}
					else if (leftIndex > rightIndex)
					{
						if (onGround)
							play('walkLR');
						if (velocity.x > 0) //apply drag manually since FlxU.computeVelocity only does it when accleration = 0
							velocity.x -= Drag;
						acceleration.x = -6*speed;//velocity.x = maxVelocity.x;
						facing = LEFT;
						_faceOrder.y = NaN;
						_faceOrder.x = this.x - 1;
					}
					else //neither left nor right held down
					{
						if(velocity.x - Drag > 0)
							velocity.x = velocity.x - Drag;
						else if(velocity.x + Drag < 0)
							velocity.x += Drag;
						else
							velocity.x = 0;
						
						if (onGround)
							play("idleHorizontal");
						acceleration.x = 0;//velocity.x = 0; //reset player's vertical speed after every update
					}
					if (up)
					{
						if (onGround)
							jump();
						if (velocity.y < 0)
							velocity.y -= (gravity * 0.60) * FlxG.elapsed;
					}
					if (velocity.y > 0)
						play('fall');
				}
				else
				{
					velocity.x = 0; //reset player's horizontal and vertical speed after every update
					velocity.y = 0;
					if (_pressOrder[0] == RIGHT || _pressOrder[0] == LEFT)
						play('walkLR');
					walk(_pressOrder[0]);
				}
				
				//updates flashing animation
				if (vulnerableTime > 0)
				{
					vulnerableTime -= FlxG.elapsed;
					_elapsed += FlxG.elapsed;
					if (vulnerableTime <= 0)
					{
						vulnerableTime = _elapsed = 0;
						visible = true;
					}
					else if (_elapsed >= 0.125)
					{
						_elapsed = 0;
						visible = !visible;
					}
				}
			}
		}
		
		override public function postUpdate():void
		{
			//this function is overriden solely to update animation during death sequence
			super.postUpdate();
			if (!alive && FlxG.paused)
				_timerManager.update(); //otherwise timerManager never gets called
		}
		
		public function jump():void
		{
			this.play('jump');
			velocity.y = -200;
			FlxG.play(Sources.Mp3boopJump);
		}
		
		/**
		 * these decide which arrow key to pay attention to if multiples are held down.
		 */
		private function walk(direction:int):void
		{
			if (direction == UP)
			{
				velocity.y = -speed;
				facing = RIGHT;
				play('walkUp');
				_faceOrder.y = this.y - 1;
				_faceOrder.x = NaN;
			}
			else if (direction == DOWN)
			{
				velocity.y = speed;
				play('walkDown');
				_faceOrder.y = this.y + this.height + 1;
				_faceOrder.x = NaN;
			}
			else if (direction == LEFT)
			{
				velocity.x = -speed;
				facing = LEFT;
				_faceOrder.y = NaN;
				_faceOrder.x = this.x - 1;
			}
			else if (direction == RIGHT)
			{
				velocity.x = speed;
				facing = RIGHT;
				_faceOrder.y = NaN;
				_faceOrder.x = this.x + this.width + 1;
			}
		}
		
		/**
		 * Checks if any of a list of objects is 1px in front of the player
		 * 
		 * @param	Object	the object to be checked
		 * @return	returns
		 */
		public function inFrontOf(Obj:FlxObject): Boolean
		{
			/*This is an earlier version of the function. I changed it because it detected overlap inside of Jon's hitbox, rather than on just the edge. 
			if ((this.x + this.width + _faceOrder[3] > Obj.x && this.x + _faceOrder[2] < Obj.x + Obj.width)
				&& (this.y + this.height + _faceOrder[1] > Obj.y && this.y - _faceOrder[0] < Obj.y + Obj.height))
				return true
			return false*/
			if (((!isNaN(_faceOrder.x) && _faceOrder.x > Obj.x && _faceOrder.x < Obj.x + Obj.width)
				&& (this.y + this.height > Obj.y && this.y < Obj.y + Obj.height))
				|| ((!isNaN(_faceOrder.y) && _faceOrder.y > Obj.y && _faceOrder.y < Obj.y + Obj.height)
				&& (this.x + this.width > Obj.x && this.x < Obj.x + Obj.width))) 
					return true;
			return false
		}
		
		private function eventTimer(Timer:FlxTimer=null):void
		{
			if (Timer == null) //game reset after death
			{
				FlxG.switchState(new HomeState(true));
				return;
			}
			
			switch (Timer.time)
			{
				case 0.1: //reset colour after hurt
					this.color = 0xffffff;
					break;
				case 1: //disappear the damage text
					_damageText.remove(_damageText.members[Timer.ID] as FlashText).destroy();
					break;
				case (new Sources.Mp3deathSequence).length / 1000:
					FlxG.fade(0xff000000, 2, eventTimer);
					break;
			}
		}
		
		override public function hurt(Damage:Number):void
		{
			this.color = 0xff0000;
			new FlxTimer().start(0.1, 1, eventTimer); //change colour back
			
			super.hurt(Damage);
			
			var colour:uint;
			if (Damage / maxHealth <= 0.5)
			{
				colour = (1 - 2 * (Damage/maxHealth)) * 0xff; //white component 
				colour = 0xff0000 + (colour<<8) + colour; // increases from white to red with damage
			}
			else //decreases from red to black with damage
				colour = uint(2 * (-Damage/maxHealth + 1) * 0xff)<<16;
			var newText:FlashText = new FlashText(x + width / 2, y - 14, String(Damage), NaN, NaN, colour);
			FlxG.flashObjects.addChild(newText.field);
			var randomHeight:int = 60 + FlxG.random() * 11;
			newText.velocity.y = -randomHeight;
			newText.acceleration.y = 2 * randomHeight;
			_damageText.add(newText);
			var textTimer:FlxTimer = new FlxTimer().start(1, 1, eventTimer, _timerManager); //to clear the ascending damage text
			textTimer.ID = _damageText.members.indexOf(newText); //to recall location of object in eventTimer function
		}
		
		override public function kill():void
		{
			//reset the player
			alive = false;
			controllable = false;
			velocity.x = velocity.y = 0;
			acceleration.x = acceleration.y = 0;
			color = 0xffffff;
			
			//pause everything else
			BattleMenu.controllable = false;
			FlxG.paused = true;
			
			//set up the death sequence
			new FlxTimer().start((new Sources.Mp3deathSequence).length / 1000, 1, eventTimer, _timerManager);
			FlxG.sounds.kill();
			if (FlxG.music == null)
				FlxG.music = new FlxSound();
			FlxG.music.loadEmbedded(Sources.Mp3deathSequence, false, true);
			FlxG.music.play();
			play('die');
		}
		
		public function setPlatformerMode(On:Boolean):void
		{
			var gravity:Number;
			if(On)
			{
				platformerMode = true;
				acceleration.y = gravity;
				height = 24;
				offset.y = 4;
				this.y -= 16; //fix this so he doesn't jump
			}
			else
			{
				platformerMode = false;
				acceleration.x = acceleration.y = 0;
				height = 8;
				offset.y = 20;
				this.y += 16;
			}
		}
		
		public function getPlatformerMode():Boolean
		{
			return platformerMode;
		}
		
		override public function destroy():void
		{
			_damageText.destroy();
			super.destroy();
		}
		
	}

}
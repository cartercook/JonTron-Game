package  
{
	import org.flixel.*;
	import org.flixel.plugin.TimerManager;
	
	/**
	 * ...
	 * @author Carter
	 */
	public class Jacques extends FlxSprite 
	{
		public static var haveJacques:Boolean = false;
		private var timerManager:TimerManager;
		private var animTimer:FlxTimer;
		private var prop:Boolean;
		private var smoking:Boolean;
		public var flyHeight:Number;
		public var flapping:FlxSound;
		public var player:Jon;
		
		/**
		 * 
		 * @param	prop	whether Jacques should loop animations as an on-stage prop
		 * OR fly around when Jon is hurt.
		 */
		public function Jacques(Prop:Boolean, Smoking:Boolean=false)
		{
			timerManager = new TimerManager;
			this.prop = Prop;
			this.smoking = Smoking
			
			if (prop)
			{
				loadGraphic(Sources.ImgJacques1, true, true, 18, 14);
				if (!smoking)
				{
					addAnimation('glanceRight', [1, 0], 1, false);
					addAnimation('glanceUp', [2, 3, 2, 0], 8, false);
					addAnimation('peck', [4, 5, 4, 0], 12, false);
					addAnimation('love', [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6, 7, 8, 9, 10], 8, false);
					frame = 0;
				}
				else
				{
					addAnimation('smoke', [16, 17, 18, 19], 2, true);
					addAnimation('glanceRight', [20, 21], 1, false);
					addAnimation('glanceUp', [22, 23, 24], 8, false);
					addAnimation('peck', [25, 26, 25], 4, false);
					addAnimation('warp', [28, 29, 31, 32, 33, 34, 35, 36, 37, 38, 39], 5, false);
					play('smoke');
				}
				
				animTimer = new FlxTimer();
				addAnimationCallback(animationCallback);
				animTimer.start(FlxG.random() * 4, 1, eventTimer, timerManager);
			}
			else
			{
				loadGraphic(Sources.ImgJacques2, true, true, 24, 19);
				addAnimation('flap', [0, 1, 2, 1], 8);
				flyHeight = NaN;
				flapping = new FlxSound();
				flapping.loadEmbedded(Sources.Mp3birdFlap, true);
				this.elasticity = 1;
				this.exists = false;
			}
		}
		
		override public function update():void
		{
			super.update();
			postUpdate();
			timerManager.update();
			trace(animTimer.timeLeft);
			if (this.prop)
				return;
			
			if (this.x <= player.x)
				this.facing = RIGHT;
			else
				this.facing = LEFT;
			if (!isNaN(this.flyHeight)) //jaques is traveling in a sine wave
			{
				//this.acceleration.y = this.flyHeight - this.y;
				this.acceleration.x = (player.x + FlxG.width / 4 - this.x) / 10;
				this.acceleration.y = (player.y - FlxG.height / 6 - this.y) / 10;
			}	
			else
			{
				if (this.velocity.x > 0)
				{
					this.maxVelocity.x = 25; //will accelerate to 25px/sec and continue on
					this.maxVelocity.y = 25;
				}
				if (this.velocity.y > 0) //Jaqcues is at the top of his arc
				{
					this.play('flap');
					this.acceleration.y = 0;
					this.acceleration.x = 5;
					this.velocity.y = 30;
					this.flyHeight = this.y;
				}
			}
		}
		
		public function flyAround(Player:Jon):void
		{
			if (this.exists)
				return;
			
			this.player = Player;
			flapping = FlxG.play(Sources.Mp3birdFlap, 1, true, false);
			this.x = player.x;
			this.y = player.y;
			this.exists = true;
			this.frame = 2;
			this.velocity.y = -45; //send Jacques into an arc
			this.acceleration.y = 12;
			if (player.facing == RIGHT)
				this.velocity.x = -90
			else
				this.velocity.x = 90;
			this.acceleration.x = 40;
			var timer:FlxTimer = new FlxTimer().start(1, 1, eventTimer, timerManager);
			timer.ID = 1;
		}
		
		override public function reset(X:Number, Y:Number):void
		{
			super.reset(X, Y);
			flyHeight = NaN;
			acceleration.x = acceleration.y = 0;
			this.exists = false;
			maxVelocity.x = 1000;
			flapping.stop();
			FlxG.play(Sources.Mp3powerup);
		}
		
		private function eventTimer(Timer:FlxTimer=null):void
		{
			if (Timer == null)
				return
			if (Timer.ID == 1)
				FlxG.play(Sources.Mp3jacquesOhShit);
			else
			{
				var rand:Number = FlxG.random();
				if (rand <= 0.2)
					play('glanceRight');
				else if (rand >= 0.4 && rand <= 0.6)
					play('peck');
				else
					play('glanceUp');
			}
		}
		
		private function animationCallback(AnimationName:String, FrameNumber:uint, FrameIndex:uint):void
		{
			trace("whoops!")
			if (AnimationName == "warp")
			{
				animTimer.stop();
				if (finished)
					this.exists = false;
			}
			if ((FrameIndex <= 5 || (FrameIndex >= 20 && FrameIndex <= 26)) && finished)
			{
				if (smoking)
					play("smoke");
				animTimer.start(FlxG.random() * 4, 1, eventTimer, timerManager);
			}
			
			//else if (!animTimer.finished)
				//animTimer.stop();
		}
		
	}

}
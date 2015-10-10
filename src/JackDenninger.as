package
{
	import org.flixel.*;
	import org.flixel.plugin.TimerManager;
	/**
	 * As I to jam heaps of code into OverWorld.as, I begin to see the light of encapsulation.
	 * As such I am giving the Jack Denninger sprite his own class.
	 * @author CC
	 */
	public class JackDenninger extends FlxSprite
	{
		static public var cutscenePhase:int = 0;
		private var timerManager:TimerManager;
		private var player:Jon;
		private var textbox:TextBox;
		private var startPos:FlxPoint;
		
		public function JackDenninger(X:Number, Y:Number, player:Jon, textBox:TextBox)
		{
			super(X, Y);
			this.timerManager = new TimerManager();
			this.startPos = new FlxPoint(X, Y);
			this.player = player;
			this.textbox = textBox;
			this.visible = false;
			this.immovable = true;
			this.solid = false;
			
			loadGraphic(Sources.ImgJackDenninger, true, true, 15, 27);
			addAnimation('walkDown', [1, 0, 2, 0], 7);
			addAnimation('walkLR', [7, 6, 8, 6], 7);
		}
		
		override public function update():void
		{
			timerManager.update();
			
			if (JackDenninger.cutscenePhase == 1 && player.y > startPos.y + 40)
			{
				player.controllable = false;
				player.velocity.x = player.velocity.y = 0;
				player.play('idleDown');
				player.play('idleDown');
				FlxG.play(Sources.Mp3doorOpen);
				this.visible = true;
				FlxG.music.fadeOut(1);
				var musicTimer:FlxTimer = new FlxTimer().start(1, 1, eventTimer, timerManager);
				musicTimer.ID = 1;
				cutscenePhase = 2;
			}
			else if (cutscenePhase == 3 && textbox.finished)
			{
				this.velocity.y = 60;
				this.play('walkDown');
				player.velocity.y = 60;
				player.play('walkUp');
				cutscenePhase = 4;
			}
			else if (cutscenePhase == 4 && this.y >= startPos.y + 38)
			{
				this.velocity.y = 0;
				this.velocity.x = 75;
				this.play('walkLR');
				player.velocity.y = 0;
				player.play('idleUp');
				cutscenePhase = 5;
			}
			else if (cutscenePhase == 5 && this.getScreenXY().x >= FlxG.width - 40)
			{
				this.velocity.x = 0;
				this.facing = LEFT;
				this.frame = 6;
				textbox.display("By the way, like the suit? It's a Giorgio Armani. 'Cause my dad knows him~.\n\nSmell you later alligator.");
				cutscenePhase = 6;
			}
			else if (JackDenninger.cutscenePhase == 6 && textbox.finished)
			{
				this.facing = FlxObject.RIGHT;
				this.velocity.x = 75;
				this.play('walkLR');
				FlxG.music.fadeOut(1);
				var fadeTimer:FlxTimer = new FlxTimer().start(1, 1, eventTimer, timerManager);
				fadeTimer.ID = 2;
				JackDenninger.cutscenePhase = 7;
			}
		}
		
		private function eventTimer(Timer:FlxTimer = null):void
		{
			if (Timer == null)
				return;
			switch (Timer.ID)
			{
				case 1:
					FlxG.playMusic(Sources.Mp3cheeryBlues);
					player.play('idleUp');
					textbox.display("Hiya Jon. Nice game you got going here. Really digging the graphics, but I wish you would patch up the end of the level here with some drywall here and throw shit into portals. THAT would be something special. But who am I to say? I'm working for a game company myself. Remind me to send you a copy if you can't afford it.", null, "Jack Denninger"); //Nice shorts, that yellow really brings up your face. Here's some neighbourly tips: remember to use the left joystick to look around. Don't use a health potion before looking both ways. And watch out for spikes, ya hear? Well, that's enough chit-chat.", null, "Jack Denninger");
					cutscenePhase = 3;
					break;
				case 2:
					this.exists = false;
					FlxG.playMusic(Sources.Mp3emulatedEuphoria);
					player.controllable = true;
					cutscenePhase = -1;
					break;
			}
		}
		
	}

}
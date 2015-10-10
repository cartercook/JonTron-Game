package
{
	import org.flixel.*;
	
	/**
	 * the loading graphic from sonic '06. You fight it. This is all I can say.
	 * @author CC
	 */
	public class NowLoading extends Enemy
	{	
		private var arrow1:FlxSprite;
		private var arrow2:FlxSprite;
		private var attackPhrases:Array;
		private var idlePhrases:Array;
		
		public function NowLoading(X:Number, Y:Number) 
		{
			super(Sources.ImgNowLoading, X, Y);
			switchState = new OverWorld(true);
			sprite.health = 6;
			_phrases = [new Phrase("The loading screen dots in a few pixels here and there..."), new Phrase("The loading screen forgot where it was and had to start over."), new Phrase("The loading screen is stuck at 99%.", false), new Phrase("The loading screen rememebers the day its father fell to the talons of pigeon poopenheimer."), new Phrase("The loading screen swears vengeance on all birdkind!")];
			
			arrow1 = new FlxSprite(FlxG.width - 86.5, 33 - sprite.height / 2, Sources.ImgLoadArrows);
			arrow2 = new FlxSprite(FlxG.width - 86.5, 72 + sprite.height / 2, Sources.ImgLoadArrows);
			arrow1.alpha = arrow2.alpha = 0;
			arrow1.exists = arrow2.exists = false;
			add(arrow1);
			add(arrow2);
		}
		
		override public function update():void
		{
			//update this
			super.update();
			
			//update arrow1
			if (arrow1.exists)
			{
				if (arrow1.alpha < 1)
				{
					arrow1.alpha += FlxG.elapsed/0.32;
					if (arrow1.alpha >= 1)
					{
						FlxG.play(Sources.Mp3arrowSwoosh);
						arrow1.velocity.x = -500 * Math.sin((arrow1.angle - 90) * (Math.PI / 180)); //convert to shitty radians
						arrow1.velocity.y = 500 * Math.cos((arrow1.angle - 90) * (Math.PI / 180));
						arrow2.exists = true;
						_player.hurt(1);
					}
				}
			}
			
			//update arrow2
			if (arrow2.exists)
			{
				if (arrow2.alpha < 1)
				{
					arrow2.alpha += FlxG.elapsed/0.32;
					if (arrow2.alpha >= 1)
					{
						FlxG.play(Sources.Mp3arrowSwoosh);
						arrow2.velocity.x = -500 * Math.sin((arrow2.angle - 90) * (Math.PI / 180));
						arrow2.velocity.y = 500 * Math.cos((arrow2.angle - 90) * (Math.PI / 180));
						_player.hurt(1);
					}
				}
				else if (!arrow2.onScreen())
				{
					arrow1.exists = arrow2.exists = false;
					dialogue.text = _phrases[_phraseIndex].string;
					attackFinished = true;
				}
			}
		}
		
		override public function attack(Player:Jon):void
		{
			_player = Player;
			
			if (this.sprite.health < 6)
			{
				dialogue.text = "The loading screen sits stunned."
				attackFinished = true;
				return;
			}
			
			getPhrase();
			//not an attck phrase, exit.
			if (!_phrases[_phraseIndex].attack)
			{
				dialogue.text = _phrases[_phraseIndex].string;
				attackFinished = true;
				return;
			}
			
			dialogue.text = "the loading screen attacks!!";
			
			//reposition arrows
			arrow1.x = arrow2.x = FlxG.width - 86.5;
			arrow1.y = 33 - sprite.height / 2;
			arrow2.y = 72 + sprite.height / 2;
			arrow1.velocity.x = arrow2.velocity.x = 0;
			arrow1.velocity.y = arrow2.velocity.y = 0;
			arrow1.alpha = arrow2.alpha = 0;
			
			//angle the arrows at the player
			arrow1.angle = FlxU.getAngle(Player.getMidpoint(), arrow1.getMidpoint()) + 90;
			arrow2.angle = FlxU.getAngle(Player.getMidpoint(), arrow2.getMidpoint()) + 90;
			arrow1.exists = true;
		}
		
	}
}
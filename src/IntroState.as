package 
{
	import org.flixel.*;

	/**
	 * just a black screen with some foreboding text. Nothing special.
	 * 
	 * @author Carter
	 */
	public class IntroState extends FlxState
	{
		private var introText:FlxText;
		private var fullText:String = "Chapter 1: Space Chase." //"SPACE%: home to the many rocks and lights that bother our planet.\nHappy nuisances that glint off Jon's fabulous beard,% as he sits in the cockpit of his low-poly spacecraft.\nHis eyes are set in a steely gaze,%\nwaiting for the exposition to end.\n'Any minute now%..~.'% he thinks to himself desperately.";//"January 29th, 2013.\nJonTron's latest video is uploaded.\nAnd then~.~.~. silence.\nNo new videos for six months.\n\nWhat befell him during those long months of emptiness?\nWhat could possibly have gone wrong~?"
		private var sliceIndex:Number;
		private var displaySpeed:Number;
		private var textHeight:Number;
		private var playSound:Boolean;
		private var elapsed:Number;
		private var hold:Boolean;
		private var spaceBar:FlxSprite;
		
		override public function create():void
		{
			super.create();
			
			sliceIndex = 0;
			displaySpeed = 0.045;
			playSound = true;
			elapsed = 0;
			hold = false;
			introText = new FlxText(FlxG.width / 2 - (FlxG.width - 50) / 2, FlxG.height / 2, FlxG.width - 50, fullText, true);
			textHeight = introText.height;
			spaceBar = new FlxSprite(6, introText.y - textHeight / 2 + 3).loadGraphic(Sources.ImgSpaceBarIcon, true, false, 79, 13)
			spaceBar.addAnimation('press', [0, 1], 2);
			spaceBar.play('press');
			add(spaceBar);
		}
		
		override public function update():void
		{
			if (FlxG.keys.justPressed("SPACE")) //speed up text
			{
				if (spaceBar.visible)
					spaceBar.visible = false;
				displaySpeed = 0.01125;
				if (hold)
				{
					if(playSound)
						FlxG.play(Sources.Mp3scrollText);
					hold = false;
					playSound = true;
				}
				if (sliceIndex >= fullText.length)
					FlxG.fade(0x000000, 3, outro);
			}
			if (FlxG.keys.justReleased("SPACE")) //slow down text
				displaySpeed = 0.0225;
			
			if (!hold)
			{
				elapsed = elapsed + FlxG.elapsed;
				if (elapsed > displaySpeed)
				{
					if (fullText.charAt(sliceIndex - 1) == "%") // "%" is used to create a pause in text
					{
						fullText = fullText.slice(0, fullText.indexOf("%")) + fullText.slice(fullText.indexOf("%") + 1);
						sliceIndex--;
						hold = true;
					}
					if (fullText.charAt(sliceIndex-1) == "~") //"~" cancels the pause on punctuation
						fullText = fullText.slice(0, fullText.indexOf("~")) + fullText.slice(fullText.indexOf("~") + 1);
					else if (fullText.charAt(sliceIndex-1) == "." || fullText.charAt(sliceIndex-1) == "!" || fullText.charAt(sliceIndex-1) == "?")
						hold = true; //creates a pause after punctuation
					//display text
					remove(introText);
					introText = new FlxText(FlxG.width / 2 - (FlxG.width - 50) / 2, FlxG.height / 2 - textHeight / 2, FlxG.width - 50, fullText.slice(0, sliceIndex), true);
					add(introText);
					sliceIndex++;
				}
			}
			super.update();
			
		}
		
		private function outro(Timer:FlxTimer = null):void
		{
			if (Timer != null)
			{
				var stateTimer:FlxTimer = new FlxTimer();
				stateTimer.start(2, 1, outro);
			}
			else
				FlxG.switchState(new SpaceState);
		}
		
	}
	
}
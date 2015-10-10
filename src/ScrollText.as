package 
{
	
	/**
	 * TODO: add whole-word skipping in single update.
	 * @author CC
	 */
	public class ScrollText extends FlashText
	{
		public var finished:Boolean;
		public var hold:Boolean; //creates natural pauses in text
		public var speedup:Boolean; //if true, speed up text
		public var fullText:String; //the full text that gets passed in via the display() function
		public var startIndex:Number; //the character at which the text displayed in the box begins
		public var endIndex:Number; //the character at which the text displayed in the box ends
		
		
		public function ScrollText(X:Number, Y:Number, Text:String, Width:Number=NaN, Height:Number=NaN, Colour:uint=0xffffff)
		{
			//set all variables
			super(X, Y, Text, Width, Height, Colour);
			finished = true;
			fullText = "";
			hold = true;
			speedup = false;
			startIndex = 0;
			endIndex = 0;
		}
		
		override public function update():void
		{
			if (!hold)
			{
				do
				{
					if (fullText.charAt(endIndex - 1) == "%") // "%" is used to create a pause in text
					{
						fullText = fullText.slice(0, fullText.indexOf("%")) + fullText.slice(fullText.indexOf("%") + 1);
						endIndex--;
						if(!speedup)
							hold = true;
					}
					if (fullText.charAt(endIndex-1) == "~") //"~" cancels the pause on punctuation
						fullText = fullText.slice(0, fullText.indexOf("~")) + fullText.slice(fullText.indexOf("~") + 1);
					else if (fullText.charAt(endIndex-1) == "." || fullText.charAt(endIndex-1) == "!" || fullText.charAt(endIndex-1) == "?" && !speedup)
						hold = true; //creates a pause after punctuation
					this.text = fullText.slice(startIndex, endIndex); //text on screen right now
					if (field.numLines >= 4) //if there's more text than can fit in the box
					{
						hold = true;
						if (fullText.lastIndexOf(" ", endIndex - 1) > fullText.lastIndexOf("\n", endIndex - 1)) //whether last word began with a space or new line
							startIndex = fullText.lastIndexOf(" ", endIndex - 1) + 1; //go back to the last word displayed and start from there
						else
							startIndex = fullText.lastIndexOf("\n", endIndex - 1) + 1;
					}
					endIndex++; //moves to the next letter in fullText.
					
					if (endIndex >= fullText.length) //if all text has been displayed
					{
						finished = true;
						break;
					}
				} while (speedup && !hold);
				speedup = false;
			}
		}
		
		public function start():void
		{
			hold = false;
			finished = false;
		}
		
		public function reset():void
		{
			finished = true;
			startIndex = 0;
			endIndex = 0;
			this.text = "";
			speedup = false;
		}
	}
	
}
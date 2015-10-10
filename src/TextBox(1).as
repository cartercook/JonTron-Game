package
{
	import org.flixel.*;
	/**
	 * add this to the stage to display a dynamic textbox, with fancy graphics and the like!
	 * 
	 * @author Carter
	 */
	public class TextBox extends FlxGroup
	{
		public var finished:Boolean;
		private var _text:FlashText;
		private var _subject:FlxSprite; //continue updating while paused
		private var _box:FlxSprite;
		private var _triangle:FlxSprite;
		private var _fullText:String; //the full text that gets passed in via the display() function
		private var _hold:Boolean; //creates natural pauses in text
		private var _displaySpeed:Number;
		private var _soundWait:Boolean;
		private var _elapsed:Number; //makes text speed independent of computer speed.
		private var _startIndex:Number; //the character at which the text displayed in the box begins
		private var _endIndex:Number; //the character at which the text displayed in the box ends
		private var _triY:Number; //used to animate the triangle
		
		/**
		 * sets an invisible textbox on the stage. Display text by calling the display() function.
		 */
		public function TextBox():void
		{
			//set all variables
			finished = true;
			_fullText = "";
			_hold = false;
			_displaySpeed = 0.0225;
			_soundWait = false;
			_elapsed = 0;
			_startIndex = _endIndex = 0;
			_triY = 0;
			this.exists = false;
			
			//create the box
			_box = new FlxSprite(0, 0, Sources.ImgTextBox);
			_box.x = FlxG.width / 2 - _box.width / 2;
			_box.y = FlxG.height - _box.height;
			_box.scrollFactor.x = _box.scrollFactor.y = 0; //so that it doesn't move relative to the camera
			var _boxBackground:FlxSprite = new FlxSprite().makeGraphic(_box.width - 12, _box.height - 10, 0xffffffff);
			_boxBackground.scrollFactor.x = _boxBackground.scrollFactor.y = 0;
			_boxBackground.x = _box.x + 6;
			_boxBackground.y = _box.y + 6;
			add(_boxBackground);
			add(_box);
			
			//Now entering sketchy flash-text territory. FlxText is blurry and shitty, there's no way around it.
			_text = new FlashText(_box.x + 15, _box.y + 11, "", _box.width - 30, _box.height - 22, 0x000000);
			FlxG.flashObjects.addChild(_text.field);
			add(_text);
			
			//the cute little triangle used to signal "press for next page".
			_triangle = new FlxSprite(_box.x + _box.width - 15, _box.y + _box.height - 29, Sources.ImgTriangle);
			_triangle.exists = false; 
			_triangle.scrollFactor.x = _triangle.scrollFactor.y = 0;
			add(_triangle);
		}
		
		override public function update():void
		{
			if (this.exists && this.active)
			{
				super.update();
				if (_subject != null)
					_subject.update();
				
				if (FlxG.keys.justPressed("SPACE"))
				{
					_displaySpeed = 0.005625; //0.0225/4, speeds up text
					
					if (_hold && !_soundWait)
					{
						_hold = false;
						if (_triangle.exists)
						{
							_triangle.exists = false;
							FlxG.play(Sources.Mp3scrollText, 0.7);
						}
					}
					
				}
				if (FlxG.keys.justReleased("SPACE"))
					_displaySpeed = 0.0225; //slow down text
				
				if (!_hold)
				{
					_elapsed += FlxG.elapsed; //this is basically a timer moderating text speed.
					if (_elapsed > _displaySpeed)
					{
						_elapsed = 0;
						if (_fullText.charAt(_endIndex - 1) == "%") // "%" is used to create a pause in text
						{
							_fullText = _fullText.slice(0, _fullText.indexOf("%")) + _fullText.slice(_fullText.indexOf("%") + 1);
							_endIndex--;
							_hold = true;
						}
						if (_fullText.charAt(_endIndex-1) == "~") //"~" cancels the pause on punctuation
							_fullText = _fullText.slice(0, _fullText.indexOf("~")) + _fullText.slice(_fullText.indexOf("~") + 1);
						else if (_fullText.charAt(_endIndex-1) == "." || _fullText.charAt(_endIndex-1) == "!" || _fullText.charAt(_endIndex-1) == "?")
							_hold = true; //creates a pause after punctuation
						_text.field.text = _fullText.slice(_startIndex, _endIndex); //text on screen right now
						if (_text.field.numLines >= 4) //if there's more text than can fit in the box
						{
							_hold = true;
							if (_fullText.lastIndexOf(" ", _endIndex - 1) > _fullText.lastIndexOf("\n", _endIndex - 1)) //whether last word began with a space or new line
								_startIndex = _fullText.lastIndexOf(" ", _endIndex - 1) + 1; //go back to the last word displayed and start from there
							else
								_startIndex = _fullText.lastIndexOf("\n", _endIndex - 1) + 1;
							_triangle.exists = true;
						}
						_endIndex++; //moves to the next letter in _fullText.
						
						if (FlxG.keys.justPressed("SPACE") && _endIndex >= _fullText.length) //if all text has been displayed
						{
							_startIndex = 0;
							_endIndex = 0;
							if (_soundWait)
								_hold = true;
							else
							{
								hide();
							}
						}
						
					}
				}
				if (_triangle.exists)
					_triangle.y += Math.sin(_triY += 1 / 5) / 3; //makes _triangle bounce up and down.
			}
		}
		
		/**
		 * shows the textbox and sets the text moving.
		 * Remember, "%" can be used to create an artificial pause, and "~" prevents puncutation from pausing.
		 * 
		 * @param	Text			whatever you want to write in the textbox. Can be as long as you'd like.
		 * @param	Subject			continue updating this sprite while paused.
		 * @param	Name			append a name to the dialogue.
		 * @param	SoundFinish		Waits until PlaySound is finished to hide the textbox and unpause the game. 
		 * @param	PlaySound		the sound you want to play when the textbox appears. It's a beep by default.
		 */
		public function display(Text:String, Subject:FlxSprite=null, Name:String=null, PlaySound:Class=null, SoundFinish:Boolean=false):void
		{
			_subject = Subject;
			if (PlaySound == null)
				FlxG.play(Sources.Mp3scrollText, 0.7);
			else
			{
				FlxG.play(PlaySound, 0.7);
				if (SoundFinish)
					new FlxTimer().start((new PlaySound).length/1000, 1, hide);
			}
			FlxG.paused = true;
			this.exists = true;
			_hold = false;
			finished = false;
			if (Name == null)
				_fullText = Text;
			else
			{
				_fullText = Name + ": " + Text;
				_endIndex = Name.length + 1;
			}
			_soundWait = SoundFinish;
		}
		
		private function hide(Timer:FlxTimer = null):void
		{
			finished = true;
			_startIndex = 0;
			_endIndex = 0;
			_text.field.text = "";
			this.exists = false;
			FlxG.paused = false;
		}
		
	}

}
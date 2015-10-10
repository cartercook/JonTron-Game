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
		private var _text:ScrollText;
		private var _elapsed:Number;
		private var _subject:FlxSprite; //continue updating while paused
		private var _box:FlxSprite;
		private var _triangle:FlxSprite;
		private var _soundWait:Boolean;
		private var _triY:Number; //used to animate the triangle
		
		/**
		 * sets an invisible textbox on the stage. Display text by calling the display() function.
		 */
		public function TextBox():void
		{
			//set all variables
			_elapsed = 0;
			_soundWait = false;
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
			_text = new ScrollText(_box.x + 15, _box.y + 11, "", _box.width - 30, _box.height - 22, 0x000000);
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
					if (_text.hold && !_soundWait)
					{
						_text.hold = false;
						if (_triangle.exists)
						{
							_triangle.exists = false;
							FlxG.play(Sources.Mp3scrollText, 0.7);
						}
					}
					else
						_text.speedup = true //write all chars up to next hold
					if (_text.finished) //if all text has been displayed
					{
						if (_soundWait)
							_text.hold = true;
						else
							hide();
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
				{
					FlxG.music.pause();
					FlxG.music.exists = false; //prevents intro music from overlapping this
					new FlxTimer().start((new PlaySound).length / 1000, 1, hide);
				}
			}
			FlxG.paused = true;
			this.exists = true;
			_text.start();
			
			if (Name == null)
				_text.fullText = Text;
			else
			{
				_text.fullText = Name + ": " + Text;
				_text.endIndex = Name.length + 1;
			}
			_soundWait = SoundFinish;
		}
		
		private function hide(Timer:FlxTimer = null):void
		{
			if (_soundWait)
			{
				FlxG.music.exists = true;
				FlxG.music.play();
			}
			_text.reset();
			this._elapsed = 0;
			this.exists = false;
			FlxG.paused = false;
		}
		
		public function get finished():Boolean
		{return _text.finished }
		
	}

}
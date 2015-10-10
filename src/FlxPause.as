package 
{
    import org.flixel.*;

	/**
	 * ripped from Tower Of Heaven (sorry)
	 * @CC
	 */
    public class FlxPause extends FlxGroup
    {
        public function FlxPause()
        {
			super();
            var width:Number = 80;
			var height:Number = 86;
			var BG:FlxSprite = new FlxSprite((FlxG.width - width) / 2, (FlxG.height - height) / 2).makeGraphic(width, height, 2852126720, true);
            add(BG);
            (add(new FlxText(BG.x, BG.y, width, "this game is")) as FlxText).alignment = "center";
            add(new FlxText(BG.x, BG.y + 10, width, "PAUSED").setFormat(null, 16, 16777215, "center"));
            add(new FlxSprite(BG.x + 4, BG.y + 36, Sources.ImgKeyP));
            add(new FlxSprite(BG.x + 4, BG.y + 48, Sources.ImgKeyPlus));
            add(new FlxSprite(BG.x + 4, BG.y + 60, Sources.ImgKeyMinus));
            add(new FlxSprite(BG.x + 4, BG.y + 72, Sources.ImgKey0));
            add(new FlxText(BG.x + 16,BG.y + 36, width - 16, "Pause"));
            add(new FlxText(BG.x + 16,BG.y + 48, width - 16, "Sound Up"));
            add(new FlxText(BG.x + 16,BG.y + 60, width - 16, "Sound Down"));
            add(new FlxText(BG.x + 16,BG.y + 72, width - 16, "Mute"));
			this.setAll('scrollFactor', new FlxPoint(0, 0));
            return;
        }// end function
    }
}

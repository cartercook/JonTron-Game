package  
{
	import org.flixel.*;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.text.AntiAliasType;
	import flash.text.TextFieldAutoSize;
	
	/**
	 * used to integrate TextFields into flixel
	 * NOTE: I need to adjust get/set XY to account for camera offset.
	 * @author CC
	 */
	public class FlashText extends FlashObject
	{
		internal var format:TextFormat;
		public var field:TextField;
		
		/**
		 * For treating flash text like an FlxObject.
		 * 
		 * @param	X		x co-oordinate. Must be translated to the field object using a getter/setter
		 * @param	Y		y co-oordinate. Must be translated to the field object using a getter/setter
		 * @param	Text
		 * @param	Width	if NaN, text will infinitely widen from the center. Else, textWrap=true.
		 * @param	Height	if NaN, text will infinitely widen from the center. Else, textWrap=true.
		 * @param	Colour
		 */
		public function FlashText(X:Number, Y:Number, Text:String, Width:Number=NaN, Height:Number=NaN, Colour:uint=0xffffff)
		{
			object = new TextField;
			field = object as TextField;
			
			if (isNaN(Width) && isNaN(Height))
				field.autoSize = TextFieldAutoSize.CENTER;
			else
			{
				field.wordWrap = true; //text can't expand past its bounding box
				if (!isNaN(Width))
					field.width = Width * FlxG.camera.zoom;
				if (!isNaN(Height))
					field.height = Height * FlxG.camera.zoom;
			}
			field.embedFonts = true;
			field.selectable = false; //cannot be selected by the mouse
			field.antiAliasType = AntiAliasType.ADVANCED; //allows you to change sharpness
			field.sharpness = 350; //kills the anti-aliasing
			field.defaultTextFormat = this.format = new TextFormat("FontSNES", 23, Colour); //white text
			field.text = Text;
			super(X, Y);
			
			if (FlxG.visualDebug)
				field.border = true;
		}
		
		public function get text():String
		{return field.text;}
		public function set text(Text:String):void
		{field.text = Text; }
		
		override public function destroy():void
		{
			format = null;
			field = null;
			super.destroy();
		}
		
	}

}
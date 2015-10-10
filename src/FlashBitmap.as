package  
{
	import org.flixel.*;
	
	/**
	 * used to integrate Bitmaps into flixel
	 * NOTE: I need to adjust get/set XY to account for camera offset.
	 * @author CC
	 */
	public class FlashBitmap extends FlashObject
	{	
		/**
		 * For treating flash text like an FlxObject.
		 * 
		 * @param	X		x co-oordinate. Must be translated to the field object using a getter/setter
		 * @param	Y		y co-oordinate. Must be translated to the field object using a getter/setter
		 */
		public function FlashBitmap(X:Number, Y:Number, Graphic:Class, scaleX:Number=1, scaleY:Number=1)
		{
			object = new Graphic;
			object.scaleX = scaleX;
			object.scaleY = scaleY;
			
			super(X, Y);
		}
		
	}

}
package  
{
	import org.flixel.*;
	
	/**
	 * a class for adding layers over an FlxSprite
	 * @CC
	 */
	public class FlxLayer extends FlxGroup 
	{
		public var properties:Array;
		private var offsets:Array;
		private var background:FlxObject;
		
		/**
		 * sets x, y, exists, and any other properties in the properties array
		 * to match the Background object.
		 * 
		 * @param	Background	the sprite you want on which you want to <code>add()</code> layers.
		 */
		public function FlxLayer(Background:FlxObject)
		{
			super();
			
			background = Background;
			properties = new Array('x', 'y', 'exists');
			offsets = new Array();
		}
		
		/**
		 * move an object added to the group behind another object.
		 * If Object2=null, send object 1 to back.
		 * 
		 * @param	Object1		move this object
		 * @param	Object2		behind this object
		 */
		public function moveBehind(Object1:FlxBasic, Object2:FlxBasic=null):void
		{
			var Obj1index:uint = members.indexOf(Object1);
			var Obj2index:uint = 0;
			if (Object2 != null)
				Obj2index = members.indexOf(Object2);
			members.splice(Obj2index, 0, members.splice(Obj1index, 1));
			offsets.splice(Obj2index, 0, members.splice(Obj1index, 1));
		}
		
		override public function update():void
		{
			var basic:FlxBasic;
			var i:uint = 0;
			while(i < length)
			{
				basic = members[i++] as FlxBasic;
				if (basic != null)
					for (var j:uint = 0; j < properties.length; j++)
					{
						if (properties[j] == 'x' || properties[j] == 'y')
							basic[properties[j]] = background[properties[j]] + offsets[i-1][properties[j]];
						else
							basic[properties[j]] = background[properties[j]];
					}
			}
		}
		
		override public function add(Object:FlxBasic):FlxBasic
		{
			//Don't bother adding an object twice.
			if(members.indexOf(Object) >= 0)
				return Object;
			
			//First, look for a null entry where we can add the object.
			var i:uint = 0;
			var l:uint = members.length;
			while(i < l)
			{
				if(members[i] == null)
				{
					members[i] = Object;
					offsets[i] = new FlxPoint(0, 0); //@author CC added this
					if(i >= length)
						length = i+1;
					return Object;
				}
				i++;
			}
			
			//Failing that, expand the array (if we can) and add the object.
			if(_maxSize > 0)
			{
				if(members.length >= _maxSize)
					return Object;
				else if(members.length * 2 <= _maxSize)
					members.length *= 2;
				else
					members.length = _maxSize;
			}
			else
				members.length *= 2;
			
			//If we made it this far, then we successfully grew the group,
			//and we can go ahead and add the object at the first open slot.
			members[i] = Object;
			offsets[i] = new FlxPoint(0, 0);
			length = i+1;
			return Object;
		}
		
	}

}
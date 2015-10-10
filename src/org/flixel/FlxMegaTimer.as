package org.flixel 
{
	import org.flixel.plugin.TimerManager;
	
	/**
	 * @author CC
	 */
	public class FlxMegaTimer extends FlxTimer 
	{
		protected var times:Array
		
		public function FlxMegaTimer(Times:Array,Callback:Function=null,Manager:TimerManager=null)
		{
			super();
			if (Times == null || Times.length < 1)
				return;
			
			times = Times.slice();
			start(times[_timeCounter], times.length, Callback, Manager);
		}
		
		override public function update():void
		{
			_timeCounter += FlxG.elapsed;
			while((_timeCounter >= time) && !paused && !finished)
			{
				_timeCounter -= time;
				
				_loopsCounter++;
				
				if(_callback != null)
					_callback(this);
				
				if((loops > 0) && (_loopsCounter >= loops))
					stop();
				else
					time = times[_loopsCounter];
			}
		}
		
	}

}
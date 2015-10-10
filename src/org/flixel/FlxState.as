package org.flixel
{
	import org.flixel.system.FlxQuadTree;
	import org.flixel.plugin.TimerManager;
	
	/**
	 * This is the basic game "state" object - e.g. in a simple game
	 * you might have a menu state and a play state.
	 * It is for all intents and purpose a fancy FlxGroup.
	 * And really, it's not even that fancy.
	 * 
	 * @author	Adam Atomic
	 */
	public class FlxState extends FlxGroup
	{
		protected var playIntro:Boolean; //makes sure the intro only runs once
		protected var timerManager:TimerManager;
		
		/**
		 * This function is called after the game engine successfully switches states.
		 * Override this function, NOT the constructor, to initialize or set up your game state.
		 * We do NOT recommend overriding the constructor, unless you want some crazy unpredictable things to happen!
		 */
		public function create():void
		{
			timerManager = new TimerManager;
			add(timerManager);
		}
		
		
		//The following shit was all written by IQAndreas
		private var _subState:FlxSubState = null;
		private var _subStateCloseCallback:Function = null;
		
		public function get subState():FlxSubState
		{
			return _subState;
		}
		
		/**
		 * Manually close the sub-state (will always give the reason FlxSubState.CLOSED_BY_PARENT)
		 */
		public function closeSubState():void
		{
			this.setSubState(null);
		}
		 
		public function setSubState(requestedState:FlxSubState, closeCallback:Function = null):void
		{
			/*New instances of the same class are however allowed
			The new callback is ignored if returned. :( */
			if (_subState == requestedState) { return; }
			_subStateCloseCallback = closeCallback;
			
			if(_subState != null)	//Destroy the old state (if there is an old state)
				_subState.close();
			
			_subState = requestedState; //assign and create the new state (or set it to null)
			
			if (_subState != null)
			{
				//WARNING: What if the state has already been created? I'm just copying the code
				//from "FlxGame::switchState" which doesn't check for already created states. :/
				_subState.parentState = this;
				
				//Reset the keys so things like "justPressed" won't interfere
				if (_subState.isBlocking) { FlxG.keys.reset(); }
				_subState.create();
			}
		}
		
		internal function subStateCloseHandler():void
		{
			//Call the "closeCallback" while subState variables are still in memory,
			//But after "FlxSubState.close()" has been called
			if (_subStateCloseCallback != null)
			{
				_subStateCloseCallback(null, _subState);
				_subStateCloseCallback = null;
			}
			
			_subState.destroy();
			_subState.parentState = null;
			_subState = null;
		}
		
		
		public override function destroy():void
		{
			if (_subState) { this.closeSubState(); }
			super.destroy();
		}
		
		
		public function tryUpdate():void
		{
			if (!_subState || !_subState.isBlocking)
				this.update();
			
			//The current state will update before the subState. Is that good or bad?
			if (_subState)
				_subState.tryUpdate();
		}
		
		//Moved drawing to inside of FlxGame
		//ALWAYS draw the background state? Or is it better to only draw if if it's non-blocking?
		public override function draw():void
		{
			super.draw(); //draw all children
			
			//If called in this order, draws the subState on top of the current state
			if (_subState) { _subState.draw(); }
		}
		
	}
}

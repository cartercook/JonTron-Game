package
{
	import org.flixel.*;
	
	[SWF(width = "540", height = "380", backgroundColor = "#000000")]
	[Frame(factoryClass="Preloader")]
	
	/*
	 * REMINDERS:
		 * Code Credits:
			* thank bfxr for sound effects
			* thank adam atomic, IQAndreas, Schulles, and photonStorm for code
		 * Graphics Credits:
			* ask MistaBird on deviant art if I can use his sprites. If not... Um...
			* ask BasheManMusic if I can use his intro. If not, UM UM UHH
			* Frario for Jon & Jacques pixel art
			* Weapon - Guns from "Castlevania - Aria of Sorrow" by Croix.
			* Ultimate Dracula Sprites by AdrianAkuma on deviantart
		 * Music Credits:
			* Credit wandschrank for backsteinhaus
			* Credit Electric ToothBrush for "Sand canyon - Kirby DL3"
		 * Copyright Credits:
			* EarthBound Morning Song
			* credit the house song from OoT
			* the house graphic and golbat cry from pokemon yellow
			* Metroid Item fanfare
			* songbird from bioshock
			* SFX from Okami
			* StarFox 2 graphic
			* Zombies ate my Neighbors tileset
			* Sonic '06 loading screen
			* Resident Evil 4 hud
			* megaman 7 death SFX
			* super mario kart latiku
			* starfox adventures game disk
			* Super Mario Bros. 3 set pieces
			* Minish Cap PBG character sprites
		 * TODO
			* add emulated euphoria to introState.
			* need a battle intro/outro sound effect
			* need a gate creaking sound for front gate
			* don't forget that you can fuck with the camera's container sprite
			* extend nowLoading and other monsters from Enemy.as
			* Consider also making N64 cartridges with flame coming out the bottom.
		 * EXTRA TIDBITS:
			 * use an FlxCamera to make a mirror effect
	 *
	 * CREDITS:
		 * A big thank you to the authors who put their tilesets up with a public liscence:
		 * Latest Tileset So Far by TheDeadHeroAlistair http://www.deviantart.com/art/Latest-Tileset-So-Far-134254669
		 * Environment Tileset by RiedYaro http://reidyaro.deviantart.com/art/Environment-Tileset-294238835
		 * My Free Tileset v10 by Silveira Neto http://silveiraneto.net/2009/07/31/my-free-tileset-version-10/
		 * Rustboro City Tileset by Heavy-Metal-Lover http://heavy-metal-lover.deviantart.com/art/Rustboro-City-Tileset-155497043
	*/
	
	public class SuperJonTron extends FlxGame
	{
		public function SuperJonTron()
		{
			super(270, 190, StartScreenState, 2, 60, 30, true); //gameboy SP resolution = 240 x 160
			this.useSoundHotKeys = true;
			
			//forceDebugger = FlxG.debug = true; //I never could get this to work
			//FlxG.visualDebug = true; //shows bounding boxes. I love it so much.
		}
		
	}
	
}
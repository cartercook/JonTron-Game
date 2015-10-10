package  
{
	import org.flixel.*;
	import org.flixelPP.*; //<3 <3 <3
	import flash.geom.Rectangle;
	
	/**
	 * Some foxy space idk spaceTron fights a circle.
	 * 
	 * add a little grow/shrinking animation to the flame of Jon's ship
	 * collision needs to be shored up, consider laying a visible FlxSprite over JonShip as a hitbox.
	 * get a better reload sound (killer 7?)
	 * @CC
	 */
	public class SpaceState extends FlxState
	{
		private var stars:FlxSprite;
		private var dukeOfDarkness:FlxSprite;
		private var endPhase:int;
		private var planet:FlxSprite;
		private var disk:FlxSpritePP; //FlixelPP is for pixel-perfect overlap with stretched sprites
		private var fullHealth:int;
		private var diskLayer:FlxLayer;
		private var diskCracks:FlxSprite;
		private var diskBob:Number; //current segment of bounce attack, -1 = not attacking
		private var bouncePhase:int;
		private var skewPhase:int;
		private var diskPath:FlxPath; //path followed during skewAttack
		private var wavePhase:int;
		private var diskScaleY:Number; //keeps track of disk scaleY during wavePhase
		private var diskLoaded:Boolean; //true when image dvd is loaded into disk sprite rather than starfox
		private var moveCounts:Array; //used to keep one move from being overused
		private var latiku:FlxSprite;
		private var player:JonShip; //JonShip extends FlixelPP
		private var playerSpeed:Number;
		private var endElapsed:Number;
		private var explosion:FlxSprite; //used in cutscene
		private var deathOrbGroup:FlxGroup; //manages orbs that fly out on death
		private var playerBounds:PlayerBounds; //hold player and disk inside the camera bounds
		private var currentAnimation:String; //name of Jon's current animation
		private var stowTimer:FlxTimer; //stows gun after 0.75 seconds of disuse
		private var bulletLine:FlxSpritePP; //hit detection for shots fired. Just a horizonatal white line.
		private var bulletHit:FlxSprite;
		private var hud:FlxSprite;
		private var i:int; //for 'for' statements
		
		override public function create():void
		{
			super.create(); //keeps timers from running while paused
			FlxG.playMusic(Sources.Mp3sandCanyon);
			
			stars = new FlxSprite(0, 0, Sources.ImgStars);
			stars.x = FlxG.width / 2 - stars.width / 2; //horizontally center the stars
			stars.y = -stars.height + FlxG.height + 10; //place bottom of png at the bottom of screen (center is above screen)
			stars.angularVelocity = 4; //spin them
			add(stars);
			
			dukeOfDarkness = new FlxSprite().loadGraphic(Sources.ImgLordOfShadow, true, false, 77, 175);
			dukeOfDarkness.x = FlxG.width / 2 - dukeOfDarkness.width / 2;
			dukeOfDarkness.y = 0;
			dukeOfDarkness.alpha = 0;
			dukeOfDarkness.addAnimation('raiseHand', [5, 4, 3, 2, 1, 0], 12, false);
			dukeOfDarkness.addAnimation('lowerHand', [0, 1, 2, 3, 4, 5], 12, false);
			dukeOfDarkness.frame = 5;
			endPhase = -1;
			add(dukeOfDarkness);
			
			planet = new FlxSprite(0, 0, Sources.ImgPlanet);
			planet.x = FlxG.width / 2 - planet.width / 2;
			planet.y = 100;
			add(planet);
			
			disk = new FlxSpritePP;
			disk.loadRotatedGraphic(Sources.ImgStairfaxTemperatures, 8);
			disk.x = FlxG.width - disk.width;
			disk.health = fullHealth = 39; //used to be 78, but it was way too hard;
			diskLayer = new FlxLayer(disk);
			diskLayer.properties = diskLayer.properties.concat(['angle', 'scale', 'skew']);
			diskCracks = new FlxSprite().loadRotatedGraphic(Sources.ImgCrack1, 8);
			diskCracks.visible = false;
			diskLayer.add(diskCracks);
			diskBob = -1;
			bouncePhase = 1; //start with a bounce
			skewPhase = -1;
			diskPath = new FlxPath;
			wavePhase = -1;
			diskLoaded = false;
			moveCounts = new Array(0, 0, 0); //bounceCount, skewCount and waveCount respectively
			add(disk);
			add(diskLayer);
			
			deathOrbGroup = new FlxGroup;
			add(deathOrbGroup);
			
			latiku = new FlxSprite().loadGraphic(Sources.ImgLatiku, true, false, 32, 39);
			latiku.exists = false;
			add(latiku);
			
			playerBounds = new PlayerBounds;
			add(playerBounds);
			
			player = new JonShip;
			player.addAnimationCallback(animationCallback); //used to pace shooting and stow/draw gun
			stowTimer = new FlxTimer; //used only once during final cutscene
			endElapsed = 0; //used to increase gravity during end sequence
			playerSpeed = 75; //used to decrease speed during end sequence
			explosion = new FlxSprite().loadGraphic(Sources.ImgExplosion, true, false, 13, 15);
			explosion.addAnimation('explode', [5, 4, 3, 2, 1, 0], 10, false);
			explosion.exists = false;
			add(player);
			
			bulletLine = new FlxSpritePP(); //only for hit-tests
			bulletLine.makeGraphic(FlxG.width + 170 / 2 - player.width, 2); //as long as it needs to be
			bulletLine.visible = false;
			bulletHit = new FlxSprite().loadGraphic(Sources.ImgBulletHit, true, false, 14, 14);
			bulletHit.addAnimation('explode', [0, 1], 18, false);
			
			hud = new FlxSprite().loadGraphic(Sources.ImgResidentEvilHud, true, false, 95, 59);
			hud.frame = 6; //six bullets in chamber
			hud.x = FlxG.width - hud.width + 35;
			hud.y = FlxG.height - hud.height;
			add(hud);
		}
		
		override public function update():void
		{	
			diskCracks.preUpdate(); //otherwise baked rotation doesn't work
			super.update();
			diskCracks.postUpdate();
			
			//handles collisions
			if (bouncePhase != -1) //only collide during bouncing attack
				FlxG.collide(disk, playerBounds);
			if(player.alive) //prevents wierdness during respawn animation
				FlxG.collide(player, playerBounds);
			if (FlxUPP.overlapPP(player, disk) && player.vulnerable) //collsion, kill player
			{
				player.kill();
				disk.health = fullHealth; //heal disk
				diskCracks.visible = false;
				diskCracks.loadRotatedGraphic(Sources.ImgCrack1); //erase cracks
				hud.frame = 6; //reload
				stowTimer.stop();
				player.frame = 0;
				player.controllable = false;
				player.vulnerable = false; //no killing during respawn
				FlxG.play(Sources.Mp3deathMegaMan7);
				deathOrbGroup.exists = true;
				for (i = 0; i < 16; i++) //death, megaman style
				{
					var deathOrb:FlxSprite = new FlxSprite(player.getMidpoint().x - 13, player.getMidpoint().y - 13);
					deathOrb.loadGraphic(Sources.ImgDeathOrb, true, false, 28, 28);
					var angle:Number;
					if (i < 8)
					{
						angle = ((i / 4) + 1 / 8) * Math.PI;
						deathOrb.addAnimation('pulse', [0, 1, 2, 3, 4], 9);
						deathOrb.velocity.x = Math.sin(angle) * 100; //disperse radially & uniform
						deathOrb.velocity.y = Math.cos(angle) * 100;
					}
					else if (i >= 8)
					{
						angle = ((i - 8) / 4) * Math.PI;
						deathOrb.addAnimation('pulse', [1, 2, 3, 4, 0], 9);
						deathOrb.x += Math.sin(angle) * 13;
						deathOrb.y += Math.cos(angle) * 13;
						deathOrb.velocity.x = Math.sin(angle) * 150; //disperse radially & uniform
						deathOrb.velocity.y = Math.cos(angle) * 150;
					}
					deathOrb.play('pulse');
					deathOrbGroup.add(deathOrb);
				}
				player.x = -player.width; //stage left
				player.y = 0;
				latiku.exists = true;
				latiku.x = player.x + 3;
				latiku.y = player.y - 11;
				latiku.velocity.y = 60; //send latiku into an arc
				latiku.acceleration.y = -45;
				latiku.velocity.x = 120;
				latiku.acceleration.x = -90;
			}
			
			//respawn sequence
			if (!player.alive)
			{
				player.x = latiku.x - 3; //attach player to latiku
				player.y = latiku.y + 11;
				if (latiku.velocity.y <= 0) //latiku is at the bottom of his arc
				{
					player.alive = true;
					player.controllable = true;
					latiku.frame = 1;
					latiku.acceleration.y = -100;
					latiku.velocity.x = 60;
					latiku.acceleration.x = -60;
					new FlxTimer().start(3.5, 1, eventTimer, timerManager); //invulnerability timer
				}
			}
			else if (latiku.exists && latiku.y + latiku.height <= 0) //reset latiku
			{
				latiku.exists = false;
				latiku.frame = 0;
			}
			
			//handles shooting animations
			if (FlxG.keys.SPACE && player.controllable && hud.frame > 0 && endPhase < 3) //not realoading & no cutscene
			{
				if ((currentAnimation == 'stowGun' && player.finished) || currentAnimation == null)
					player.play('drawShoot');
				else if ((currentAnimation == 'shoot' || currentAnimation == 'drawShoot') && player.finished)
					player.play('shoot');
				stowTimer.stop();
				stowTimer.start(0.75, 1, eventTimer, timerManager);
			}
			
			//handles bouncing animation
			switch (bouncePhase)
			{
			case -1:
				break;
			case 1:
				disk.angularVelocity = -1080;
				disk.elasticity = 0.9;
				disk.acceleration.y = 700;
				bouncePhase = 2;
				break;
			case 2:
				if (disk.justTouched(FlxObject.DOWN)) //runs every time the disk touches the ground
				{
					FlxG.play(Sources.Mp3thump);
					disk.velocity.x -= 50;
					disk.elasticity -= 0.2;
				}
				if (disk.justTouched(FlxObject.LEFT)) //runs when it hits the left wall
				{
					disk.elasticity = 0;
					disk.angularVelocity = 800; //reverse spin
					disk.velocity.x = 175; //reverse velocity
					bouncePhase = 3;
				}
				break;
			case 3:
				if (disk.justTouched(FlxObject.RIGHT))
				{
					disk.angle %= 360 //reduce disk angle to <360
					disk.angularVelocity = 0; //deceleration happens in bouncePhase == 3
					disk.velocity.y = -230; //shoot to top of screen and decelerate for 1 second
					disk.acceleration.y = 230;
					bouncePhase = 4;
				}
				break;
			case 4:
				if (disk.velocity.y > 0) 
				{
					disk.y = disk.velocity.y = disk.acceleration.y = 0; //stop the disk in its original position
					moveCounts[0]++;
					new FlxTimer().start(1, 1, eventTimer, timerManager);
					if (diskBob == -1)
						diskBob = 0;
					bouncePhase = 5;
				}
				if (disk.angle < 0) //decelerate disk
					disk.angle += 360 * FlxG.elapsed;
				else if (disk.angle > 0) //return to upright position, end bounce animation, and return to bobbing animtion 
					disk.angle = 0;
				break;
			}
			
			//handles chasing attack
			switch (skewPhase)
			{
			case -1:
				break;
			case 1:
				FlxG.play(Sources.Mp3spinDash);
				disk.skew.x = -1;
				disk.scale.x = disk.scale.y = 0.7;
				disk.angularVelocity = 1080;
				disk.velocity.y = -20;
				skewPhase = 2;
				break;
			case 2:
				if (disk.y <= -20)
					skewPhase = 3
				break;
			case 3:
			case 4:
			case 5:
			case 6:
				diskBob = -1;
				if (skewPhase == 6) //return to corner of screen
				{
					FlxG.play(Sources.Mp3dashReturn);
					diskPath.nodes = [disk.getMidpoint(), new FlxPoint(FlxG.width - disk.width / 2, disk.height / 2)];
				}
				else //shoot directly at player
				{
					FlxG.play(Sources.Mp3dashRelease);
					diskPath.nodes = [disk.getMidpoint(), player.getMidpoint()];
					new FlxTimer().start(3, 1, eventTimer, timerManager); //give player time to dodge
				}
				disk.followPath(diskPath, 118);
				skewPhase += 4;
				break;
				
			case 7:
			case 8:
			case 9:
			case 10:
				if (disk.pathSpeed == 0 && disk.velocity.x != 0 && disk.velocity.y != 0) //once disk has finished path
				{
					disk.velocity.x = disk.velocity.y = 0; //stop disk at end of path
					diskBob = 0; //disk bobs while stationary
					if (skewPhase == 10) //cleanup
					{
						disk.skew.x = 0;
						disk.scale.x = disk.scale.y = 1;
						disk.angle %= 360 //reduce disk angle to <360
						if (360 - disk.angle < 90) //prevents jerky stops
							disk.angle -= 360;
						disk.angularDrag = Math.pow(1080, 2) / (2 * (360 - disk.angle)); //(w_f)^2 = (w_i)^2 + 2*a*theda, 0^2 = 1080^2 + 2*drag*angle
						moveCounts[1]++;
						new FlxTimer().start(1, 1, eventTimer, timerManager);
						if (diskBob == -1)
							diskBob = 0;
						skewPhase = 11;
					}
				}
				break;
				
			case 11:
				if (disk.angularVelocity == 0)
				{
					disk.angle = 0;
					disk.angularDrag = 0;
				}
				break;
			}
			
			//handles sinewave attack
			switch (wavePhase)
			{
			case -1:
				break;
			case 1:
				disk.velocity.x = 100; //move ofscreen right
				wavePhase = 2;
				break;
			case 2:
				if (disk.x > FlxG.width)
				{
					disk.x = FlxG.width + FlxG.height / 2 - disk.height / 2;
					disk.y = FlxG.height / 2 - disk.height / 2; //center disk
					disk.scale.x = 170 / disk.frameHeight; //170 = FlxG.height - 20
					disk.velocity.x = -84;
					diskScaleY = Math.PI / 4; //whole lotta wave math
					disk.scale.y = (170 / disk.frameHeight) * (Math.cos(diskScaleY) + 1) * 0.5;
					FlxG.play(Sources.Mp3hum);
					wavePhase = 3;
				}
				break;
			case 3:
				disk.scale.y = (170 / disk.frameHeight) * (Math.cos(diskScaleY  += (2.7875 * FlxG.elapsed)) + 1) * 0.5;
				if (Math.floor((diskScaleY - 6 * 0.0446) / (2 * Math.PI) + Math.PI / 2) % 2 == 0)
				{
					if (!diskLoaded)
					{
						disk.loadGraphic(Sources.ImgDVD);
						diskLoaded = true;
					}
				}
				else if (diskLoaded)
				{
					disk.loadRotatedGraphic(Sources.ImgStairfaxTemperatures, 8);
					diskLoaded = false;
				}
				if (disk.x + 170 <= 0)
					wavePhase = 4;
				break;	
			case 4:
				if (diskLoaded)
				{
					disk.loadRotatedGraphic(Sources.ImgStairfaxTemperatures, 8);
					diskLoaded = false;
				}
				disk.scale.x = disk.scale.y = 1;
				disk.velocity.x = 150;
				disk.x = -disk.width;
				disk.y = 0;
				wavePhase = 5;
				break;
			case 5:
				if (disk.x >= -disk.width * (2/3))
				{
					disk.velocity.x = 0;
					new FlxTimer().start(0.35, 1, eventTimer, timerManager);
				}
				break;
			case 6:
				if (disk.x >= FlxG.width - disk.width)
				{
					disk.velocity.x = 0;
					moveCounts[2]++;
					new FlxTimer().start(1, 1, eventTimer, timerManager);
					if (diskBob == -1)
						diskBob = 0;
					wavePhase = 7;
				}
				break;
			}
			
			//handles disk bobbing animation
			if (diskBob != -1)
				disk.y += Math.sin(diskBob += 1 / 10) / 7;
			
			//remove offscreen orbs
			if (deathOrbGroup.exists)
			{
				deathOrbGroup.exists = false;
				for (i = 0; i < deathOrbGroup.members.length; i++)
				{
					if (deathOrbGroup.members[i] != null)
					{
						deathOrbGroup.exists = true;
						if (!deathOrbGroup.members[i].onScreen())
							deathOrbGroup.remove(deathOrbGroup.members[i]);
					}
				}
			}
			
			
			//handles dukeOfDarkness cutscene after winning
			switch (endPhase)
			{
			case -1:
				if (dukeOfDarkness.alpha > (1 - disk.health / 8)) //fade out if player dies before winning
					dukeOfDarkness.alpha -= 0.4 * (FlxG.elapsed / 5);
				break;
			case 1: //fade in
				dukeOfDarkness.alpha += FlxG.elapsed / 14.5;
			case 4: //keep explosion pinned to JonTron
				explosion.x = player.x + 67 - explosion.width / 2;
				explosion.y = player.y + 42 - explosion.height / 2;
				break;
			case 5:
				if (player.scale.x > 0)
				{
					player.scale.x = player.scale.y = -Math.pow(2, 6 * (endElapsed += FlxG.elapsed / 6) - 6) + 1; //exponential decrease
					player.speed = playerSpeed * (1 - endElapsed); //decrease player control
					player.acceleration.x = (planet.getMidpoint().x - 20 - player.getMidpoint().x) * (250 * endElapsed); //force, stronger further away
					player.acceleration.y = (FlxG.height - player.height / 2 - 5 - player.getMidpoint().y) * (250 * endElapsed); //increases linearly over time
					if (endElapsed >= 1)
					{
						FlxG.fade(0xff000000, 3, eventTimer, false, false);
						endPhase = 14;
					}
				}
			}
			
		}
		
		private function eventTimer(Timer:FlxTimer = null):void
		{
			if (Timer == null)
				FlxG.switchState(new HomeState(true));
			else if (Timer == stowTimer)
				player.play('stowGun');
			else
			{
				switch (Timer.time)
				{
					//handles transition between disk's moves
				case 1: 
					diskBob = -1;
					//returns index of the biggest & smallest number
					var maxVal:int = 0;
					var maxValIndex:int = 0;
					var minVal:int = Infinity;
					var minValIndex:int = 0;
					for (var i:Number = 0; i < moveCounts.length; i++)
					{
						if (moveCounts[i] > maxVal)
						{
							maxVal = moveCounts[i];
							maxValIndex = i;
						}
						if (moveCounts[i] < minVal)
						{
							minVal = moveCounts[i];
							minValIndex = i;
						}
					}
					
					//decides next move based on move buildup
					if (moveCounts[maxValIndex] >= moveCounts[minValIndex] + 3)
					{
						if (minValIndex == 0)
							bouncePhase = 1;
						else if (minValIndex == 1)
							skewPhase = 1;
						else if (minValIndex == 2)
							wavePhase = 1;
					}
					else
					{
						var rand:Number = FlxG.random();
						if (skewPhase >= 11)
						{
							if (rand < 0.4)
								bouncePhase = 1;
							else if (rand >= 0.4 && rand < 0.8)
									wavePhase = 1;
							else
								skewPhase = 1;
						}
						else if (bouncePhase >= 5)
						{
							if (rand < 0.4)
								skewPhase = 1;
							else if (rand >= 0.4 && rand < 0.8)
								wavePhase = 1;
							else
								bouncePhase = 1;
						}
						else if (wavePhase >= 7)
						{
							if (rand < 0.4)
									skewPhase = 1;
							else if (rand >= 0.4 && rand < 0.9)
								bouncePhase = 1;
							else
								wavePhase = 1;
						}
					}
					
					//return finished moves to inactive
					if (skewPhase >= 11)
					{
						disk.angularVelocity = disk.angle = disk.angularDrag = 0; //just in case. This is pretty badly programmed.
						skewPhase = -1;
					}
					if (bouncePhase >= 5)
						bouncePhase = -1;
					if (wavePhase >= 7)
						wavePhase = -1;
					break;
					
					//handles player's actions
				case 1.1: //reload
					hud.frame = 6;
					break;
				case 2/18: //remove from stage after frames finish
					remove(bulletHit, true);
					break;
				case 3: //interval between skewAttacks
					skewPhase -= 3;
					break;
				case 0.35: //brief stop when the disk peeks out of stage-left during wavePhase
					disk.velocity.x = 170;
					wavePhase = 6;
					break;
				case 3.5: //invulnerability timer
					player.vulnerable = true;
					break
				}
			}
		}
		
		//handles parts of endPhase that doesn't need to be handled by update loop
		private function endTimer(Timer:FlxTimer):void
		{
			switch(Timer.currentLoop)
			{
			case 1: //disk stops flickering and dies
				disk.exists = false;
				stars.angularDrag = 4 / 12; //slow stars to a stop
				FlxG.music.loadEmbedded(Sources.Mp3FFVIopening).play();
				endPhase = 1;
				break;
			case 2: //raises hand
				dukeOfDarkness.play('raiseHand');
				endPhase = 2; //do nothing until endPhase = 3
				break;
			case 3: //stops player
				stowTimer.stop();
				player.frame = player.frame; //freeze Jon
				endPhase = 3; //prevents shooting
				break;
			case 4: //lowers hand
				dukeOfDarkness.play('lowerHand');
				break;
			case 5: //first explosion
				FlxG.play(Sources.Mp3explosion);
				explosion.x = player.x + 67 - explosion.width / 2;
				explosion.y = player.y + 42 - explosion.height / 2;
				explosion.exists = true;
				explosion.play('explode');
				add(explosion);
				endPhase = 4; //keep explosion pinned to Jon
				break;
			case 6: //Jon looks sad
				player.frame = 6;
				break;
			case 7: //blown to high hell & gravity kicks in
				playerSpeed = player.speed;
				player.play('explode');
				endPhase = 5; //gradually pull Jon towards the earth
				break;
			}
		}
		
		private function animationCallback(AnimationName:String, FrameNumber:uint, FrameIndex:uint):void
		{
			currentAnimation = AnimationName;
			
			//quiets sound effects during cutscene
			var volume:Number = 0.75;
			if (!disk.exists)
				volume = 0.2;
			
			//deals with reloading
			if (hud.frame <= 0 && (currentAnimation == 'shoot' || currentAnimation == 'drawShoot') && player.finished)
			{
				stowTimer.stop();
				player.play('stowGun');
				player.drawFrame(); // the first frame of animation gets cut off, so this needs to go here >:(
				new FlxTimer().start(1.1, 1, eventTimer, timerManager);
			}
			if (hud.frame == 0 && currentAnimation == 'stowGun' && player.finished)
				FlxG.play(Sources.Mp3glockCock, volume * 0.7);
			
			if (FrameIndex == 2) //whenever firing frame is played
			{
				//play shoot sound and reduce bullet count
				FlxG.play(Sources.Mp3asteroidsShot, volume);
				hud.frame -= 1;
				bulletLine.x = player.x + player.width;
				bulletLine.y = player.y + 25;
				var lineCollide:Rectangle = bulletLine.overlapsPP(disk);
				if (lineCollide != null && disk.alive) //lineCollide = null if miss
				{
					disk.hurt(1);
					//disk gets progressively more crackes
					if (disk.health == int(fullHealth*(4/5)))
						diskCracks.visible = true;
					else if (disk.health == int(fullHealth*(3/5)))
						diskCracks.loadRotatedGraphic(Sources.ImgCrack2, 8);
					else if (disk.health == int(fullHealth*(2/5)))
						diskCracks.loadRotatedGraphic(Sources.ImgCrack3, 8);
					else if (disk.health == int(fullHealth/5))
						diskCracks.loadRotatedGraphic(Sources.ImgCrack4, 8);
					else if (disk.health < int(fullHealth*(1/5)) && disk.health > 0)
						dukeOfDarkness.alpha = (1 - disk.health / 16) * 0.4;
					else if (disk.health <= 0) //disk is dead
					{
						disk.exists = true;
						disk.active = false; //draw but don't update
						bouncePhase = skewPhase = wavePhase = diskBob = -1; //cancel moves
						disk.velocity.x = disk.velocity.y = disk.angularVelocity = 0; //cancel movement
						disk.acceleration.x = disk.acceleration.y = 0;
						disk.flicker(2.5);
						FlxG.music.fadeOut(2.5);
						//times for endPhase events
						new FlxMegaTimer([2.5, 11.52, 5 / 12, 3.57, 0.9, 0.49, 2], endTimer, timerManager);
						endPhase = 1; //the beginning of the end!!
					}
					FlxG.play(Sources.Mp3asteroidsHit);
					bulletHit.x = lineCollide.x - bulletHit.width / 2; //lineCollide.x = left-most corner of collision area
					bulletHit.y = player.y + 25 - bulletHit.height / 2;
					bulletHit.angle = FlxG.random() * 360;
					bulletHit.play('explode');
					new FlxTimer().start(2 / 18, 1, eventTimer, timerManager); //duration of animation
					add(bulletHit);
				}
			}
			else if (FrameIndex >= 7 && FrameIndex <= 11)//FrameIndex == 7 || FrameIndex == 8 || FrameIndex == 9 || FrameIndex == 10
			{
				var rand:Number = FlxG.random();
				if (rand < 3/4)
					FlxG.play(Sources.Mp3explosion, 1 - endElapsed);
			}
		}
		
	}

}
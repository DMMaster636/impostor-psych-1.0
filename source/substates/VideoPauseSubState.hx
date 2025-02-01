package substates;

import states.StoryMenuState;
import states.FreeplayState;

class VideoPauseSubState extends MusicBeatSubstate
{
	var grpMenuShit:FlxTypedGroup<Alphabet>;

	var menuItems:Array<String> = [];
	var menuItemsOG:Array<String> = ['Resume', 'Restart cutscene'];
	var curSelected:Int = 0;

	var pauseMusic:FlxSound;

	var camPause:PsychCamera;

	var canSkip:Bool = false;
	var canExit:Bool = false;
	public function new(canSkip:Bool = true, canExit:Bool = false)
	{
		this.canSkip = canSkip;
		this.canExit = canExit;
		super();
	}

	override function create()
	{
		camPause = new PsychCamera();
		camPause.bgColor.alpha = 0;
		FlxG.cameras.add(camPause, false);
		camPause.zoom = 0.1;

		if(canSkip) menuItemsOG.insert(1, 'Skip cutscene');
		if(canExit) menuItemsOG.push('Exit to menu');
		menuItems = menuItemsOG;

		pauseMusic = new FlxSound();
		try
		{
			var pauseSong:String = PauseSubState.getPauseSong();
			if(pauseSong != null) pauseMusic.loadEmbedded(Paths.music(pauseSong), true, true);
		}
		catch(e:Dynamic) {}
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		FlxG.sound.list.add(pauseMusic);

		var bg:FlxSprite = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		bg.scale.set(FlxG.width, FlxG.height);
		bg.updateHitbox();
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});

		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);

		regenMenu();
		cameras = [camPause];

		super.create();

		FlxTween.tween(camPause, {zoom: 1}, 0.1, {ease: FlxEase.linear});
	}

	var holdTime:Float = 0;
	var cantUnpause:Float = 0.2;
	override function update(elapsed:Float)
	{
		cantUnpause -= elapsed;
		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;

		super.update(elapsed);

		if(cantUnpause <= 0)
		{
			if(controls.BACK)
			{
				cantUnpause = 0.2;
				FlxTween.tween(camPause, {zoom: 0.1}, 0.1, {
					ease: FlxEase.linear,
					onComplete: function(twn:FlxTween)
					{
						close();
						return;
					}
				});
			}

			if(FlxG.keys.justPressed.F5)
			{
				FlxTransitionableState.skipNextTransIn = FlxTransitionableState.skipNextTransOut = true;
				PlayState.nextReloadAll = true;
				MusicBeatState.resetState();
			}
		}

		if (controls.UI_UP_P) changeSelection(-1);
		if (controls.UI_DOWN_P) changeSelection(1);

		if (controls.ACCEPT && (cantUnpause <= 0 || !controls.controllerMode))
		{
			switch (daSelected)
			{
				case "Resume":
					FlxTween.tween(camPause, {zoom: 0.1}, 0.1, {
						ease: FlxEase.linear,
						onComplete: function(twn:FlxTween)
						{
							close();
						}
					});
				case "Restart cutscene":
					// restartVideo();
				case "Skip cutscene":
					// skip cutscene
					FlxTween.tween(camPause, {zoom: 0.1}, 0.1, {
						ease: FlxEase.linear,
						onComplete: function(twn:FlxTween)
						{
							close();
						}
					});
				case "Exit to menu":
					#if DISCORD_ALLOWED DiscordClient.resetClientID(); #end
					PlayState.deathCounter = 0;
					PlayState.seenCutscene = false;

					PlayState.instance.canResync = false;
					Mods.loadTopMod();
					if(PlayState.isStoryMode)
						MusicBeatState.switchState(new StoryMenuState());
					else 
						MusicBeatState.switchState(new FreeplayState());

					FlxG.sound.playMusic(Paths.music('freakyMenu'));
					PlayState.changedDifficulty = PlayState.chartingMode = false;
					FlxG.camera.followLerp = 0;
			}
		}
	}

	public static function restartVideo()
	{
		// restart video
	}

	override function destroy()
	{
		pauseMusic.destroy();
		super.destroy();
	}

	function changeSelection(change:Int = 0):Void
	{
		curSelected = FlxMath.wrap(curSelected + change, 0, menuItems.length - 1);
		for(num => item in grpMenuShit.members)
		{
			item.targetY = num - curSelected;
			item.alpha = 0.6;
			if(item.targetY == 0) item.alpha = 1;
		}
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
	}

	function regenMenu():Void
	{
		for (obj in grpMenuShit)
		{
			obj.kill();
			grpMenuShit.remove(obj, true);
			obj.destroy();
		}

		for (num => str in menuItems)
		{
			var item = new Alphabet(0, 320, Language.getPhrase('pause_$str', str), true);
			item.isMenuItem = true;
			item.changeX = false;
			item.distancePerItem.y = 80;
			item.screenCenter();
			item.targetY = num;
			grpMenuShit.add(item);
		}
		curSelected = 0;
		changeSelection();
	}
}
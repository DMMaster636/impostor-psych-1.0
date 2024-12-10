package states.stages;

import cutscenes.DialogueBoxImpostor;

class PolusRed extends BaseStage
{
	var speaker:BGSprite;
	var crowd:BGSprite;
	override function create()
	{
		var sky:BGSprite = new BGSprite('polus/polus_custom_sky', -400, -400, 0.5, 0.5);
		sky.setGraphicSize(Std.int(sky.width * 1.4));
		sky.updateHitbox();
		add(sky);

		var rocks:BGSprite = new BGSprite('polus/polusrocks', -700, -300, 0.6, 0.6);
		add(rocks);

		var hills:BGSprite = new BGSprite('polus/polusHills', -1050, -180.55, 0.9, 0.9);
		add(hills);

		var warehouse:BGSprite = new BGSprite('polus/polus_custom_lab', 50, -400, 1, 1);
		add(warehouse);

		var ground:BGSprite = new BGSprite('polus/polus_custom_floor', -1350, 80, 1, 1);
		add(ground);

		speaker = new BGSprite('polus/speakerlonely', 300, 185, 0.95, 0.95, ['speakers lonely'], false, 24);
		if(songName == 'sabotage' || songName == 'meltdown') add(speaker);

		if(songName == 'meltdown')
		{
			substates.GameOverSubstate.characterName = 'bfg-dead';
			var bfdead:BGSprite = new BGSprite('polus/bfdead', 600, 525, 1, 1);
			bfdead.setGraphicSize(Std.int(bfdead.width * 0.8));
			bfdead.updateHitbox();
			add(bfdead);
		}

		if (isStoryMode)
		{
			switch (songName)
			{
				case 'sussus-moogus':
					if(!seenCutscene) setStartCallback(videoCutscene.bind('polus1'));
				case 'sabotage':
					if(!seenCutscene) setStartCallback(videoCutscene.bind('polus2'));
				case 'meltdown':
					if(!seenCutscene) setStartCallback(videoCutscene.bind('polus3'));
					setEndCallback(function()
					{
						game.endingSong = true;
						inCutscene = true;
						canPause = false;
						FlxG.camera.visible = false;
						camHUD.visible = false;
						game.startVideo('meltdown_afterscene');
					});
			}
		}
	}

	override function createPost()
	{
		var snow:BGSprite = new BGSprite('polus/snow', 0, -250, 1, 1, ['cum'], true, 24);
		snow.setGraphicSize(Std.int(snow.width * 2));
		snow.updateHitbox();
		add(snow);

		crowd = new BGSprite('polus/boppers_meltdown', -900, 150, 1.5, 1.5, ['BoppersMeltdown'], false, 24);
		if(songName == 'meltdown') add(crowd);
	}

	override function countdownTick(count:Countdown, num:Int)
	{
		speaker.dance();
		if(num % 2 == 0) crowd.dance();
	}

	override function beatHit()
	{
		speaker.dance();
		if(curBeat % 2 == 0) crowd.dance();
	}

	var videoEnded:Bool = false;
	function videoCutscene(?videoName:String = null)
	{
		inCutscene = true;
		if(!videoEnded && videoName != null)
		{
			#if VIDEOS_ALLOWED
			game.startVideo(videoName);
			game.videoCutscene.overallFinish = function()
			{
				videoEnded = true;
				if (game.generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null && !game.endingSong && !game.isCameraOnForcedPos)
				{
					game.moveCameraSection();
					FlxG.camera.snapToTarget();
				}
				game.videoCutscene = null;
				videoCutscene();
			};
			#else //Make a timer to prevent it from crashing due to sprites not being ready yet.
			new FlxTimer().start(0.0, function(tmr:FlxTimer)
			{
				videoEnded = true;
				videoCutscene(videoName);
			});
			#end
			return;
		}

		switch (songName)
		{
			case 'sussus-moogus':
				startImpDialogue();
			case 'sabotage':
				startImpDialogue();
			case 'meltdown':
				startImpDialogue();
		}
	}

	var doof:DialogueBoxImpostor = null;
	function startImpDialogue()
	{
		var file:String = Paths.txt('$songName/${songName}Dialogue_${ClientPrefs.data.language}'); //Checks for vanilla/Senpai dialogue
		if (!Paths.fileExistsAbsolute(file))
			file = Paths.txt('$songName/${songName}Dialogue');

		if (!Paths.fileExistsAbsolute(file))
		{
			trace("FUCK, it didn't work...");
			startCountdown();
			return;
		}

		doof = new DialogueBoxImpostor(false, CoolUtil.coolTextFile(file));
		doof.cameras = [camHUD];
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;
		doof.nextDialogueThing = PlayState.instance.startNextDialogue;
		doof.skipDialogueThing = PlayState.instance.skipDialogue;

		inCutscene = true;
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		new FlxTimer().start(0.1, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;

			if (black.alpha <= 0)
			{
				if (doof != null) add(doof);
				else startCountdown();

				remove(black);
				black.destroy();
			}
			else tmr.reset(0.1);
		});
	}
}
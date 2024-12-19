
package states.stages;

import states.stages.objects.WalkingCrewmate;

//import cutscenes.DialogueBoxImpostor;

class MiraGreen extends BaseStage
{
	var speaker:BGSprite;
	override function create()
	{
		var bg:BGSprite = new BGSprite('mira/mirabg', -1600, 50, 1, 1);
		bg.setGraphicSize(Std.int(bg.width * 1.06));
		bg.updateHitbox();
		add(bg);

		var fg:BGSprite = new BGSprite('mira/mirafg', -1600, 50, 1, 1);
		fg.setGraphicSize(Std.int(fg.width * 1.06));
		fg.updateHitbox();
		add(fg);

		if(songName == 'sussus-toogus' && !ClientPrefs.data.lowQuality)
		{
			var walker:WalkingCrewmate = new WalkingCrewmate(FlxG.random.int(0, 1), [-700, 1850], 50, 0.8);
			add(walker);
			var walker2:WalkingCrewmate = new WalkingCrewmate(FlxG.random.int(2, 3), [-700, 1850], 50, 0.8);
			add(walker2);
			var walker3:WalkingCrewmate = new WalkingCrewmate(FlxG.random.int(4, 5), [-700, 1850], 50, 0.8);
			add(walker3);
		}

		if(songName == 'lights-down')
		{
			var bfvent:BGSprite = new BGSprite('mira/bf_mira_vent', 70, 200, 1, 1, ['bf vent']);
			bfvent.visible = false;
			add(bfvent);
		}

		var table:BGSprite = new BGSprite('mira/table_bg', -1600, 50, 1, 1);
		table.setGraphicSize(Std.int(table.width * 1.06));
		table.updateHitbox();
		add(table);

		if(songName == 'lights-down')
		{
			speaker = new BGSprite('mira/stereo_taken', 400, 420, 1, 1, ['stereo boom']);
			speaker.visible = false;
			add(speaker);
		}

		if (isStoryMode)
		{
			switch (songName)
			{
				case 'sussus-toogus':
					if(!seenCutscene) setStartCallback(videoCutscene.bind('toogus'));
				case 'sabotage':
					//if(!seenCutscene) setStartCallback(startImpDialogue);
				case 'meltdown':
					if(!seenCutscene) setStartCallback(videoCutscene.bind('polus3'));
					setEndCallback(function()
					{
						game.endingSong = inCutscene = true;
						canPause = FlxG.camera.visible = camHUD.visible = false;
						game.startVideo('meltdown_afterscene');
					});
			}
		}
	}

	var powers:BGSprite;
	override function createPost()
	{
		powers = new BGSprite('mira/cyan_toogus', -550, 275, 1, 1, ['Cyan Dancy'], true);
		powers.visible = false;
		add(powers);
	}

	var goSax:Bool = false;
	override function update(elapsed:Float)
	{
		if(goSax) powers.x = FlxMath.lerp(powers.x, powers.x + 15, FlxMath.bound(elapsed * 9 * game.playbackRate, 0, 1));
	}

	override function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float)
	{
		switch(eventName)
		{
			case "Toogus Sax":
				powers.dance();
				powers.visible = true;
				goSax = true;
		}
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

		/*switch (songName)
		{
			case 'sussus-moogus':
				startImpDialogue();
			case 'sabotage':
				startImpDialogue();
			case 'meltdown':
				startImpDialogue();
		}*/
	}

	/*var doof:DialogueBoxImpostor = null;
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
	}*/
}
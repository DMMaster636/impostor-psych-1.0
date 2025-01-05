
package states.stages;

import states.stages.objects.WalkingCrewmate;

import shaders.BWShader;

//import cutscenes.DialogueBoxImpostor;

class MiraGreen extends BaseStage
{
	var speaker:BGSprite;
	var bfVent:BGSprite;
	var bgBlack:FlxSprite;
	override function create()
	{
		camOffset = 20;

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
			bfVent = new BGSprite('mira/bf_mira_vent', 70, 200, 1, 1, ['bf vent']);
			bfVent.visible = false;
			add(bfVent);
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

		bgBlack = new FlxSprite().makeGraphic(FlxG.width * 4, FlxG.height * 2, FlxColor.BLACK);
		bgBlack.screenCenter();
		bgBlack.alpha = 0;
		add(bgBlack);

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
		if(songName == 'sussus-toogus')
		{
			powers = new BGSprite('mira/cyan_toogus', -550, 275, 1, 1, ['Cyan Dancy'], true);
			powers.visible = false;
			add(powers);
		}
	}

	var goSax:Bool = false;
	override function update(elapsed:Float)
	{
		if(goSax && powers != null)
			powers.x = FlxMath.lerp(powers.x, powers.x + 15, FlxMath.bound(elapsed * 9 * game.playbackRate, 0, 1));
	}

	var charShader:BWShader;
	override function eventPushed(event:objects.Note.EventNote)
	{
		// used for preloading assets used on events that doesn't need different assets based on its values
		switch(event.event)
		{
			case "Lights out":
				if (charShader == null)
					charShader = new BWShader(0.01, 0.12, true);
		}
	}

	override function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float)
	{
		switch(eventName)
		{
			case "Toogus Sax":
				if(powers != null)
				{
					powers.dance(true);
					powers.visible = true;
				}
				goSax = true;

			case "Lights out":
				FlxG.camera.flash(ClientPrefs.data.flashing ? FlxColor.WHITE : 0x4CFFFFFF, 0.35);

				if (boyfriend.curCharacter == 'bf') game.triggerEvent('Change Character', 'bf', 'whitebf');
				else boyfriend.shader = charShader.shader;

				if (dad.curCharacter == 'impostor3') game.triggerEvent('Change Character', 'dad', 'whitegreen');
				else dad.shader = charShader.shader;

				game.iconP1.shader = game.iconP2.shader = charShader.shader;

				game.healthBar.setColors(FlxColor.BLACK, FlxColor.WHITE);
				game.scoreTxt.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.WHITE, 1.25);

				bgBlack.alpha = 1;
				gf.alpha = 0;
				// if(game.usingPet) pet.alpha = 0;

			case "Lights on":
				FlxG.camera.flash(ClientPrefs.data.flashing ? FlxColor.BLACK : 0x4C000000, 0.35);

				if (boyfriend.curCharacter == 'whitebf') game.triggerEvent('Change Character', 'bf', 'bf');
				else boyfriend.shader = null;

				if (dad.curCharacter == 'whitegreen') game.triggerEvent('Change Character', 'dad', 'impostor3');
				else dad.shader = null;

				game.iconP1.shader = game.iconP2.shader = null;

				game.scoreTxt.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 1.25);

				bgBlack.alpha = 0;
				gf.alpha = 1;
				// if(game.usingPet) pet.alpha = 1;

			case "Lights on Ending":
				if (boyfriend.curCharacter == 'whitebf') game.triggerEvent('Change Character', 'bf', 'bf');
				else boyfriend.shader = null;

				if (dad.curCharacter == 'whitegreen') game.triggerEvent('Change Character', 'dad', 'impostor3');
				else dad.shader = null;

				game.iconP1.shader = game.iconP2.shader = null;

				game.scoreTxt.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 1.25);

				bgBlack.alpha = 0;
				boyfriend.visible = gf.visible = camHUD.visible = false;
				// if(game.usingPet) pet.visible = false;

				game.triggerEvent('Play Animation', 'liveReaction', 'dad');
				if(songName == 'lights-down')
				{
					bfVent.dance(true);
					bfVent.visible = true;
					speaker.dance(true);
					speaker.visible = gf.curCharacter != 'ghostgf';
				}

			case "Lights Down OFF":
				camGame.visible = false;
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
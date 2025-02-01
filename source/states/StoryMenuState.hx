package states;

import backend.Song;
import backend.StageData;
import backend.WeekData;

import objects.HealthIcon;

import substates.ResetScoreSubState;

import flixel.input.mouse.FlxMouseEvent;

import shaders.ChromaticAbberation;
import openfl.filters.ShaderFilter;

class StoryMenuState extends MusicBeatState
{
	// Wether you have to beat the previous week for playing this one
	// Not recommended, as people usually download your mod for, you know,
	// playing just the modded week then delete it.
	// defaults to True
	public static var weekCompleted:Map<String, Bool> = new Map<String, Bool>();
	public static var curWeek:Int = 0;

	var lerpScore:Int = 49324858;
	var intendedScore:Int = 0;

	var scoreText:FlxText;

	var txtWeekTitle:FlxText;
	var txtWeekNumber:FlxText;

	var txtTracklist:FlxText;

	var selectedWeek:Bool = false;

	var weekHealthIcon:HealthIcon;
	var weekHealthIconLose:HealthIcon;

	var ship:FlxOffsetSprite;

	var weekCircles:FlxTypedGroup<FlxSprite>;
	var weekLines:FlxTypedGroup<FlxSprite>;
	var weekXvalues:Array<Float> = [];
	var weekYvalues:Array<Float> = [];
	var canMove:Bool = true;
	// left[0] down[1] up[2] right[3]
	var moveDirs:Array<Bool> = [true, true, true, true];

	public var camSpace:PsychCamera;
	public var camScreen:PsychCamera;

	// red[0] green[1] yellowWeek[2] black[3] maroon[4] grey[5] pink[6] jorsawsee?[7] henry[8] tomong[9] loggo[10] alpha[11]
	var unlockedWeek:Array<Bool> = [true, false, false, false, true, false, false, true, false, false, false, false]; //weeks in order of files in preload/weeks

	var localFinaleState:FinaleState;
	var finaleAura:FlxSprite;

	var caShader:ChromaticAbberation;

	override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		persistentUpdate = persistentDraw = true;
		PlayState.isStoryMode = true;
		WeekData.reloadWeekFiles(true);

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Selecting a Week", null);
		#end

		localFinaleState = ClientPrefs.data.finaleState;

		unlockedWeek = ClientPrefs.data.unlockedWeek;

		persistentUpdate = persistentDraw = true;

		camSpace = initPsychCamera();
		camSpace.y = 100;
		camSpace.zoom = 0.7;
		camScreen = new PsychCamera();
		camScreen.bgColor.alpha = 0;
		FlxG.cameras.add(camScreen, false);

		if(localFinaleState == NOT_PLAYED)
		{
			caShader = new ChromaticAbberation(0);
			caShader.amount = 0;
			camSpace.filters = [new ShaderFilter(caShader.shader)];
		}

		var starBG:FlxBackdrop = new FlxBackdrop(Paths.image('freeplay/starBG', 'impostor'));
		starBG.setPosition(111.3, 67.95);
        starBG.updateHitbox();
        starBG.scrollFactor.set();
		starBG.velocity.set(-8, 0);
        add(starBG);
        
        var starFG:FlxBackdrop = new FlxBackdrop(Paths.image('freeplay/starFG', 'impostor'));
        starFG.setPosition(54.3, 59.45);
        starFG.updateHitbox();
        starFG.scrollFactor.set();
		starFG.velocity.set(-24, 0);
        add(starFG);

		finaleAura = new FlxSprite(710, -500).loadGraphic(Paths.image('storymenu/finaleAura', 'impostor'));
        finaleAura.updateHitbox();
		finaleAura.scale.set(2.5,2.5);
        if(localFinaleState == NOT_PLAYED) add(finaleAura);

		ship = new FlxOffsetSprite();
		ship.frames = Paths.getSparrowAtlas('storymenu/ship', 'impostor');
		for(anim in ['left', 'down', 'up', 'right']) ship.quickAnimAdd(anim, anim);
		ship.addOffset('left', -54, 0);
		ship.addOffset('down', -47, 57);
		ship.addOffset('up', -47, -10);
		ship.addOffset('right', 10, 0);
		ship.playAnim('right');
		ship.cameras = [camSpace];

		weekCircles = new FlxTypedGroup<FlxSprite>();
		add(weekCircles);

		weekLines = new FlxTypedGroup<FlxSprite>();
		add(weekLines);

		scoreText = new FlxText(80, 170, 0, Language.getPhrase('week_score', 'HIGHSCORE: {1}', [lerpScore]));
		scoreText.setFormat(Paths.font('AmaticSC-Bold.ttf'), 54, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreText.borderSize = 2;
		scoreText.cameras = [camScreen];

		txtWeekNumber = new FlxText(FlxG.width / 2.4 - 10, 40, 0, "");
		txtWeekNumber.setFormat(Paths.font('AmaticSC-Bold.ttf'), 111, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		txtWeekNumber.borderSize = 2.6;
		txtWeekNumber.cameras = [camScreen];

		txtWeekTitle = new FlxText(FlxG.width / 2.6, txtWeekNumber.y + 115, 0, "");
		txtWeekTitle.setFormat(Paths.font('AmaticSC-Bold.ttf'), 64, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		txtWeekTitle.borderSize = 1;
		txtWeekTitle.cameras = [camScreen];

		var rankText:FlxText = new FlxText(0, 10);
		rankText.text = 'RANK: GREAT';
		rankText.setFormat(Paths.font("vcr.ttf"), 32);
		rankText.size = scoreText.size;
		rankText.screenCenter(X);

		weekHealthIcon = new HealthIcon('impostor', true);
		weekHealthIconLose = new HealthIcon('impostor', true);
		weekHealthIcon.x = FlxG.width / 2.4 - 115;
		weekHealthIconLose.x = FlxG.width / 2.4 + 200;
		weekHealthIcon.y = weekHealthIconLose.y = 55;
		weekHealthIcon.flipX = weekHealthIconLose.flipX = true;
		weekHealthIcon.cameras = weekHealthIconLose.cameras = [camScreen];

		var border:FlxSprite = new FlxSprite().loadGraphic(Paths.image('storymenu/border', 'impostor'));
		add(border);
		border.cameras = [camScreen];

		var back:FlxSprite = new FlxSprite(85, 65).loadGraphic(Paths.image('storymenu/menuBack', 'impostor'));
		add(back);
		back.cameras = [camScreen];

		FlxMouseEvent.add(back, function onMouseDown(back:FlxSprite)
		{
			goBack();
			trace("worked");
		}, null);

		for (i in 0...unlockedWeek.length)
		{
			WeekData.setDirectoryFromWeek(WeekData.weeksLoaded.get(WeekData.weeksList[i]));

			var weekCircle:FlxSprite = new FlxSprite(0, 50).loadGraphic(Paths.image('storymenu/circle', 'impostor'));
			FlxMouseEvent.add(weekCircle, function onMouseDown(weekCircle:FlxSprite)
			{
				if(curWeek == i && curWeek != 0)
				{
					openDiff();
					trace("worked2");
				}
				else if ((curWeek - 1 == i && unlockedWeek[curWeek - 1] || curWeek + 1 == i && unlockedWeek[curWeek + 1]))
				{
					if(curWeek == 9 || curWeek == 10) trace('lmao u thought');
					else
					{
						if(i > curWeek)
						{
							if(i == 5 || i == 6 || i == 7) ship.playAnim('left');
							else ship.playAnim('right');
						}
						if(i < curWeek)
						{
							if(i == 5 || i == 6 || i == 7) ship.playAnim('right');
							else ship.playAnim('left');
						}
						curWeek = i;

						changeWeek();
						FlxG.sound.play(Paths.sound('scrollMenu'));

						trace("worked3");
					}
				}
			}, null);

			if (i == 5)
			{
				weekCircle.alpha = 1;
				weekCircle.x = 0;
				weekCircle.y += 400;
			}
			if (i == 6)
			{
				weekCircle.x = -400;
				weekCircle.y += 400;
			}
			if (i == 7)
			{
				weekCircle.x = -800;
				weekCircle.y += 400;
			}
			if (i == 8)
			{
				weekCircle.x = 0;
				weekCircle.y -= 400;
			}
			if (i == 9)
			{
				weekCircle.x = 1200;
				weekCircle.y += 400;
			}
			if (i == 10)
			{
				weekCircle.x = 800;
				weekCircle.y += 400;
			}
			if (i == 11)
			{
				weekCircle.x = 800;
				weekCircle.y -= 400;
			}

			if (i < 5)
			{
				weekCircle.x = i * 400;

				if (i < 4)
				{
					var weekLine:FlxSprite = new FlxSprite(weekCircle.x + 95, 72).loadGraphic(Paths.image('storymenu/line', 'impostor'));
					var weekLine2:FlxSprite = new FlxSprite(weekCircle.x + 195, 72).loadGraphic(Paths.image('storymenu/line', 'impostor'));
					var weekLine3:FlxSprite = new FlxSprite(weekCircle.x + 295, 72).loadGraphic(Paths.image('storymenu/line', 'impostor'));

					weekLines.add(weekLine);
					weekLines.add(weekLine2);
					weekLines.add(weekLine3);

					if(!unlockedWeek[i]) weekLine.alpha = weekLine2.alpha = weekLine3.alpha = 0.5;
				}
			}

			if (i == 4)
			{
				var weekLine:FlxSprite = new FlxSprite(-4, 165).loadGraphic(Paths.image('storymenu/line', 'impostor'));
				var weekLine2:FlxSprite = new FlxSprite(-4, 265).loadGraphic(Paths.image('storymenu/line', 'impostor'));
				var weekLine3:FlxSprite = new FlxSprite(-4, 365).loadGraphic(Paths.image('storymenu/line', 'impostor'));

				weekLine.angle = weekLine2.angle = weekLine3.angle = 90;

				weekLines.add(weekLine);
				weekLines.add(weekLine2);
				weekLines.add(weekLine3);

				weekCircle.alpha = 1;
			}

			if (i > 4 && i < 7)
			{
				var weekLine:FlxSprite = new FlxSprite(weekCircle.x - 95, 472).loadGraphic(Paths.image('storymenu/line', 'impostor'));
				var weekLine2:FlxSprite = new FlxSprite(weekCircle.x - 195, 472).loadGraphic(Paths.image('storymenu/line', 'impostor'));
				var weekLine3:FlxSprite = new FlxSprite(weekCircle.x - 295, 472).loadGraphic(Paths.image('storymenu/line', 'impostor'));

				weekLines.add(weekLine);
				weekLines.add(weekLine2);
				weekLines.add(weekLine3);

				if(!unlockedWeek[i]) weekLine.alpha = weekLine2.alpha = weekLine3.alpha = 0.5;
			}

			if (i == 8)
			{
				var weekLine:FlxSprite = new FlxSprite(-4, -27).loadGraphic(Paths.image('storymenu/line', 'impostor'));
				var weekLine2:FlxSprite = new FlxSprite(-4, -127).loadGraphic(Paths.image('storymenu/line', 'impostor'));
				var weekLine3:FlxSprite = new FlxSprite(-4, -227).loadGraphic(Paths.image('storymenu/line', 'impostor'));

				weekLine.angle = weekLine2.angle = weekLine3.angle = 90;

				weekLines.add(weekLine);
				weekLines.add(weekLine2);
				weekLines.add(weekLine3);
			}

			if (i == 9)
			{
				var weekLine:FlxSprite = new FlxSprite(1197, 165).loadGraphic(Paths.image('storymenu/line', 'impostor'));
				var weekLine2:FlxSprite = new FlxSprite(1197, 265).loadGraphic(Paths.image('storymenu/line', 'impostor'));
				var weekLine3:FlxSprite = new FlxSprite(1197, 365).loadGraphic(Paths.image('storymenu/line', 'impostor'));

				weekLine.angle = weekLine2.angle = weekLine3.angle = 90;

				weekLines.add(weekLine);
				weekLines.add(weekLine2);
				weekLines.add(weekLine3);

				if(!unlockedWeek[8]) weekLine.alpha = weekLine2.alpha = weekLine3.alpha = 0.5;
			}
			if (i == 10)
			{
				var weekLine:FlxSprite = new FlxSprite(797, 165).loadGraphic(Paths.image('storymenu/line', 'impostor'));
				var weekLine2:FlxSprite = new FlxSprite(797, 265).loadGraphic(Paths.image('storymenu/line', 'impostor'));
				var weekLine3:FlxSprite = new FlxSprite(797, 365).loadGraphic(Paths.image('storymenu/line', 'impostor'));

				weekLine.angle = weekLine2.angle = weekLine3.angle = 90;

				weekLines.add(weekLine);
				weekLines.add(weekLine2);
				weekLines.add(weekLine3);

				if(!unlockedWeek[i]) weekLine.alpha = weekLine2.alpha = weekLine3.alpha = 0.5;
			}
			if (i == 11)
			{
				var weekLine:FlxSprite = new FlxSprite(797, -27).loadGraphic(Paths.image('storymenu/line', 'impostor'));
				var weekLine2:FlxSprite = new FlxSprite(797, -127).loadGraphic(Paths.image('storymenu/line', 'impostor'));
				var weekLine3:FlxSprite = new FlxSprite(797, -227).loadGraphic(Paths.image('storymenu/line', 'impostor'));

				weekLine.angle = weekLine2.angle = weekLine3.angle = 90;

				weekLines.add(weekLine);
				weekLines.add(weekLine2);
				weekLines.add(weekLine3);

				if(!unlockedWeek[10]) weekLine.alpha = weekLine2.alpha = weekLine3.alpha = 0.5;
			}

			weekCircles.add(weekCircle);
			weekXvalues.push(weekCircle.x - 95);
			weekYvalues.push(weekCircle.y - 50);

			// trace(weekYvalues[i]);
		}

		add(ship);

		WeekData.setDirectoryFromWeek(WeekData.weeksLoaded.get(WeekData.weeksList[0]));

		txtTracklist = new FlxText(FlxG.width * 0.75, 55, 0);
		txtTracklist.alignment = CENTER;
		txtTracklist.setFormat(Paths.font('AmaticSC-Bold.ttf'), 32, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		txtTracklist.cameras = [camScreen];
		add(txtTracklist);

		// add(rankText);
		add(scoreText);
		add(txtWeekTitle);
		add(txtWeekNumber);

		add(weekHealthIcon);
		add(weekHealthIconLose);

		FlxG.camera.follow(ship, LOCKON, 1);

		changeWeek();

		super.create();
	}

	override function closeSubState()
	{
		persistentUpdate = true;
		changeWeek();
		super.closeSubState();
	}

	override function update(elapsed:Float)
	{
		if(intendedScore != lerpScore)
		{
			lerpScore = Math.floor(FlxMath.lerp(intendedScore, lerpScore, Math.exp(-elapsed * 30)));
			if(Math.abs(intendedScore - lerpScore) < 10) lerpScore = intendedScore;
	
			scoreText.text = Language.getPhrase('week_score', 'HIGHSCORE: {1}', [lerpScore]);
		}

		ship.x = FlxMath.lerp(ship.x, weekXvalues[curWeek], FlxMath.bound(elapsed * 9, 0, 1));
		ship.y = FlxMath.lerp(ship.y, weekYvalues[curWeek], FlxMath.bound(elapsed * 9, 0, 1));

		if(localFinaleState == NOT_PLAYED)
		{
			caShader.amount = -2 / (FlxMath.distanceToPoint(ship, FlxPoint.get(1505, 0)) / 100);
			camSpace.shake(0.5 / FlxMath.distanceToPoint(ship, FlxPoint.get(1505, 0)) / 2, 0.05);
			camScreen.shake(0.3 / FlxMath.distanceToPoint(ship, FlxPoint.get(1505, 0)) / 2, 0.05);
		}

		if (!selectedWeek)
		{
			if (canMove)
			{
				if (controls.UI_LEFT_P && moveDirs[0]) ship.playAnim("left");
				else if (controls.UI_DOWN_P && moveDirs[1]) ship.playAnim("down");
				else if (controls.UI_UP_P && moveDirs[2]) ship.playAnim("up");
				else if (controls.UI_RIGHT_P && moveDirs[3]) ship.playAnim("right");

				switch(curWeek)
				{
					case 0:
						if (controls.UI_RIGHT_P) changeWeek(1);
						else if (controls.UI_DOWN_P) changeWeek(5);
						else if (controls.UI_UP_P) changeWeek(8);

					case 1:
						if (controls.UI_LEFT_P) changeWeek(0);
						else if (controls.UI_RIGHT_P && unlockedWeek[1]) changeWeek(2);

					case 2:
						if (controls.UI_LEFT_P) changeWeek(1);
						else if (controls.UI_RIGHT_P && unlockedWeek[2]) changeWeek(3);
						else if (controls.UI_UP_P && unlockedWeek[10]) changeWeek(9);
						else if (controls.UI_DOWN_P && unlockedWeek[9]) changeWeek(8);

					case 3:
						if (controls.UI_LEFT_P) changeWeek(2);
						else if (controls.UI_RIGHT_P && unlockedWeek[3]) changeWeek(4);
						else if (controls.UI_DOWN_P && unlockedWeek[8]) changeWeek(7);

					case 4:
						if (controls.UI_LEFT_P) changeWeek(3);

					case 5:
						if (controls.UI_LEFT_P && unlockedWeek[5]) changeWeek(1);
						else if (controls.UI_UP_P) changeWeek(0);

					case 6:
						if (controls.UI_LEFT_P && unlockedWeek[6]) changeWeek(1);
						else if (controls.UI_RIGHT_P && unlockedWeek[5]) changeWeek(0);

					case 7:
						if (controls.UI_RIGHT_P) changeWeek(0);

					case 8:
						if (controls.UI_DOWN_P) changeWeek(0);

					case 9:
						if (controls.UI_UP_P) changeWeek(0);

					case 10:
						if (controls.UI_UP_P) changeWeek(0);

					case 11:
						if (controls.UI_DOWN_P) changeWeek(0);
				}

				if (curWeek != 0)
				{
					if (controls.ACCEPT) openDiff();
					else if (controls.RESET)
					{
						persistentUpdate = false;
						openSubState(new ResetScoreSubState('', 2, '', curWeek));
						FlxG.sound.play(Paths.sound('scrollMenu'));
					}
				}

				if (controls.BACK) goBack();
			}
		}

		super.update(elapsed);
	}

	function goBack()
	{
		FlxG.sound.play(Paths.sound('cancelMenu'));
		selectedWeek = true;
		MusicBeatState.switchState(new MainMenuState());
	}

	function selectWeek()
	{
		if (!weekIsLocked(curWeek))
		{
			FlxG.sound.play(Paths.sound('confirmMenu'));
			PlayState.isStoryMode = selectedWeek = true;

			// We can't use Dynamic Array .copy() because that crashes HTML5, here's a workaround.
			var songArray:Array<String> = [];
			var leWeek:Array<Dynamic> = WeekData.weeksLoaded.get(WeekData.weeksList[curWeek]).songs;
			for (i in 0...leWeek.length) songArray.push(leWeek[i][0]);

			// Nevermind that's stupid lmao
			if(curWeek == 4 && localFinaleState == NOT_PLAYED) PlayState.storyPlaylist = ['finale'];
			else if(curWeek == 4 && localFinaleState == NOT_UNLOCKED) PlayState.storyPlaylist = ['defeat'];
			else if(curWeek == 4 && localFinaleState == COMPLETED) PlayState.storyPlaylist = ['defeat'];
			else PlayState.storyPlaylist = songArray;

			PlayState.storyDifficulty = 2;

			Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + "-hard", PlayState.storyPlaylist[0].toLowerCase());
			PlayState.campaignScore = PlayState.campaignMisses = 0;

			var directory = StageData.forceNextDirectory;
			LoadingState.loadNextDirectory();
			StageData.forceNextDirectory = directory;

			@:privateAccess
			if(PlayState._lastLoadedModDirectory != Mods.currentModDirectory)
			{
				trace('CHANGED MOD DIRECTORY, RELOADING STUFF');
				Paths.freeGraphicsFromMemory();
			}
			LoadingState.prepareToSong();
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				#if !SHOW_LOADING_SCREEN FlxG.sound.music.stop(); #end
				LoadingState.loadAndSwitchState(new PlayState(), true);
				FreeplayState.destroyFreeplayVocals();
			});
		}
		else FlxG.sound.play(Paths.sound('cancelMenu'));
	}

	function changeWeek(change:Int = 0):Void
	{
		FlxG.sound.play(Paths.sound('scrollMenu'));
		canMove = false;

		curWeek = change;

		switch(curWeek)
		{
			case 0: moveDirs = [false, true, true, true];
			case 1: moveDirs = [true, false, false, true];
			case 2: moveDirs = [true, true, true, true];
			case 3: moveDirs = [true, false, false, true];
			case 4: moveDirs = [true, true, true, true];
			case 5: moveDirs = [true, true, true, true];
			case 6: moveDirs = [true, true, true, true];
			case 7: moveDirs = [true, true, true, true];
			case 8: moveDirs = [true, true, true, true];
			case 9: moveDirs = [true, true, true, true];
			case 10: moveDirs = [true, true, true, true];
			case 11: moveDirs = [true, true, true, true];
		}
		
		if (curWeek == 0)
			txtTracklist.visible = txtWeekNumber.visible = txtWeekTitle.visible = weekHealthIcon.visible = weekHealthIconLose.visible = scoreText.visible = false;
		else
			txtTracklist.visible = txtWeekNumber.visible = txtWeekTitle.visible = weekHealthIcon.visible = weekHealthIconLose.visible = scoreText.visible = true;

		var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[curWeek]);
		WeekData.setDirectoryFromWeek(leWeek);

		txtWeekTitle.text = leWeek.storyName.toUpperCase();
		txtWeekTitle.setFormat(Paths.font('AmaticSC-Bold.ttf'), 64, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		txtWeekNumber.text = leWeek.weekName.toUpperCase();
		if(!leWeek.weekName.startsWith("Week")) 
			txtWeekNumber.x = ((FlxG.width / 2) - (txtWeekNumber.width / 2));
		else
			txtWeekNumber.x = FlxG.width / 2.4;
		txtWeekTitle.borderSize = 2.2;

		if(curWeek == 4)
		{
			txtTracklist.visible = false;
			if(localFinaleState == NOT_PLAYED)
			{
				txtWeekTitle.text = 'FINALE';
				txtWeekTitle.color = 0xFFFF0000;
			}
			else
			{
				txtWeekTitle.text = 'DEFEAT';
				txtWeekTitle.color = 0xFFFFFFFF;
			}
		}

		#if !switch
		intendedScore = Highscore.getWeekScore(WeekData.weeksList[curWeek], 2);
		#end

		weekHealthIcon.changeIcon(leWeek.songs[0][1]);
		weekHealthIconLose.changeIcon(leWeek.songs[0][1]);
		weekHealthIcon.animation.curAnim.curFrame = 0;
		weekHealthIconLose.animation.curAnim.curFrame = 1;
		txtWeekNumber.updateHitbox();

		switch (leWeek.songs.length)
		{
			case 2:
				txtTracklist.setFormat(Paths.font('AmaticSC-Bold.ttf'), 50, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				txtTracklist.borderSize = 1.8;
				txtTracklist.y = 75;
			case 3:
				txtTracklist.setFormat(Paths.font('AmaticSC-Bold.ttf'), 40, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				txtTracklist.borderSize = 1.6;
				txtTracklist.y = 62;
			case 4:
				txtTracklist.setFormat(Paths.font('AmaticSC-Bold.ttf'), 34, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				txtTracklist.borderSize = 1.5;
				txtTracklist.y = 55;
			case 5:
				txtTracklist.setFormat(Paths.font('AmaticSC-Bold.ttf'), 26, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				txtTracklist.borderSize = 1.3;
				txtTracklist.y = 58;
			default:
				txtTracklist.y = 55;
		}

		txtWeekTitle.x = ((FlxG.width / 2) - (txtWeekTitle.width / 2));

		switch(curWeek)
		{
			case 4:
				weekHealthIcon.x = FlxG.width / 2.4 - 115;
				weekHealthIconLose.x = FlxG.width / 2.4 + 180;
				weekHealthIcon.y = weekHealthIconLose.y = 55;
			case 5:
				weekHealthIcon.x = FlxG.width / 2.4 - 135;
				weekHealthIconLose.x = FlxG.width / 2.4 + 220;
				weekHealthIcon.y = weekHealthIconLose.y = 45;
			case 6:
				weekHealthIcon.x = FlxG.width / 2.4 - 135;
				weekHealthIconLose.x = FlxG.width / 2.4 + 220;
				weekHealthIcon.y = weekHealthIconLose.y = 45;
			case 7:
				weekHealthIcon.x = FlxG.width / 2.4 - 135;
				weekHealthIconLose.x = FlxG.width / 2.4 + 220;
				weekHealthIcon.y = weekHealthIconLose.y = 40;
			case 9:
				weekHealthIcon.x = FlxG.width / 2.4 - 115;
				weekHealthIconLose.x = FlxG.width / 2.4 + 180;
				weekHealthIcon.y = weekHealthIconLose.y = 40;
			case 10:
				weekHealthIcon.x = FlxG.width / 2.4 - 205;
				weekHealthIconLose.x = FlxG.width / 2.4 + 270;
				weekHealthIcon.y = weekHealthIconLose.y = 55;
			case 11:
				weekHealthIcon.x = FlxG.width / 2.4 - 115;
				weekHealthIconLose.x = FlxG.width / 2.4 + 170;
				weekHealthIcon.y = weekHealthIconLose.y = 45;
			default:
				weekHealthIcon.x = FlxG.width / 2.4 - 115;
				weekHealthIconLose.x = FlxG.width / 2.4 + 200;
				weekHealthIcon.y = weekHealthIconLose.y = 55;
		}

		new FlxTimer().start(0.08, function(tmr:FlxTimer)
		{
			canMove = true;
		});
		
		updateText();
	}

	function weekIsLocked(weekNum:Int)
	{
		var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[weekNum]);
		return (!leWeek.startUnlocked && leWeek.weekBefore.length > 0 && (!weekCompleted.exists(leWeek.weekBefore) || !weekCompleted.get(leWeek.weekBefore)));
	}

	function updateText()
	{
		var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[curWeek]);
		var stringThing:Array<String> = [];
		for (i in 0...leWeek.songs.length)
		{
			stringThing.push(leWeek.songs[i][0]);
		}

		txtTracklist.text = '';
		for (i in 0...stringThing.length)
		{
			txtTracklist.text += stringThing[i] + '\n';
		}

		txtTracklist.text = txtTracklist.text.toUpperCase();
		txtTracklist.x = ((FlxG.width / 2) - (txtTracklist.width / 2)) + 400;

		#if !switch
		intendedScore = Highscore.getWeekScore(WeekData.weeksList[curWeek], 2);
		#end
	}

	function openDiff()
	{
		FlxG.sound.play(Paths.sound('panelAppear'), 0.5);
		canMove = false;
		selectedWeek = true;
		if(curWeek == 4 && localFinaleState != NOT_PLAYED)
		{
			FlxG.sound.music.fadeOut(1.2, 0);
			camScreen.fade(FlxColor.BLACK, 1.2, false, function()
			{
				camScreen.visible = camSpace.visible = false;
				openSubState(new DeathSubstate());
			});
		}
		else selectWeek();
	}
}

class DeathSubstate extends MusicBeatSubstate
{
	public static var songsWithMissLimits:Array<String> = ['defeat'];

	var missAmountArrow:FlxSprite;
	var missTxt:FlxText;
	public var dummySprites:FlxTypedGroup<FlxSprite>;
	public var maximumMissLimit:Int = 5;

	public var camUpper:PsychCamera;

	public function new()
	{
		super();

		camUpper = new PsychCamera();
		camUpper.bgColor.alpha = 0;
		FlxG.cameras.add(camUpper);

		cameras = [camUpper];

		dummySprites = new FlxTypedGroup<FlxSprite>();
		for (i in 0...6)
		{
			var dummypostor:FlxSprite = new FlxSprite((i * 150) + 200, 450).loadGraphic(Paths.image('freeplay/dummypostor${i + 1}', 'impostor'));
			dummypostor.alpha = 0;
			dummypostor.ID = i;
			dummySprites.add(dummypostor);
			switch(i)
			{
				case 2 | 3: dummypostor.y += 40;
				case 4 | 5: dummypostor.y += 65;
			}
		}
		add(dummySprites);

		missAmountArrow = new FlxSprite(0, 400).loadGraphic(Paths.image('freeplay/missAmountArrow', 'impostor'));
		missAmountArrow.alpha = 0;
		add(missAmountArrow);

		missTxt = new FlxText(0, 150, FlxG.width, "", 20);
		missTxt.setFormat(Paths.font("vcr.ttf"), 100, FlxColor.RED, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		missTxt.antialiasing = false;
        missTxt.scrollFactor.set();
		missTxt.alpha = 0;
		missTxt.borderSize = 3;
        add(missTxt);

		changeMissAmount();
		openMissLimit();
	}

	public var hasEnteredMissSelection:Bool = false;
	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (!hasEnteredMissSelection) return;

		if(controls.ACCEPT)
		{
			FlxG.sound.play(Paths.sound('amongkill'), 0.9);
			hasEnteredMissSelection = false;

			close();

			var blackScreen:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
			add(blackScreen);

			missTxt.alpha = missAmountArrow.alpha = 0;
			dummySprites.forEach(function(spr:FlxSprite)
			{
				spr.alpha = 0;	
			});

			var songArray:Array<String> = [];
			var leWeek:Array<Dynamic> = WeekData.weeksLoaded.get(WeekData.weeksList[StoryMenuState.curWeek]).songs;
			for (i in 0...leWeek.length) songArray.push(leWeek[i][0]);

			// Nevermind that's stupid lmao
			PlayState.storyPlaylist = songArray;
			PlayState.isStoryMode = true;

			var diffic = Difficulty.getFilePath(2);
			if(diffic == null) diffic = '';

			PlayState.storyDifficulty = 2;

			PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + diffic, PlayState.storyPlaylist[0].toLowerCase());
			PlayState.storyWeek = StoryMenuState.curWeek;
			PlayState.campaignScore = 0;
			PlayState.campaignMisses = 0;

			var directory = StageData.forceNextDirectory;
			LoadingState.loadNextDirectory();
			StageData.forceNextDirectory = directory;

			@:privateAccess
			if(PlayState._lastLoadedModDirectory != Mods.currentModDirectory)
			{
				trace('CHANGED MOD DIRECTORY, RELOADING STUFF');
				Paths.freeGraphicsFromMemory();
			}
			LoadingState.prepareToSong();
			FlxTween.tween(camUpper, {alpha: 0}, 0.25, {
				ease: FlxEase.circOut,
				onComplete: function(tween:FlxTween)
				{
					trace('CURRENT WEEK: ' + WeekData.getWeekFileName());

					new FlxTimer().start(0.75, function(tmr:FlxTimer)
					{
						#if !SHOW_LOADING_SCREEN FlxG.sound.music.stop(); #end
						LoadingState.loadAndSwitchState(new PlayState(), true);
						FreeplayState.destroyFreeplayVocals();
					});
				}
			});
		}

		if (controls.UI_RIGHT_P) changeMissAmount(-1);
		else if (controls.UI_LEFT_P) changeMissAmount(1);
	}

	function changeMissAmount(change:Int = 0)
	{
		if(change > 0) FlxG.sound.play(Paths.sound('panelAppear'), 0.5);
		else if(change < 0) FlxG.sound.play(Paths.sound('panelDisappear'), 0.5);

		PlayState.missLimitCount = FlxMath.wrap(PlayState.missLimitCount + change, 0, maximumMissLimit);
		dummySprites.forEach(function(spr:FlxSprite)
		{
			if((maximumMissLimit - spr.ID) == PlayState.missLimitCount)
			{
				missAmountArrow.x = spr.x;
				missTxt.text = '${PlayState.missLimitCount}/$maximumMissLimit COMBO BREAKS';
				missTxt.x = ((FlxG.width / 2) - (missTxt.width / 2));
			}
		});
	}

	function openMissLimit()
	{
		hasEnteredMissSelection = true;
		missAmountArrow.alpha = missTxt.alpha = 1;
		dummySprites.forEach(function(spr:FlxSprite)
		{
			spr.alpha = 1;
		});
	}
}
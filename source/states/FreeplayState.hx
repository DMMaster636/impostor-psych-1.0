package states;

import backend.WeekData;
import backend.Highscore;
import backend.Song;

import objects.HealthIcon;
// import objects.MusicPlayer; will do later    - DM

import options.GameplayChangersSubstate;

import substates.ResetScoreSubState;

import shaders.ColorShader;
import shaders.RimlightShader;

import flixel.util.FlxDestroyUtil;
import flixel.input.mouse.FlxMouseEvent;

import openfl.utils.Assets;

import haxe.Json;

enum RequireType
{
	FROM_STORY_MODE;
	BEANS;
	SPECIAL;
}

typedef FreeplayWeek = {
	// JSON variables
	var songs:Array<Dynamic>;
	var section:Int;
}

class FreeplayState extends MusicBeatState
{
	// someones dying for this- and its me!
	public static var weeks:Array<FreeplayWeek> = [];
	var hasSavedData:Bool = false;
	var localWeeks:Array<FreeplayWeek> = [];
	var listOfButtons:Array<FreeplayCard> = [];

	private static var curSelected:Int = 0;
	private static var curWeek:Int = 0;
	var prevSel:Int;
	var prevWeek:Int;
	var prevPort:Dynamic;

	var lockMovement:Bool = false;

	var camGame:PsychCamera;
	var camUpper:PsychCamera;

	var space:FlxSprite;
	var upperBar:FlxSprite;
	var porGlow:FlxSprite;
	var intendedColor:Int;

	var crossImage:FlxSprite;

	var portrait:FlxSprite;
	var portraitTween:FlxTween;
	var portraitAlphaTween:FlxTween;

	var localBeans:Int;
	var topBean:FlxSprite;
    var beanText:FlxText;

	var infoText:FlxText;
	var lerpScore:Int = 0;
	var lerpRating:Float = 0;
	var intendedScore:Int = 0;
	var intendedRating:Float = 0;

	var rimlight:RimlightShader;
	var buttonTween:FlxTween;
	var lockTween:FlxTween;
    var textTween:FlxTween;

    //var player:MusicPlayer;

    var bottomString:String = "";
    var bottomText:FlxText;
	var bottomBG:FlxSprite;

	public static var instance:FreeplayState;

	override function create()
	{
		//Paths.clearStoredMemory();
		//Paths.clearUnusedMemory();

		instance = this;

		camGame = initPsychCamera();
		camUpper = new PsychCamera();
		camUpper.bgColor.alpha = 0;
		FlxG.cameras.add(camUpper,false);

		persistentUpdate = persistentDraw = true;
		PlayState.isStoryMode = false;
		WeekData.reloadWeekFiles(false);
		Mods.loadTopMod();

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Selecting a Song", null);
		#end

		space = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		space.updateHitbox();
		space.scrollFactor.set();
		add(space);
	
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

		porGlow = new FlxSprite(-11.1, -12.65).loadGraphic(Paths.image('freeplay/backGlow', 'impostor'));
		porGlow.updateHitbox();
		porGlow.scrollFactor.set();
		porGlow.color = FlxColor.RED;
		add(porGlow);

		intendedColor = porGlow.color;

		final songPortraitStuff:Array<String> = [
			'red','yellow','green','tomo','ham','black','white','para','pink','maroon','grey',
			'chef','tit','ellie','rhm','loggo','clow','ziffy','chips','oldpostor','top','jorsawsee','warchief','redmungus','banananungus',
			'powers','kills','jerma','who','monotone','charles','finale','pop','torture','dave','bpmar','grinch','redmunp','nuzzus',
			'monotoner','idk','esculent'
		];
		portrait = new FlxSprite();
		portrait.frames = Paths.getSparrowAtlas('freeplay/portraits', 'impostor');
		for(i => name in songPortraitStuff) portrait.animation.addByIndices(name, 'Character', [i + 1], null, 24, true);
		portrait.animation.play('red');
		portrait.setPosition(304.65, -100);
		portrait.updateHitbox();
		portrait.scrollFactor.set();
		add(portrait);

		infoText = new FlxText(1071.05, 91, 0, '291921 \n Rating: 32 \n', 48);
		infoText.updateHitbox();
		infoText.scrollFactor.set();
		infoText.setFormat(Paths.font("vcr.ttf"), 36, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(infoText);

		listOfButtons = [];
		weeks = addWeeks();

		if(ClientPrefs.data.forceUnlockedSongs != null && ClientPrefs.data.forceUnlockedSongs.length > 0)
		{
			localWeeks = ClientPrefs.data.forceUnlockedSongs;
			hasSavedData = true;
			// trace(localWeeks);
		}
		else localWeeks = weeks;

		for (num => week in weeks)
		{
			for (i => song in week.songs)
			{
				if (week.section == curWeek)
				{
					if(!hasSavedData) listOfButtons.push(new FreeplayCard(0,0,song[0],song[1],song[3],song[2],song[4],song[5],song[6],song[7]));
					else listOfButtons.push(new FreeplayCard(0,0,song[0],song[1],song[3],song[2],song[4],song[5],song[6],localWeeks[num].songs[i][7]));
				}
			}
		}
		trace('created Weeks');
		trace('pushed list of buttons with ${listOfButtons.length} buttons');

		for (i in listOfButtons)
		{
			add(i);
			add(i.spriteOne);
			add(i.icon);
			add(i.songText);
			add(i.bean);
			add(i.lock);
			add(i.priceText);
		}

		for (i => button in listOfButtons)
		{
			button.targetY = i;
			button.spriteOne.setPosition(10, (120 * i) + 100);
		}

		upperBar = new FlxSprite(-2, -1.4).loadGraphic(Paths.image('freeplay/topBar', 'impostor'));
		upperBar.updateHitbox();
		upperBar.scrollFactor.set();
		upperBar.cameras = [camUpper];
		add(upperBar);

		crossImage = new FlxSprite(12.50, 8.05).loadGraphic(Paths.image('freeplay/menuBack', 'impostor'));
		crossImage.scrollFactor.set();
		crossImage.updateHitbox();
		crossImage.cameras = [camUpper];
		add(crossImage);
		FlxMouseEvent.add(crossImage, function onMouseDown(s:FlxSprite)
		{
			goBack();
		}, null, null);

		bottomBG = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		bottomBG.alpha = 0.6;
        bottomBG.cameras = [camUpper];
		add(bottomBG);

		var leText:String = Language.getPhrase("freeplay_tip", "Press SPACE to listen to the Song / Press RESET to Reset your Score and Accuracy.");
		bottomString = leText;
		bottomText = new FlxText(bottomBG.x, bottomBG.y + 4, FlxG.width, leText, 16);
		bottomText.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, CENTER);
		bottomText.scrollFactor.set();
        bottomText.cameras = [camUpper];
		add(bottomText);

		rimlight = new RimlightShader(315, 10, 0xFFFF6600, portrait);
		add(rimlight);
		portrait.shader = rimlight.shader;

		topBean = new FlxSprite(30, 100).loadGraphic(Paths.image('shop/bean', 'impostor'));
        topBean.cameras = [camUpper];
        topBean.updateHitbox();
		add(topBean);	

        beanText = new FlxText(110, 105, 200, Std.string(localBeans), 35);
		beanText.setFormat(Paths.font("ariblk.ttf"), 35, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        beanText.updateHitbox();
		beanText.borderSize = 3;
        beanText.scrollFactor.set();
        beanText.cameras = [camUpper];
        add(beanText);

		//player = new MusicPlayer(this);
		//add(player);

		changeWeek();
		changeSelection();
		changePortrait();

		super.create();
	}

	var inSubstate:Bool = false;
	override function openSubState(SubState:flixel.FlxSubState)
	{
		inSubstate = true;
		persistentUpdate = false;
		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		inSubstate = false;
		persistentUpdate = true;
		changeSelection();
		super.closeSubState();
	}

	var stopMusicPlay:Bool = false;
	var holdTime:Float = 0;
	var instPlaying:Int = -1;
	public static var vocals:FlxSound = null;
	public static var opponentVocals:FlxSound = null;
	override function update(elapsed:Float)
	{
		if(WeekData.weeksList.length < 1) return;

		if (FlxG.sound.music.volume < 0.7)
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;

		if (!inSubstate/* && !player.playingMusic*/)
		{
			lerpScore = Math.floor(FlxMath.lerp(intendedScore, lerpScore, Math.exp(-elapsed * 24)));
			lerpRating = FlxMath.lerp(intendedRating, lerpRating, Math.exp(-elapsed * 12));

			if (Math.abs(lerpScore - intendedScore) <= 10) lerpScore = intendedScore;
			if (Math.abs(lerpRating - intendedRating) <= 0.01) lerpRating = intendedRating;

			var ratingSplit:Array<String> = Std.string(CoolUtil.floorDecimal(lerpRating * 100, 2)).split('.');
			if(ratingSplit.length < 2) //No decimals, add an empty space
				ratingSplit.push('');
			
			while(ratingSplit[1].length < 2) //Less than 2 decimals in it, add decimals then
				ratingSplit[1] += '0';

			var shiftMult:Int = 1;
			if(FlxG.keys.pressed.SHIFT) shiftMult = 3;

			infoText.text = Language.getPhrase('personal_best', 'Score: {1}\nRating: {2}%', [lerpScore, ratingSplit.join('.')]);
			infoText.x = FlxG.width - infoText.width - 6;

			if(!lockMovement)
			{
				if(controls.UI_LEFT_P)
				{
					changeWeek(-shiftMult);
					holdTime = 0;
				}
				if(controls.UI_RIGHT_P)
				{
					changeWeek(shiftMult);
					holdTime = 0;
				}

				if(FlxG.keys.justPressed.HOME)
				{
					curSelected = 0;
					changeSelection();
					holdTime = 0;
				}
				else if(FlxG.keys.justPressed.END)
				{
					curSelected = listOfButtons.length - 1;
					changeSelection();
					holdTime = 0;
				}

				if(controls.UI_UP_P)
				{
					changeSelection(-shiftMult);
					holdTime = 0;
				}
				if(controls.UI_DOWN_P)
				{
					changeSelection(shiftMult);
					holdTime = 0;
				}

				if(controls.UI_DOWN || controls.UI_UP)
				{
					var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
					holdTime += elapsed;
					var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

					if(holdTime > 0.5 && checkNewHold - checkLastHold > 0)
						changeSelection((checkNewHold - checkLastHold) * (controls.UI_UP ? -shiftMult : shiftMult));
				}

				if(FlxG.mouse.wheel != 0)
					changeSelection(-shiftMult * FlxG.mouse.wheel);

				if(controls.BACK) goBack();

				if (controls.ACCEPT)
				{
					if(listOfButtons[curSelected].locked)
					{
						if(listOfButtons[curSelected].requirementtype == BEANS && localBeans >= listOfButtons[curSelected].price)
						{
							for (week in weeks)
							{
								for (song in week.songs)
								{
									if(song[7] == false && song[0] == listOfButtons[curSelected].songName)
									{
										song[7] = true;
										listOfButtons[curSelected].unlockAnim();
										lockMovement = true;
										new FlxTimer().start(1.45, function(tmr:FlxTimer)
										{
											changePortrait(true);
											lockMovement = false;
										});
										localBeans -= listOfButtons[curSelected].price;
										beanText.text = Std.string(localBeans);
										trace(song, song[7], listOfButtons[curSelected].songName, song[0]);
										return;
									} 
								}
							}
							return;
						}

						FlxG.sound.play(Paths.sound('locked'), 0.7);
						camUpper.shake(0.01, 0.35);
						FlxG.camera.shake(0.005, 0.35);

						if(buttonTween != null) buttonTween.cancel();
						if(lockTween != null) lockTween.cancel();
						if(textTween != null) textTween.cancel();
						final pulseColor:FlxColor = 0xFFFF4444;
						buttonTween = FlxTween.color(listOfButtons[curSelected].spriteOne, 0.6, pulseColor, 0xFF4A4A4A, {ease: FlxEase.sineOut});
						lockTween = FlxTween.color(listOfButtons[curSelected].lock, 0.6, pulseColor, 0xFFFFFFFF, {ease: FlxEase.sineOut});
						textTween = FlxTween.color(listOfButtons[curSelected].songText, 0.5, pulseColor, 0xFFFFFFFF, {ease: FlxEase.sineOut});
					}
					else
					{
						openSubState(new DifficultySubstate(curWeek, listOfButtons[curSelected].songName));
						FlxG.sound.play(Paths.sound('panelAppear'), 0.5);
						ClientPrefs.data.beans = localBeans;
						ClientPrefs.data.forceUnlockedSongs = localWeeks;
						ClientPrefs.saveSettings();
					}
				}
				else if(controls.RESET)
				{
					openSubState(new ResetScoreSubState(listOfButtons[curSelected].songName, 2, listOfButtons[curSelected].iconName));
					FlxG.sound.play(Paths.sound('select'), 0.5);
				}
			}
		}
		else
		{
			if(controls.BACK/* && player.playingMusic*/)
			{
				FlxG.sound.music.stop();
				destroyFreeplayVocals();
				FlxG.sound.music.volume = 0;
				instPlaying = -1;

				//player.playingMusic = false;
				//player.switchPlayMusic();

				FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
				FlxTween.tween(FlxG.sound.music, {volume: 1}, 1);
			}
		}

		super.update(elapsed);
	}

	function getVocalFromCharacter(char:String)
	{
		try
		{
			var path:String = Paths.getPath('characters/$char.json', TEXT);
			#if MODS_ALLOWED
			var character:Dynamic = Json.parse(File.getContent(path));
			#else
			var character:Dynamic = Json.parse(Assets.getText(path));
			#end
			return character.vocals_file;
		}
		catch (e:Dynamic) {}
		return null;
	}

	public static function destroyFreeplayVocals()
	{
		if(vocals != null) vocals.stop();
		vocals = FlxDestroyUtil.destroy(vocals);

		if(opponentVocals != null) opponentVocals.stop();
		opponentVocals = FlxDestroyUtil.destroy(opponentVocals);
	}

	function goBack()
	{
		FlxG.sound.play(Paths.sound('select'), 0.5);

		persistentUpdate = false;

		ClientPrefs.data.beans = localBeans;
		ClientPrefs.data.forceUnlockedSongs = localWeeks;
		ClientPrefs.saveSettings();

		MusicBeatState.switchState(new MainMenuState());
	}

	public static function addWeeks():Array<FreeplayWeek>
	{
		weeks = [];
		// im just like putting this in its own function because
		// jesus christ man this cant get near the coherent code
		weeks.push({
			songs: [
				["Sussus Moogus", "impostor", 'red', FlxColor.RED, FROM_STORY_MODE, ['sussus-moogus'], 0, false],
				["Sabotage", "impostor", 'red', FlxColor.RED, FROM_STORY_MODE, ['sabotage'], 0, false],
				["Meltdown", "impostor2", 'red', FlxColor.RED, FROM_STORY_MODE, ['meltdown'], 0, false]
			],

			section: 0
		});

		weeks.push({
			songs: [
				["Sussus Toogus", "crewmate", 'green', FlxColor.fromRGB(0, 255, 0), FROM_STORY_MODE, ['sussus-toogus'], 0, false],
				["Lights Down", "impostor3", 'green', FlxColor.fromRGB(0, 255, 0), FROM_STORY_MODE, ['lights-down'], 0, false],
				["Reactor", "impostor3", 'green', FlxColor.fromRGB(0, 255, 0), FROM_STORY_MODE, ['reactor'], 0, false],
				["Ejected", "parasite", 'para', FlxColor.fromRGB(0, 255, 0), FROM_STORY_MODE, ['ejected'], 0, false]
			],

			section: 0
		});

		weeks.push({
			songs: [
				["Mando", "yellow", 'yellow', FlxColor.fromRGB(255, 218, 67), FROM_STORY_MODE, ['mando'], 0, false],
				["Dlow", "yellow", 'yellow', FlxColor.fromRGB(255, 218, 67), FROM_STORY_MODE, ['dlow'], 0, false],
				["Oversight", "white", 'white', FlxColor.WHITE, FROM_STORY_MODE, ['oversight'], 0, false],
				["Danger", "black", 'black', FlxColor.fromRGB(179, 0, 255), FROM_STORY_MODE, ['danger'], 0, false],
				["Double Kill", "whiteblack", 'black', FlxColor.fromRGB(179, 0, 255), FROM_STORY_MODE, ['double-kill'], 0, false]
			],

			section: 0
		});

		weeks.push({
			songs: [
				["Defeat", "black", 'black', FlxColor.fromRGB(179, 0, 255), FROM_STORY_MODE, ['defeat'], 0, false],
				["Finale", "black", 'finale', FlxColor.fromRGB(179, 0, 255), SPECIAL, ['finale'], 0, false]
			],

			section: 0
		});

		weeks.push({
			songs: [["Identity Crisis", "monotone", 'monotone', FlxColor.BLACK, SPECIAL, ['meltdown', 'ejected', 'double-kill', 'defeat', 'boiling-point', 'neurotic', 'pretender'], 0, false]],
			section: 0
		});

		weeks.push({
			songs: [
				["Ashes", "maroon", 'maroon', FlxColor.fromRGB(181, 0, 0), FROM_STORY_MODE, ['ashes'], 0, false],
				["Magmatic", "maroon", 'maroon', FlxColor.fromRGB(181, 0, 0), FROM_STORY_MODE, ['magmatic'], 0, false],
				["Boiling Point", "boilingpoint", 'bpmar', FlxColor.fromRGB(181, 0, 0), FROM_STORY_MODE, ['boiling-point'], 0, false]
			],

			section: 1
		});

		weeks.push({
			songs: [
				["Delusion", "gray", 'grey', FlxColor.fromRGB(139, 157, 168), FROM_STORY_MODE, ['delusion'], 0, false],
				["Blackout", "gray", 'grey', FlxColor.fromRGB(139, 157, 168), FROM_STORY_MODE, ['blackout'], 0, false],
				["Neurotic", "gray", 'grey', FlxColor.fromRGB(139, 157, 168), FROM_STORY_MODE, ['neurotic'], 0, false]
			],

			section: 1
		});

		weeks.push({
			songs: [
				["Heartbeat", "pink", 'pink', FlxColor.fromRGB(255, 0, 222), FROM_STORY_MODE, ['heartbeat'], 0, false],
				["Pinkwave", "pink", 'pink', FlxColor.fromRGB(255, 0, 222), FROM_STORY_MODE, ['pinkwave'], 0, false],
				["Pretender", "pretender", 'pink', FlxColor.fromRGB(255, 0, 222), FROM_STORY_MODE, ['pretender'], 0, false]
			],

			section: 1
		});

		weeks.push({
			songs: [["Sauces Moogus", "chef", 'chef', FlxColor.fromRGB(242, 114, 28), SPECIAL, ['ashes', 'delusion', 'heartbeat'], 0, false]],
			section: 1
		});

		weeks.push({
			songs: [
				["O2", "jorsawsee", 'jorsawsee', FlxColor.fromRGB(38, 127, 230), FROM_STORY_MODE, ['o2'], 0],
				["Voting Time", "votingtime", 'warchief', FlxColor.fromRGB(153, 67, 196), FROM_STORY_MODE, ['voting-time'], 0, false],
				["Turbulence", "redmungus", 'redmunp', FlxColor.RED, FROM_STORY_MODE, ['turbulence'], 0, false],
				["Victory", "warchief", 'warchief', FlxColor.fromRGB(153, 67, 196), FROM_STORY_MODE, ['victory'], 0, false]
			],

			section: 2
		});

		weeks.push({
			songs: [
				["ROOMCODE", "powers", 'powers', FlxColor.fromRGB(80, 173, 235), SPECIAL, ['victory'], 0, false]
			],

			section: 2
		});

		weeks.push({
			songs: [
				["Sussy Bussy", "tomongus", 'tomo', FlxColor.fromRGB(255, 90, 134), FROM_STORY_MODE, ['sussy-bussy'], 0, false],
				["Rivals", "tomongus", 'tomo', FlxColor.fromRGB(255, 90, 134), FROM_STORY_MODE, ['rivals'], 0, false],
				["Chewmate", "hamster", 'ham', FlxColor.fromRGB(255, 90, 134), FROM_STORY_MODE, ['chewmate'], 0, false]
			],

			section: 3
		});

		weeks.push({
			songs: [
				["Tomongus Tuesday", "tuesday", 'tomo', FlxColor.fromRGB(255, 90, 134), SPECIAL, ['chewmate'], 0, false],
			],

			section: 3
		});

		weeks.push({
			songs: [
				["Christmas", "fella", 'loggo', FlxColor.fromRGB(0, 255, 0), FROM_STORY_MODE, ['christmas'], 0, false],
				["Spookpostor", "boo", 'loggo', FlxColor.fromRGB(0, 255, 0), FROM_STORY_MODE, ['spookpostor'], 0, false]
			],

			section: 4
		});

		weeks.push({
			songs: [
				["Titular", "henry", 'tit', FlxColor.ORANGE, FROM_STORY_MODE, ['titular'], 0, false],
				["Greatest Plan", "charles", 'charles', FlxColor.RED, FROM_STORY_MODE, ['greatest-plan'], 0, false],
				["Reinforcements", "ellie", 'ellie', FlxColor.ORANGE, FROM_STORY_MODE, ['reinforcements'], 0, false],
				["Armed", "rhm", 'rhm', FlxColor.ORANGE, FROM_STORY_MODE, ['armed'], 0, false]
			],

			section: 5
		});

		weeks.push({
			songs: [
				["Alpha Moogus", "oldpostor", 'oldpostor', FlxColor.RED, BEANS, [], 250, false],
				["Actin Sus", "oldpostor", 'oldpostor', FlxColor.RED, BEANS, [], 250, false]
			],

			section: 6
		});

		weeks.push({
			songs: [
				["Ow", "kills", 'kills', FlxColor.fromRGB(84, 167, 202), BEANS, [], 400, false],
				["Who", "whoguys", 'who', FlxColor.fromRGB(22, 65, 240), BEANS, [], 500, false],
				["Insane Streamer", "jerma", 'jerma', FlxColor.BLACK, BEANS, [], 400, false],
				["Sussus Nuzzus", "nuzzles", 'nuzzus', FlxColor.BLACK, BEANS, [], 400, false],
				["Idk", "idk", 'idk', FlxColor.fromRGB(255, 140, 177), BEANS, [], 350, false],
				["Esculent", "dead", 'esculent', FlxColor.BLACK, BEANS, [], 350, false],
				["Drippypop", "drippy", 'pop', FlxColor.fromRGB(188, 106, 223), BEANS, [], 425, false],
				["Crewicide", "dave", 'dave', FlxColor.BLUE, BEANS, [], 450, false],
				["Monotone Attack", "attack", 'monotoner', FlxColor.WHITE, BEANS, [], 400, false],
				["Top 10", "top", 'top', FlxColor.RED, BEANS, [], 200, false]
			],

			section: 7
		});

		weeks.push({
			songs: [
				["Chippin", "cvp", 'chips', FlxColor.fromRGB(255, 60, 38), BEANS, [], 300, false],
				["Chipping", "cvp", 'chips', FlxColor.fromRGB(255, 60, 38), BEANS, [], 300, false],
				["Torture", "ziffy", 'torture', FlxColor.fromRGB(188, 106, 223), SPECIAL, ['chippin', 'chipping'], 0, false]
			],

			section: 8
		});

		return weeks;
	}

	function changeSelection(change:Int = 0)
	{
		prevSel = curSelected;

		curSelected += change;
		if (curSelected < 0)
		{
			changeWeek(-1);
			curSelected = listOfButtons.length - 1;
		}
		else if (curSelected > listOfButtons.length - 1)
		{
			changeWeek(1);
			curSelected = 0;
		}
		else
		{
			if(change != 0) FlxG.sound.play(Paths.sound('hover'), 0.5);
		}

		#if !switch
		intendedScore = Highscore.getScore(listOfButtons[curSelected].songName, 2);
		intendedRating = Highscore.getRating(listOfButtons[curSelected].songName, 2);
		#end

		if (listOfButtons.length > 0)
		{
			for (i => button in listOfButtons)
			{
				button.targetY = i - curSelected;
			}
		}

		changePortrait();
	}

	function changeWeek(change:Int = 0)
	{
		if (change > 0) FlxG.sound.play(Paths.sound('panelAppear'), 0.5);
		else if (change < 0) FlxG.sound.play(Paths.sound('panelDisappear'), 0.5);

		prevWeek = curWeek;

		curWeek = FlxMath.wrap(curWeek + change, 0, 8);

		trace(curWeek + '/' + weeks.length);
		trace('created Weeks');

		for (i in listOfButtons)
		{
			FlxTween.cancelTweensOf(i);
			FlxTween.cancelTweensOf(i.spriteOne);
			FlxTween.cancelTweensOf(i.icon);
			FlxTween.cancelTweensOf(i.lock);
			FlxTween.cancelTweensOf(i.songText);
			FlxTween.cancelTweensOf(i.bean);
			FlxTween.cancelTweensOf(i.priceText);
			i.destroy();
			i.spriteOne.destroy();
			i.icon.destroy();
			i.lock.destroy();
			i.songText.destroy();
			i.bean.destroy();
			i.priceText.destroy();
		}

		listOfButtons = [];

		for (num => week in weeks)
		{
			for (i => song in week.songs)
			{
				if (week.section == curWeek)
				{
					if(!hasSavedData) listOfButtons.push(new FreeplayCard(0,0,song[0],song[1],song[3],song[2],song[4],song[5],song[6],song[7]));
					else listOfButtons.push(new FreeplayCard(0,0,song[0],song[1],song[3],song[2],song[4],song[5],song[6],localWeeks[num].songs[i][7]));
				}
			}
		}

		for (i in listOfButtons)
		{
			add(i);
			add(i.spriteOne);
			add(i.icon);
			add(i.songText);
			add(i.bean);
			add(i.lock);
			add(i.priceText);
			// trace('added button ' + i);
		}

		for (i => button in listOfButtons)
		{
			button.targetY = i;
			button.spriteOne.alpha = 0;
			button.songText.alpha = 0;
			button.icon.alpha = 0;
			button.lock.alpha = 0;
			button.bean.alpha = 0;
			button.priceText.alpha = 0;
			button.spriteOne.setPosition((Math.abs(button.targetY * 70) * -1) - 270,
				(FlxMath.remapToRange(button.targetY, 0, 1, 0, 1.3) * 90) + (FlxG.height * 0.45));
		}

		curSelected = 0;

		#if !switch
		intendedScore = Highscore.getScore(listOfButtons[curSelected].songName, 2);
		intendedRating = Highscore.getRating(listOfButtons[curSelected].songName, 2);
		#end

		changePortrait(true);
	}

	function changePortrait(?reset:Bool = false)
	{
		prevPort = portrait.animation.name;

		switch (listOfButtons[curSelected].portrait)
		{
			default: portrait.animation.play(listOfButtons[curSelected].portrait);
		}

		if(listOfButtons[curSelected].locked)
		{
			portrait.shader = rimlight.shader;
			portrait.color = FlxColor.BLACK;
		}
		else
		{
			portrait.shader = null;
			portrait.color = FlxColor.WHITE;
		}

		if(prevPort != portrait.animation.name) trace(portrait.animation.name);

		if (!reset)
		{
			if (prevSel != curSelected)
			{
				if (prevPort != portrait.animation.name)
				{
					if (portraitTween != null) portraitTween.cancel();
					if (portraitAlphaTween != null) portraitAlphaTween.cancel();

					portrait.x = 504.65;
					portrait.alpha = 0;
					portraitTween = FlxTween.tween(portrait, {x: 304.65}, 0.3, {ease: FlxEase.expoOut});
					portraitAlphaTween = FlxTween.tween(portrait, {alpha: 1}, 0.3, {ease: FlxEase.expoOut});

					var newColor:Int = listOfButtons[curSelected].coloring;
					if(newColor != intendedColor)
					{
						intendedColor = newColor;
						FlxTween.cancelTweensOf(porGlow);
						FlxTween.color(porGlow, 0.3, porGlow.color, intendedColor);
					}
				}
			}
		}
		else
		{
			if (portraitTween != null) portraitTween.cancel();
			if (portraitAlphaTween != null) portraitAlphaTween.cancel();

			portrait.x = 504.65;
			portrait.alpha = 0;
			portraitTween = FlxTween.tween(portrait, {x: 304.65}, 0.3, {ease: FlxEase.expoOut});
			portraitAlphaTween = FlxTween.tween(portrait, {alpha: 1}, 0.3, {ease: FlxEase.expoOut});

			var newColor:Int = listOfButtons[curSelected].coloring;
			if(newColor != intendedColor)
			{
				intendedColor = newColor;
				FlxTween.cancelTweensOf(porGlow);
				FlxTween.color(porGlow, 0.3, porGlow.color, intendedColor);
			}
		}

		rimlight.rimlightColor = listOfButtons[curSelected].coloring;
	}

	public function startSong(selectedSong:String)
	{
		FlxG.sound.play(Paths.sound('confirmMenu'));

		var songLowercase:String = Paths.formatToSongPath(selectedSong);
		Song.loadFromJson(songLowercase + "-hard", songLowercase);
		PlayState.isStoryMode = false;
		PlayState.storyDifficulty = 2;
		PlayState.storyWeek = curWeek;

		trace('CURRENT WEEK: ' + WeekData.getWeekFileName());

		LoadingState.prepareToSong();
		new FlxTimer().start(0.25, function(tmr:FlxTimer)
		{
			LoadingState.loadAndSwitchState(new PlayState());
			#if !SHOW_LOADING_SCREEN FlxG.sound.music.stop(); #end
			destroyFreeplayVocals();
		});

		#if (MODS_ALLOWED && DISCORD_ALLOWED)
		DiscordClient.loadModRPC();
		#end
	}

	override function destroy():Void
	{
		super.destroy();

		FlxG.autoPause = ClientPrefs.data.autoPause;
		if (!FlxG.sound.music.playing && !stopMusicPlay)
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
	}
}

class DifficultySubstate extends MusicBeatSubstate
{
	// hey please automate this sometime soon I'm not a fan of hardcoding this
	public static var songsWithMissLimits:Array<String> = ['defeat'];

	var curWeek:Int;
	var selectedSong:String;

	var camOther:PsychCamera;

	var blackBG:FlxSprite;
	var missAmountArrow:FlxSprite;
	var missTxt:FlxText;

	var dummySprites:FlxTypedGroup<FlxSprite>;
	var maximumMissLimit:Int = 5;

	public function new(curWeek:Int, selectedSong:String)
	{
		super();

		this.curWeek = curWeek;
		this.selectedSong = selectedSong;

		camOther = new PsychCamera();
		camOther.bgColor.alpha = 0;
		FlxG.cameras.add(camOther, false);

		cameras = [camOther];

		blackBG = new FlxSprite().makeGraphic(1400, 1400, FlxColor.BLACK);
		blackBG.screenCenter(XY);
		blackBG.alpha = 0;
		add(blackBG);

		// miss limit stuff
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

		if (!songsWithMissLimits.contains(selectedSong.toLowerCase())) startSong();
		else openMissLimit();
	}

	var hasEnteredMissSelection:Bool = false;
	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if(!hasEnteredMissSelection) return;

		if(controls.UI_LEFT_P) changeMissAmount(1);
		if(controls.UI_RIGHT_P) changeMissAmount(-1);
		if(controls.ACCEPT) startSong();
		if(controls.BACK)
		{
			close();
			FlxG.sound.play(Paths.sound('select'), 0.5);
		}
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
		FlxTween.tween(blackBG, {alpha: 1}, 0.25, {ease: FlxEase.circIn});
		FlxTween.tween(missAmountArrow, {alpha: 1}, 0.25, {ease: FlxEase.circIn});
		FlxTween.tween(missTxt, {alpha: 1}, 0.25, {ease: FlxEase.circIn});
		dummySprites.forEach(function(spr:FlxSprite)
		{
			FlxTween.tween(spr, {alpha: 1}, 0.25, {ease: FlxEase.circIn});
		});
	}

	function startSong()
	{
		close();
		FreeplayState.instance.startSong(selectedSong);
	}
}

class FreeplayCard extends FlxSprite
{
    public var spriteOne:FlxSprite;
    public var icon:FlxSprite;
    public var trueX:Float;
    public var trueY:Float;
    public var coloring:FlxColor;
    public var iconName:String;
    public var songText:FlxText;
    public var portrait:String;
    public var songName:String;
    public var targetY:Float = 0;
    public var forceX:Float = Math.NEGATIVE_INFINITY;
	public var yMult:Float = 100;
	public var xAdd:Float = 0;
    public var yAdd:Float = 0;
    public var deAlpha:Float = 0;

    public var lock:FlxSprite;
    public var priceText:FlxText;
    public var price:Int = 0;
    public var locked:Bool = true;
    public var shuffleLetters:Array<String> = [];
    public var bean:FlxSprite;
    public var requirementtype:RequireType;

    var shuffleTimer:FlxTimer;

    public function new(x:Float, y:Float, song:String, namer:String, colord:FlxColor, portraits:String, ?requirement:RequireType, ?songs:Array<String>, _price:Int = 0, ?forceUnlock = false)
    {
        trueX = x;
        trueY = y;
        iconName = namer;
        coloring = colord;
        songName = song;
        portrait = portraits;
        requirementtype = requirement;
        price = _price;

        visible = false;

        spriteOne = new FlxSprite(trueX, trueY).loadGraphic(Paths.image('freeplay/songPanel', 'impostor'));
        spriteOne.updateHitbox();

        lock = new FlxSprite(0, 0);
        if(requirement != SPECIAL) lock.frames = Paths.getSparrowAtlas('freeplay/lock', 'impostor');
        else lock.frames = Paths.getSparrowAtlas('freeplay/lockGold', 'impostor');
		lock.animation.addByPrefix('lock', 'lock0', 24, true);
        lock.animation.addByPrefix('unlock', 'lock open', 24, false);
		lock.animation.play('lock');
        lock.updateHitbox();

        priceText = new FlxText(0, 0, 500, Std.string(price), 28);
		priceText.setFormat(Paths.font("ariblk.ttf"), 28, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        priceText.updateHitbox();
		priceText.borderSize = 2;

        bean = new FlxSprite(trueX, trueY).loadGraphic(Paths.image('freeplay/bean', 'impostor'));
        bean.scale.set(0.6, 0.6);
        bean.updateHitbox();

        var name:String = 'icons/icon-' + iconName;
        var file:Dynamic = Paths.image(name);

        icon = new FlxSprite(trueX - 13, trueY - 23).loadGraphic(file, true, 150, 150);
        icon.updateHitbox();
        icon.setGraphicSize(Std.int(icon.width * 0.6));

        songText = new FlxText(trueX + 50, trueY - 23, 0, song, 48);
        songText.setFormat(Paths.font('AmaticSC-Bold.ttf'), 64, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        songText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 1, 1);
        songText.updateHitbox();

        for(i in 0...song.length) shuffleLetters.push(song.charAt(i));

        findLocked(requirement, songs, forceUnlock);

        if(price == 0) bean.visible = priceText.visible = false;

        if(locked)
        {
            doShuffle();
            icon.color = FlxColor.BLACK;
            spriteOne.color = 0xFF4A4A4A;
            shuffleTimer = new FlxTimer().start(FlxG.random.float(0.1, 0.2), function(tmr:FlxTimer)
            {
                doShuffle();
            }, 0);
        }

        super();        
    }

    public function unlockAnim()
    {
        var colorShader:ColorShader = new ColorShader(0);
        spriteOne.shader = lock.shader = priceText.shader = bean.shader = icon.shader = songText.shader = colorShader.shader;
        locked = false;

        FlxG.sound.play(Paths.sound('unlockSong'), 0.9);
        new FlxTimer().start(0.1, function(tmr:FlxTimer)
        {
            lock.animation.play('unlock');
            FlxTween.tween(colorShader, {amount: 1}, 1.2, {ease: FlxEase.expoIn});
            new FlxTimer().start(1.3, function(tmr:FlxTimer)
            {
                FlxTween.tween(colorShader, {amount: 0}, 1.2, {ease: FlxEase.expoOut});
                lock.visible = priceText.visible = bean.visible = false;
                spriteOne.color = icon.color = 0xFFFFFFFF;
                shuffleTimer.cancel();
                songText.text = songName;
                new FlxTimer().start(1.5, function(tmr:FlxTimer)
                {
                    spriteOne.shader = lock.shader = priceText.shader = bean.shader = icon.shader = songText.shader = null;
                });
            });
        });
    }

    function findLocked(requirement:RequireType, songs:Array<String>, forceUnlock:Bool = false)
    {
        locked = false;

        #if debug
        lock.visible = bean.visible = priceText.visible = false;
        return;
        #end

        if(forceUnlock)
        {
            lock.visible = bean.visible = priceText.visible = false;
            return;
        }

        if(requirement == FROM_STORY_MODE)
        {
            for(song in songs)
            {
                if(Highscore.getScore(song, 2) == 0) locked = true;
            }
        }
        if(requirement == BEANS) locked = true;
        if(requirement == SPECIAL)
        { 
            for(song in songs)
            {
                if(Highscore.getScore(song, 2) == 0) locked = true;
            }
        }

        if(locked) lock.visible =/* bean.visible = priceText.visible =*/ true;
        else lock.visible = bean.visible = priceText.visible = false;
    }

    function doShuffle()
    {
        FlxG.random.shuffle(shuffleLetters);
        var theText:String = '';
        for(letter in shuffleLetters)
        {
            if(FlxG.random.bool(50)) letter = letter.toUpperCase();
            else letter = letter.toLowerCase();
            theText += letter;
        }
        songText.text = theText;
    }

    override function update(elapsed:Float)
    {
        final scaledY = FlxMath.remapToRange(targetY, 0, 1, 0, 1.3);
        final theX:Float = (Math.abs(targetY * 70) * -1) + 70;
        final lerpVal:Float = FlxMath.bound(elapsed * 15.6, 0, 1);        

        spriteOne.y = FlxMath.lerp(spriteOne.y, (scaledY * 90) + (FlxG.height * 0.45), lerpVal);
        spriteOne.x = FlxMath.lerp(spriteOne.x, theX, lerpVal);

        deAlpha = 1 + (-Math.abs(targetY) * 0.25);

        final lerpV = FlxMath.lerp(icon.alpha, deAlpha, lerpVal);
        icon.alpha = lock.alpha = bean.alpha = priceText.alpha = spriteOne.alpha = songText.alpha = lerpV;

        icon.setPosition(spriteOne.x - 13, spriteOne.y - 23);
        lock.setPosition(spriteOne.x + 25, spriteOne.y + 11);
        bean.setPosition(spriteOne.x + 405, spriteOne.y - 20);
        priceText.setPosition(spriteOne.x + 440, spriteOne.y - 20);
        songText.setPosition(spriteOne.x + 120, spriteOne.y + 5);

        super.update(elapsed);
    }
}
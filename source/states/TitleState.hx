package states;

import flixel.input.keyboard.FlxKey;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;

import openfl.Assets;

import objects.VideoSprite;

import states.MainMenuState;
import substates.OutdatedSubState;

class TitleState extends MusicBeatState
{
	public static var initialized:Bool = false;
	var canPressEnter:Bool = false;

	var credGroup:FlxGroup = new FlxGroup();
	var textGroup:FlxGroup = new FlxGroup();
	var blackScreen:FlxSprite;
	var logoSpr:FlxSprite;

	var curWacky:Array<String> = [];

	var logoBl:FlxSprite;
	var titleText:FlxOffsetSprite;

	var skippedIntro:Bool = false;
	var transitioning:Bool = false;

	private var sickBeats:Int = 0; //Basically curBeat but won't be skipped if you hold the tab or resize the screen
	public static var closedState:Bool = false;
	static var showOutdatedWarning:Bool = true;

	override public function create():Void
	{
		Paths.clearStoredMemory();
		super.create();
		Paths.clearUnusedMemory();

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("On the Title Screen", null);
		#end

		curWacky = FlxG.random.getObject(getIntroTextShit());

		Paths.music('freakyMenu'); // cache the music!!!!

		if(FlxG.save.data.flashing == null)
		{
			FlxTransitionableState.skipNextTransIn = FlxTransitionableState.skipNextTransOut = true;
			MusicBeatState.switchState(new FlashingState());
		}
		else
		{
			if (initialized) startIntro();
			else startVideo('v4_startup');
		}
	}

	function startIntro()
	{
		canPressEnter = true;

		if (!initialized)
		{
			if(FlxG.sound.music == null)
			{
				FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
				FlxG.sound.music.fadeIn(4, 0, 0.7);
			}
		}

		Conductor.bpm = 102;

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		var starBG:FlxBackdrop = new FlxBackdrop(Paths.image('menuBooba/starBG', 'impostor'), XY, 1, 1);
		starBG.updateHitbox();
		starBG.scrollFactor.set();
		starBG.velocity.set(-8, 0);
		add(starBG);

		var starFG:FlxBackdrop = new FlxBackdrop(Paths.image('menuBooba/starFG', 'impostor'), XY, 1, 1);
		starFG.updateHitbox();
		starFG.scrollFactor.set();
		starFG.velocity.set(-24, 0);
		add(starFG);

		logoBl = new FlxSprite(0, 0).loadGraphic(Paths.image('logoBumpin'));
		logoBl.screenCenter();
		logoBl.centerOffsets();
		add(logoBl);
		logoBl.y -= 40;

		titleText = new FlxOffsetSprite(300, FlxG.height * 0.85);
		titleText.frames = Paths.getSparrowAtlas('menuBooba/startText', 'impostor');
		titleText.animation.addByPrefix('idle', "EnterIdle", 24, false);
		titleText.animation.addByPrefix('press', "EnterStart", 24, false);
		titleText.updateHitbox();
		titleText.addOffset('idle', 0, 0);
		titleText.addOffset('press', 278, 2);
		titleText.playAnim('idle');
		titleText.y -= 60;
		add(titleText);

		add(credGroup);

		blackScreen = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		blackScreen.scale.set(FlxG.width, FlxG.height);
		blackScreen.updateHitbox();
		credGroup.add(blackScreen);

		logoSpr = new FlxSprite(0, FlxG.height * 0.4).loadGraphic(Paths.image('titlelogo'));
		logoSpr.setGraphicSize(Std.int(logoSpr.width * 0.55));
		logoSpr.updateHitbox();
		logoSpr.screenCenter(X);
		logoSpr.visible = false;
		add(logoSpr);

		if (initialized) skipIntro();
		else initialized = true;
	}

	function getIntroTextShit():Array<Array<String>>
	{
		#if MODS_ALLOWED
		var firstArray:Array<String> = Mods.mergeAllTextsNamed('data/introText.txt');
		#else
		var fullText:String = Assets.getText(Paths.txt('introText'));
		var firstArray:Array<String> = fullText.split('\n');
		#end
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
		{
			swagGoodArray.push(i.split('--'));
		}

		return swagGoodArray;
	}

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		if (FlxG.keys.justPressed.F)
			FlxG.fullscreen = !FlxG.fullscreen;

		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER || controls.ACCEPT;

		#if mobile
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
				pressedEnter = true;
		}
		#end

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;
		if (gamepad != null)
		{
			if (gamepad.justPressed.START)
				pressedEnter = true;

			#if switch
			if (gamepad.justPressed.B)
				pressedEnter = true;
			#end
		}

		if (initialized && !transitioning && skippedIntro)
		{
			if(pressedEnter && canPressEnter)
			{
				#if CHECK_FOR_UPDATES
				if (showOutdatedWarning && ClientPrefs.data.checkForUpdates && OutdatedSubState.updateVersion != MainMenuState.impostorPortVersion)
				{
					persistentUpdate = showOutdatedWarning = false;
					openSubState(new OutdatedSubState());
				}
				else
				#end
				{
					if(titleText != null) titleText.playAnim('press', true);

					FlxG.camera.flash(ClientPrefs.data.flashing ? FlxColor.WHITE : 0x4CFFFFFF, 1);
					FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

					transitioning = true;
					new FlxTimer().start(1, function(tmr:FlxTimer)
					{
						MusicBeatState.switchState(new MainMenuState());
						closedState = true;
					});
				}
			}
		}

		if (initialized && pressedEnter && !skippedIntro)
			skipIntro();

		if (logoBl != null)
		{
			var mult:Float = FlxMath.lerp(1, logoBl.scale.x, Math.exp(-elapsed * 9));
			logoBl.scale.set(mult, mult);
		}

		super.update(elapsed);
	}

	function createCoolText(textArray:Array<String>, ?offset:Float = 0)
	{
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true);
			money.screenCenter(X);
			money.y += (i * 60) + 200 + offset;
			if(credGroup != null && textGroup != null)
			{
				credGroup.add(money);
				textGroup.add(money);
			}
		}
	}

	function addMoreText(text:String, ?offset:Float = 0)
	{
		if(textGroup != null && credGroup != null) {
			var coolText:Alphabet = new Alphabet(0, 0, text, true);
			coolText.screenCenter(X);
			coolText.y += (textGroup.length * 60) + 200 + offset;
			credGroup.add(coolText);
			textGroup.add(coolText);
		}
	}

	function deleteCoolText()
	{
		while (textGroup.members.length > 0)
		{
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	override function beatHit()
	{
		super.beatHit();

		if(logoBl != null) logoBl.scale.set(1.05, 1.05);

		if(!closedState)
		{
			sickBeats++;
			switch (sickBeats)
			{
				case 1:
					createCoolText(['Impostorm'], 45);
				case 3:
					addMoreText('Presents', 45);
					addMoreText('', 45);
				case 4:
					deleteCoolText();
				case 5:
					createCoolText(['This is a mod to'], -60);
				case 7:
					addMoreText('This game right below lol', -60);
					logoSpr.visible = true;
				case 8:
					deleteCoolText();
					logoSpr.visible = false;
				case 9:
					createCoolText([curWacky[0]]);
				case 11:
					addMoreText(curWacky[1]);
				case 12:
					deleteCoolText();
				case 13:
					addMoreText("FNF");
				case 14:
					addMoreText('VS Impostor');
				case 15:
					addMoreText('V4');
				case 16:
					skipIntro();
			}
		}
	}

	function skipIntro():Void
	{
		if (skippedIntro) return;

		remove(logoSpr);
		remove(credGroup);

		if (!closedState) FlxG.camera.flash(ClientPrefs.data.flashing ? FlxColor.WHITE : 0x4CFFFFFF, 4);

		skippedIntro = true;
	}

	public function startVideo(name:String):Void
	{
		#if VIDEOS_ALLOWED
		final skipVid:Bool = #if debug true #else false #end;
		var fileName:String = Paths.video(name);
		if(Paths.fileExistsAbsolute(fileName))
		{
			var videoCutscene:VideoSprite = new VideoSprite(fileName, false, skipVid, false);
			#if debug videoCutscene.canPause = true; #end
			videoCutscene.overallFinish = startIntro;
			add(videoCutscene);

			videoCutscene.play();
			return;
		}
		else FlxG.log.warn('Couldnt find video file: $fileName');
		#else
		FlxG.log.warn('Platform not supported!');
		#end
		startIntro();
	}
}
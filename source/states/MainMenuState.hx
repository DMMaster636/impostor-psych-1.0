package states;

import flixel.FlxObject;
import states.editors.MasterEditorMenu;
import options.OptionsState;

class MainMenuState extends MusicBeatState
{
	public static var impostorPortVersion:String = '0.2';
	public static var impostorModVersion:String = '4.1.0';
	public static var psychEngineVersion:String = '1.0.3';

	public static var curSelected:Int = 0;

	var localFinaleState:FinaleState;

	var menuItems:FlxTypedGroup<FlxSpriteButton>;

	var starFG:FlxBackdrop;
	var starBG:FlxBackdrop;
	var redImpostor:FlxSprite;
	var greenImpostor:FlxSprite;
	var vignette:FlxSprite;
	var glowyThing:FlxSprite;

	var optionShit:Array<String> = [
		'Story_Mode', // 0
		'Freeplay', // 1
		'Gallery', // 2
		'Credits', // 3
		'Options', // 4
		'Shop', // 5
		'Innersloth' // 6
	];

	var navigationMap:Map<String, {left:Int, right:Int, down:Int, up:Int}> = [
		'Story_Mode' => {left: 1, right: 1, down: 2, up: 4},
		'Freeplay' => {left: 0, right: 0, down: 3, up: 6},
		'Gallery' => {left: 3, right: 3, down: 4, up: 0},
		'Credits' => {left: 2, right: 2, down: 6, up: 1},
		'Options' => {left: 6, right: 5, down: 0, up: 2},
		'Shop' => {left: 4, right: 6, down: 0, up: 2},
		'Innersloth' => {left: 5, right: 4, down: 1, up: 3}
	];

	var camFollow:FlxObject;

	override function create()
	{
		super.create();

		#if MODS_ALLOWED
		Mods.pushGlobalMods();
		#end
		Mods.loadTopMod();

		localFinaleState = ClientPrefs.data.finaleState;

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Main Menu", null);
		#end

		persistentUpdate = persistentDraw = true;

		if(!FlxG.sound.music.playing)
			FlxG.sound.playMusic(Paths.music(localFinaleState == NOT_PLAYED ? 'finaleMenu' : 'freakyMenu'));

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		FlxG.camera.follow(camFollow, null, 0.15);

		var bg:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.scrollFactor.set();
		add(bg);

		starBG = new FlxBackdrop(Paths.image('menuBooba/starBG', 'impostor'));
		starBG.updateHitbox();
		starBG.scrollFactor.set();
		starBG.velocity.set(-12, 0);
		add(starBG);

		starFG = new FlxBackdrop(Paths.image('menuBooba/starFG', 'impostor'));
		starFG.updateHitbox();
		starFG.scrollFactor.set();
		starFG.velocity.set(-36, 0);
		add(starFG);

		redImpostor = new FlxSprite(350, -160);
		redImpostor.frames = Paths.getSparrowAtlas('menuBooba/redmenu', 'impostor');
		redImpostor.animation.addByPrefix('idle', 'red idle', 24, true);
		redImpostor.animation.addByPrefix('select', 'red select', 24, false);
		redImpostor.animation.play('idle');
		redImpostor.updateHitbox();
		redImpostor.active = true;
		redImpostor.scale.set(0.7, 0.7);
		redImpostor.scrollFactor.set();
		add(redImpostor);

		greenImpostor = new FlxSprite(-300, -60);
		greenImpostor.frames = Paths.getSparrowAtlas('menuBooba/greenmenu', 'impostor');
		greenImpostor.animation.addByPrefix('idle', 'green idle', 24, true);
		greenImpostor.animation.addByPrefix('select', 'green select', 24, false);
		greenImpostor.animation.play('idle');
		greenImpostor.updateHitbox();
		greenImpostor.active = true;
		greenImpostor.scale.set(0.7, 0.7);
		greenImpostor.scrollFactor.set();
		add(greenImpostor);

		if(localFinaleState == NOT_PLAYED)
			greenImpostor.visible = redImpostor.visible = false;

		vignette = new FlxSprite(0, 0).loadGraphic(Paths.image('menuBooba/vignette', 'impostor'));
		vignette.updateHitbox();
		vignette.active = false;
		vignette.scrollFactor.set();
		add(vignette);

		glowyThing = new FlxSprite(361, 438).loadGraphic(Paths.image('menuBooba/buttonglow', 'impostor'));
		glowyThing.scale.set(0.51, 0.51);
		glowyThing.updateHitbox();
		glowyThing.active = false;
		glowyThing.scrollFactor.set();
		if(localFinaleState != NOT_PLAYED) glowyThing.visible = false;
		add(glowyThing);

		menuItems = new FlxTypedGroup<FlxSpriteButton>();
		add(menuItems);

		for(num => option in optionShit)
		{
			var item:FlxSpriteButton = createMenuItem(option, num);
			if(curSelected == num) item.animation.play('hover', true);
		}

		var logo:FlxSprite = new FlxSprite().loadGraphic(Paths.image('logoBumpin'));
		logo.scrollFactor.set();
		logo.scale.set(0.65, 0.65);
		logo.updateHitbox();
		logo.screenCenter();
		logo.y -= 140;
		add(logo);

		var portVer:FlxText = new FlxText(12, FlxG.height - 64, 0, 'Mod Port v$impostorPortVersion', 12);
		portVer.scrollFactor.set();
		portVer.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(portVer);
		var impVer:FlxText = new FlxText(12, FlxG.height - 44, 0, 'VS Impostor v$impostorModVersion', 12);
		impVer.scrollFactor.set();
		impVer.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(impVer);
		var psychVer:FlxText = new FlxText(12, FlxG.height - 24, 0, 'Psych Engine v$psychEngineVersion', 12);
		psychVer.scrollFactor.set();
		psychVer.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(psychVer);

		#if ACHIEVEMENTS_ALLOWED
		// Unlocks "Freaky on a Friday Night" achievement if it's a Friday and between 18:00 PM and 23:59 PM
		var leDate = Date.now();
		if (leDate.getDay() == 5 && leDate.getHours() >= 18)
			Achievements.unlock('friday_night_play');

		#if MODS_ALLOWED
		Achievements.reloadList();
		#end
		#end

		super.create();

		changeItem(curSelected, false);
	}

	function createMenuItem(name:String, num:Int):FlxSpriteButton
	{
		var menuItem:FlxSpriteButton = new FlxSpriteButton(0, 0, function()
		{
			if(selectedSomethin) return;
			changeItem(num);
			selectSomething();
		});
		menuItem.onOver.callback = function()
		{
			if(selectedSomethin) return;
			changeItem(num);
		};
		menuItem.onOut.callback = function()
		{
			if(selectedSomethin) return;
			menuItem.animation.play('idle');
		};
		menuItem.frames = Paths.getSparrowAtlas('menuBooba/Buttons_$name', 'impostor');
		menuItem.animation.addByPrefix('idle', '$name Button', 24, true);
		menuItem.animation.addByPrefix('hover', '$name Select', 24, true);
		menuItem.animation.play('idle');
		menuItem.scale.set(0.5, 0.5);
		menuItem.updateHitbox();
		menuItem.screenCenter(X);
		menuItem.scrollFactor.set();
		switch(num)
		{
			case 0: menuItem.setPosition(400, 475);
			case 1: menuItem.setPosition(633, 475);
			case 2: menuItem.setPosition(400, 580);
			case 3: menuItem.setPosition(633, 580);
			case 4: menuItem.setPosition(455, 640);
			case 5: menuItem.setPosition(590, 640);
			case 6: menuItem.setPosition(725, 640);
		}
		menuItems.add(menuItem);
		return menuItem;
	}

	var selectedSomethin:Bool = false;
	var usingMouse:Bool = false;
	var timerThing:Float = 0;
	var timeNotMoving:Float = 0;
	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.7)
			FlxG.sound.music.volume += 0.5 * elapsed;

		timerThing += elapsed;
		glowyThing.alpha = Math.sin(timerThing) + 0.4;

		if (!selectedSomethin)
		{
			if (controls.UI_LEFT_P || controls.UI_DOWN_P || controls.UI_UP_P || controls.UI_RIGHT_P)
				usingMouse = FlxG.mouse.visible = false;

			if ((FlxG.mouse.deltaScreenX != 0 && FlxG.mouse.deltaScreenY != 0) || FlxG.mouse.justPressed)
				usingMouse = FlxG.mouse.visible = true;

			var nav = navigationMap.get(optionShit[curSelected]);
			if (controls.UI_LEFT_P) changeItem(nav.left);
			if (controls.UI_DOWN_P) changeItem(nav.down);
			if (controls.UI_UP_P) changeItem(nav.up);
			if (controls.UI_RIGHT_P) changeItem(nav.right);

			if (controls.ACCEPT) selectSomething();
			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			#if (desktop && debug)
			if (controls.justPressed('debug_1'))
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end
		}

		super.update(elapsed);
	}

	function selectSomething()
	{
		FlxG.sound.play(Paths.sound('confirmMenu'));

		switch (optionShit[curSelected])
		{
			case 'Gallery':
				FlxG.openURL('https://vsimpostor.com/');
				return;
			case 'Innersloth':
				FlxG.openURL('https://www.innersloth.com/');
				return;
		}

		selectedSomethin = true;

		greenImpostor.animation.play('select');
		redImpostor.animation.play('select');

		FlxTween.tween(starFG, {y: starFG.y + 500}, 1, {ease: FlxEase.quadInOut});
		FlxTween.tween(starBG, {y: starBG.y + 500}, 1, {ease: FlxEase.quadInOut, startDelay: 0.2});
		FlxTween.tween(greenImpostor, {y: greenImpostor.y + 800}, 0.7, {ease: FlxEase.quadInOut, startDelay: 0.24});
		FlxTween.tween(redImpostor, {y: redImpostor.y + 800}, 0.7, {ease: FlxEase.quadInOut, startDelay: 0.3});
		FlxG.camera.fade(FlxColor.BLACK, 0.7, false);
		for(item in menuItems) FlxTween.tween(item, {alpha: 0}, 1.3, {ease: FlxEase.quadOut});

		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			switch (optionShit[curSelected])
			{
				case 'Story_Mode':
					MusicBeatState.switchState(new StoryMenuState());
				case 'Freeplay':
					MusicBeatState.switchState(new FreeplayState());
				case 'Shop':
					MusicBeatState.switchState(new ShopState());
				case 'Options':
					MusicBeatState.switchState(new OptionsState());
					OptionsState.onPlayState = false;
					if (PlayState.SONG != null)
					{
						PlayState.SONG.arrowSkin = null;
						PlayState.SONG.splashSkin = null;
						PlayState.stageUI = 'normal';
					}
				case 'Credits':
					MusicBeatState.switchState(new CreditsState());
			}
		});
	}

	function changeItem(change:Int = 0, playSound:Bool = true)
	{
		if(playSound) FlxG.sound.play(Paths.sound('scrollMenu'));
		curSelected = change;

		for(item in menuItems) item.animation.play('idle', true);
		menuItems.members[curSelected].animation.play('hover', true);
	}
}
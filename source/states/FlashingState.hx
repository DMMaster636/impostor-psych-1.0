package states;

class FlashingState extends MusicBeatState
{
	override function create()
	{
		super.create();

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		final str:Array<String> = [
			"Hey, watch out!",
			"This Mod contains some flashing lights!",
			"",
			"Press ACCEPT to disable them now.",
			"Press BACK to ignore this message.",
			"You can also go to Options Menu to change them!",
			"",
			"You've been warned!"
		];

        var warnings:FlxSpriteGroup = new FlxSpriteGroup();
        for (i => txt in str)
        {
            if(txt.length < 1) continue;

            var warnText:FlxText = new FlxText(0, 0, FlxG.width, txt, 24);
            warnText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, CENTER);
            warnText.screenCenter();
            add(warnText);
            warnText.y += ((i - str.length / 2) * 32) + 16;
            warnings.add(warnText);
        }
        add(warnings);
	}

	static var leftState:Bool = false;
	override function update(elapsed:Float)
	{
		if(!leftState)
		{
			if(controls.ACCEPT) confirmSelection(true);
			if(controls.BACK) confirmSelection(false);
		}

		super.update(elapsed);
	}

	function confirmSelection(disable:Bool)
	{
		leftState = FlxTransitionableState.skipNextTransIn = FlxTransitionableState.skipNextTransOut = true;
		if(disable)
		{
			ClientPrefs.data.flashing = false;
			ClientPrefs.saveSettings();
			FlxG.sound.play(Paths.sound('cancelMenu'));
			FlxG.camera.fade(FlxColor.BLACK, 1, false, function()
			{
				MusicBeatState.switchState(new TitleState());
			});
		}
		else
		{
			ClientPrefs.data.flashing = true;
			ClientPrefs.saveSettings();
			FlxG.sound.play(Paths.sound('confirmMenu'));
			FlxG.camera.flash(FlxColor.WHITE, 0.6, function()
			{
				FlxG.camera.fade(FlxColor.BLACK, 0.6, false, function()
				{
					MusicBeatState.switchState(new TitleState());
				});
			});
		}
	}
}
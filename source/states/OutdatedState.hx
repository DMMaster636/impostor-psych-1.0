package states;

class OutdatedState extends MusicBeatState
{
	var newVer:String;
	public function new(newVer:String)
	{
		this.newVer = newVer;
		super();
	}

	override function create():Void
	{
		super.create();

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		final str:Array<String> = [
			"Hey, you! As you can see, there's a new update to this Port.",
			"Your current version (" + MainMenuState.impostorPortVersion + ") is outdated.",
			"Please Update to " + newVer + ", as it may contain",
			"various Bug fixes and Improvements!",
			"",
			"Press ACCEPT to Open the Page.",
			"Press BACK to Continue.",
			"",
			"Thanks for playing this Port!!!"
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

	var leftState:Bool = false;
	override function update(elapsed:Float)
	{
		if(!leftState)
		{
			if(controls.ACCEPT) confirmSelection(true);
			if(controls.BACK) confirmSelection(false);
		}

		super.update(elapsed);
	}

	function confirmSelection(update:Bool)
	{
		leftState = true;
		if(update)
		{
			CoolUtil.browserLoad("https://github.com/DMMaster636/impostor-psych-1.0/releases");
			FlxG.sound.play(Paths.sound('confirmMenu'));
			FlxG.camera.flash(ClientPrefs.data.flashing ? FlxColor.WHITE : 0x4CFFFFFF, 0.6, function()
			{
				FlxG.camera.fade(FlxColor.BLACK, 0.6, false, function()
				{
					MusicBeatState.switchState(new TitleState());
				});
			});
		}
		else
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			FlxG.camera.fade(FlxColor.BLACK, 1, false, function()
			{
				MusicBeatState.switchState(new TitleState());
			});
		}
	}
}
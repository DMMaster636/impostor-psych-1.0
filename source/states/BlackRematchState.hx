package states;

import objects.VideoSprite;

class BlackRematchState extends MusicBeatState
{
	override function create()
	{
		super.create();

		#if DISCORD_ALLOWED
		DiscordClient.changePresence("A Rematch it is...", null);
		#end

		startVideo();
	}

	public function startVideo():Void
	{
		function goToMenu()
		{
			if(ClientPrefs.data.finaleState != NOT_PLAYED || ClientPrefs.data.finaleState != COMPLETED)
				ClientPrefs.data.finaleState = NOT_PLAYED;
	
			ClientPrefs.saveSettings();
			MusicBeatState.switchState(new TitleState());
		}

		#if VIDEOS_ALLOWED
		var fileName:String = Paths.video('finale');
		if(Paths.fileExistsAbsolute(fileName))
		{
			var videoCutscene:VideoSprite = new VideoSprite(fileName, false, true, false);
			videoCutscene.overallFinish = goToMenu;
			add(videoCutscene);

			videoCutscene.play();
			return;
		}
		else FlxG.log.warn('Couldnt find video file: $fileName');
		#else
		FlxG.log.warn('Platform not supported!');
		#end
		goToMenu();
	}
}
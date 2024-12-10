package states;

import objects.VideoSprite;

class CreditsVideoState extends MusicBeatState
{
	override function create()
	{
		super.create();

		#if DISCORD_ALLOWED
		DiscordClient.changePresence("Watching the Credits", null);
		#end

		startVideo();
	}

	public function startVideo():Void
	{
		function goToMenu()
		{
			MusicBeatState.switchState(new TitleState());
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}

		#if VIDEOS_ALLOWED
		var fileName:String = Paths.video('credits');
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
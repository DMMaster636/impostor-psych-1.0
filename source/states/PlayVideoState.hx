package states;

import objects.VideoSprite;

class PlayVideoState extends MusicBeatState
{
	public var videoID:String = "credits3";
	public var onComplete:Void->Void = null;
	public var canSkip:Bool = true;
	public var canPause:Bool = true;
	public var discordText:String = "Watching a Video";

	public function new(videoID:String, onComplete:Void->Void = null, ?canSkip:Bool = true, ?canPause:Bool = true, ?discordText:String = "Watching a Video")
	{
		this.videoID = videoID;
		this.onComplete = onComplete;
		this.canSkip = canSkip;
		this.canPause = canPause;
		this.discordText = discordText;

		super();
	}

	override function create()
	{
		super.create();

		#if DISCORD_ALLOWED
		DiscordClient.changePresence(discordText, null);
		#end

		startVideo(videoID);
	}

	public function startVideo(name:String):Void
	{
		#if VIDEOS_ALLOWED
		var fileName:String = Paths.video(name);
		if(Paths.fileExistsAbsolute(fileName))
		{
			var videoCutscene:VideoSprite = new VideoSprite(fileName, false, canSkip, false);
			videoCutscene.overallFinish = onComplete;
			videoCutscene.canPause = canPause;
			add(videoCutscene);

			videoCutscene.play();
			return;
		}
		else FlxG.log.warn('Couldnt find video file: $fileName');
		#else
		FlxG.log.warn('Platform not supported!');
		#end
		if(onComplete != null) onComplete();
		else
		{
			trace("what the FUCK did you DO YOU IDIOT");
			MusicBeatState.switchState(new MainMenuState());
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}
	}
}
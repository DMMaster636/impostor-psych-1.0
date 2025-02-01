package states;

import flixel.input.keyboard.FlxKey;

#if desktop
import hxwindowmode.WindowColorMode;
#end

class InitState extends MusicBeatState
{
	public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];

	var mustUpdate:Bool = false;
	var updateVersion:String;

	override public function create():Void
	{
		trace('Initializing!');

		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		super.create();

		ClientPrefs.loadPrefs();
		Language.reloadPhrases();
		Difficulty.resetList();
		Highscore.load();
		#if ACHIEVEMENTS_ALLOWED Achievements.load(); #end

		#if MODS_ALLOWED
		Mods.pushGlobalMods();
		#end
		Mods.loadTopMod();

		FlxG.fixedTimestep = false;
		FlxG.game.focusLostFramerate = 60;
		FlxG.keys.preventDefaultKeys = [TAB];

		if(FlxG.save.data != null && FlxG.save.data.fullscreen)
			FlxG.fullscreen = FlxG.save.data.fullscreen;

		persistentUpdate = persistentDraw = true;

		if (FlxG.save.data.weekCompleted != null)
			StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;

		FlxSprite.defaultAntialiasing = ClientPrefs.data.antialiasing;

		#if desktop
		WindowColorMode.setWindowColorMode(ClientPrefs.data.darkBorder);
		WindowColorMode.redrawWindowHeader();
		#end

		FlxG.mouse.visible = false;

		#if DISCORD_ALLOWED
		DiscordClient.prepare();
		#end

		#if CHECK_FOR_UPDATES
		if(ClientPrefs.data.checkForUpdates)
		{
			trace('Checking for updates...');

			var http = new haxe.Http("https://raw.githubusercontent.com/DMMaster636/impostor-psych-1.0/main/gitVersion.txt");
			http.onData = function(data:String)
			{
				updateVersion = data.split('\n')[0].trim();
				if(updateVersion != MainMenuState.impostorPortVersion.trim()) mustUpdate = true;
			}
			http.onError = function(error)
			{
				trace('Error: $error');
			}
			http.request();
		}
		#end

		if(mustUpdate) MusicBeatState.switchState(new OutdatedState(updateVersion));
		else MusicBeatState.switchState(new TitleState());
	}
}
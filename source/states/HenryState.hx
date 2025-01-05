package states;

import backend.Song;
import backend.StageData;
import backend.WeekData;

import objects.VideoSprite;

class HenryState extends MusicBeatState
{
    var freezeFrame:FlxSprite;
    var grad:FlxSprite;

    var mic:FlxSpriteButton;
    var stare:FlxSpriteButton;
    var sock:FlxSpriteButton;

    var canClick:Bool = false;

	override function create()
	{
		super.create();

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Henry is choosing an Option", null);
		#end

        FlxG.mouse.visible = true;

        freezeFrame = new FlxSprite(0, 0).loadGraphic(Paths.image('henry/finalframe', 'impostor'));
        freezeFrame.setGraphicSize(FlxG.width, FlxG.height);
        freezeFrame.updateHitbox();
        freezeFrame.screenCenter();
		add(freezeFrame);

        grad = new FlxSprite(0, 0).loadGraphic(Paths.image('henry/hguiofuhjpsod', 'impostor'));
        grad.setGraphicSize(FlxG.width, FlxG.height);
        grad.updateHitbox();
        grad.screenCenter();
		add(grad);

        function dead()
        {
            canClick = sock.visible = stare.visible = mic.visible = freezeFrame.visible = grad.visible = true;
        }

        sock = new FlxSpriteButton(0, 0, function()
        {
            if(!canClick) return;
            canClick = sock.visible = stare.visible = mic.visible = freezeFrame.visible = grad.visible = false;
            startVideo('henrysock', dead);
        });
        sock.onOver.callback = function()
        {
            if(!canClick) return;
            FlxG.sound.play(Paths.sound('sock'), 0.6);
            sock.animation.play('select', true);
        };
        sock.onOut.callback = function()
        {
            if(!canClick) return;
            sock.animation.play('deselect', true);
        };
        sock.frames = Paths.getSparrowAtlas('henry/Sock_Puppet_Option', 'impostor');	
        sock.animation.addByPrefix('select', 'Sock Puppet Select', 24, false);
        sock.animation.addByPrefix('deselect', 'Sock Puppet', 24, false);
        sock.scale.set(0.5, 0.5);
        sock.updateHitbox();
        add(sock);
        sock.visible = false;

        stare = new FlxSpriteButton(0, 0, function()
        {
            if(!canClick) return;
            canClick = sock.visible = stare.visible = mic.visible = freezeFrame.visible = grad.visible = false;
            startVideo('henrystare', dead);
        });
        stare.onOver.callback = function()
        {
            if(!canClick) return;
            FlxG.sound.play(Paths.sound('stare'), 0.6);
            stare.animation.play('select', true);
        };
        stare.onOut.callback = function()
        {
            if(!canClick) return;
            stare.animation.play('deselect', true);
        };
        stare.frames = Paths.getSparrowAtlas('henry/Stare_Down_Option', 'impostor');	
        stare.animation.addByPrefix('select', 'Stare Down Select', 24, false);
        stare.animation.addByPrefix('deselect', 'Stare Down', 24, false);
        stare.scale.set(0.5, 0.5);
        stare.updateHitbox();
        add(stare);
        stare.visible = false;

        mic = new FlxSpriteButton(0, 0, function()
        {
            if(!canClick) return;
            canClick = sock.visible = stare.visible = mic.visible = freezeFrame.visible = grad.visible = false;
            startVideo('henrymic', startWeek);
        });
        mic.onOver.callback = function()
        {
            if(!canClick) return;
            FlxG.sound.play(Paths.sound('mic'), 0.6);
            mic.animation.play('select', true);
        };
        mic.onOut.callback = function()
        {
            if(!canClick) return;
            mic.animation.play('deselect', true);
        };
        mic.frames = Paths.getSparrowAtlas('henry/Microphone_Option', 'impostor');	
        mic.animation.addByPrefix('select', 'Microphone Select', 24, false);
        mic.animation.addByPrefix('deselect', 'Microphone', 24, false);
        mic.scale.set(0.5, 0.5);
        mic.updateHitbox();
        add(mic);
        mic.visible = false;

        stare.screenCenter();
        stare.y += FlxG.height * 0.15;

        sock.screenCenter();
        sock.x += FlxG.width * 0.15;
        sock.y -= FlxG.height * 0.15;

        mic.screenCenter();
        mic.x -= FlxG.width * 0.15;
        mic.y -= FlxG.height * 0.15;

        function options()
        {
            new FlxTimer().start(1, function(tmr:FlxTimer)
            {
                mic.visible = true;
                FlxG.sound.play(Paths.sound('mic'), 0.6);
            });
    
            new FlxTimer().start(2, function(tmr:FlxTimer)
            {
                sock.visible = true;
                FlxG.sound.play(Paths.sound('sock'), 0.6);
            });
    
            new FlxTimer().start(3, function(tmr:FlxTimer)
            {
                stare.visible = true;
                FlxG.sound.play(Paths.sound('stare'), 0.6);
                canClick = true;
            });
        }

        startVideo('henry1', options);
    }

    function startWeek():Void
    {
        var _difficulty:Int = 2; // TODO: make this the actual diff
        var _week:Int = 9;

        WeekData.reloadWeekFiles(true);

        // We can't use Dynamic Array .copy() because that crashes HTML5, here's a workaround.
        var songArray:Array<String> = [];
        var leWeek:Array<Dynamic> = WeekData.weeksLoaded.get(WeekData.weeksList[_week]).songs;
        for (i in 0...leWeek.length) songArray.push(leWeek[i][0]);

        // Nevermind that's stupid lmao
		try
		{
            PlayState.storyPlaylist = songArray;
            PlayState.isStoryMode = true;

            var diffic = Difficulty.getFilePath(_difficulty);
            if(diffic == null) diffic = '';

            PlayState.storyDifficulty = _difficulty;

            Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + diffic, PlayState.storyPlaylist[0].toLowerCase());
            PlayState.storyWeek = _week;
            PlayState.campaignScore = 0;
            PlayState.campaignMisses = 0;
        }
        catch(e:Dynamic)
        {
            trace('ERROR! $e');
            return;
        }

        var directory = StageData.forceNextDirectory;
        LoadingState.loadNextDirectory();
        StageData.forceNextDirectory = directory;

        LoadingState.prepareToSong();
        new FlxTimer().start(1, function(tmr:FlxTimer)
        {
            #if !SHOW_LOADING_SCREEN FlxG.sound.music.stop(); #end
            LoadingState.loadAndSwitchState(new PlayState(), true);
            FreeplayState.destroyFreeplayVocals();
        });
    }

	public function startVideo(name:String, funcToCall:Void->Void):Void
	{
		#if VIDEOS_ALLOWED
		var fileName:String = Paths.video(name);
		if(Paths.fileExistsAbsolute(fileName))
		{
			var videoCutscene:VideoSprite = new VideoSprite(fileName, false, false, false);
			videoCutscene.overallFinish = funcToCall;
			videoCutscene.canPause = false;
			add(videoCutscene);

			videoCutscene.play();
			return;
		}
		else FlxG.log.warn('Couldnt find video file: $fileName');
		#else
		FlxG.log.warn('Platform not supported!');
		#end
		funcToCall();
	}
}
package objects;

import flixel.addons.display.FlxPieDial;

#if hxvlc
import hxvlc.flixel.FlxVideo;
import hxvlc.flixel.FlxVideoSprite;
#end

class VideoSprite extends FlxSpriteGroup
{
	#if VIDEOS_ALLOWED
	public var overallFinish:Void->Void = null;
	public var finishCallback:Void->Void = null;
	public var onSkip:Void->Void = null;

	public var canSkip(default, set):Bool = false;
	final _timeToSkip:Float = 1;
	final _timeToPause:Float = 0.2;
	public var holdingTime:Float = 0;
	public var skipSprite:FlxPieDial;

	private var videoName:String;
	public var videoSprite:FlxVideoSprite;
	public var cover:FlxSprite;

	public var isWaiting:Bool = false;
	public var isPlaying:Bool = false;
	public var isPaused:Bool = false;
	public var didPlay:Bool = false;

	public var canPause(default, set):Bool = true;
	public var pauseText:FlxText;

	public function new(videoName:String, isWaiting:Bool, canSkip:Bool = false, shouldLoop:Dynamic = false)
	{
		super();

		this.videoName = videoName;
		this.isWaiting = isWaiting;

		scrollFactor.set();

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

		if(!isWaiting)
		{
			cover = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
			cover.scale.set(FlxG.width + 100, FlxG.height + 100);
			cover.screenCenter();
			cover.scrollFactor.set();
			add(cover);
		}

		// initialize sprites
		videoSprite = new FlxVideoSprite();
		add(videoSprite);

		this.canSkip = canSkip;
		canPause = !isWaiting;

		// callbacks
		if(!shouldLoop)
		{
			videoSprite.bitmap.onEndReached.add(function()
			{
				if(alreadyDestroyed) return;
		
				trace('Video destroyed');
				if(cover != null)
				{
					remove(cover);
					cover.destroy();
				}

				if(pauseText != null)
				{
					remove(pauseText);
					pauseText.destroy();
				}

				psychlua.LuaUtils.getTargetInstance().remove(this);
				destroy();
				alreadyDestroyed = true;
			});
		}

		videoSprite.bitmap.onFormatSetup.add(function()
		{
			/*
			#if hxvlc
			var wd:Int = videoSprite.bitmap.formatWidth;
			var hg:Int = videoSprite.bitmap.formatHeight;
			trace('Video Resolution: ${wd}x${hg}');
			videoSprite.scale.set(FlxG.width / wd, FlxG.height / hg);
			#end
			*/
			videoSprite.setGraphicSize(FlxG.width, FlxG.height);
			videoSprite.updateHitbox();
			videoSprite.screenCenter();
		});

		// start video and adjust resolution to screen size
		videoSprite.load(videoName, shouldLoop ? ['input-repeat=65545'] : null);
	}

	var skippedVideo:Bool = false;
	var alreadyDestroyed:Bool = false;
	override function destroy()
	{
		if(alreadyDestroyed)
		{
			super.destroy();
			return;
		}

		trace('Video destroyed');
		if(cover != null)
		{
			remove(cover);
			cover.destroy();
		}

		if(pauseText != null)
		{
			remove(pauseText);
			pauseText.destroy();
		}

		if(skippedVideo)
		{
			if(onSkip != null) onSkip();
			finishCallback = null;
		}
		else
		{
			if(finishCallback != null) finishCallback();
			onSkip = null;
		}

		if(overallFinish != null) overallFinish();

		psychlua.LuaUtils.getTargetInstance().remove(this);
	}

	override function update(elapsed:Float)
	{
		if(!isWaiting)
		{
			if(Controls.instance.pressed('accept'))
				holdingTime = Math.max(0, Math.min(_timeToSkip, holdingTime + elapsed));
			else if (holdingTime > 0)
				holdingTime = Math.max(0, FlxMath.lerp(holdingTime, -0.1, FlxMath.bound(elapsed * 3, 0, 1)));

			if(canSkip)
			{
				updateSkipAlpha();

				if(holdingTime >= _timeToSkip)
				{
					skippedVideo = true;
					videoSprite.bitmap.onEndReached.dispatch();
					trace('Skipped video');
					destroy();
					super.destroy();
					return;
				}
			}

			if(canPause)
			{
				if(Controls.instance.justReleased('accept') && holdingTime <= _timeToPause && holdingTime > 0)
				{
					if(isPaused) resume();
					else pause();
					pauseText.visible = isPaused;
				}
			}
		}

		super.update(elapsed);
	}

	function set_canSkip(newValue:Bool)
	{
		canSkip = newValue;
		if(canSkip)
		{
			if(skipSprite == null)
			{
				skipSprite = new FlxPieDial(0, 0, 40, FlxColor.WHITE, 40, true, 24);
				skipSprite.replaceColor(FlxColor.BLACK, FlxColor.TRANSPARENT);
				skipSprite.x = FlxG.width - (skipSprite.width + 80);
				skipSprite.y = FlxG.height - (skipSprite.height + 72);
				skipSprite.amount = 0;
				add(skipSprite);
			}
		}
		else if(skipSprite != null)
		{
			remove(skipSprite);
			skipSprite.destroy();
			skipSprite = null;
		}
		return canSkip;
	}

	function updateSkipAlpha()
	{
		if(skipSprite == null) return;

		skipSprite.amount = Math.min(1, Math.max(0, (holdingTime / _timeToSkip) * 1.025));
		skipSprite.alpha = FlxMath.remapToRange(skipSprite.amount, 0.025, 1, 0, 1);
	}

	function set_canPause(newValue:Bool)
	{
		canPause = newValue;
		if(canPause)
		{
			if(pauseText == null)
			{
				pauseText = new FlxText(0, 0, FlxG.width, "|| Paused");
				pauseText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
				pauseText.borderSize = 1.25;
				pauseText.scrollFactor.set();
				pauseText.updateHitbox();
				pauseText.y = FlxG.height - pauseText.height;
				pauseText.visible = false;
				add(pauseText);
			}
		}
		else if(pauseText != null)
		{
			remove(pauseText);
			pauseText.destroy();
			pauseText = null;
		}
		return canPause;
	}

	public function play()
	{
		isPlaying = true;
		videoSprite?.play();
	}
	public function resume()
	{
		isPaused = false;
		videoSprite?.resume();
	}
	public function pause()
	{
		isPaused = true;
		videoSprite?.pause();
	}
	#end
}
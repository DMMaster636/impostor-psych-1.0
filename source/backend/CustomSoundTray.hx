package backend;

import openfl.display.Bitmap;
import flixel.system.ui.FlxSoundTray;

class CustomSoundTray extends FlxSoundTray
{
	public var volumeMaxSound:String;
	var slider:Bitmap;

	var defaultBarX:Float = 0;
	var positions:Array<Float> = [-120, -96, -72, -48, -24, 0, 24, 48, 72, 96, 120];

	var graphicScale:Float = 0.3;
	var lerpYPos:Float = 0;
	var alphaTarget:Float = 0;

	var globalVolume:Int = Math.round(FlxG.sound.volume * 10);

	public function new()
	{
		super();

		removeChildren();
		_bars = [];

		var bg:Bitmap = new Bitmap(Paths.bitmap('soundtray/volumebox'));
		bg.scaleX = bg.scaleY = graphicScale;
		bg.smoothing = ClientPrefs.data.antialiasing;
		addChild(bg);
		defaultBarX = bg.x = -9;

		y = -height;
		visible = false;

		slider = new Bitmap(Paths.bitmap('soundtray/slider'));
		slider.scaleX = slider.scaleY = graphicScale;
		slider.smoothing = ClientPrefs.data.antialiasing;
		addChild(slider);
		// the slider kinda replaces the bars, sooooo-
		_bars.push(slider);
		slider.x = defaultBarX + positions[globalVolume] * graphicScale;

		y = -height;
		screenCenter();

		volumeUpSound = 'pop';
		volumeDownSound = 'hover';
		volumeMaxSound = 'locked';

		Paths.sound('$volumeUpSound');
		Paths.sound('$volumeDownSound');
		Paths.sound('$volumeMaxSound');
	}

	override public function update(MS:Float):Void
	{
		y = coolLerp(y, lerpYPos, 0.1);
		alpha = coolLerp(alpha, alphaTarget, 0.25);
		slider.x = coolLerp(slider.x, defaultBarX + positions[globalVolume] * graphicScale, 0.1);

		if (_timer > 0)
		{
			_timer -= (MS / 1000);
			alphaTarget = 1;
		}
		else if (y >= -height)
		{
			lerpYPos = -height - 10;
			alphaTarget = 0;
		}

		if (y <= -height) visible = active = false;
	}

	override public function show(up:Bool = false):Void
	{
		_timer = 2;
		lerpYPos = 10;
		visible = active = true;

		globalVolume = Math.round(FlxG.sound.volume * 10);
		if (FlxG.sound.muted) globalVolume = 0;

		if (!silent)
		{
			var sound:String = up ? volumeUpSound : volumeDownSound;
			if (globalVolume == 10) sound = volumeMaxSound;

			FlxG.sound.play(Paths.sound('$sound'));
		}

	}

	public function coolLerp(base:Float, target:Float, ratio:Float):Float
	{
		return base + (ratio  * (FlxG.elapsed / (1 / 60))) * (target - base);
	}
}
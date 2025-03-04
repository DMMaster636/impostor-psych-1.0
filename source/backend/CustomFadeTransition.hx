package backend;

import flixel.util.FlxGradient;

class CustomFadeTransition extends MusicBeatSubstate
{
	public static var finishCallback:Void->Void;
	var camTrans:PsychCamera;

	var isTransIn:Bool = false;
	var transBlack:FlxSprite;
	var transGradient:FlxSprite;

	var duration:Float;
	public function new(duration:Float, isTransIn:Bool)
	{
		this.duration = duration;
		this.isTransIn = isTransIn;
		super();
	}

	override function create()
	{
		camTrans = new PsychCamera();
		camTrans.bgColor.alpha = 0;
		FlxG.cameras.add(camTrans, false);

		cameras = [camTrans];

		var width:Int = Std.int(FlxG.width / Math.max(camera.zoom, 0.001));
		var height:Int = Std.int(FlxG.height / Math.max(camera.zoom, 0.001));
		transGradient = FlxGradient.createGradientFlxSprite(1, height, (isTransIn ? [0x0, FlxColor.BLACK] : [FlxColor.BLACK, 0x0]));
		transGradient.scale.x = width;
		transGradient.updateHitbox();
		transGradient.scrollFactor.set();
		transGradient.screenCenter(X);
		add(transGradient);

		transBlack = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		transBlack.scale.set(width, height + 400);
		transBlack.updateHitbox();
		transBlack.scrollFactor.set();
		transBlack.screenCenter(X);
		add(transBlack);

		if(!isTransIn) transGradient.y = -transGradient.height;
		else transGradient.y = transBlack.y - transBlack.height;

		super.create();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		final height:Float = FlxG.height * Math.max(camera.zoom, 0.001);
		final targetPos:Float = transGradient.height + 50 * Math.max(camera.zoom, 0.001);
		if(duration > 0)
			transGradient.y += (height + targetPos) * elapsed / duration;
		else
			transGradient.y = (targetPos) * elapsed;

		if(isTransIn)
			transBlack.y = transGradient.y + transGradient.height;
		else
			transBlack.y = transGradient.y - transBlack.height;

		if(transGradient.y >= targetPos) close();
	}

	// Don't delete this
	override function close():Void
	{
		super.close();

		if(finishCallback != null)
		{
			finishCallback();
			finishCallback = null;
		}
	}
}

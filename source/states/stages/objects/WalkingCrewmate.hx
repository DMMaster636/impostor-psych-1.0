package states.stages.objects;

import backend.animation.PsychAnimationController;

class WalkingCrewmate extends FlxSprite
{
	public var theColor:String = 'yellow';
	public var xRange:Array<Float> = [0, 0];
	var savedHeight:Float = 0;

	var idle:Bool = false;
	var nextActionTime:Float = 5;
	var time:Float = 0;
	var right:Bool = true;
	var hibernating:Bool = false;

	public function new(col:Int, xRange:Array<Float>, savedHeight:Float = 0, scale:Float = 1)
	{
		super(FlxG.random.float(xRange[1] - xRange[0]), savedHeight);

		animation = new PsychAnimationController(this);

		this.xRange = xRange;
		this.savedHeight = savedHeight;
		this.scale.set(scale, scale);

		lookupColor(col);

		frames = Paths.getSparrowAtlas('mira/walkers', 'impostor');
		for(animCol in ['blue', 'brown', 'lime', 'tan', 'white', 'yellow'])
		{
			animation.addByPrefix(animCol + '_walk', animCol, 24, true);
			animation.addByIndices(animCol + '_idle', animCol, [8], "", 24, true);
		}
		animation.play(theColor + '_walk');
		scrollFactor.set(1, 1);

		setNewActionTime();
	}

	function lookupColor(num:Int)
	{
		y = savedHeight;
		switch(num)
		{
			case 0:
				theColor = 'blue';
				y += 70;
			case 1:
				theColor = 'brown';
			case 2:
				theColor = 'lime';
				y += 70;
			case 3:
				theColor = 'tan';
			case 4:
				theColor = 'white';
			default:
				theColor = 'yellow';
		}
	}

	function swapSkin()
	{
		setNewActionTime(5, 10);

		visible = false;

		var newColor:Int = 0;
		switch(theColor) //prevent duplicate guys appearing on the screen at the same time
		{
			case 'blue' | 'brown': newColor = FlxG.random.int(0, 1);
			case 'lime' | 'tan': newColor = FlxG.random.int(2, 3);
			default: newColor = FlxG.random.int(4, 5);
		}
		lookupColor(newColor);
	}

	function setNewActionTime(min:Float = 0.5, max:Float = 1)
	{
		nextActionTime = time + FlxG.random.float(min, max);
	}

	function triggerNextAction()
	{
		if(hibernating)
		{
			hibernating = false;
			visible = true;
		}

		if(FlxG.random.bool(20)) right = FlxG.random.bool(50);

		if(!idle && FlxG.random.bool(60)) idle = true;
		if(idle && FlxG.random.bool(50)) idle = false;

		setNewActionTime();
	}

	override function update(elapsed:Float)
	{
		time += elapsed;

		if(time > nextActionTime) triggerNextAction();

		super.update(elapsed);

		if(!hibernating)
		{
			if(x > (xRange[1] * 0.9))
			{
				hibernating = true;
				x -= 50;
				right = false;
				swapSkin();
			}

			if(x < (xRange[0] * 1.1))
			{
				hibernating = true;
				x += 50;
				right = true;
				swapSkin();
			}

			if(!idle)
			{
				if(animation.curAnim.name != theColor + '_walk') animation.play(theColor + '_walk');

				if(right) x = FlxMath.lerp(x, x + 30, FlxMath.bound(elapsed * 9, 0, 1));
				else x = FlxMath.lerp(x, x - 30, FlxMath.bound(elapsed * 9, 0, 1));
			}
			else
			{
				if(animation.curAnim.name != theColor + '_idle' && (animation.curAnim.curFrame == 7 || animation.curAnim.curFrame == 15))
					animation.play(theColor + '_idle');
			}

			flipX = !right;

			if(x > xRange[1]) right = false;
			else if(x < xRange[0]) right = true;
		}
	}
}
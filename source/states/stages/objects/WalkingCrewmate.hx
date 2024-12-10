package states.stages.objects;

class WalkingCrewmate extends FlxSprite
{
    public var thecolor:String;
    public var xRange:Array<Float> = [0, 0];
    var savedHeight:Float;

    var idle:Bool = false;
    var nextActionTime:Float;
    var time:Float;
    var right:Bool;
    var hibernating:Bool = false;

    public function new(theColor:Int, range:Array<Float>, height:Float, thescale:Float)
    {
        super(FlxG.random.float(range[1] - range[0]), height);   

        xRange = range;
        savedHeight = height;
        scale.set(thescale, thescale);

        lookupColor(theColor);

        frames = Paths.getSparrowAtlas('mira/walkers', 'impostor');	
	    animation.addByPrefix('walk', thecolor, 24, true);
        animation.addByIndices('idle', thecolor, [8], "", 24, true);
	    animation.play('walk');
	    scrollFactor.set(1, 1);

        setNewActionTime();
    }

    function lookupColor(h:Int)
    {
        y = savedHeight;
        switch(h)
        {
            case 0:
                thecolor = 'blue';
                y += 70;
            case 1:
                thecolor = 'brown';
            case 2:
                thecolor = 'lime';
                y += 70;
            case 3:
                thecolor = 'tan';
            case 4:
                thecolor = 'white';
            case 5:
                thecolor = 'yellow';
        }
    }

    function swapSkin()
    {
        nextActionTime = time + FlxG.random.float(5, 10);
        visible = false;
        animation.stop();
        animation.remove('walk');
        animation.remove('idle');

        var newColor:Int = 0;
        switch(thecolor) //prevent duplicate guys appearing on the screen at the same time
        {
            case 'blue' | 'brown': newColor = FlxG.random.int(0, 1);
            case 'lime' | 'tan': newColor = FlxG.random.int(2, 3);
            case 'white' | 'yellow': newColor = FlxG.random.int(4, 5);
        }
        lookupColor(newColor);
        animation.addByPrefix('walk', thecolor, 24, true);
        animation.addByIndices('idle', thecolor, [8], "", 24, true);
    }

    function setNewActionTime() nextActionTime = time + FlxG.random.float(0.5, 1);

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

        if(hibernating) return;

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
            if(animation.curAnim.name != 'walk') animation.play('walk');
            if(right)
            {
                x = FlxMath.lerp(x, x + 30, FlxMath.bound(elapsed * 9, 0, 1));
                flipX = false;
            }
            else
            {
                x = FlxMath.lerp(x, x - 30, FlxMath.bound(elapsed * 9, 0, 1));
                flipX = true;
            }
        }
        else
        {
            if(animation.curAnim.name != 'idle' && (animation.curAnim.curFrame == 7 || animation.curAnim.curFrame == 15))
                animation.play('idle');
    
            if(right) flipX = false;
            else flipX = true;
        }

        if(x > xRange[1]) right = false;
        if(x < xRange[0]) right = true;
    }
}
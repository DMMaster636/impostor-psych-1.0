package objects;

import shaders.ColorShader;

class BeansPopup extends FlxSpriteGroup
{
	public var onFinish:Void->Void = null;

	var alphaTween:FlxTween;
    var bean:FlxSprite;
    var popupBG:FlxSprite;
    var theText:FlxText;
    var lerpScore:Int = 0;
    var canLerp:Bool = false;

	public function new(amount:Int, ?camera:FlxCamera = null)
	{
		super(x, y);

        this.y -= 100;
        lerpScore = amount;
		alpha = 0;

        ClientPrefs.data.beans += amount;
		ClientPrefs.saveSettings();

		popupBG = new FlxSprite(FlxG.width - 300, 0).makeGraphic(300, 100, 0xF8FF0000);
        popupBG.visible = false;
		popupBG.scrollFactor.set();
        add(popupBG);

        bean = new FlxSprite(0, 0).loadGraphic(Paths.image('shop/bean', 'impostor'));
        bean.setPosition(popupBG.getGraphicMidpoint().x - 90, popupBG.getGraphicMidpoint().y - (bean.height / 2));
        bean.updateHitbox(); 
        bean.scrollFactor.set();
		add(bean);	

        theText = new FlxText(popupBG.x + 90, popupBG.y + 35, 200, Std.string(amount), 35);
		theText.setFormat(Paths.font("ariblk.ttf"), 35, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        theText.setPosition(popupBG.getGraphicMidpoint().x - 10, popupBG.getGraphicMidpoint().y - (theText.height / 2));
        theText.updateHitbox();
		theText.borderSize = 3;
        theText.scrollFactor.set();
        add(theText);

        var colorShader:ColorShader = new ColorShader(0);
        bean.shader = theText.shader = colorShader.shader;

        FlxTween.tween(this, {y: 0}, 0.35, {ease: FlxEase.circOut});

        new FlxTimer().start(0.9, function(tmr:FlxTimer)
		{
            canLerp = true;
            colorShader.amount = 1;
            FlxTween.tween(colorShader, {amount: 0}, 0.8, {ease: FlxEase.expoOut});
            FlxG.sound.play(Paths.sound('getbeans', 'impostor'), 0.9);
        });

		var cam:Array<FlxCamera> = FlxCamera.defaultCameras;
		if(camera != null) cam = [camera];
		bean.cameras = theText.cameras = popupBG.cameras = cam;
		alphaTween = FlxTween.tween(this, {alpha: 1}, 0.5, {
            onComplete: function(twn:FlxTween)
            {
                alphaTween = FlxTween.tween(this, {alpha: 0}, 0.5, {
                    startDelay: 2.5,
                    onComplete: function(twn:FlxTween)
                    {
                        alphaTween = null;
                        remove(this);
                        if(onFinish != null) onFinish();
                    }
                });
            }
        });
	}

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if(canLerp)
        {
            lerpScore = Math.floor(FlxMath.lerp(lerpScore, 0, FlxMath.bound(elapsed * 4, 0, 1) / 1.5));
            if(Math.abs(0 - lerpScore) < 10) lerpScore = 0;
        }

        theText.text = Std.string(lerpScore);
        bean.setPosition(popupBG.getGraphicMidpoint().x - 90, popupBG.getGraphicMidpoint().y - (bean.height / 2));
        theText.setPosition(popupBG.getGraphicMidpoint().x - 10, popupBG.getGraphicMidpoint().y - (theText.height / 2));
    }

	override function destroy()
    {
		if(alphaTween != null) alphaTween.cancel();
		super.destroy();
	}
}
package objects;

import backend.animation.PsychAnimationController;

import shaders.RGBPalette;
import shaders.RGBPalette.RGBShaderReference;

class StrumNote extends FlxSprite
{
	public var rgbShader:RGBShaderReference;
	public var resetAnim:Float = 0;
	private var noteData:Int = 0;
	public var direction(default, set):Float;
	public var downScroll:Bool = false;
	public var sustainReduce:Bool = true;
	private var player:Int;

	private var _dirSin:Float;
	private var _dirCos:Float;

	private function set_direction(_fDir:Float):Float
	{
		// 0.01745329251 = Math.PI / 180
		_dirSin = Math.sin(_fDir * 0.01745329251);
		_dirCos = Math.cos(_fDir * 0.01745329251);

		return direction = _fDir;
	}

	public var texture(default, set):String = null;
	private function set_texture(value:String):String {
		if(texture != value) reloadNote(value);

		texture = value;
		return value;
	}

	public var useRGBShader:Bool = true;
	public function new(x:Float, y:Float, leData:Int, player:Int) {
		direction = 90;

		animation = new PsychAnimationController(this);

		rgbShader = new RGBShaderReference(this, Note.initializeGlobalRGBShader(leData));
		rgbShader.enabled = false;
		if(PlayState.SONG != null && PlayState.SONG.disableNoteRGB) useRGBShader = false;
		
		var arr:Array<FlxColor> = ClientPrefs.data.arrowRGB[leData];
		if(leData <= arr.length)
		{
			@:bypassAccessor
			{
				rgbShader.r = arr[0];
				rgbShader.g = arr[1];
				rgbShader.b = arr[2];
			}
		}

		noteData = leData;
		this.player = player;
		this.noteData = leData;
		this.ID = noteData;
		super(x, y);

		texture = '';
		scrollFactor.set();
		playAnim('static');
	}

	static var _lastValidChecked:String; //optimization
	public function reloadNote(texture:String = '', postfix:String = '')
	{
		if(texture == null) texture = '';
		if(postfix == null) postfix = '';

		var skin:String = texture + postfix;
		if(texture.length < 1)
		{
			skin = PlayState.SONG != null ? PlayState.SONG.arrowSkin : null;
			if(skin == null || skin.length < 1)
				skin = Note.defaultNoteSkin + postfix;
		}
		else rgbShader.enabled = false;

		var animName:String = null;
		if(animation.curAnim != null)
			animName = animation.curAnim.name;

		var skinPixel:String = skin;
		var skinPostfix:String = Note.getNoteSkinPostfix();
		var customSkin:String = skin + skinPostfix;
		var path:String = PlayState.isPixelStage ? 'pixelUI/' : '';
		if(customSkin == _lastValidChecked || Paths.fileExists('images/' + path + customSkin + '.png', IMAGE))
		{
			skin = customSkin;
			_lastValidChecked = customSkin;
		}
		else skinPostfix = '';

		if(PlayState.isPixelStage)
		{
			loadGraphic(Paths.image('pixelUI/' + skinPixel + skinPostfix));
			width = width / 4;
			height = height / 5;
			loadGraphic(Paths.image('pixelUI/' + skinPixel + skinPostfix), true, Math.floor(width), Math.floor(height));
			loadPixelNoteAnims();
			antialiasing = false;
		}
		else
		{
			frames = Paths.getSparrowAtlas(skin);
			loadNoteAnims();
		}
		updateHitbox();

		if(animName != null) playAnim(animName, true);
	}

	function loadNoteAnims() {
		animation.addByPrefix('purple', 'arrowLEFT');
		animation.addByPrefix('blue', 'arrowDOWN');
		animation.addByPrefix('green', 'arrowUP');
		animation.addByPrefix('red', 'arrowRIGHT');
		switch (Math.abs(noteData) % 4)
		{
			case 0:
				animation.addByPrefix('static', 'arrowLEFT');
				animation.addByPrefix('pressed', 'left press', 24, false);
				animation.addByPrefix('confirm', 'left confirm', 24, false);
			case 1:
				animation.addByPrefix('static', 'arrowDOWN');
				animation.addByPrefix('pressed', 'down press', 24, false);
				animation.addByPrefix('confirm', 'down confirm', 24, false);
			case 2:
				animation.addByPrefix('static', 'arrowUP');
				animation.addByPrefix('pressed', 'up press', 24, false);
				animation.addByPrefix('confirm', 'up confirm', 24, false);
			case 3:
				animation.addByPrefix('static', 'arrowRIGHT');
				animation.addByPrefix('pressed', 'right press', 24, false);
				animation.addByPrefix('confirm', 'right confirm', 24, false);
		}
		setGraphicSize(Std.int(width * 0.7));
		updateHitbox();
	}

	function loadPixelNoteAnims() {
		animation.add('purple', [4]);
		animation.add('blue', [5]);
		animation.add('green', [6]);
		animation.add('red', [7]);
		switch (Math.abs(noteData) % 4)
		{
			case 0:
				animation.add('static', [0]);
				animation.add('pressed', [4, 8], 12, false);
				animation.add('confirm', [12, 16], 12, false);
			case 1:
				animation.add('static', [1]);
				animation.add('pressed', [5, 9], 12, false);
				animation.add('confirm', [13, 17], 12, false);
			case 2:
				animation.add('static', [2]);
				animation.add('pressed', [6, 10], 12, false);
				animation.add('confirm', [14, 18], 12, false);
			case 3:
				animation.add('static', [3]);
				animation.add('pressed', [7, 11], 12, false);
				animation.add('confirm', [15, 19], 12, false);
		}
		setGraphicSize(Std.int(width * PlayState.daPixelZoom));
		updateHitbox();
	}

	public function playerPosition()
	{
		x += Note.swagWidth * noteData;
		x += 50;
		x += ((FlxG.width / 2) * player);
	}

	override function update(elapsed:Float) {
		if(resetAnim > 0) {
			resetAnim -= elapsed;
			if(resetAnim <= 0) {
				playAnim('static');
				resetAnim = 0;
			}
		}
		super.update(elapsed);
	}

	public function playAnim(anim:String, ?force:Bool = false) {
		animation.play(anim, force);
		if(animation.curAnim != null)
		{
			centerOffsets();
			centerOrigin();
		}
		if(useRGBShader) rgbShader.enabled = (animation.curAnim != null && animation.curAnim.name != 'static');
	}

	override public function destroy()
	{
		super.destroy();
		_lastValidChecked = '';
	}
}
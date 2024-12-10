package cutscenes;

import haxe.Json;
import lime.utils.Assets;

typedef DialogueCharacterFile = {
	// character data
	var animations:Array<DialogueAnimArray>;
	var image:String;
	var scale:Float;
	var flip_x:Bool;
	var position:Array<Float>;
	var no_antialiasing:Bool;

	// dialogue box data
	var name:String;
	var sound:String;
	var box_icon:String;
	var box_colors:Array<Array<Int>>
}

typedef DialogueAnimArray = {
	var anim:String;
	var name:String;
	var fps:Int;
	var loop:Bool;
	var indices:Array<Int>;
	var offsets:Array<Int>;
}

class DialogueCharacterImpostor extends FlxSprite
{
	public static var DEFAULT_CHARACTER:String = 'bf';
	public var debugMode:Bool = false;

	public var inPosition:Bool = false;
	public var alignment:String = 'right';

	public var animOffsets:Map<String, Array<Dynamic>>;
	public var animationsArray:Array<DialogueAnimArray> = [];

	public var curCharacter:String = DEFAULT_CHARACTER;
	public var imageFile:String = '';
	public var jsonScale:Float = 1;
	public var originalFlipX:Bool = false;
	public var positionArray:Array<Float> = [0, 0];
	public var noAntialiasing:Bool = false;

	public var charName:String = '';
	public var charSound:String = '';
	public var boxIcon:String = 'face';
	public var boxColorArray:Array<Array<Int>> = [[255, 0, 0], [0, 255, 0], [0, 0, 255]];

	public function new(x:Float = 0, y:Float = 0, ?character:String = 'bf', ?alignment:String = 'right')
	{
		super(x, y);

		this.alignment = alignment;
		animOffsets = new Map<String, Array<Dynamic>>();

		changeCharacter(character);
	}

	public function changeCharacter(character:String)
	{
		animOffsets = [];
		animationsArray = [];
		curCharacter = character;

		var path:String = Paths.getPath('dialogueImpostor/$character.json', TEXT);
		if (!Paths.fileExistsAbsolute(path)) //If a character couldn't be found, change him to BF just to prevent a crash
			path = Paths.getSharedPath('dialogueImpostor/' + DEFAULT_CHARACTER + '.json');

		try
		{
			#if MODS_ALLOWED
			loadCharacterFile(Json.parse(File.getContent(path)));
			#else
			loadCharacterFile(Json.parse(Assets.getText(path)));
			#end
		}
		catch(e:Dynamic)
		{
			trace('Error loading character file of "$character": $e');
		}
	}

	public function loadCharacterFile(json:Dynamic)
	{
		scale.set(1, 1);
		updateHitbox();

		frames = Paths.getMultiAtlas(json.image.split(','));

		// character data
		imageFile = json.image;
		jsonScale = json.scale;
		if(jsonScale != 1)
		{
			scale.set(jsonScale, jsonScale);
			updateHitbox();
		}
		final isPlayer:Bool = (alignment == 'right');
		originalFlipX = (json.flip_x == true);
		flipX = (json.flip_x != isPlayer);
		positionArray = json.position;
		noAntialiasing = (json.no_antialiasing == true);
		antialiasing = ClientPrefs.data.antialiasing ? !noAntialiasing : false;

		// dialogue box data
		charName = json.name;
		charSound = json.sound;
		boxIcon = json.box_icon;
		boxColorArray = (json.box_colors != null && json.box_colors.length > 2) ? json.box_colors : [161, 161, 161];

		// animations
		animationsArray = json.animations;
		if(animationsArray != null && animationsArray.length > 0)
		{
			for (anim in animationsArray)
			{
				var animAnim:String = '' + anim.anim;
				var animName:String = '' + anim.name;
				var animFps:Int = anim.fps;
				var animLoop:Bool = !!anim.loop; //Bruh
				var animIndices:Array<Int> = anim.indices;

				if(animIndices != null && animIndices.length > 0)
					animation.addByIndices(animAnim, animName, animIndices, "", animFps, animLoop);
				else
					animation.addByPrefix(animAnim, animName, animFps, animLoop);

				if(anim.offsets != null && anim.offsets.length > 1) addOffset(anim.anim, anim.offsets[0], anim.offsets[1]);
				else addOffset(anim.anim, 0, 0);
			}
		}
		//trace('Loaded file to character ' + curCharacter);
	}

	var _lastPlayedAnimation:String;
	inline public function getAnimationName():String
		return _lastPlayedAnimation;

	public function hasAnimation(anim:String):Bool
		return animOffsets.exists(anim);

	public function isAnimationFinished():Bool
	{
		if(isAnimationNull()) return false;
		return animation.curAnim.finished;
	}

	inline public function isAnimationNull():Bool
		return animation.curAnim == null;

	inline public function animationIsLoop():Bool
		return getAnimationName().endsWith('-loop');

	public function playAnim(AnimName:String, Force:Bool = false, ?isLoop:Bool = false):Void
	{
		if(isLoop && hasAnimation(AnimName + '-loop')) AnimName += '-loop';

		animation.play(AnimName, Force, Reversed, Frame);
		_lastPlayedAnimation = AnimName;

		if (hasAnimation(AnimName))
		{
			final daOffset = animOffsets.get(AnimName);
			offset.set(daOffset[0], daOffset[1]);
		}
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		animOffsets[name] = [x, y];
	}
}
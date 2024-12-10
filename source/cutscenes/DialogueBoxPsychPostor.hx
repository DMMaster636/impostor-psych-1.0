package cutscenes;

import haxe.Json;
import openfl.utils.Assets;

import flixel.addons.text.FlxTypeText;

import objects.TypedAlphabet;
import cutscenes.DialogueCharacterImpostor;

enum Speaker
{
	LEFT;
	MIDDLE;
	RIGHT;
}

typedef DialogueFile = {
	var dialogue:Array<DialogueLine>;
}

typedef DialogueLine = {
	var position:Null<String>;
	var portrait:Null<String>;
	var expression:Null<String>;
	var text:Null<String>;
	var speed:Null<Float>;
}

class DialogueBoxPsychPostor extends FlxSpriteGroup
{
	public static var DEFAULT_TEXT_X = 175;
	public static var DEFAULT_TEXT_Y = 460;
	public static var LONG_TEXT_ADD = 24;
	var scrollSpeed = 4000;

	var dialogue:TypedAlphabet;
	var dialogueList:DialogueFile = null;

	public var finishThing:Void->Void;
	public var nextDialogueThing:Void->Void = null;
	public var skipDialogueThing:Void->Void = null;

	var bgFade:FlxSprite = null;

	var boxGroup:FlxSpriteGroup;

	var rgbShader:RGBPalette;
	var box:FlxSprite;
	var boxBack:FlxSprite;

	var swagDialogue:FlxTypeText;
	var textToType:String = '';

	var arrayCharacters:Array<DialogueCharacterImpostor> = [];

	var leftCharMap:Map<String, DialogueCharacterImpostor> = new Map<String, DialogueCharacterImpostor>();
	var leftCharGroup:FlxSpriteGroup;
	var leftChar:DialogueCharacterImpostor = null;

	var middleCharMap:Map<String, DialogueCharacterImpostor> = new Map<String, DialogueCharacterImpostor>();
	var middleCharGroup:FlxSpriteGroup;
	var middleChar:DialogueCharacterImpostor = null;

	var rightCharMap:Map<String, DialogueCharacterImpostor> = new Map<String, DialogueCharacterImpostor>();
	var rightCharGroup:FlxSpriteGroup;
	var rightChar:DialogueCharacterImpostor = null;

	var currentText:Int = 0;
	var offsetPos:Float = -600;
	var skipText:FlxText;

	var textBoxTypes:Array<String> = ['normal', 'angry'];

	var curCharacter:String = "";
	//var charPositionList:Array<String> = ['left', 'center', 'right'];

	public function new(dialogueList:DialogueFile, ?song:String = null)
	{
		super();

		//precache sounds
		Paths.sound('dialogue');
		Paths.sound('dialogueClose');

		if(song != null && song != '')
		{
			FlxG.sound.playMusic(Paths.music(song), 0);
			FlxG.sound.music.fadeIn(2, 0, 1);
		}

		bgFade = new FlxSprite(-500, -500).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.WHITE);
		bgFade.scrollFactor.set();
		bgFade.visible = true;
		bgFade.alpha = 0;
		add(bgFade);

		this.dialogueList = dialogueList;

		boxGroup = new FlxSpriteGroup(0, 0);
		add(boxGroup);

		spawnCharacters();

		rgbShader = new RGBPalette();
		box = new FlxSprite(0, 0).loadGraphic(Paths.image('dialogueImpostor/dialogueBox'));
		box.scrollFactor.set();
		box.screenCenter();
		box.y += 257;
		box.alpha = 0;
		box.shader = rgbShader.shader;

		boxBack = new FlxSprite(box.x, box.y).loadGraphic(Paths.image('dialogueImpostor/dialogueBoxBack'));
		boxBack.scrollFactor.set();
		boxBack.alpha = 0;

		boxGroup.add(boxBack);
		boxGroup.add(box);

		daText = new TypedAlphabet(DEFAULT_TEXT_X, DEFAULT_TEXT_Y, '');
		daText.setScale(0.7);
		boxGroup.add(daText);

		swagDialogue = new FlxTypeText(bubble.x + 100, bubble.y + 50, Std.int(bubble.width * 0.8), "", 26);
		swagDialogue.setFormat(Paths.font("liber.ttf"), 26, FlxColor.BLACK, LEFT);
		boxGroup.add(swagDialogue);

		skipText = new FlxText(FlxG.width - 320, FlxG.height - 30, 300, Language.getPhrase('dialogue_skip', 'Press BACK to Skip'), 16);
		skipText.setFormat(null, 16, FlxColor.WHITE, RIGHT, OUTLINE_FAST, FlxColor.BLACK);
		skipText.borderSize = 2;
		boxGroup.add(skipText);

		startNextDialog();
	}

	var dialogueStarted:Bool = false;
	var dialogueEnded:Bool = false;
	var isEnding:Bool = false;

	public static var LEFT_CHAR_X:Float = -60;
	public static var RIGHT_CHAR_X:Float = -100;
	public static var DEFAULT_CHAR_Y:Float = 60;

	function spawnCharacters()
	{
		var charsMap:Map<String, Bool> = new Map<String, Bool>();
		for (dialogue in dialogueList.dialogue)
		{
			if(dialogue != null)
			{
				var charToAdd:String = dialogue.portrait;
				if(!charsMap.exists(charToAdd) || !charsMap.get(charToAdd))
					charsMap.set(charToAdd, true);
			}
		}

		for (individualChar in charsMap.keys())
		{
			var x:Float = LEFT_CHAR_X;
			var y:Float = DEFAULT_CHAR_Y;
			var char:DialogueCharacterImpostor = new DialogueCharacterImpostor(x + offsetPos, y, individualChar);
			char.scrollFactor.set();
			char.alpha = 0.00001;
			boxGroup.add(char);

			var saveY:Bool = false;
			switch(char.jsonFile.dialogue_pos)
			{
				case 'center':
					char.x = FlxG.width / 2;
					char.x -= char.width / 2;
					y = char.y;
					char.y = FlxG.height + 50;
					saveY = true;
				case 'right':
					x = FlxG.width - char.width + RIGHT_CHAR_X;
					char.x = x - offsetPos;
			}
			x += char.jsonFile.position[0];
			y += char.jsonFile.position[1];
			char.x += char.jsonFile.position[0];
			char.y += char.jsonFile.position[1];
			char.startingPos = (saveY ? y : x);
			arrayCharacters.push(char);
		}
	}

	var daText:TypedAlphabet = null;
	var ignoreThisFrame:Bool = true; //First frame is reserved for loading dialogue images

	public var closeSound:String = 'dialogueClose';
	public var closeVolume:Float = 1;
	override function update(elapsed:Float)
	{
		if(ignoreThisFrame)
		{
			ignoreThisFrame = false;
			super.update(elapsed);
			return;
		}

		if(!dialogueEnded)
		{
			bgFade.alpha += 0.35 * elapsed;
			if(bgFade.alpha > 0.35) bgFade.alpha = 0.35;

			if(Controls.instance.ACCEPT || Controls.instance.BACK)
			{
				if(swagDialogue._typing && !Controls.instance.BACK)
				{
					swagDialogue.skip();
					daText.finishText();
					if(skipDialogueThing != null)
						skipDialogueThing();
				}
				else if(Controls.instance.BACK || currentText >= dialogueList.dialogue.length)
				{
					dialogueEnded = true;
					if(daText != null)
					{
						daText.kill();
						remove(daText);
						daText.destroy();
					}
					skipText.visible = false;
					FlxG.sound.music.fadeOut(1, 0, (_) -> FlxG.sound.music.stop());
					FlxTween.tween(boxGroup, {y: boxGroup.y + 500}, 0.25, {ease: FlxEase.circIn});
				}
				else startNextDialog();
				FlxG.sound.play(Paths.sound(closeSound), closeVolume);
			}
			else if(!swagDialogue._typing)
			{
				var char:DialogueCharacterImpostor = arrayCharacters[lastCharacter];
				if(char != null && !char.isAnimationNull() && char.isAnimationFinished() && !char.animationIsLoop())
					char.playAnim(char.getAnimationName(), true, true);
			}
			else
			{
				var char:DialogueCharacterImpostor = arrayCharacters[lastCharacter];
				if(char != null && !char.isAnimationNull() && char.isAnimationFinished())
					char.animation.curAnim.restart();
			}

			if(lastCharacter != -1 && arrayCharacters.length > 0)
			{
				for (i => char in arrayCharacters)
				{
					if(char != null)
					{
						if(i != lastCharacter)
						{
							switch(char.jsonFile.dialogue_pos)
							{
								case 'left':
									char.x -= scrollSpeed * elapsed;
									if(char.x < char.startingPos + offsetPos) char.x = char.startingPos + offsetPos;
								case 'center':
									char.y += scrollSpeed * elapsed;
									if(char.y > char.startingPos + FlxG.height) char.y = char.startingPos + FlxG.height;
								case 'right':
									char.x += scrollSpeed * elapsed;
									if(char.x > char.startingPos - offsetPos) char.x = char.startingPos - offsetPos;
							}
							char.alpha -= 3 * elapsed;
							if(char.alpha < 0.00001) char.alpha = 0.00001;
						}
						else
						{
							switch(char.jsonFile.dialogue_pos)
							{
								case 'left':
									char.x += scrollSpeed * elapsed;
									if(char.x > char.startingPos) char.x = char.startingPos;
								case 'center':
									char.y -= scrollSpeed * elapsed;
									if(char.y < char.startingPos) char.y = char.startingPos;
								case 'right':
									char.x -= scrollSpeed * elapsed;
									if(char.x < char.startingPos) char.x = char.startingPos;
							}
							char.alpha += 3 * elapsed;
							if(char.alpha > 1) char.alpha = 1;
						}
					}
				}
			}
		}
		else //Dialogue ending
		{
			if(box != null)
			{
				box.kill();
				remove(box);
				box.destroy();
				box = null;
			}

			if(boxBack != null)
			{
				boxBack.kill();
				remove(boxBack);
				boxBack.destroy();
				boxBack = null;
			}

			if(bgFade != null)
			{
				bgFade.alpha -= 0.5 * elapsed;
				if(bgFade.alpha <= 0)
				{
					bgFade.kill();
					remove(bgFade);
					bgFade.destroy();
					bgFade = null;
				}
			}

			if(box == null && boxBack == null && bgFade == null)
			{
				for (leChar in arrayCharacters)
				{
					if(leChar != null)
					{
						arrayCharacters.remove(leChar);
						leChar.kill();
						remove(leChar);
						leChar.destroy();
					}
				}
				if(finishThing != null) finishThing();
				kill();
			}
		}
		super.update(elapsed);
	}

	var lastCharacter:Int = -1;
	function startNextDialog():Void
	{
		var curDialogue:DialogueLine = null;
		do
		{
			curDialogue = dialogueList.dialogue[currentText];
		}
		while(curDialogue == null);

		switch(getSpeaker(curDialogue.speaker))
		{
			case LEFT:
				// change left char
				lastCharacter = 0;
			case MIDDLE:
				// change middle char
				lastCharacter = 1;
			case RIGHT:
				// change right char
				lastCharacter = 2;
		}

		if(curDialogue.text == null || curDialogue.text.length < 1) curDialogue.text = ' ';
		if(curDialogue.speed == null || Math.isNaN(curDialogue.speed)) curDialogue.speed = 0.05;

		var character:Int = 0;
		box.visible = boxBack.visible = true;
		for (i => char in arrayCharacters)
		{
			if(char.curCharacter == curDialogue.portrait)
			{
				character = i;
				break;
			}
		}

		daText.text = curDialogue.text;
		daText.delay = curDialogue.speed;
		daText.sound = curDialogue.sound;
		if(daText.sound == null || daText.sound.trim() == '') daText.sound = 'dialogue';

		daText.y = DEFAULT_TEXT_Y;
		if(daText.rows > 2) daText.y -= LONG_TEXT_ADD;

		var char:DialogueCharacterImpostor = arrayCharacters[character];
		if(char != null)
		{
			char.playAnim(curDialogue.expression, daText.finishedText);
			if(char.animation.curAnim != null)
			{
				var rate:Float = 24 - (((curDialogue.speed - 0.05) / 5) * 480);
				if(rate < 12) rate = 12;
				else if(rate > 48) rate = 48;
				char.animation.curAnim.frameRate = rate;
			}
		}
		currentText++;

		if(nextDialogueThing != null)
			nextDialogueThing();
	}

	public function getSpeaker(who:String):Speaker
	{
		switch(who.toLowerCase().trim())
		{
			case 'left': return LEFT;
			case 'middle': return MIDDLE;
			default: return RIGHT;
		}
	}

	inline public static function parseDialogue(path:String):DialogueFile
	{
		#if MODS_ALLOWED
		return cast (FileSystem.exists(path)) ? Json.parse(File.getContent(path)) : dummy();
		#else
		return cast (Assets.exists(path, TEXT)) ? Json.parse(Assets.getText(path)) : dummy();
		#end
	}

	inline public static function dummy():DialogueFile
	{
		return {
			dialogue: [
				{
					position: "right",
					portrait: "bf",
					expression: "neutral",
					text: "DIALOGUE NOT FOUND",
					speed: 0.05
				}
			]
		};
	}
}
package cutscenes;

import objects.HealthIcon;
import shaders.RGBPalette;

import flixel.addons.text.FlxTypeText;

// bro, i'm definitely remaking this similar to the psych dialogue, dear god    - DM
class DialogueBoxImpostor extends FlxSpriteGroup
{
	var boxGroup:FlxSpriteGroup;
	var box:FlxSprite;

	var curCharacter:String = '';
	var boxChar:String = '';
	var curEmote:String = '';
	var curSound:String = '';
	var curIcon:String = '';
	var charOff:Map<String, Array<Dynamic>>;
	var diasong:String = PlayState.SONG.song.toLowerCase();
	var speaker:FlxSprite;

	// var dialogue:Alphabet;
	var dialogueList:Array<String> = [];

	// This codes a mess im sorry to anyone who knows what they're actually doing
	var swagDialogue:FlxTypeText;

	var dropText:FlxText;
	var OldDropText:FlxText;
	var OldDText:FlxText;

	public var finishThing:Void->Void;
	
	public var nextDialogueThing:Void->Void = null;
	public var skipDialogueThing:Void->Void = null;
	
	var dialogueOpened:Bool = false;
	var dialogueStarted:Bool = false;
	var dialogueEnded:Bool = false;
	var isEnding:Bool = false;

	var portraitBubble:FlxSprite;
	var bubble2:FlxSprite;

	var portraitLeft:FlxSprite;
	var portraitRight:FlxSprite;
	var portraitMid:FlxSprite;

	var iconYea:HealthIcon;
	var OiconYea:HealthIcon;

	var bgFade:FlxSprite;

	public function new(talkingRight:Bool = true, ?dialogueList:Array<String>)
	{
		super();

		charOff = new Map<String, Array<Dynamic>>();
		bgFade = new FlxSprite(-200, -200).makeGraphic(Std.int(FlxG.width * 1.3), Std.int(FlxG.height * 1.3), 0xFFFFFFFF);
		bgFade.scrollFactor.set();
		bgFade.alpha = 0;
		add(bgFade);

		FlxTween.tween(bgFade, { alpha: 0.35}, 0.8, { ease: FlxEase.circIn });

		boxGroup = new FlxSpriteGroup(0, 0);
		add(boxGroup);

		box = new FlxSprite(260.1, 431.45);
		portraitBubble = new FlxSprite(355.85, 495.55).loadGraphic(Paths.image('dialogueV4/bubble', 'impostor'));
		bubble2 = new FlxSprite(355.85, 616.35).loadGraphic(Paths.image('dialogueV4/bubble', 'impostor'));

		var hasDialog = false;

		// this fucking sucks
		hasDialog = true;
		box.frames = Paths.getSparrowAtlas('dialogueV4/dialogueBox', 'impostor');
		final charBoxes:Array<String> = ['bf', 'gf', 'red', 'gc', 'gi', 'y', 'wi', 'maroon', 'grey', 'pink', 'pi', 'war', 'jelq'];
		for(i => char in charBoxes) box.animation.addByIndices(char, 'dialog frame', [i], "", 24);

		this.dialogueList = dialogueList;

		// if (!hasDialog)
			// return;

		portraitMid = new FlxSprite(206.85, 148.15);
		portraitMid.y = portraitMid.y + 50;
		portraitMid.frames = Paths.getSparrowAtlas('dialogueV4/gf', 'impostor');

		portraitMid.updateHitbox();
		portraitMid.scrollFactor.set();

		boxGroup.add(portraitMid);

		portraitMid.screenCenter(X);
		
		portraitMid.visible = false;
		portraitMid.alpha = 0;

		//portrait left
		portraitLeft = new FlxSprite(246.85, 251.35); portraitLeft.x = portraitLeft.x - 50;
		portraitLeft.updateHitbox();
		portraitLeft.scrollFactor.set();
		boxGroup.add(portraitLeft);

		portraitLeft.visible = false;
		portraitLeft.alpha = 0;

		//portrait right
		portraitRight = new FlxSprite(864.75+50, 216.3); portraitRight.x = portraitRight.x + 50;
		portraitRight.updateHitbox();
		portraitRight.scrollFactor.set();

		boxGroup.add(portraitRight);
		portraitRight.visible = false;
		portraitRight.alpha = 0;

		box.updateHitbox();
		boxGroup.add(box);
		boxGroup.add(portraitBubble);
		boxGroup.add(bubble2);
		box.screenCenter(X);
		portraitBubble.screenCenter(X);
		portraitBubble.x += 18.5; // fuck it

		bubble2.screenCenter(X);
		bubble2.x += 18.5; // fuck it

		iconYea = new HealthIcon('impostor', false);
		iconYea.x = 325-91;	
		iconYea.y = portraitBubble.getMidpoint().y-63.5;//495.55;
		iconYea.setGraphicSize(Std.int(iconYea.width * 0.8));
		iconYea.updateHitbox();
		boxGroup.add(iconYea);

		OiconYea = new HealthIcon('impostor', false);
		OiconYea.x = 325-91;	
		OiconYea.y = (portraitBubble.getMidpoint().y-63.5)+120.8;//495.55;
		OiconYea.setGraphicSize(Std.int(OiconYea.width * 0.8));
		OiconYea.updateHitbox();
		boxGroup.add(OiconYea);
		//portraitLeft.screenCenter(X);

		var textX:Float = 350; //325.85
		OldDropText = new FlxText(textX, 622.65-9, Std.int(FlxG.width * 0.6), "", 28);
		OldDropText.setFormat(Paths.font("liberbold.ttf"), 30, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		OldDropText.borderSize = 3;
		boxGroup.add(OldDropText);

		dropText = new FlxText(textX, 502.7-9, Std.int(FlxG.width * 0.6), "", 28);

		dropText.setFormat(Paths.font("liberbold.ttf"), 30, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		dropText.borderSize = 3;
		boxGroup.add(dropText);

		OldDText = new FlxText(textX, 671.05-21, Std.int(FlxG.width * 0.6), "", 28);
		OldDText.setFormat(Paths.font("liber.ttf"), 26, FlxColor.BLACK, LEFT);
		//swagDialogue.font = 'LiberationSans Regular';
		OldDText.color = 0xFF000000;

		boxGroup.add(OldDText);

		swagDialogue = new FlxTypeText(textX, 544.95-15, Std.int(FlxG.width * 0.6), "", 28);

		swagDialogue.setFormat(Paths.font("liber.ttf"), 26, FlxColor.BLACK, LEFT);
		//swagDialogue.font = 'LiberationSans Regular';
		swagDialogue.color = 0xFF000000;

		boxGroup.add(swagDialogue);

		// this was always here idk why
		// dialogue = new Alphabet(0, 80, "", false, true);
		// dialogue.x = 90;
		// add(dialogue);
	}

	override function update(elapsed:Float)
	{
		// this is a really bad idea, oh well
		dialogueOpened = true;

		dropText.text = boxChar;

		if(OldDropText.text != "")
		{
			bubble2.alpha = 1;
			OiconYea.alpha = 1;
		}
		else
		{
			bubble2.alpha = 0;
			OiconYea.alpha = 0;
		}

		if (dialogueOpened && !dialogueStarted)
		{
			startDialogue();
			dialogueStarted = true;
			trace('dialogue started');
			FlxG.sound.playMusic(Paths.music('dialogue/' + diasong), 0);
			FlxG.sound.music.fadeIn(1, 0, 0.8);
		}

		if(Controls.instance.ACCEPT)
		{
			if (dialogueEnded)
			{
				// remove(dialogue);
				if (dialogueList[1] == null && dialogueList[0] != null)
				{
					if (!isEnding)
					{
						isEnding = true;
						FlxG.sound.music.stop();//fadeOut(1.5, 0);

						var ThisTime:Float = 0.25;
						// IDK WHAT THE FUCK IM DOING
						FlxG.sound.play(Paths.sound('panelDisappear'), 0.5);
						FlxTween.tween(boxGroup, { y: boxGroup.y+500}, ThisTime, { ease: FlxEase.circIn });
						/*
						FlxTween.tween(portraitBubble, { y: portraitBubble.y+500}, ThisTime, { ease: FlxEase.circIn });
						FlxTween.tween(OldDropText, { y: OldDropText.y+500}, ThisTime, { ease: FlxEase.circIn });
						FlxTween.tween(OldDText, { y: OldDText.y+500}, ThisTime, { ease: FlxEase.circIn });
						FlxTween.tween(dropText, { y: dropText.y+500}, ThisTime, { ease: FlxEase.circIn });
						FlxTween.tween(portraitLeft, { y: portraitLeft.y+500}, ThisTime, { ease: FlxEase.circIn });
						FlxTween.tween(portraitRight, { y: portraitRight.y+500}, ThisTime, { ease: FlxEase.circIn });
						FlxTween.tween(portraitMid, { y: portraitRight.y+500}, ThisTime, { ease: FlxEase.circIn });
						FlxTween.tween(box, { y: box.y+500}, ThisTime, { ease: FlxEase.circIn });
						FlxTween.tween(swagDialogue, { y: swagDialogue.y+500}, ThisTime, { ease: FlxEase.circIn });
						FlxTween.tween(iconYea, { y: iconYea.y+500}, ThisTime, { ease: FlxEase.circIn });
						FlxTween.tween(OiconYea, { y: OiconYea.y+500}, ThisTime, { ease: FlxEase.circIn });*/
						FlxTween.tween(bgFade, { alpha: 0}, ThisTime, {
							ease: FlxEase.circIn, onComplete: function(twn:FlxTween)
								{
									kill();
								}
							});

						finishThing();

					}
				}
				else
				{
					dialogueList.remove(dialogueList[0]);
					startDialogue();
					FlxG.sound.play(Paths.sound('clickText'), 0.8);
				}
			}
			else if (dialogueStarted)
			{
				swagDialogue.skip();

				if(skipDialogueThing != null)
					skipDialogueThing();
			}
		}

		super.update(elapsed);
	}

	function startDialogue():Void
	{
		cleanDialog();

		swagDialogue.resetText(dialogueList[0]);
		swagDialogue.start(0.05, true);
		swagDialogue.completeCallback = function()
		{
			dialogueEnded = true;
			animPlay(speaker, curEmote);
		};

		dialogueEnded = false;

		if(nextDialogueThing != null)
			nextDialogueThing();
	}

	function Dinnit():Void
	{
		// this gotta be the worst code in history
		box.animation.play(curCharacter);

		speaker = portraitLeft;
		boxChar = "Red";
		curIcon = curCharacter;
		curSound = "red";

		switch(curCharacter) {				
			case 'red':
				if(diasong == 'meltdown') curIcon = 'impostor2';
				else curIcon = 'impostor';
				portraitLeft.frames = Paths.getSparrowAtlas('dialogueV4/red', 'impostor');

			case 'gc':
				curIcon = 'crewmate';
				boxChar = 'Green';
				portraitLeft.frames = Paths.getSparrowAtlas('dialogueV4/green', 'impostor');

			case 'y':
				curIcon = 'yellow';
				boxChar = 'Yellow';
				portraitLeft.frames = Paths.getSparrowAtlas('dialogueV4/yellow', 'impostor');

			case 'wi':
				curIcon = 'white';
				boxChar = 'White';
				portraitLeft.frames = Paths.getSparrowAtlas('dialogueV4/white', 'impostor');

			case 'gi':
				curIcon = 'impostor3';
				boxChar = 'Green';
				portraitLeft.frames = Paths.getSparrowAtlas('dialogueV4/green', 'impostor');

			case 'maroon':
				curIcon = 'maroon';
				boxChar = 'Maroon';
				portraitLeft.frames = Paths.getSparrowAtlas('dialogueV4/maroon', 'impostor');

			case 'pink':
				curIcon = 'pink';
				boxChar = 'Pink';
				portraitLeft.frames = Paths.getSparrowAtlas('dialogueV4/pink', 'impostor');

			case 'pi':
				curIcon = 'pink';
				boxChar = 'Pink';
				portraitRight.frames = Paths.getSparrowAtlas('dialogueV4/pretendpink', 'impostor');

			case 'grey':
				curIcon = 'gray';
				boxChar = 'Grey';
				portraitLeft.frames = Paths.getSparrowAtlas('dialogueV4/grey', 'impostor');

			case 'bf':
				speaker = portraitRight;
				boxChar = 'Boyfriend';
				curSound = "bf";
				portraitRight.frames = Paths.getSparrowAtlas('dialogueV4/boyfriend', 'impostor');

			case 'gf':
				curSound = "gf";
				speaker = portraitMid;
				boxChar = 'Girlfriend';

			default:
				// nothing
		}

		swagDialogue.sounds = [FlxG.sound.load(Paths.sound(curSound + 'D'), 0.6)];
		trace('Play anim!');
		animPlay(speaker, curEmote + "T");
		//speaker.animation.play(curEmote + "T", false);

		if(!speaker.visible)
		{
			speaker.visible = true;
			if(speaker == portraitRight) FlxTween.tween(speaker, {alpha: 1, x: 864.75}, 0.5, {ease: FlxEase.quadInOut});
			if(speaker == portraitLeft) FlxTween.tween(speaker, {alpha: 1, x: 246.85}, 0.5, {ease: FlxEase.quadInOut});
			if(speaker == portraitMid) FlxTween.tween(speaker, {alpha: 1, y: 148.15}, 0.5, {ease: FlxEase.quadInOut});
		}	
	}

	function cleanDialog():Void
	{
		OldDropText.text = dropText.text;
		OldDText.text = swagDialogue.text;
		OiconYea.changeIcon(curIcon);
		var splitName:Array<String> = dialogueList[0].split(":");
		trace(splitName);
		curCharacter = splitName[1]; // idk
		curEmote = splitName[2]; // emote

		dialogueList[0] = dialogueList[0].substr(splitName[1].length + 3 + splitName[2].length).trim();

		// nothing beats duct tape
		if(dialogueList[0] == '') dialogueList[0] = ' ';
		curSound = curCharacter;

		Dinnit();

		iconYea.changeIcon(curIcon);
	}
}
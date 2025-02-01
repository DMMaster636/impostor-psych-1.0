package states.stages;

import shaders.ColorShader;
import states.HenryState;

class AirshipCockpit extends BaseStage
{
	var whiteAwkward:BGSprite;

	var canPress:Bool = true;
	var henryTeleporter:FlxSpriteButton;

	override function create()
	{
		Paths.sound('teleport_sound');

		camOffset = 20;

		var sky:BGSprite = new BGSprite('airship/newAirship/fartingSky', -1468, -995, 0.3, 0.3);
		add(sky);

		var farCloud:BGSprite = new BGSprite('airship/newAirship/backSkyyellow', -1125, 284, 0.4, 0.7);
		add(farCloud);

		var cloud3:BGSprite = new BGSprite('airship/newAirship/yellow cloud 3', 1330, 283, 0.5, 0.8);
		add(cloud3);

		var cloud2:BGSprite = new BGSprite('airship/newAirship/yellow could 2', -837, 304, 0.6, 0.9);
		add(cloud2);

		var cloud1:BGSprite = new BGSprite('airship/newAirship/cloudYellow 1', -1541, 242, 0.8, 0.8);
		add(cloud1);

		var window:BGSprite = new BGSprite('airship/newAirship/window', -1387, -1231, 1, 1);
		add(window);

		var backFloor:BGSprite = new BGSprite('airship/newAirship/backDlowFloor', -642, 325, 0.9, 1);
		add(backFloor);

		var floor:BGSprite = new BGSprite('airship/newAirship/DlowFloor', -2440, 336, 1, 1);
		add(floor);

		var glow:BGSprite = new BGSprite('airship/newAirship/DlowFloor', -1113, -1009, 1, 1);
		glow.blend = ADD;
		add(glow);

		if (songName != 'oversight')
		{
			whiteAwkward = new BGSprite('airship/newAirship/white_awkward', 298, 480, 1, 1);
			whiteAwkward.frames = Paths.getSparrowAtlas('airship/newAirship/white_awkward');
			whiteAwkward.animation.addByPrefix('sweat', 'fetal position', 24, true);
			whiteAwkward.animation.addByPrefix('stare', 'white stare', 24, false);
			whiteAwkward.animation.play('sweat', true);
			add(whiteAwkward);

			if (isStoryMode)
			{
				henryTeleporter = new FlxSpriteButton(998, 620, function()
				{
					if(!canPress) return;
					henryTeleport();
				});
				henryTeleporter.loadGraphic(Paths.image('airship/newAirship/Teleporter', 'impostor'));
				henryTeleporter.scrollFactor.set(1, 1);
				add(henryTeleporter);
			}
		}
	}

	override function startSong() defaultCamZoom -= 0.1;

	function henryTeleport()
	{
		inCutscene = true;
		canPause = canPress = false;

		game.KillNotes();

		game.vocals.volume = 0;
		game.vocals.pause();
		FlxTween.tween(FlxG.sound.music, {volume: 0}, 5, {ease: FlxEase.expoOut});

		var colorShader:ColorShader = new ColorShader(0);
		boyfriend.shader = henryTeleporter.shader = colorShader.shader;

		FlxTween.tween(camHUD, {alpha: 0}, 0.7, {ease: FlxEase.quadInOut});

		game.triggerEvent('Camera Follow Pos', '750', '500');
		game.stopEvents = true;

		dad.setPosition(-240, 175);
		dad.playAnim('first', true);
		dad.specialAnim = true;

		FlxG.sound.play(Paths.sound('teleport_sound'), 1);

		new FlxTimer().start(0.45, function(tmr:FlxTimer)
		{
			colorShader.amount = 1;
			FlxTween.tween(colorShader, {amount: 0}, 0.73, {ease: FlxEase.expoOut});
			// dad.stunned = true;
		});

		/*new FlxTimer().start(1.25, function(tmr:FlxTimer)
		{
			FlxTween.tween(colorShader, {amount: 1}, 2.25, {ease: FlxEase.expoOut});
		});*/

		new FlxTimer().start(1.28, function(tmr:FlxTimer)
		{
			colorShader.amount = 1;
			gf.shader = colorShader.shader;
			// pet.shader = colorShader.shader;
			FlxTween.tween(colorShader, {amount: 0.1}, 0.55, {ease: FlxEase.expoOut});
		});

		new FlxTimer().start(1.93, function(tmr:FlxTimer)
		{
			colorShader.amount = 1;
			FlxTween.tween(colorShader, {amount: 0.2}, 0.2, {ease: FlxEase.expoOut});
			dad.playAnim('second', true);
			dad.specialAnim = true;
		});

		new FlxTimer().start(2.23, function(tmr:FlxTimer)
		{
			colorShader.amount = 1;
			FlxTween.tween(colorShader, {amount: 0.4}, 0.22, {ease: FlxEase.expoOut});
		});
		new FlxTimer().start(2.55, function(tmr:FlxTimer)
		{
			colorShader.amount = 1;
			FlxTween.tween(colorShader, {amount: 0.8}, 0.05, {ease: FlxEase.expoOut});
		});

		new FlxTimer().start(2.7, function(tmr:FlxTimer)
		{
			colorShader.amount = 1;
			FlxTween.tween(boyfriend, {'scale.x': 3.5, 'scale.y': 0}, 0.7, {ease: FlxEase.expoOut});
			FlxTween.tween(henryTeleporter, {'scale.x': 3.5, 'scale.y': 0}, 0.7, {ease: FlxEase.expoOut});
		});

		/*new FlxTimer().start(2.75, function(tmr:FlxTimer)
		{
			FlxTween.tween(pet, {'scale.x': 3.5, 'scale.y': 0}, 0.7, {ease: FlxEase.expoOut});
		});*/

		new FlxTimer().start(2.8, function(tmr:FlxTimer)
		{
			FlxTween.tween(gf, {'scale.x': 3.5, 'scale.y': 0}, 0.7, {ease: FlxEase.expoOut});
		});

		new FlxTimer().start(2.9, function(tmr:FlxTimer)
		{
			whiteAwkward.animation.play('stare', true);
			dad.playAnim('third', true);
			dad.specialAnim = true;
		});

		new FlxTimer().start(4.5, function(tmr:FlxTimer)
		{
			FlxG.camera.fade(FlxColor.BLACK, 1.4, false, function()
			{
				MusicBeatState.switchState(new HenryState());
			}, true);
		});
	}
}
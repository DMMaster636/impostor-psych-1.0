package states.stages;

import substates.GameOverSubstate;

class AirshipOutside extends BaseStage
{
	var platforms:FlxSpriteGroup;
	var farClouds:FlxSpriteGroup;
	var midClouds:FlxSpriteGroup;
	var closeClouds:FlxSpriteGroup;
	var speedlines:FlxSpriteGroup;

	var bigCloud:BGSprite;
	var bigCloudSpeed:Float = 10;

	var flash:BGSprite;

	override function create()
	{
		FlxG.camera.height += 200;
		FlxG.camera.y -= 100;
		camOther.height += 200;
		camOther.y -= 100;

		// bare bones fix for seeing oob    - DM-kun
		var barUp:FlxSprite = new FlxSprite(0, -100).makeGraphic(FlxG.width, 200, FlxColor.BLACK);
		var barDown:FlxSprite = new FlxSprite(0, FlxG.height + 100).makeGraphic(FlxG.width, 200, FlxColor.BLACK);
		barUp.cameras = barDown.cameras = [camOther];
		add(barUp); add(barDown);

		GameOverSubstate.characterName = 'bf-running-death';

		camOffset = 50;

		//platforms = new FlxSpriteGroup();
		farClouds = new FlxSpriteGroup();
		midClouds = new FlxSpriteGroup();
		closeClouds = new FlxSpriteGroup();
		speedlines = new FlxSpriteGroup();

		var sky:BGSprite = new BGSprite('airship/sky', -1404, -897.55, 0, 0);
		sky.updateHitbox();
		sky.scale.set(1.5, 1.5);
		add(sky);

		for(i in 0...2)
		{
			var cloud:BGSprite = new BGSprite('airship/farthestClouds', -1148.05, -142.2, 0.1, 0.1);
			switch(i)
			{
				case 1: cloud.setPosition(-5678.95, -142.2);
				case 2: cloud.setPosition(3385.95, -142.2);
			}
			farClouds.add(cloud);
		}
		add(farClouds);

		for(i in 0...2)
		{
			var cloud:BGSprite = new BGSprite('airship/backClouds', -1162.4, 76.55, 0.2, 0.2);
			switch(i)
			{
				case 1: cloud.setPosition(3352.4, 76.55);
				case 2: cloud.setPosition(-5651.4, 76.55);
			}
			midClouds.add(cloud);
		}
		add(midClouds);

		var airship:BGSprite = new BGSprite('airship/airship', 1114.75, -873.05, 0.25, 0.25);
		add(airship);

		var fan:BGSprite = new BGSprite('airship/airshipFan', 2285.4, 102, 0.27, 0.27, ['ala avion instance 1'], true);
		add(fan);

		bigCloud = new BGSprite('airship/bigCloud', 3507.15, -744.2, 0.4, 0.4);
		add(bigCloud);

		for(i in 0...2)
		{
			var cloud:BGSprite = new BGSprite('airship/frontClouds', -1903.9, 422.15, 0.3, 0.3);
			switch(i)
			{
				case 1: cloud.setPosition(-9900.2, 422.15);
				case 2: cloud.setPosition(6092.2, 422.15);
			}
			closeClouds.add(cloud);
		}
		add(closeClouds);

		var platform:FlxBackdrop = new FlxBackdrop(Paths.image('airship/fgPlatform'), X, -436, 0);
		platform.setPosition(-1454.2, 282.25);
		platform.scrollFactor.set(1, 1);
		platform.velocity.set(-4000, 0);
		add(platform);

		/*for(i in 0...2)
		{
			var platform:BGSprite = new BGSprite('airship/fgPlatform', -1454.2, 282.25, 1, 1);
			switch(i)
			{
				case 1: platform.setPosition(-7184.8, 282.25);
				case 2: platform.setPosition(4275.15, 282.25);
			}
			add(platform);
			platforms.add(platform);
		}*/

		flash = new BGSprite('airship/screamsky', 0, -300, 1, 1, ['scream sky  instance 1']);
		flash.setGraphicSize(Std.int(flash.width * 3));
		add(flash);
		flash.alpha = 0;
	}

	override function createPost()
	{
		for(i in 0...2)
		{
			var speedline:BGSprite = new BGSprite('airship/speedlines', -912.75, -1035.95, 1.3, 1.3);
			switch(i)
			{
				case 1: speedline.setPosition(-3352.1, -1035.95);
				case 2: speedline.setPosition(5140.05, -1035.95);
			}
			speedline.alpha = 0.2;
			add(speedline);
			speedlines.add(speedline);
		}
	}

	override function update(elapsed:Float)
	{
		FlxG.camera.shake(0.0008, 0.01);
		FlxG.camera.y = Math.sin((Conductor.songPosition / 280) * (Conductor.bpm / 60) * 1.0) * 2 - 100;
		camHUD.y = Math.sin((Conductor.songPosition / 300) * (Conductor.bpm / 60) * 1.0) * 0.6;
		camHUD.angle = Math.sin((Conductor.songPosition / 350) * (Conductor.bpm / 60) * -1.0) * 0.6;

		if(closeClouds != null && closeClouds.members.length > 0)
		{
			for(cloud in closeClouds)
			{
				cloud.x = FlxMath.lerp(cloud.x, cloud.x - 50, FlxMath.bound(elapsed * 9 * game.playbackRate, 0, 1));
				if(cloud.x < -10400.2) cloud.x = 5582.2;
			}
		}

		if(midClouds != null && midClouds.members.length > 0)
		{
			for(cloud in midClouds)
			{
				cloud.x = FlxMath.lerp(cloud.x, cloud.x - 13, FlxMath.bound(elapsed * 9 * game.playbackRate, 0, 1));
				if(cloud.x < -6153.4) cloud.x = 2852.4;
			}
		}

		if(speedlines != null && speedlines.members.length > 0)
		{
			for(line in speedlines)
			{
				line.x = FlxMath.lerp(line.x, line.x - 350, FlxMath.bound(elapsed * 9 * game.playbackRate, 0, 1));
				if(line.x < -5140.05) line.x = 3352.1;
			}
		}

		if(farClouds != null && farClouds.members.length > 0)
		{
			for(cloud in farClouds)
			{
				cloud.x = FlxMath.lerp(cloud.x, cloud.x - 7, FlxMath.bound(elapsed * 9 * game.playbackRate, 0, 1));
				if(cloud.x < -6178.95) cloud.x = 2874.95;
			}
		}

		/*if(platforms != null && platforms.members.length > 0)
		{
			for(platform in platforms)
			{
				platform.x = FlxMath.lerp(platform.x, platform.x - 300, FlxMath.bound(elapsed * 9 * game.playbackRate, 0, 1));
				if(platform.x < -7184.8) platform.x = 4275.15;
			}
		}*/

		if(bigCloud != null)
		{
			bigCloud.x = FlxMath.lerp(bigCloud.x, bigCloud.x - bigCloudSpeed, FlxMath.bound(elapsed * 9 * game.playbackRate, 0, 1));
			if(bigCloud.x < -4163.7)
			{
				bigCloud.setPosition(FlxG.random.float(3931.5, 4824.05), FlxG.random.float(-1087.5, -307.35));
				bigCloudSpeed = FlxG.random.float(7, 15);
			}
		}
	}
}
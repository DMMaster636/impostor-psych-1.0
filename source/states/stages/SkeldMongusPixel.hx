package states.stages;

import substates.GameOverSubstate;

class SkeldMongusPixel extends BaseStage
{
	override function create()
	{
		GameOverSubstate.deathSoundName = 'fnf_loss_sfx-pixel';
		GameOverSubstate.loopSoundName = 'gameOver-pixel';
		GameOverSubstate.endSoundName = 'gameOverEnd-pixel';
		GameOverSubstate.characterName = 'bf-pixel-dead';

		camOffset = 10;

		var sky:BGSprite = new BGSprite('skeld/pixel/stars', -200, 0, 0.8, 0.8);
		sky.setGraphicSize(Std.int(sky.width * 6));
		sky.updateHitbox();
		sky.antialiasing = false;
		add(sky);

		var bg:BGSprite = new BGSprite('skeld/pixel/bg', -200, 0, 1, 1);
		bg.setGraphicSize(Std.int(bg.width * 6));
		bg.updateHitbox();
		bg.antialiasing = false;
		add(bg);
	}
}
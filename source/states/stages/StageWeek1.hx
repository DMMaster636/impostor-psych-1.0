package states.stages;

class StageWeek1 extends BaseStage
{
	override function create()
	{
		var bg:BGSprite = new BGSprite('editors/stageback', -600, -200, 0.9, 0.9);
		add(bg);

		var stageFront:BGSprite = new BGSprite('editors/stagefront', -650, 600, 0.9, 0.9);
		stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
		stageFront.updateHitbox();
		add(stageFront);
	}
}
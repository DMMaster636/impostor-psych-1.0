package states.stages;

class OwStage extends BaseStage
{
	override function create()
	{
		camOffset = 10;

		var bg:BGSprite = new BGSprite('killbg', -620, -227, 1, 1);
		add(bg);
	}

	override function opponentNoteHit(note:objects.Note)
	{
		var animName:String = dad.getAnimationName() + '-hit';
		if(boyfriend.hasAnimation(animName))
		{
			boyfriend.playAnim(animName);
			boyfriend.specialAnim = true;
		}
	}
}
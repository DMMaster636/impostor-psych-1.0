package objects;

import backend.animation.PsychAnimationController;

class FlxOffsetSprite extends FlxSprite
{
	public var animOffsets:Map<String, Array<Dynamic>>;

	public function new(x:Float = 0, y:Float = 0)
	{
		super(x, y);

		animation = new PsychAnimationController(this);
		animOffsets = new Map<String, Array<Dynamic>>();
	}

	inline public function isAnimationNull():Bool
		return animation.curAnim == null;

	var _lastPlayedAnimation:String;
	inline public function getAnimationName():String
		return _lastPlayedAnimation;

	public function isAnimationFinished():Bool
	{
		if(isAnimationNull()) return false;
		return animation.curAnim.finished;
	}

	public function finishAnimation():Void
	{
		if(isAnimationNull()) return;
		animation.curAnim.finish();
	}

	public function hasAnimation(anim:String):Bool
		return animOffsets.exists(anim);

	public var animPaused(get, set):Bool;
	private function get_animPaused():Bool
	{
		if(isAnimationNull()) return false;
		return animation.curAnim.paused;
	}
	private function set_animPaused(value:Bool):Bool
	{
		if(isAnimationNull()) return value;
		animation.curAnim.paused = value;
		return value;
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
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

	public function quickAnimAdd(name:String, anim:String)
	{
		animation.addByPrefix(name, anim, 24, false);
	}
}
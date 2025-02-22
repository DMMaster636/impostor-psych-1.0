package objects;

class TaskSong extends FlxSpriteGroup
{
    private var size:Float = 0;
    private var fontSize:Int = 24;
    public function new(x:Float, y:Float, song:String, ?infoNum:Null<Int> = null)
    {
        super(x, y);

        var addToPath:String = '';
        if(infoNum != null) addToPath = '$infoNum';

        var splitText:Array<String> = CoolUtil.coolTextFile(Paths.txt(Paths.formatToSongPath(song) + '/info$addToPath'));
        splitText.resize(2);

        var text:FlxText = new FlxText(0, 0, 0, splitText[0], fontSize);
        text.setFormat(Paths.font("arial.ttf"), fontSize, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        text.updateHitbox();

        var text2:FlxText = new FlxText(0, 30, 0, splitText[1], fontSize);
        text2.setFormat(Paths.font("arial.ttf"), fontSize, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        text2.updateHitbox();

        size = text2.fieldWidth;

        var bg:FlxSprite = new FlxSprite(fontSize / -2, fontSize / -2).makeGraphic(Math.floor(size + fontSize), Std.int(text.height + text2.height + 15), FlxColor.WHITE);
        bg.height = text.height + text2.height;
        bg.alpha = 0.47;

        add(bg);
        add(text);
        add(text2);

        this.x -= size;
        alpha = 0.0001; 
    }

    public function start()
    {
        alpha = 1;
        FlxTween.tween(this, {x: x + size + (fontSize / 2)}, 1, {
            ease: FlxEase.quintInOut,
            onComplete: function(twn:FlxTween) {
                FlxTween.tween(this, {x: x - size - 50}, 1, {
                    ease: FlxEase.quintInOut,
                    startDelay: 2,
                    onComplete: function(twn:FlxTween) {
                        this.destroy();
                    }
                });
            }
        });
    }
}
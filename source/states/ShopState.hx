package states;

import openfl.utils.AssetType;
import openfl.utils.Assets;
import haxe.Json;

import flixel.FlxObject;

import objects.Character;
import objects.Pet;
import objects.HealthIcon;

enum RequirementType
{
    PERCENT95;
    COMPLETED;
}

enum SkinType
{
    BF;
    GF;
    PET;
}

class ShopState extends MusicBeatState
{
    var buttonTween:FlxTween;
    var textTween:FlxTween;

    var connectors:FlxTypedGroup<FlxSprite>;
    var outlines:FlxTypedGroup<FlxSprite>;
    var nodes:FlxTypedGroup<ShopNode>;
    var icons:FlxTypedGroup<FlxSprite>;
    var portraits:FlxTypedGroup<FlxSprite>;
    var overlays:FlxTypedGroup<FlxSprite>;
    var texts:FlxTypedGroup<FlxText>;

    var clickPos:FlxPoint = FlxPoint.get();
    var clickPosScreen:FlxPoint = FlxPoint.get();

    private var camFollow:FlxObject;

    public var camGame:PsychCamera;
    public var camUpper:PsychCamera;

    var isFocused:Bool = false;
    var canUnfocus:Bool = false;
    var focusTarget:FlxPoint = FlxPoint.get(0, 0);
    var focusedNode:ShopNode;

    var beanText:FlxText;

    var panel:FlxSprite;

    var equipbutton:FlxSprite;
    var equipText:FlxText;

    var charName:FlxText;
    var charDesc:FlxText;

    var localBeans:Int;

    /*
        NOTE FOR ANYONE ADDING NODES:
        - first value is the connetction, going from top bottom left and right, which
        determine where the connection to another node will be made
        - the 2nd value is the previous node that it will connect to by name 
        (i.e 'greenp' will connect the node to the greenp node itself)
        - the 3rd value is the name of the current node and will determine the character it represents

        - the 4th value is the price in beans (this serves literally no purpose rn)

        - the 'root' is the starting node

        - the root isnt listed here but can be accessed by connecting to 'root'

        - TODO: expand on this menu with more tabs and shit but ehhhhhh im bored lol ill do it later
        jus saving this here to remember


        okay more shit

        OH AND THE CHARACTER TYPE           \/ - right here
        next four are the name, description, nd the requirements, then if its secret and if it is then u get a description to cover the real one
    */
    var nodeData:Array<Dynamic> = [
        ['bottom', 'root', 'redp', 125, false, 'Red', 'Unlocked by completing the first week.', BF, COMPLETED, ['sussus-moogus', 'sabotage', 'meltdown']],
        ['right', 'redp', 'greenp', 250, false, 'Green', 'Unlocked by completing the second week.', BF, COMPLETED, ['sussus-toogus', 'lights-down', 'ejected']],
        ['right', 'greenp', 'blackp', 450, false, 'Black', "Unlocked by completing the black week", BF, COMPLETED, ['defeat', 'finale'], true, "It's a secret!"],
        ['top', 'blackp', 'amongbf', 400, false, 'Crewmate', "Unlocked by completing all of the main story's songs.", BF, COMPLETED, ['sussus-moogus', 'sabotage', 'meltdown', 'sussus-toogus', 'lights-down', 'ejected', 'mando', 'dlow', 'oversight', 'danger', 'double-kill']],
        ['bottom', 'redp', 'bfg', 200, false, 'Ghost BF', "Unlocked by achieving an accuracy higher than 95% on all of the first week's songs.", BF, PERCENT95, ['sussus-moogus', 'sabotage', 'meltdown']],
        ['right', 'bfg', 'ghostgf', 450, false, 'Ghost GF', "Unlocked by achieving an accuracy higher than 95% on all of the first week's songs.", GF, PERCENT95, ['sussus-moogus', 'sabotage', 'meltdown']],
        ['top', 'root', 'bfpolus', 175, false, 'Polus BF', 'Unlocked by completing the fifth week.', BF, COMPLETED, ['magmatic', 'ashes', 'boiling-point']],
        ['right', 'root', 'dripbf', 225, false, 'Drippypop BF', 'Unlocked by achieving an accuracy higher than 95% on Drippypop.', BF, PERCENT95, ['drippypop']],
        ['right', 'bfpolus', 'bfmira', 225, false, 'Mira BF', 'Unlocked by completing the sixth week.', BF, COMPLETED, ['heartbeat', 'pinkwave', 'pretender']],
        ['left', 'bfpolus', 'bfairship', 200, false, 'Airship BF', 'Unlocked by completing the sixth week.', BF, COMPLETED, ['delusion', 'blackout', 'neurotic']],
        ['right', 'bfmira', 'gfmira', 250, false, 'Mira GF', 'Unlocked by completing the seventh week.', GF, COMPLETED, ['heartbeat', 'pinkwave', 'pretender']],
        ['top', 'bfmira', 'bfsauce', 250, false, 'Chef BF', 'Unlocked by achieving an accuracy higher than 95% on Sauces Moogus.', BF, PERCENT95, ['sauces-moogus']],

        ['top', 'bfpolus', 'gfpolus', 450, false, 'Polus GF', "Unlocked by completing the fifth week.", GF, COMPLETED, ['magmatic', 'ashes', 'boiling-point']],
        ['top', 'gfpolus', 'snowball', 300, false, 'Snowball', "i dont even know man", PET],
        ['right', 'bfsauce', 'ham', 300, false, 'Hammy', "its like a ham but with legs", PET],

        ['bottom', 'bfg', 'dog', 300, false, 'Doggy', "man(?)'s best friend!", PET],
        ['bottom', 'ghostgf', 'frankendog', 300, false, 'Frankendog', "spooky ass dog", PET],

        ['left', 'redp', 'minicrewmate', 300, false, 'Crewmate', "your very own child", PET],
        ['left', 'minicrewmate', 'tomong', 300, false, 'Tomongus', "he's not among us, he's a hamster!", PET],

        ['top', 'bfairship', 'crab', 300, false, 'Bedcrab', "the thing from half life", PET],
        ['left', 'crab', 'ufo', 300, false, 'UFO', "aliens ahh", PET],

        ['left', 'root', 'stick-bf', 375, false, 'Stickmin BF', "Unlocked by completing Henry's week.", BF, COMPLETED, ['titular', 'reinforcements', 'greatest-plan', 'armed'], true, "Someone told me about some broken old device lying around the airship and i dont think anyones cleaned it up yet.\nMight wanna check that out sometime."],
        ['left', 'stick-bf', 'henrygf', 375, false, 'Stickmin GF', "Unlocked by completing Henry's week.", GF, COMPLETED, ['titular', 'reinforcements', 'greatest-plan', 'armed'], true, "..."],

        ['top', 'henrygf', 'stickmin', 300, false, 'H. Stickmin', "a tiny henry?", PET],
        ['left', 'stickmin', 'elliepet', 300, false, 'E. Rose', "and an ellie too!", PET]
    ];

    var root:ShopNode;

    var blockInput:Bool = false;

    override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		persistentUpdate = persistentDraw = true;

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Shopping in the Shop", null);
		#end

        for(i => nodeD in nodeData) nodeD[4] = ClientPrefs.data.boughtArray.contains(nodeD[2]);

        localBeans = ClientPrefs.data.beans;

        FlxG.mouse.visible = true;

        //i dont care
        camGame = initPsychCamera();
        camUpper = new PsychCamera();
        camUpper.bgColor.alpha = 0;
        FlxG.cameras.add(camUpper,false);

        icons = new FlxTypedGroup<FlxSprite>();
        nodes = new FlxTypedGroup<ShopNode>();
        outlines = new FlxTypedGroup<FlxSprite>();
        overlays = new FlxTypedGroup<FlxSprite>();
        connectors = new FlxTypedGroup<FlxSprite>();
        portraits = new FlxTypedGroup<FlxSprite>();
        texts = new FlxTypedGroup<FlxText>();

		camFollow = new FlxObject();
		camFollow.setPosition(0, 0);
        FlxG.camera.follow(camFollow, null, 2);

		var starBG:FlxBackdrop = new FlxBackdrop(Paths.image('freeplay/starBG', 'impostor'));
        starBG.updateHitbox();
        starBG.scrollFactor.set(0.3, 0.3);
		starBG.velocity.set(-8, 0);
        add(starBG);

        var starFG:FlxBackdrop = new FlxBackdrop(Paths.image('freeplay/starFG', 'impostor'));
        starFG.updateHitbox();
        starFG.scrollFactor.set(0.5, 0.5);
		starFG.velocity.set(-24, 0);
        add(starFG);

        add(connectors);
        add(outlines);
        add(nodes);
        add(portraits);
        add(icons);
        add(overlays);
        add(texts);

        root = new ShopNode('root', 'root', 'description', FlxColor.RED, BF, null, null, 0, true);
        nodes.add(root);
        // trace('root name is ' + root.name);

        for(i => nodeD in nodeData)
        {
            var node:ShopNode = new ShopNode(nodeD[2], nodeD[5], nodeD[6], FlxColor.ORANGE, nodeD[7], nodeD[1], nodeD[0], nodeD[3], nodeD[4]);
            node.ID = i;
            connectors.add(node.connector);
            outlines.add(node.outline);
			nodes.add(node);
            icons.add(node.icon);
            portraits.add(node.portrait);
            overlays.add(node.overlay);
            texts.add(node.text);

            node.setUnlockState(nodeD[8], nodeD[9]);

            if(nodeD[10]) node.updateSecret(nodeD[11]);
        }

        arrangeNodes();
        updateNodeVisibility();

        panel = new FlxSprite(FlxG.width * 1.4, 0).makeGraphic(Std.int(FlxG.width * 0.4), FlxG.height, 0xFFA2A2A2);
        panel.alpha = 0.47;
        panel.cameras = [camUpper];
        add(panel);

        equipbutton = new FlxSprite(0, 0);
        equipbutton.frames = Paths.getSparrowAtlas('shop/button', 'impostor');
		equipbutton.animation.addByPrefix('buy', 'buy', 0, false);
        equipbutton.animation.addByPrefix('equipped', 'equipped', 0, false);
        equipbutton.animation.addByPrefix('grey', 'grey', 0, false);
        equipbutton.animation.addByPrefix('locked', 'locked', 0, false);
		equipbutton.animation.play('buy');
        equipbutton.scale.set(0.8, 0.8);
        equipbutton.updateHitbox();
        equipbutton.scrollFactor.set();
        equipbutton.cameras = [camUpper];
        add(equipbutton);

        equipText = new FlxText(0, 0, equipbutton.width, 'BUY', 35);
		equipText.setFormat(Paths.font("ariblk.ttf"), 35, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        equipText.updateHitbox();
		equipText.borderSize = 3;
        equipText.scrollFactor.set();
        equipText.cameras = [camUpper];
        add(equipText);

        charName = new FlxText(0, 0, panel.width, 'this is a test', 70);
		charName.setFormat(Paths.font("ariblk.ttf"), 70, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        charName.updateHitbox();
		charName.borderSize = 3;
        charName.scrollFactor.set();
        charName.cameras = [camUpper];
        add(charName);

        charDesc = new FlxText(0, 0, panel.width, 'this is a test', 20);
		charDesc.setFormat(Paths.font("ariblk.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        charDesc.updateHitbox();
		charDesc.borderSize = 1;
        charDesc.scrollFactor.set();
        charDesc.cameras = [camUpper];
        add(charDesc);

        var upperBar:FlxSprite = new FlxSprite(-2, -1.4).loadGraphic(Paths.image('freeplay/topBar', 'impostor'));
		upperBar.updateHitbox();
		upperBar.scrollFactor.set();
		upperBar.cameras = [camUpper];
		add(upperBar);

        var crossImage:FlxSpriteButton = new FlxSpriteButton(12.50, 8.05, goBack);
		crossImage.loadGraphic(Paths.image('freeplay/menuBack', 'impostor'));
		crossImage.scrollFactor.set();
		crossImage.updateHitbox();
		crossImage.cameras = [camUpper];
		add(crossImage);

		var topBean:FlxSprite = new FlxSprite(30, 100).loadGraphic(Paths.image('shop/bean', 'impostor'));
        topBean.cameras = [camUpper];
        topBean.updateHitbox();
		add(topBean);	

        beanText = new FlxText(110, 105, 200, Std.string(localBeans), 35);
		beanText.setFormat(Paths.font("ariblk.ttf"), 35, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        beanText.updateHitbox();
		beanText.borderSize = 3;
        beanText.scrollFactor.set();
        beanText.cameras = [camUpper];
        add(beanText);

		super.create();
    }

    function resetChar(id:Int)
    {
        equipbutton.animation.play('equipped');
        switch(id)
        {
            case 0: ClientPrefs.data.charOverrides[0] = 'bf';
            case 1: ClientPrefs.data.charOverrides[1] = 'gf';
            case 2: ClientPrefs.data.charOverrides[2] = 'none';
        }
    }

    function arrangeNodes()
    {
        //test for now; just a linear path from one to another;
        nodes.forEach(function(node:ShopNode)
        {
            if(node.name == 'root') return;

            //trace('node connection is ' + node.connection + ' direction is ' + node.connectionDirection);

            final offset:Float = 250;
            var finalPos:Array<Float> = grabNodePos(node.connection);
            switch(node.connectionDirection)
            {
                case 'top': finalPos[1] += offset;
                case 'bottom': finalPos[1] -= offset;
                case 'left': finalPos[0] -= offset;
                case 'right': finalPos[0] += offset;
            }
            node.setPosition(finalPos[0], finalPos[1]);
            node.connector.visible = true;
            switch(node.connectionDirection)
            {
                case 'top':
                    node.connector.angle = -90;
                    node.connector.setPosition(node.x - 5, node.y - 100);
                case 'bottom':
                    node.connector.angle = -90;
                    node.connector.setPosition(node.x - 5, node.y + 200);
                case 'right':
                    node.connector.setPosition(node.x + -184, node.y + 39.3);
                case 'left':
                    node.connector.setPosition(node.x + 163.8, node.y + 39.3);
            }
        });
    }

    function updateNodeVisibility()
    {
        nodes.forEach(function(node:ShopNode)
        {
            if(node.connection != null || node.connection != 'root')
            {
                if(checkPurchased(node.connection))
                {
                    node.portrait.color = 0xFFFFFFFF;
                    node.icon.visible = node.text.visible = true;
                }
                else
                {
                    node.portrait.color = 0xFF000000;
                    node.icon.visible = node.text.visible = false;
                    node.visibleName = '???';
                }
            }

            node.text.visible = !node.bought;

            if(!node.gotRequirements)
            {
                node.portrait.color = 0xFF000000;
                node.icon.visible = node.text.visible = false;
                node.visibleName = '???';
            }
        });
    }

    function checkPurchased(_name:String):Bool
    {
        var stupidThing:Bool = false;
        nodes.forEach(function(node:ShopNode)
        {
            if(node.name == _name)
                stupidThing = node.bought;
        });
        return stupidThing;
    }

    function grabNodePos(_name:String):Array<Float>
    {
        var stupidThing:Array<Float> = [0, 0];
        nodes.forEach(function(node:ShopNode)
        {
            if(node.name == _name)
                stupidThing = [node.x, node.y];
        });
        return stupidThing;
    }

    function updateButton(?node:ShopNode = null)
    {
        if(node == null) return;

        if(!node.bought)
        {
            equipbutton.animation.play('buy');
            equipText.text = 'BUY X' + node.price;
        }
        else
        {
            equipbutton.animation.play('equipped');
            equipText.text = 'EQUIP';
        }

        if(node.name == ClientPrefs.data.charOverrides[0] || node.name == ClientPrefs.data.charOverrides[1] || node.name == ClientPrefs.data.charOverrides[2])
        {
            equipbutton.animation.play('grey');
            equipText.text = 'EQUIPPED';
        }

        if(!node.gotRequirements || !checkPurchased(node.connection))
        {
            equipbutton.animation.play('locked');
            equipText.text = 'LOCKED';
        }
    }

    function focusNode(node:ShopNode)
    {
        isFocused = true;
        FlxG.sound.play(Paths.sound('pop'), 0.9);
        focusedNode = node;
        updateButton(node);
        charName.text = node.visibleName;
        charDesc.text = node.description;
        if(node.secret && !node.gotRequirements) charDesc.text = node.secretDesc;
        FlxTween.tween(panel, {x: FlxG.width * 0.6}, 0.4, {ease: FlxEase.circOut});
    }

    function buyNode(node:ShopNode)
    {
        node.bought = true;
        localBeans -= node.price;
        updateButton(node);
        updateNodeVisibility();
        beanText.text = Std.string(localBeans);
    }

    function equipNode(node:ShopNode)
    {
        switch(node.skinType)
        {
            case BF:
                if(node.name == ClientPrefs.data.charOverrides[0])
                    ClientPrefs.data.charOverrides[0] = 'bf';
                else
                    ClientPrefs.data.charOverrides[0] = node.name;
            case GF:
                if(node.name == ClientPrefs.data.charOverrides[1])
                    ClientPrefs.data.charOverrides[1] = 'gf';
                else
                    ClientPrefs.data.charOverrides[1] = node.name;
            case PET:
                if(node.name == ClientPrefs.data.charOverrides[2])
                    ClientPrefs.data.charOverrides[2] = '';
                else
                    ClientPrefs.data.charOverrides[2] = node.name;
        }
        updateButton(node);
        ClientPrefs.saveSettings();
        updateNodeVisibility();
    }

    override function update(elapsed:Float)
    {
        if(FlxG.sound.music.volume < 0.3) FlxG.sound.music.volume += 0.5 * elapsed;
        if(FlxG.sound.music.volume > 0.3) FlxG.sound.music.volume -= 0.5 * elapsed;

        equipbutton.setPosition(panel.getGraphicMidpoint().x - (equipbutton.width / 2), FlxG.height * 0.75);
        equipText.setPosition(panel.getGraphicMidpoint().x - (equipText.width / 2), FlxG.height * 0.785);
        charName.setPosition(panel.getGraphicMidpoint().x - (charName.width / 2), FlxG.height * 0.15);
        charDesc.setPosition(panel.getGraphicMidpoint().x - (charDesc.width / 2), FlxG.height * 0.39);

        if(!blockInput)
        {
            //trace(FlxG.camera.zoom);
            nodes.forEach(function(node:ShopNode)
            {
                if (FlxG.mouse.overlaps(node) && FlxG.mouse.justPressed && node.name != 'root' && !FlxG.mouse.overlaps(equipbutton))
                {
                    canUnfocus = false;
                    focusNode(node);
                    new FlxTimer().start(0.5, function(tmr:FlxTimer) {
                        canUnfocus = true;
                    });
                    focusTarget.x = (node.x + (node.width / 2)) + (FlxG.width * 0.18);
                    focusTarget.y = node.y + (node.height / 2);
                }
            });

            if(FlxG.mouse.overlaps(equipbutton) && FlxG.mouse.justPressed)
            {
                var connectedBought:Bool = true;
                if(focusedNode.connection != null || focusedNode.connection != 'root')
                {
                    connectedBought = checkPurchased(focusedNode.connection);
                    trace(connectedBought, focusedNode.connection);
                }

                var pulseColor:FlxColor;
                if(!focusedNode.bought && focusedNode.gotRequirements && localBeans >= focusedNode.price && connectedBought)
                {
                    buyNode(focusedNode);
                    FlxG.sound.play(Paths.sound('shopbuy'), 1);
                    pulseColor = 0xFF30FF86;
                }
                else if(!focusedNode.bought && focusedNode.gotRequirements && localBeans < focusedNode.price || !connectedBought)
                {
                    FlxG.sound.play(Paths.sound('locked'), 1);
                    camUpper.shake(0.01, 0.35);
                    FlxG.camera.shake(0.005, 0.35);
                    pulseColor = 0xFFFF4444;
                }
                else if(!focusedNode.gotRequirements)
                {
                    FlxG.sound.play(Paths.sound('locked'), 1);
                    camUpper.shake(0.01, 0.35);
                    FlxG.camera.shake(0.005, 0.35);
                    pulseColor = 0xFFFF4444;
                }
                else
                {
                    equipNode(focusedNode);
                    if(focusedNode.skinType == PET) FlxG.sound.play(Paths.sound('equippet'), 1);
                    else FlxG.sound.play(Paths.sound('equip'), 1);
                    pulseColor = 0xFFFFA143;
                }

                if(buttonTween != null) buttonTween.cancel();
                if(textTween != null) textTween.cancel();
                buttonTween = FlxTween.color(equipbutton, 0.6, pulseColor, 0xFFFFFFFF, {ease: FlxEase.sineOut});
                textTween = FlxTween.color(equipText, 0.5, pulseColor, 0xFFFFFFFF, {ease: FlxEase.sineOut});
            }

            if(!isFocused)
            {
                if(FlxG.mouse.justPressed) handleCamPress();
                if(FlxG.mouse.pressed) handleCamDrag();
                if (FlxG.mouse.wheel != 0)
                {
                    var nextZoom = FlxG.camera.zoom + ((FlxG.mouse.wheel / 10) * FlxG.camera.zoom);
                    if (nextZoom > 0.05 && nextZoom < 1.75) FlxG.camera.zoom = nextZoom;
                }
            }
            else
            {
                if(canUnfocus && FlxG.mouse.screenX < FlxG.width * 0.6)
                {
                    if(FlxG.mouse.justPressed || FlxG.mouse.wheel != 0)
                    {
                        isFocused = canUnfocus = false;
                        FlxTween.tween(panel, {x: FlxG.width * 1.4}, 0.4, {ease: FlxEase.circIn});
                        handleCamPress();
                    }
                }
                var lerpVal:Float = FlxMath.bound(elapsed * 2.4 * 3, 0, 1);
                camFollow.setPosition(FlxMath.lerp(camFollow.x, focusTarget.x, lerpVal), FlxMath.lerp(camFollow.y, focusTarget.y, lerpVal));
                FlxG.camera.zoom = FlxMath.lerp(FlxG.camera.zoom, 1, lerpVal);
            }

            if(controls.RESET)
            {
                nodes.forEach(function(node:ShopNode) {
                    node.bought = false;
                });
                updateNodeVisibility();
                ClientPrefs.data.boughtArray = [];
                ClientPrefs.saveSettings();
            }

            if(controls.BACK) goBack();
        }

        super.update(elapsed);
    }

    function handleCamPress()
    {
        clickPos.x = camFollow.x;
        clickPos.y = camFollow.y;
        clickPosScreen.x = FlxG.mouse.screenX;
        clickPosScreen.y = FlxG.mouse.screenY;
    }

    function handleCamDrag()
    {
        camFollow.x = clickPos.x + (clickPosScreen.x - FlxG.mouse.screenX);
        camFollow.y = clickPos.y + (clickPosScreen.y - FlxG.mouse.screenY);
    }

    function goBack()
    {
        blockInput = true;
        nodes.forEach(function(node:ShopNode) {
            if(node.bought && !ClientPrefs.data.boughtArray.contains(node.name))
                ClientPrefs.data.boughtArray.push(node.name);
        });
        ClientPrefs.data.beans = localBeans;
        ClientPrefs.saveSettings();

        FlxG.sound.play(Paths.sound('cancelMenu'));
        MusicBeatState.switchState(new MainMenuState());
    }
}

class ShopNode extends FlxSprite
{
    public var outline:FlxSprite;
    public var overlay:FlxSprite;
    public var icon:HealthIcon;
    public var portrait:FlxSprite;

    public var connector:FlxSprite;

    public var text:FlxText;
    public var price:Int;
    public var bought:Bool;

    public var name:String;
    public var charData:CharacterFile;
    public var petData:PetFile;

    public var gotRequirements:Bool = true;

    public var visibleName:String;
    public var description:String;

    public var secret:Bool = false;
    public var secretDesc:String = '';

    public var skinType:SkinType = BF;

    // CONNECTIONS
    public var connectionDirection:String;

    public var connection:String;

	public function new(_name:String, _visibleName:String, _description:String, _color:FlxColor, _skinType:SkinType, ?_connection:String, ?_conDir:String, ?_price:Int, ?_bought:Bool)
	{
		super(x, y);

        name = _name;
        visibleName = _visibleName;
        description = _description;
        connection = _connection;
        connectionDirection = _conDir;
        price = _price;
        bought = _bought;

        skinType = _skinType;

        connector = new FlxSprite(0, 0).loadGraphic(Paths.image('shop/connector', 'impostor'));
        connector.updateHitbox();
        connector.visible = false;

        outline = new FlxSprite(0, 0);
        outline.frames = Paths.getSparrowAtlas('shop/node', 'impostor');
		outline.animation.addByPrefix('guh', 'back', 24, true);
		outline.animation.play('guh');
        outline.updateHitbox();

		frames = Paths.getSparrowAtlas('shop/node', 'impostor');
		animation.addByPrefix('guh', 'emptysquare', 24, true);
		animation.play('guh');
        updateHitbox();

        overlay = new FlxSprite(0, 0);
        overlay.frames = Paths.getSparrowAtlas('shop/node', 'impostor');
		overlay.animation.addByPrefix('guh', 'overlay', 24, true);
		overlay.animation.play('guh');
        overlay.updateHitbox();

        if(skinType == PET)
        {
            petData = grabPetData(name);
            _color = FlxColor.fromRGB(petData.healthbar_colors[0], petData.healthbar_colors[1], petData.healthbar_colors[2]);
            icon = new HealthIcon('face', false);
            icon.alpha = 0;
        }
        else
        {
            charData = grabCharData(name);
            _color = FlxColor.fromRGB(charData.healthbar_colors[0], charData.healthbar_colors[1], charData.healthbar_colors[2]);
            icon = new HealthIcon(charData.healthicon, false);
        }

        outline.color = overlay.color = _color;

        setupPortrait(name);

        text = new FlxText(0, 0, width, Std.string(price), 36);
		text.setFormat(Paths.font("ariblk.ttf"), 36, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		text.borderSize = 3;
        text.updateHitbox();
    }

    public function updateSecret(desc:String)
    {
        secret = true;
        secretDesc = desc;
    }

    public function setUnlockState(requirement:RequirementType, songs:Array<String>)
    {
        gotRequirements = true;
        if(requirement == PERCENT95)
        {
            for(song in songs)
            {
                if(Highscore.getRating(song, 2) < 0.95) gotRequirements = false;
            }
        }
        if(requirement == COMPLETED)
        {
            for(song in songs)
            {
                if(Highscore.getScore(song, 2) == 0) gotRequirements = false;
            }
        }
    }

    function setupPortrait(name:String)
    {
        if(name != 'bf')
        {
            portrait = new FlxSprite(0, 0);
            portrait.frames = Paths.getSparrowAtlas('shop/portraits', 'impostor');
            portrait.animation.addByPrefix('guh', name, 0, false);
            portrait.animation.play('guh');
            portrait.updateHitbox();
        }
        else
        {
            portrait = new FlxSprite(0, 0).loadGraphic(Paths.image('shop/missing', 'impostor'));
            portrait.updateHitbox();
        }
    }

	override function update(elapsed:Float)
	{
		super.update(elapsed);

        outline.setPosition(x, y);
        overlay.setPosition(x, y);
        icon.setPosition(getGraphicMidpoint().x - icon.frameWidth, getGraphicMidpoint().y - icon.frameHeight);
        portrait.setPosition(getGraphicMidpoint().x - (portrait.width / 2), getGraphicMidpoint().y - (portrait.height / 2));
        text.setPosition(getGraphicMidpoint().x - (text.width / 2), getGraphicMidpoint().y + (text.height / 1.8));

        if(bought) color = connector.color = 0xFFFFFFFF;
        else color = connector.color = 0xFF4A4A4A;
    }

    function grabCharData(_char:String):CharacterFile
    {
		var characterPath:String = 'characters/$_char.json';
		var path:String = Paths.getPath(characterPath, TEXT);
		#if MODS_ALLOWED
		if (!FileSystem.exists(path))
		#else
		if (!Assets.exists(path))
		#end
			path = Paths.getSharedPath('characters/' + Character.DEFAULT_CHARACTER + '.json'); //If a character couldn't be found, change him to BF just to prevent a crash

		var json:CharacterFile = cast Json.parse( #if MODS_ALLOWED File.getContent(path) #else Assets.getText(path) #end );
        return json;
    }

    function grabPetData(_pet:String):PetFile
    {
		var characterPath:String = 'pets/$_pet.json';
		var path:String = Paths.getPath(characterPath, TEXT);
		#if MODS_ALLOWED
		if (!FileSystem.exists(path))
		#else
		if (!Assets.exists(path))
		#end
			path = Paths.getSharedPath('pets/' + Pet.DEFAULT_PET + '.json'); //If a pet couldn't be found, change him to crab just to prevent a crash

		var json:CharacterFile = cast Json.parse( #if MODS_ALLOWED File.getContent(path) #else Assets.getText(path) #end );
        return json;
    }
}
package states;

import objects.AttachedSprite;

class CreditsState extends MusicBeatState
{
	private var creditsStuff:Array<Array<String>> = [];
	var curSelected:Int = 0;

    var nameText:FlxText;
	var descText:FlxText;

    var wallback:FlxSprite;
    var frame:FlxSprite;
    var dumnote:FlxSprite;
    var lamp:FlxSprite;
    var lamplight:FlxSprite;
    var tree1:FlxSprite;
    var tree2:FlxSprite;

    var portrait:FlxSprite;

    var mole:FlxSprite; //hey pip :]
    var baritone:FlxSprite; //hey pip again :]

	override function create()
	{
		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Checking the Credits", null);
		#end

		persistentUpdate = persistentDraw = true;

        wallback = new FlxSprite().loadGraphic(Paths.image('credits/wallback', 'impostor'));
        wallback.scale.set(1.3, 1.3);
		add(wallback);

        portrait = new FlxSprite(0, 100).loadGraphic(Paths.image('credits/portraits/clow', 'impostor'));
		add(portrait);

        frame = new FlxSprite(0, 50).loadGraphic(Paths.image('credits/frame', 'impostor'));
		add(frame);

        dumnote = new FlxSprite(0, 30).loadGraphic(Paths.image('credits/stickynote', 'impostor'));
		dumnote.scale.set(1.25, 1.25);
		add(dumnote);

        lamplight = new FlxSprite(0, 100).loadGraphic(Paths.image('credits/lamplight', 'impostor'));
        lamplight.x = (FlxG.width / 2)  - (lamplight.width / 2);
        lamplight.blend = ADD;
        lamplight.alpha = 0.2;
		add(lamplight);

        lamp = new FlxSprite(0, -50).loadGraphic(Paths.image('credits/lamp', 'impostor'));
        lamp.x = (FlxG.width / 2)  - (lamp.width / 2);
		add(lamp);

        tree1 = new FlxSprite(-400, 0).loadGraphic(Paths.image('credits/tree', 'impostor'));
		add(tree1);

        tree2 = new FlxSprite(1050, 0).loadGraphic(Paths.image('credits/tree2', 'impostor'));
		add(tree2);

        mole = new FlxSprite(621, 620).loadGraphic(Paths.image('credits/mole', 'impostor'));
		mole.antialiasing = false;
        add(mole);

        descText = new FlxText(0, 600, 1200, "", 0);
		descText.setFormat(Paths.font("AmaticSC-Bold.ttf"), 50, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descText.scrollFactor.set();
		descText.borderSize = 1.3;
        add(descText);

        nameText = new FlxText(565, 120, 800, "", 0);
		nameText.setFormat(Paths.font("Dum-Regular.ttf"), 45, FlxColor.BLACK, CENTER);
		nameText.angle = -12;
        nameText.updateHitbox();
        add(nameText);

        baritone = new FlxSprite(630, 638).loadGraphic(Paths.image('credits/baritoneAd', 'impostor'));
		baritone.antialiasing = false;
        baritone.scale.set(1.2, 1.2);
        add(baritone);

		#if MODS_ALLOWED
		for (mod in Mods.parseList().enabled) pushModCreditsToList(mod);
		#end

		// Name - Icon name - Description - Link - BG Color
		/*var defaultList:Array<Array<String>> = [
			["Psych Engine Team"],
			["Shadow Mario",		"shadowmario",		"Main Programmer and Head of Psych Engine",					"https://ko-fi.com/shadowmario",	"444444"],
			["Riveren",				"riveren",			"Main Artist/Animator of Psych Engine",						"https://x.com/riverennn",			"14967B"],
			[""],
			["Former Engine Members"],
			["bb-panzu",			"bb",				"Ex-Programmer of Psych Engine",							"https://x.com/bbsub3",				"3E813A"],
			[""],
			["Engine Contributors"],
			["crowplexus",			"crowplexus",		"HScript Iris, Input System v3, and Other PRs",				"https://github.com/crowplexus",	"CFCFCF"],
			["Kamizeta",			"kamizeta",			"Creator of Pessy, Psych Engine's mascot.",				"https://www.instagram.com/cewweey/",	"D21C11"],
			["MaxNeton",			"maxneton",			"Loading Screen Easter Egg Artist/Animator.",	"https://bsky.app/profile/maxneton.bsky.social","3C2E4E"],
			["Keoiki",				"keoiki",			"Note Splash Animations and Latin Alphabet",				"https://x.com/Keoiki_",			"D2D2D2"],
			["SqirraRNG",			"sqirra",			"Crash Handler and Base code for\nChart Editor's Waveform",	"https://x.com/gedehari",			"E1843A"],
			["EliteMasterEric",		"mastereric",		"Runtime Shaders support and Other PRs",					"https://x.com/EliteMasterEric",	"FFBD40"],
			["MAJigsaw77",			"majigsaw",			".MP4 Video Loader Library (hxvlc)",						"https://x.com/MAJigsaw77",			"5F5F5F"],
			["Tahir Toprak Karabekiroglu",	"tahir",	"Note Splash Editor and Other PRs",							"https://x.com/TahirKarabekir",		"A04397"],
			["iFlicky",				"flicky",			"Composer of Psync and Tea Time\nAnd some sound effects",	"https://x.com/flicky_i",			"9E29CF"],
			["KadeDev",				"kade",				"Fixed some issues on Chart Editor and Other PRs",			"https://x.com/kade0912",			"64A250"],
			["superpowers04",		"superpowers04",	"LUA JIT Fork",												"https://x.com/superpowers04",		"B957ED"],
			["CheemsAndFriends",	"cheems",			"Creator of FlxAnimate",									"https://x.com/CheemsnFriendos",	"E1E1E1"],
			[""],
			["Funkin' Crew"],
			["ninjamuffin99",		"ninjamuffin99",	"Programmer of Friday Night Funkin'",						"https://x.com/ninja_muffin99",		"CF2D2D"],
			["PhantomArcade",		"phantomarcade",	"Animator of Friday Night Funkin'",							"https://x.com/PhantomArcade3K",	"FADC45"],
			["evilsk8r",			"evilsk8r",			"Artist of Friday Night Funkin'",							"https://x.com/evilsk8r",			"5ABD4B"],
			["kawaisprite",			"kawaisprite",		"Composer of Friday Night Funkin'",							"https://x.com/kawaisprite",		"378FC7"],
			[""],
			["Psych Engine Discord"],
			["Join the Psych Ward!", "discord", "", "https://discord.gg/2ka77eMXDv", "5165F6"]
		];*/
		// Name - Portrait name - Description - Link
		var impostorList:Array<Dynamic> = [
			//WE ARE ALL IMPORTANT PEOPLE
			['Clowfoe',		     'clow',	          'im clowfoe.... i directed the mod and i coded a SHIT TON of it\nim really proud of this whole team ty all for playing and hope it was worth the wait',																															'https://x.com/Clowfoe'],		
			['Ethan\nTheDoodler','ethan',		      'im a real doodler now, mama',																																																													'https://x.com/D00dlerEthan'],        
			['_emi',		     'emi',			      'artist!! so glad to be a part of this mod.. ty for playing <3',																																																					'https://x.com/superinky_'],   
			['mayhew',		     'mayhew',		      'i made triple trouble and i am gay artist',																																																										'@kibolomay'],
			
			['aqua',		     'aqua',			  "local sexy babe and hot programmer\ni coded a lot of this mod and lost sleep working on it\nfollow me for my insane ramblings @ useraqua_",																																		'https://x.com/useraqua_'],   
			['fabs',	         'fabs',	          'did a thing',																																																																	'https://x.com/fabsthefabs'],		
			['ziffy',	         'ziffy',		      'I HELPED ON TORTURE AND\nI MADE THE FREEPLAY MENU',																																																								'https://x.com/ziffymusic'],
			['Rozebud',	         'rozebud',	          "Download Bunker Bumrush.\nPlay my new game Bunker Bumrush.",																																																						'https://x.com/helpme_thebigt'],
			['duskie',	         'duskie',	          'From what little i did do for this mod, the team was nice and fun to work with. Hope you enjoyed the double note ghosts :)',																																						'https://x.com/DuskieWhy'],		
			
			['punkett',			 'punkett',		      "im punkett",																																																																		'https://x.com/_punkett'],
			['emihead',			 'emihead',			  "im emihead i made tomonjus tuesday and the credits song also i am canonically the black impostor's lover so please draw us making out and tag me on x @ emihead",																												'https://x.com/emihead'],
			['Saster',		     'saster',	          "Hey guys, it's me! I composed Sauces Moogus and Heartbeat. Though they are both songs I created more than a year ago, I still think they're not too bad. I hope you enjoyed those songs and see you in another mod!!",															'https://x.com/sub0ru'],
			['Rareblin',		 'rareblin',	      "im a funny musician idk check out my Youtube channel",																																																							'https://www.youtube.com/@Rareblin'],
			['keoni',			 'keoni',			  "keoni",																																																																			'https://x.com/AmongUsVore'],
			['Keegan',		     'keegan',	          "Hey Gamers, I'm Keegan, I made Turbulence and all the midi sections of Room Code.\nI like ENA and I draw occasionally you should follow me @__Keegan_",																															'https://x.com/__Keegan_'],
			['fluffyhairs',		 'fluffyhair',		  "subscribe to fluffyhairs",																																																														'https://x.com/fluffyhairslol'],
			['Nii-san',          'niisan',            'Musician. Had lots of fun working on this mod, thanks to everyone for playing V4! (sub to my youtube, @niisanmusic, i uploaded the songs there)', 																																'https://x.com/NiisanHP'],
			['JADS',             'jads',              '"if u tired, just sleep." - Gandhi',																																																												'https://x.com/Aw3somejds'],
			
			['loggo',			 'lojo',			  'halloween',																																																																		'https://x.com/loggoman512'],   
			['mayo',			 'mayo',		      "Hi I'm Mayokiddo! I'm an artist for the mod and I made a bunch of the playable mini impostor skins, and i also made a few sprites\nshout out to everyone currently in silly squad",																								'https://x.com/Mayokiddo_'],
			['Mash\nPro\nTato',  'mashywashy',        'im so sorry for making among us kills 2 years ago',																																																								'https://x.com/MashProTato'],
			['Julien',           'julien',            'hi i made the parasite form isnt he so awesome',																																																									'https://x.com/itjulienn'],
			['neato',			 'neato',		      'if she yo girl why my leitmotif in her theme',																																																									'https://neatong.newgrounds.com/'],
			['orbyy',		     'orb',			      "Im really happy i got to work on this, i was brought on v3 to do pixel art for tomongus and i'm grateful for being given the opportunity. I hope yall love the new pixel art for tomongus week and i apologize for v3's defeat chart.",											'https://x.com/OrbyyNew'],   
			['squidboy',         'squid',	          'hi im squid you may or may not know me for moderating the impostorm discord server\nive also been working for impostor ever since its beginning so thats cool i guess\nlove u zial <3<3<3',																						'https://x.com/SquidBoy84'],
			['pip',		         'pip',			      '"            "',																																																																	'https://x.com/DojimaDog'],   
			['grave',			 'grave',		      "opium",																																																																			'https://x.com/konn_artist'],
			['data\n5',			 'data',		      "i saved the mod",																																																																'https://x.com/_data5'],
			['Lay\nLasagna',	 'lay',		          "#1 giggleboy and omfg fan\nhello mommy!!!!!!! :)))) i'm a big boy now!!!!",																																																		'https://x.com/LayLasagna7'],
			['coti',	    	 'coti',			  'hi !! im coti-- i didnt really do much except for a drawing or visual tweaking here and there, but im happy i got to work on the mod anyway !! remember to always be silly',																										'https://x.com/espeoncutie'],   
			['elikapika',		 'pika',			  'bunny emoji',																																																																	'https://x.com/elikapika'],   
			['salterino',	     'salterino',	      'hi i did 1 thing for mod hi',																																																													'https://x.com/Salterin0'],		
			['Farfoxx',		     'hi',			      "hi!!! i did a few little things for the mod - although i wish i could've helped more, seeing the mod's development progress was incredible! everyone on the team is so talented, i'm grateful i got to see it reach completion",													'https://x.com/iron222_2'],   
			['Steve',            'thales',            "I'm very happy to help draw a small part of this mod, it's a big achievement for me, I hope you all have a good time in the game!", 																																				'https://x.com/Steve06421194'],
			['MSG',              'msg',               "gaming", 																																																																		'https://x.com/MSGTheEpic'],
	
			['Gonk',			 'gonk',	          "Working on Impostor has been a ton of fun honestly, was really cool to be a part of something special like this. I'm also the reason crewicide is in, dumb joke song based off a dream I had and its probably my favourite thing I worked on in the mod, It Funny, makes Me Lol",'https://www.youtube.com/watch?v=rZP7kWOMPzI'],
			['gibz',			 'gibz',		      "shit idk , charted a few songs",																																																													'https://x.com/9766Gibz'],
			['thales',			 'thalesrealthistime',"I guess I'm the closest to a Jorsawsee director in the mod? Created / Voiced Warchief and charted a lot, making sure everything was playable. Working with everyone was a pleasure, but never tell me to chart two 4+ minute songs again.",										'https://x.com/MoonlessShift'],
			['kal',			     'kal',		          "i love snas\n-art by @Butholeeo",																																																												'https://x.com/Kal_050'],
			
			['monotone\ndoc',	 'monotone',	      "hi i'm the guy who voiced the shapeshifter, very grateful to have had the opportunity and i hope y'all thought it was cool :)",																																					'https://x.com/MonotoneDoc'],
			['amongus\nfan',	 'cooper',		      "i did nothing for this mod but let them use red mungus but i get a quote for having cancer\nfly high cooper",																																									'https://x.com/amongusfan24'],
			
			['DM-kun',	 		 'dmkun',			  "this was a pain to make, but hey, it's now here and it's so awesome and cool and yeah!\ni hope y'all liked this port :>",																																						'https://www.youtube.com/@dm-kun'],
			['5UP34',	 		 '5up34',		      "insert 5up quote here if she actually helps with icons",																																																							'https://x.com/5UP34']
		];

		for(pal in impostorList)
		{
			Paths.image('credits/portraits/' + pal[1], 'impostor');
			creditsStuff.push(pal);
		}

		changeSelection();
		super.create();
	}

	var quitting:Bool = false;
	var holdTime:Float = 0;
	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.7)
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;

		if(!quitting)
		{
			if(creditsStuff.length > 1)
			{
				var shiftMult:Int = 1;
				if(FlxG.keys.pressed.SHIFT) shiftMult = 3;

				if (controls.UI_LEFT_P)
				{
					changeSelection(-shiftMult);
					holdTime = 0;
				}
				if (controls.UI_RIGHT_P)
				{
					changeSelection(shiftMult);
					holdTime = 0;
				}

				if(controls.UI_LEFT || controls.UI_RIGHT)
				{
					var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
					holdTime += elapsed;
					var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

					if(holdTime > 0.5 && checkNewHold - checkLastHold > 0)
						changeSelection((checkNewHold - checkLastHold) * (controls.UI_LEFT ? -shiftMult : shiftMult));
				}
			}

			if(controls.ACCEPT && (creditsStuff[curSelected][3] == null || creditsStuff[curSelected][3].length > 4))
			{
				FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
				CoolUtil.browserLoad(creditsStuff[curSelected][3]);
			}

			if (controls.BACK)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new MainMenuState());
				quitting = true;
			}
		}

		super.update(elapsed);
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		do
		{
			curSelected = FlxMath.wrap(curSelected + change, 0, creditsStuff.length - 1);
		}
		while(unselectableCheck(curSelected));

        nameText.text = creditsStuff[curSelected][0];
		descText.text = creditsStuff[curSelected][2];
		if(descText.text.trim().length > 0)
		{
			descText.visible = true;
			descText.x = ((FlxG.width / 2) - (descText.width / 2));
		}
		else descText.visible = false;

        switch(creditsStuff[curSelected][0])
		{
            case 'Ethan\nTheDoodler' | 'Lay\nLasagna' | 'monotone\ndoc' | 'amongus\nfan':
                nameText.y = 100;
            case 'Mash\nPro\nTato':
                nameText.y = 80;
            default:
                nameText.y = 120;
        }

        portrait.loadGraphic(Paths.image('credits/portraits/' + creditsStuff[curSelected][1], 'impostor'));
        portrait.x = ((FlxG.width / 2) - (portrait.width / 2));
        frame.x = portrait.x - 55;
        dumnote.x = frame.x + 560;

        tree1.visible = (curSelected <= 0);
    	tree2.visible = (curSelected >= creditsStuff.length - 1);

		mole.visible = (creditsStuff[curSelected][1] == 'pip');
		baritone.visible = (creditsStuff[curSelected][1] == 'rozebud');
	}

	#if MODS_ALLOWED
	function pushModCreditsToList(folder:String)
	{
		var creditsFile:String = Paths.mods(folder + '/data/credits.txt');

		#if TRANSLATIONS_ALLOWED
		//trace('/data/credits-${ClientPrefs.data.language}.txt');
		var translatedCredits:String = Paths.mods(folder + '/data/credits-${ClientPrefs.data.language}.txt');
		#end

		if (#if TRANSLATIONS_ALLOWED (FileSystem.exists(translatedCredits) && (creditsFile = translatedCredits) == translatedCredits) || #end FileSystem.exists(creditsFile))
		{
			var firstarray:Array<String> = File.getContent(creditsFile).split('\n');
			for(i in firstarray)
			{
				var arr:Array<String> = i.replace('\\n', '\n').split("::");
				if(arr.length >= 5) arr.push(folder);
				creditsStuff.push(arr);
			}
			creditsStuff.push(['']);
		}
	}
	#end

	private function unselectableCheck(num:Int):Bool
		return creditsStuff[num].length <= 1;
}
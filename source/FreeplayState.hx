package;

import StoryMenuState.StoryMenuState2;
import flixel.util.FlxTimer;
#if !hl
#if desktop
import Discord.DiscordClient;
#end
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;

using StringTools;

class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];

	var selector:FlxText;
	var curSelected:Int = 0;
	var curDifficulty:Int = 0;

	var bg:FlxSprite;
	var scoreBG:FlxSprite;
	var scoreText:FlxText;
	var diffText:FlxText;
	var diffic:String = "";
	var lerpScore:Float = 0;
	var ps:PlayState;
	var cs:ChartingState;
	var intendedScore:Int = 0;

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var coolColors = [0xFF9271FD, 0xFF9271FD, 0xFF223344, 0xFF941653, 0xFFFC96D7, 0xFFA0D1FF, 0xFFFF78BF, 0xFFF6B604, 0xFF9271FD];

	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];

	override function create()
	{
		#if desktop
		// if(PlayState.storyWeek == 6)
		// 	{
		// FlxG.sound.music.pitch = 1;				
		// 	}
#end
		var initSonglist = CoolUtil.coolTextFile(Paths.txt('freeplaySonglist'));

		for (i in 0...initSonglist.length)
		{
			songs.push(new SongMetadata(initSonglist[i], 1, 'gf'));
		}

		/* 
			if (FlxG.sound.music != null)
			{
				if (!FlxG.sound.music.playing)
					FlxG.sound.playMusic(Paths.music('freakyMenu'));
			}
		 */
		 #if !hl
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Freeplay", null);
		#end
		#end

		if (!FlxG.sound.music.playing)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}

		if (StoryMenuState.weekUnlocked[2])
			addWeek(['Switch', 'Fresh', 'Dadbattle'], 1, ['dad']);

		if (StoryMenuState.weekUnlocked[2])
			addWeek(['Spookeez', 'South', 'Monster'], 2, ['spooky', 'spooky', 'monster']);

		if (StoryMenuState.weekUnlocked[3])
			addWeek(['Pico', 'Philly', 'Blammed'], 3, ['pico']);

		if (StoryMenuState.weekUnlocked[4])
			addWeek(['Satin-Panties', 'High', 'Milf'], 4, ['mom']);

		if (StoryMenuState.weekUnlocked[5])
			addWeek(['Cocoa', 'Eggnog', 'Winter-Horrorland'], 5, ['parents-christmas', 'parents-christmas', 'monster-christmas']);

		if (StoryMenuState.weekUnlocked[6])
			addWeek(['Senpai', 'Roses', 'Thorns'], 6, ['senpai', 'senpai', 'spirit']);

		if (StoryMenuState.weekUnlocked[7])
			addWeek(['Ugh', 'Guns', 'Stress'], 7, ['tankman']);

		if (StoryMenuState.weekUnlocked[8])
			addWeek(['Darnell','Lit-Up','2Hot'], 8, ['darnell']);		

		// LOAD MUSIC

		// LOAD CHARACTERS

		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		add(bg);

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].songName, true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpSongs.add(songText);

			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;

			// using a FlxGroup is too much fuss!
			iconArray.push(icon);
			add(icon);

			// songText.x += 40;
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			// songText.screenCenter(X);
		}

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		// scoreText.autoSize = false;
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);
		// scoreText.alignment = RIGHT;

		scoreBG = new FlxSprite(scoreText.x - 6, 0).makeGraphic(1, 66, 0xFF000000);
		scoreBG.antialiasing = false;
		scoreBG.alpha = 0.6;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		add(diffText);

		add(scoreText);

		changeSelection();
		changeDiff();

		// FlxG.sound.playMusic(Paths.music('title'), 0);
		// FlxG.sound.music.fadeIn(2, 0, 0.8);
		selector = new FlxText();

		selector.size = 40;
		selector.text = ">";
		// add(selector);

		var swag:Alphabet = new Alphabet(1, 0, "swag");

		// JUST DOIN THIS SHIT FOR TESTING!!!
		/* 
			var md:String = Markdown.markdownToHtml(Assets.getText('CHANGELOG.md'));

			var texFel:TextField = new TextField();
			texFel.width = FlxG.width;
			texFel.height = FlxG.height;
			// texFel.
			texFel.htmlText = md;

			FlxG.stage.addChild(texFel);

			// scoreText.textField.htmlText = md;

			trace(md);
		 */

		super.create();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter));
	}

	public function addWeek(songs:Array<String>, weekNum:Int, ?songCharacters:Array<String>)
	{
		if (songCharacters == null)
			songCharacters = ['bf-pixel'];

		var num:Int = 0;
		for (song in songs)
		{
			addSong(song, weekNum, songCharacters[num]);

			if (songCharacters.length != 1)
				num++;
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.sound.music != null && FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		lerpScore = CoolUtil.coolLerp(lerpScore, intendedScore, 0.4);
		
		var b = Std.parseInt(bg.color.toHexString()),
			c = coolColors[songs[curSelected].week % coolColors.length],
			d = CoolUtil.camLerpShit(0.045);
		var e = Std.int(((c >> 0x10 & 0xFF) - (b >> 0x10 & 0xFF)) * d + (b >> 0x10 & 0xFF)),
			f = Std.int(((c >> 0x8 & 0xFF) - (b >> 0x8 & 0xFF)) * d + (b >> 0x8 & 0xFF)),
			h = Std.int(((c & 0xFF) - (b & 0xFF)) * d + (b & 0xFF)),
			i = Std.int(((c >> 0x18 & 0xFF) - (b >> 0x18 & 0xFF)) * d + (b >> 0x18 & 0xFF));
		b = (b & 0xFF00FFFF | (0xFF < e ? 0xFF : 0x0 > e ? 0x0 : e) << 0x10) & 0xFFFF00FF | (0xFF < f ? 0xFF : 0x0 > f ? 0x0 : f) << 0x8;
		b &= 0xFFFFFF00;
		b |= 0xFF < h ? 0xFF : 0x0 > h ? 0x0 : h;
		b &= 0xFFFFFF;
		b |= (0xFF < i ? 0xFF : 0x0 > i ? 0x0 : i) << 0x18;
		bg.color = b;
		// fucking over

		scoreText.text = "PERSONAL BEST:" + Math.round(lerpScore);
		positionHighscore();

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var leftP = controls.UI_LEFT_P;
		var rightP = controls.UI_RIGHT_P;
		var accepted = controls.ACCEPT;

		if(FlxG.keys.justPressed.C)
			{
				FlxG.switchState(new Freeplay2());
			}
			#if desktop
		if (FlxG.keys.pressed.TWO)//suck my dick you stupid hard code fuck
			{	
				FlxG.sound.music.pitch -= 0.01;		
				// ps.dadVocals.pitch -= 0.01;
				// ps.bfVocals.pitch -= 0.01;
				// cs.dadVocals.pitch -= 0.01;
				// cs.bfVocals.pitch -= 0.01;
			}
			if (FlxG.keys.pressed.THREE)
			{

				FlxG.sound.music.pitch += 0.01;
				// ps.dadVocals.pitch += 0.01;
				// ps.bfVocals.pitch += 0.01;
				// cs.dadVocals.pitch += 0.01;
				// cs.bfVocals.pitch += 0.01;
			}
			if (FlxG.keys.justPressed.FIVE)
				{
	
					FlxG.sound.music.pitch = 1;
					// ps.dadVocals.pitch += 0.01;
					// ps.bfVocals.pitch += 0.01;
					// cs.dadVocals.pitch += 0.01;
					// cs.bfVocals.pitch += 0.01;
				}
				#end
		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}
		if (FlxG.mouse.wheel != 0)
			changeSelection(-Math.round(FlxG.mouse.wheel / 4));

		if (controls.UI_LEFT_P)
			changeDiff(-1);
		if (controls.UI_RIGHT_P)
			changeDiff(1);

		if (controls.BACK)
		{
			FlxG.sound.play(Paths.sound("cancelMenu"));
			FlxG.switchState(new MainMenuState());
		}

		if (accepted)
		{
			var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);

			PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = curDifficulty;
			#if desktop
			FlxG.sound.music.pitch = 1;
			#end
			PlayState.storyWeek = songs[curSelected].week;
			trace('ON WEEK: ' + PlayState.storyWeek);
			LoadingState.loadAndSwitchState(new PlayState(), true);
		}
	}

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = 2;
		if (curDifficulty > 2)
			curDifficulty = 0;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		#end

		PlayState.storyDifficulty = curDifficulty;
		diffText.text = '< ' + CoolUtil.difficultyString() + ' >';


		switch (curDifficulty)
		{
			case 0:
				diffic = '-easy';
			case 2:
				diffic = '-hard';
			case 3:
				diffic = '-erect';					
		}
		
		// switch (curDifficulty)
		// {
		// 	case 0:
		// 		diffText.text = "< EASY >";
		// 	case 1:
		// 		diffText.text = "< NORMAL >";
		// 	case 2:
		// 		diffText.text = "< HARD >";
		// 	case 3:
		// 		diffText.text = "< ERECT >";
		// }
		positionHighscore();
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		// selector.y = (70 * curSelected) + 30;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		// lerpScore = 0;
		#end

		#if PRELOAD_ALL
		// No clue if this was removed or not, but I wanted to keep this as close as possible to the web version, and this is not in there.
		// Yes, I know it's because the web version doesn't preload everything. If this being gone bothers you so much, then do it yourself lol.
		//FlxG.sound.playMusic(Paths.inst(songs[curSelected].songName), 0);
		#end

		var bullShit:Int = 0;

		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
		}

		iconArray[curSelected].alpha = 1;

		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}

	function positionHighscore()
	{
		scoreText.x = FlxG.width - scoreText.width - 6;
		scoreBG.scale.x = FlxG.width - scoreText.x + 6;
		scoreBG.x = FlxG.width - scoreBG.scale.x / 2;
		diffText.x = scoreBG.x + scoreBG.width / 2;
		diffText.x -= diffText.width / 2;
	}
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";

	public function new(song:String, week:Int, songCharacter:String)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
	}
}


class Freeplay2 extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];

	var selector:FlxText;
	var curSelected:Int = 0;
	var curDifficulty:Int = 0;

	var bg:FlxSprite;
	var scoreBG:FlxSprite;
	var scoreText:FlxText;
	var diffText:FlxText;
	var diffic:String = "";
	var lerpScore:Float = 0;
	var ps:PlayState;
	var cs:ChartingState;
	var intendedScore:Int = 0;

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var coolColors = [0xFF9271FD, 0xFF9271FD, 0xFF223344, 0xFF941653, 0xFFFC96D7, 0xFFA0D1FF, 0xFFFF78BF, 0xFFF6B604, 0xFFff1b31];

	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];

	override function create()
	{
		#if desktop
		// if(PlayState.storyWeek == 6)
		// 	{
		// FlxG.sound.music.pitch = 1;				
		// 	}
			#end

		var initSonglist = CoolUtil.coolTextFile(Paths.txt('freeplaySonglist'));

		for (i in 0...initSonglist.length)
		{
			songs.push(new SongMetadata(initSonglist[i], 1, 'gf'));
		}

		/* 
			if (FlxG.sound.music != null)
			{
				if (!FlxG.sound.music.playing)
					FlxG.sound.playMusic(Paths.music('freakyMenu'));
			}
		 */
		 #if !hl
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Freeplay", null);
		#end
		#end

		if (!FlxG.sound.music.playing)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}

		if (StoryMenuState2.weekUnlocked[2])
			addWeek(['State', 'Fresh', 'Dadbattle'], 1, ['dad']);

		if (StoryMenuState2.weekUnlocked[2])
			addWeek(['Spookeez', 'South', 'Monster'], 2, ['spooky', 'spooky', 'monster']);

		if (StoryMenuState2.weekUnlocked[3])
			addWeek(['Pico', 'Philly', 'Blammed'], 3, ['pico']);

		if (StoryMenuState2.weekUnlocked[4])
			addWeek(['Satin-Panties', 'High', 'Milf'], 4, ['mom']);

		if (StoryMenuState2.weekUnlocked[5])
			addWeek(['Cocoa', 'Eggnog', 'Winter-Horrorland'], 5, ['parents-christmas', 'parents-christmas', 'monster-christmas']);

		if (StoryMenuState2.weekUnlocked[6])
			addWeek(['Senpai', 'Roses', 'Thorns'], 6, ['senpai', 'senpai', 'spirit']);

		if (StoryMenuState2.weekUnlocked[7])
			addWeek(['Ugh', 'Guns', 'Stress'], 7, ['tankman']);

		if (StoryMenuState2.weekUnlocked[8])
			addWeek(['Accelerant'], 8, ['hank']);	

		if (StoryMenuState2.weekUnlocked[9])
			addWeek(['South-Erect', 'Dadbattle-Erect'], 9, ['dad', 'spooky']);		

		// LOAD MUSIC

		// LOAD CHARACTERS

		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		add(bg);

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].songName, true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpSongs.add(songText);

			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;

			// using a FlxGroup is too much fuss!
			iconArray.push(icon);
			add(icon);

			// songText.x += 40;
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			// songText.screenCenter(X);
		}

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		// scoreText.autoSize = false;
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);
		// scoreText.alignment = RIGHT;

		scoreBG = new FlxSprite(scoreText.x - 6, 0).makeGraphic(1, 66, 0xFF000000);
		scoreBG.antialiasing = false;
		scoreBG.alpha = 0.6;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		add(diffText);

		add(scoreText);

		changeSelection();
		changeDiff();

		// FlxG.sound.playMusic(Paths.music('title'), 0);
		// FlxG.sound.music.fadeIn(2, 0, 0.8);
		selector = new FlxText();

		selector.size = 40;
		selector.text = ">";
		// add(selector);

		var swag:Alphabet = new Alphabet(1, 0, "swag");

		// JUST DOIN THIS SHIT FOR TESTING!!!
		/* 
			var md:String = Markdown.markdownToHtml(Assets.getText('CHANGELOG.md'));

			var texFel:TextField = new TextField();
			texFel.width = FlxG.width;
			texFel.height = FlxG.height;
			// texFel.
			texFel.htmlText = md;

			FlxG.stage.addChild(texFel);

			// scoreText.textField.htmlText = md;

			trace(md);
		 */

		super.create();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter));
	}

	public function addWeek(songs:Array<String>, weekNum:Int, ?songCharacters:Array<String>)
	{
		if (songCharacters == null)
			songCharacters = ['bf-pixel'];

		var num:Int = 0;
		for (song in songs)
		{
			addSong(song, weekNum, songCharacters[num]);

			if (songCharacters.length != 1)
				num++;
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.sound.music != null && FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		lerpScore = CoolUtil.coolLerp(lerpScore, intendedScore, 0.4);
		
		var b = Std.parseInt(bg.color.toHexString()),
			c = coolColors[songs[curSelected].week % coolColors.length],
			d = CoolUtil.camLerpShit(0.045);
		var e = Std.int(((c >> 0x10 & 0xFF) - (b >> 0x10 & 0xFF)) * d + (b >> 0x10 & 0xFF)),
			f = Std.int(((c >> 0x8 & 0xFF) - (b >> 0x8 & 0xFF)) * d + (b >> 0x8 & 0xFF)),
			h = Std.int(((c & 0xFF) - (b & 0xFF)) * d + (b & 0xFF)),
			i = Std.int(((c >> 0x18 & 0xFF) - (b >> 0x18 & 0xFF)) * d + (b >> 0x18 & 0xFF));
		b = (b & 0xFF00FFFF | (0xFF < e ? 0xFF : 0x0 > e ? 0x0 : e) << 0x10) & 0xFFFF00FF | (0xFF < f ? 0xFF : 0x0 > f ? 0x0 : f) << 0x8;
		b &= 0xFFFFFF00;
		b |= 0xFF < h ? 0xFF : 0x0 > h ? 0x0 : h;
		b &= 0xFFFFFF;
		b |= (0xFF < i ? 0xFF : 0x0 > i ? 0x0 : i) << 0x18;
		bg.color = b;
		// Alright, shit's over. Sincere apologies yet again, but at least it works.

		scoreText.text = "PERSONAL BEST:" + Math.round(lerpScore);
		positionHighscore();

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		// var leftP = controls.UI_LEFT_P;
		// var rightP = controls.UI_RIGHT_P;
		var accepted = controls.ACCEPT;

		if(FlxG.keys.justPressed.C)
		{
			FlxG.switchState(new FreeplayState());
		}	
		#if desktop
		if (FlxG.keys.pressed.TWO)//suck my dick you stupid hard code fuck
			{	
				FlxG.sound.music.pitch -= 0.01;		
				// ps.dadVocals.pitch -= 0.01;
				// ps.bfVocals.pitch -= 0.01;
				// cs.dadVocals.pitch -= 0.01;
				// cs.bfVocals.pitch -= 0.01;
			}
			if (FlxG.keys.pressed.THREE)
			{

				FlxG.sound.music.pitch += 0.01;
				// ps.dadVocals.pitch += 0.01;
				// ps.bfVocals.pitch += 0.01;
				// cs.dadVocals.pitch += 0.01;
				// cs.bfVocals.pitch += 0.01;
			}
			if (FlxG.keys.justPressed.FIVE)
				{
	
					FlxG.sound.music.pitch = 1;
					// ps.dadVocals.pitch += 0.01;
					// ps.bfVocals.pitch += 0.01;
					// cs.dadVocals.pitch += 0.01;
					// cs.bfVocals.pitch += 0.01;
				}
				#end
		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}
		if (FlxG.mouse.wheel != 0)
			changeSelection(-Math.round(FlxG.mouse.wheel / 4));

		if (controls.UI_LEFT_P)
			changeDiff(-1);
		if (controls.UI_RIGHT_P)
			changeDiff(1);

		if (controls.BACK)
		{
			FlxG.sound.play(Paths.sound("cancelMenu"));
			FlxG.switchState(new MainMenuState());
		}

		if (accepted)
		{
			var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);

			PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = curDifficulty;
			#if desktop
			FlxG.sound.music.pitch = 1;
			#end
			PlayState.storyWeek = songs[curSelected].week;
			trace('ON WEEK: ' + PlayState.storyWeek);
			LoadingState.loadAndSwitchState(new PlayState(), true);
		}
	}

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = 2;
		if (curDifficulty > 2)
			curDifficulty = 0;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		#end

		PlayState.storyDifficulty = curDifficulty;
		diffText.text = '< ' + CoolUtil.difficultyString() + ' >';


		switch (curDifficulty)
		{
			case 0:
				diffic = '-easy';
			case 2:
				diffic = '-hard';
			case 3:
				diffic = '-erect';					
		}
		
		// switch (curDifficulty)
		// {
		// 	case 0:
		// 		diffText.text = "< EASY >";
		// 	case 1:
		// 		diffText.text = "< NORMAL >";
		// 	case 2:
		// 		diffText.text = "< HARD >";
		// 	case 3:
		// 		diffText.text = "< ERECT >";
		// }
		positionHighscore();
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		// selector.y = (70 * curSelected) + 30;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		// lerpScore = 0;
		#end

		#if PRELOAD_ALL
		// No clue if this was removed or not, but I wanted to keep this as close as possible to the web version, and this is not in there.
		// Yes, I know it's because the web version doesn't preload everything. If this being gone bothers you so much, then do it yourself lol.
		//FlxG.sound.playMusic(Paths.inst(songs[curSelected].songName), 0);
		#end

		var bullShit:Int = 0;

		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
		}

		iconArray[curSelected].alpha = 1;

		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}

	function positionHighscore()
	{
		scoreText.x = FlxG.width - scoreText.width - 6;
		scoreBG.scale.x = FlxG.width - scoreText.x + 6;
		scoreBG.x = FlxG.width - scoreBG.scale.x / 2;
		diffText.x = scoreBG.x + scoreBG.width / 2;
		diffText.x -= diffText.width / 2;
	}
}
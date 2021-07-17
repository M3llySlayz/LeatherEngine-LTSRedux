package states;

import haxe.macro.Expr.Var;
import lime.utils.Assets;
#if sys
import sys.io.File;
#end

#if discord_rpc
import utilities.Discord.DiscordClient;
#end

import haxe.Json;
import ui.MenuCharacter;
import ui.MenuItem;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.net.curl.CURLCode;
import game.Song;
import game.Highscore;

using StringTools;

class StoryMenuState extends MusicBeatState
{
	/* WEEK GROUPS */
	var groupIndex:Int = 0;
	var groups:Array<StoryGroup> = [];

	var currentGroup:StoryGroup;

	/* WEEK VARIABLES */
	var curWeek:Int = 0;
	var curDifficulty:Int = 1;

	/* TEXTS */
	var weekScoreText:FlxText;
	var weekTitleText:FlxText;
	var weekSongListText:FlxText;

	/* UI */
	var yellowBG:FlxSprite;
	
	var weekGraphics:FlxTypedGroup<MenuItem>;
	var menuCharacters:FlxTypedGroup<MenuCharacter>;

	/* DIFFICULTY UI */
	var difficultySelectorGroup:FlxGroup;
	
	var difficultySprite:FlxSprite;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;

	// old ass variables to get rid of
	public static var weekProgression:Bool = false;
	public static var weekUnlocked:Array<Bool> = [true, false, false, false, false, false, false];

	override function create()
	{
		// SETUP THE GROUPS //

		// uhhh this is for testing :)
		#if sys
		groups.push(cast Json.parse(File.getContent(Sys.getCwd() + Paths.jsonSYS("week data/original_weeks")).trim()));
		#else
		groups.push(cast Json.parse(Assets.getText(Paths.json("week data/original_weeks")).trim()));
		#end

		// CREATE THE UI //
		currentGroup = groups[0];

		createStoryUI();

		super.create();
	}

	override function update(elapsed:Float)
	{
		/*
		// scoreText.setFormat('VCR OSD Mono', 32);
		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.5));

		scoreText.text = "WEEK SCORE:" + lerpScore;

		txtWeekTitle.x = FlxG.width - (txtWeekTitle.width + 10);

		// FlxG.watch.addQuick('font', scoreText.font);

		if(weekProgression)
			difficultySelectors.visible = weekUnlocked[curWeek];
		else
			difficultySelectors.visible = true;

		grpLocks.forEach(function(lock:FlxSprite)
		{
			lock.y = grpWeekText.members[lock.ID].y;
		});

		if (!movedBack)
		{
			if (!selectedWeek)
			{
				if (controls.UP_P)
				{
					changeWeek(-1);
				}

				if (controls.DOWN_P)
				{
					changeWeek(1);
				}

				if (controls.RIGHT)
					rightArrow.animation.play('press')
				else
					rightArrow.animation.play('idle');

				if (controls.LEFT)
					leftArrow.animation.play('press');
				else
					leftArrow.animation.play('idle');

				if (controls.RIGHT_P)
					changeDifficulty(1);
				if (controls.LEFT_P)
					changeDifficulty(-1);
			}

			if (controls.ACCEPT)
			{
				selectWeek();
			}
		}

		if (controls.BACK && !movedBack && !selectedWeek)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			movedBack = true;
			FlxG.switchState(new MainMenuState());
		}*/

		super.update(elapsed);
	}

	function createStoryUI()
	{
		weekScoreText = new FlxText(10, 10, 0, "SCORE: 49324858", 36);
		weekScoreText.setFormat("VCR OSD Mono", 32);

		weekTitleText = new FlxText(FlxG.width * 0.7, 10, 0, "", 32);
		weekTitleText.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, RIGHT);
		weekTitleText.alpha = 0.7;

		var rankText:FlxText = new FlxText(0, 10);
		rankText.text = 'RANK: GREAT';
		rankText.setFormat(Paths.font("vcr.ttf"), 32);
		rankText.size = weekScoreText.size;
		rankText.screenCenter(X);

		yellowBG = new FlxSprite(0, 56).makeGraphic(FlxG.width, 400, 0xFFF9CF51);

		weekGraphics = new FlxTypedGroup<MenuItem>();
		add(weekGraphics);

		var blackBarThingie:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 56, FlxColor.BLACK);
		add(blackBarThingie);

		menuCharacters = new FlxTypedGroup<MenuCharacter>();
		
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Story Menus", null);
		#end

		createWeekGraphics();
		addWeekCharacters();

		difficultySelectorGroup = new FlxGroup();
		add(difficultySelectorGroup);

		var ui_tex = Paths.getSparrowAtlas('campaign_menu_UI_assets');

		leftArrow = new FlxSprite(weekGraphics.members[0].x + weekGraphics.members[0].width + 10, weekGraphics.members[0].y + 10);
		leftArrow.frames = ui_tex;
		leftArrow.animation.addByPrefix('idle', "arrow left");
		leftArrow.animation.addByPrefix('press', "arrow push left");
		leftArrow.animation.play('idle');

		difficultySprite = new FlxSprite(leftArrow.x + 130, leftArrow.y);
		difficultySprite.frames = ui_tex;
		difficultySprite.animation.addByPrefix('easy', 'EASY');
		difficultySprite.animation.addByPrefix('normal', 'NORMAL');
		difficultySprite.animation.addByPrefix('hard', 'HARD');
		difficultySprite.animation.play('normal');
		changeDifficulty();

		rightArrow = new FlxSprite(difficultySprite.x + difficultySprite.width + 50, leftArrow.y);
		rightArrow.frames = ui_tex;
		rightArrow.animation.addByPrefix('idle', 'arrow right');
		rightArrow.animation.addByPrefix('press', "arrow push right", 24, false);
		rightArrow.animation.play('idle');

		difficultySelectorGroup.add(leftArrow);
		difficultySelectorGroup.add(difficultySprite);
		difficultySelectorGroup.add(rightArrow);

		add(yellowBG);
		add(menuCharacters);

		weekSongListText = new FlxText(FlxG.width * 0.05, yellowBG.x + yellowBG.height + 100, 0, "Tracks", 32);
		weekSongListText.alignment = CENTER;
		weekSongListText.font = rankText.font;
		weekSongListText.color = 0xFFe55777;
		add(weekSongListText);
		add(weekScoreText);
		add(weekTitleText);
	}

	function addWeekCharacters()
	{
		for (char in 0...3)
		{
			var weekCharacterThing:MenuCharacter = new MenuCharacter((FlxG.width * 0.25) * (1 + char) - 150, currentGroup.weeks[curWeek].characters[char]);
			weekCharacterThing.y += 70;
			weekCharacterThing.antialiasing = true;

			switch (weekCharacterThing.character)
			{
				case 'dad':
					weekCharacterThing.setGraphicSize(Std.int(weekCharacterThing.width * 0.5));
					weekCharacterThing.updateHitbox();

				case 'bf':
					weekCharacterThing.setGraphicSize(Std.int(weekCharacterThing.width * 0.9));
					weekCharacterThing.updateHitbox();
					weekCharacterThing.x -= 80;

				case 'gf':
					weekCharacterThing.setGraphicSize(Std.int(weekCharacterThing.width * 0.5));
					weekCharacterThing.updateHitbox();

				case 'parents':
					weekCharacterThing.setGraphicSize(Std.int(weekCharacterThing.width * 1.5));
					weekCharacterThing.updateHitbox();
			}

			menuCharacters.add(weekCharacterThing);
		}
	}

	function createWeekGraphics()
	{
		weekGraphics.forEachAlive(function(item:MenuItem){
			item.kill();
			item.destroy();
		});

		for (i in 0...groups[groupIndex].weeks.length)
		{
			var selectedGroup = groups[groupIndex];

			var weekGraphic:MenuItem = new MenuItem(0, yellowBG.y + yellowBG.height + 10, selectedGroup.weeks[i].imagePath, selectedGroup.pathName);
			weekGraphic.y += ((weekGraphic.height + 20) * i);
			weekGraphic.targetY = i;

			weekGraphics.add(weekGraphic);

			weekGraphic.screenCenter(X);
			weekGraphic.antialiasing = true;
		}
	}

	var movedBack:Bool = false;
	var selectedWeek:Bool = false;
	var stopspamming:Bool = false;

	function selectWeek()
	{
		if (!stopspamming)
		{
			FlxG.sound.play(Paths.sound('confirmMenu'));

			weekGraphics.members[curWeek].startFlashing();
			menuCharacters.members[1].animation.play(menuCharacters.members[1].animation.curAnim.name + 'Confirm');
			stopspamming = true;

			PlayState.storyPlaylist = currentGroup.weeks[curWeek].songs;
			PlayState.isStoryMode = true;
			selectedWeek = true;
	
			var diffic = "";
	
			switch (curDifficulty)
			{
				case 0:
					diffic = '-easy';
				case 2:
					diffic = '-hard';
			}
	
			PlayState.storyDifficulty = curDifficulty;
	
			PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + diffic, PlayState.storyPlaylist[0].toLowerCase());
			PlayState.storyWeek = curWeek;
			PlayState.campaignScore = 0;
	
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				LoadingState.loadAndSwitchState(new PlayState());
			});
		}
	}

	function changeDifficulty(change:Int = 0):Void
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = 2;
		if (curDifficulty > 2)
			curDifficulty = 0;

		difficultySprite.offset.x = 0;

		switch (curDifficulty)
		{
			case 0:
				difficultySprite.animation.play('easy');
				difficultySprite.offset.x = 20;
			case 1:
				difficultySprite.animation.play('normal');
				difficultySprite.offset.x = 70;
			case 2:
				difficultySprite.animation.play('hard');
				difficultySprite.offset.x = 20;
		}

		difficultySprite.alpha = 0;

		// USING THESE WEIRD VALUES SO THAT IT DOESNT FLOAT UP
		difficultySprite.y = leftArrow.y - 15;

		#if !switch
		intendedScore = Highscore.getWeekScore(curWeek, curDifficulty);
		#end

		FlxTween.tween(difficultySprite, {y: leftArrow.y + 15, alpha: 1}, 0.07);
	}

	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	function changeWeek(change:Int = 0):Void
	{
		curWeek += change;

		if (curWeek >= currentGroup.weeks.length)
			curWeek = 0;
		if (curWeek < 0)
			curWeek = currentGroup.weeks.length - 1;

		var bullShit:Int = 0;

		for (item in weekGraphics.members)
		{
			item.targetY = bullShit - curWeek;

			if (item.targetY == Std.int(0))
				item.alpha = 1;
			else
				item.alpha = 0.6;

			bullShit++;
		}

		FlxG.sound.play(Paths.sound('scrollMenu'));

		updateText();
	}

	function changeGroup(change:Int = 0)
	{
		groupIndex += change;

		if(groupIndex >= groups.length)
			groupIndex = 0;
		if(groupIndex < 0)
			groupIndex = groups.length - 1;

		curWeek = 0;

		updateText();
	}

	function updateText()
	{
		/*
		var currentGroup = groups[curGroup];
		var curGroupWeek = currentGroup.weeks[curWeek];

		grpWeekCharacters.members[0].animation.play(curGroupWeek.characters[0]);
		grpWeekCharacters.members[1].animation.play(curGroupWeek.characters[1]);
		grpWeekCharacters.members[2].animation.play(curGroupWeek.characters[2]);

		txtTracklist.text = "Tracks\n\n";
		txtWeekTitle.text = curGroupWeek.weekTitle;

		switch (grpWeekCharacters.members[0].animation.curAnim.name)
		{
			case 'parents':
				grpWeekCharacters.members[0].offset.set(250, 200);
				grpWeekCharacters.members[0].flipX = false;
				grpWeekCharacters.members[0].setGraphicSize(Std.int(grpWeekCharacters.members[0].width * 1.5));

			case 'senpai':
				grpWeekCharacters.members[0].offset.set(130, 0);
				grpWeekCharacters.members[0].flipX = false;
				grpWeekCharacters.members[0].setGraphicSize(Std.int(grpWeekCharacters.members[0].width * 1.4));

			case 'mom':
				grpWeekCharacters.members[0].offset.set(100, 220);
				grpWeekCharacters.members[0].flipX = false;
				grpWeekCharacters.members[0].setGraphicSize(Std.int(grpWeekCharacters.members[0].width * 0.8));

			case 'dad':
				grpWeekCharacters.members[0].offset.set(120, 200);
				grpWeekCharacters.members[0].flipX = false;
				grpWeekCharacters.members[0].setGraphicSize(Std.int(grpWeekCharacters.members[0].width * 1));

			case 'pico':
				grpWeekCharacters.members[0].flipX = true;
				grpWeekCharacters.members[0].offset.set(150, 100);
				grpWeekCharacters.members[0].setGraphicSize(Std.int(grpWeekCharacters.members[0].width * 1.2));

			case 'spooky':
				grpWeekCharacters.members[0].offset.set(150, 150);
				grpWeekCharacters.members[0].flipX = false;
				grpWeekCharacters.members[0].setGraphicSize(Std.int(grpWeekCharacters.members[0].width * 1.3));

			default:
				grpWeekCharacters.members[0].offset.set(100, 100);
				grpWeekCharacters.members[0].flipX = false;
				grpWeekCharacters.members[0].setGraphicSize(Std.int(grpWeekCharacters.members[0].width * 1));
		}

		for (i in curGroupWeek.songs)
		{
			txtTracklist.text += i + "\n";
		}

		grpWeekCharacters.members[0].visible = true;
		txtTracklist.screenCenter(X);
		txtTracklist.x -= FlxG.width * 0.35;
		txtTracklist.text = txtTracklist.text.toUpperCase();

		#if !switch
		intendedScore = Highscore.getWeekScore(curWeek, curDifficulty);
		#end
		*/
	}
}

typedef StoryGroup =
{
	var groupName:String;
	var pathName:String;
	var weeks:Array<StoryWeek>;
}

typedef StoryWeek =
{
	var imagePath:String;
	var songs:Array<String>;
	var characters:Array<String>;
	var weekTitle:String;
}
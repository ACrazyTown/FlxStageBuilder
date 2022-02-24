package stagebuilder;

import haxe.crypto.Base64;
import openfl.utils.Assets;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import stagebuilder.FlxStageFile.FileFormat;
import haxe.Json;
import openfl.events.Event;
import openfl.net.FileFilter;
import openfl.net.FileReference;
import stagebuilder.FlxStageFile.AssetMapFormat;
import flixel.graphics.FlxGraphic;
import openfl.display.BitmapData;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxState;

using StringTools;

class FlxStageBuilder extends FlxState
{
	// id, [name, path, base64]
	// [name, path, base64], id
	//var assets:Map<Int, AssetMapFormat>;
	//var shit:Array<String>;
	//var usedID:Int = -1;
	//var dumb:Array<FlxSprite> = [];

	var assets:Array<AssetMapFormat> = [];
	var availableID:Int = -1;

	var spriteGroup:FlxTypedGroup<FlxDragSprite>;

	var fileReference:FileReference;

	var sprText:FlxText;

	override public function create()
	{
		super.create();

		FlxG.autoPause = false;

		var bg = FlxGridOverlay.create(10, 10);
		add(bg);

		var lmao:FlxText = new FlxText(0, 20, 0, "Drag and drop an image.", 24);
		lmao.screenCenter(X);
		lmao.color = 0xFF000000;
		add(lmao);

		spriteGroup = new FlxTypedGroup<FlxDragSprite>();
		add(spriteGroup);

		sprText = new FlxText(10, 10, 0, "null", 24);
		sprText.visible = false;
		sprText.color = 0xFF000000;
		add(sprText);

		FlxG.stage.window.onDropFile.add(function(path:String) {
			trace("combobulating asset with path: " + path);

			var bitmap:BitmapData = BitmapData.fromFile(path);
			var graph:FlxGraphic = FlxGraphic.fromBitmapData(bitmap);

			var temp:FlxDragSprite = new FlxDragSprite(0, 0, graph);
			temp.screenCenter();
			spriteGroup.add(temp);

			assets.push({
				id: availableID + 1,
				name: "Test",
				path: path,
				sprite: temp
			});

			trace("added new drawer");
			trace("x: " + temp.x, " | y: " + temp.y);
			availableID++;
		});
	}

	var initCamX:Float = 0;
	var initCamY:Float = 0;
	var initMsX:Float = 0;
	var initMsY:Float = 0;

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		// buggy as hell
		if (FlxG.keys.pressed.SHIFT)
		{
			if (!FlxG.mouse.pressedMiddle)
			{
				initCamX = FlxG.camera.x;
				initCamY = FlxG.camera.y;

				initMsX = FlxG.mouse.screenX;
				initMsY = FlxG.mouse.screenY;
			}

			if (FlxG.mouse.pressedMiddle)
			{
				FlxG.camera.x = initCamX + (FlxG.mouse.x - initMsX);
				FlxG.camera.y = initCamY + (FlxG.mouse.y - initMsY);
			}
		}

		if (FlxG.mouse.wheel != 0)
		{
			FlxG.camera.zoom += (FlxG.mouse.wheel / 10);
		}

		if (FlxG.keys.justPressed.R)
		{
			FlxG.camera.zoom = 1.0;
		}

		if (FlxG.keys.justPressed.ONE)
		{
			FlxStageFile.generate(Json, assets);
		}
		//if (FlxG.keys.justPressed.TWO)
		//	FlxStageFile.generate(JsonBase64, assets);
		//if (FlxG.keys.justPressed.THREE)
		//	FlxStageFile.generate(Archive, assets);
		if (FlxG.keys.justPressed.FOUR)
			buildStageFromFile();

		spriteGroup.forEach(function(spr:FlxDragSprite)
		{
			if (spr.dragActive)
			{
				sprText.visible = true;
				sprText.text = 'X: ${spr.x}\nY: ${spr.y}';
			}
		});
	}

	function buildStageFromFile()
	{
		fileReference = new FileReference();
		fileReference.addEventListener(Event.SELECT, function(e:Event)
		{
			fileReference.load();
			var data:FileFormat = Json.parse(fileReference.data.toString());

			switch (data.format)
			{
				case "json":
				{
					if (spriteGroup.members.length > 0)
					{
						spriteGroup.clear();
					}

					for (asset in data.assets)
					{
						// they're sorted in from first to last... i think???
						var bitmap:BitmapData;
						bitmap = BitmapData.fromFile(asset.assetPath);

						var graph:FlxGraphic = FlxGraphic.fromBitmapData(bitmap);

						var temp:FlxDragSprite = new FlxDragSprite(asset.x, asset.y, graph);
						spriteGroup.add(temp);
					}
				}
			}
		});
		
		fileReference.browse([new FileFilter("StageBuilder JSON or StageBuilder JSON with Base64 support", "json")]);
	}
}
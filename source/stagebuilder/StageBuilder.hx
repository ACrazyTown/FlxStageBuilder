package stagebuilder;

import stage.FlxStageFile;
import openfl.events.IOErrorEvent;
import flixel.util.FlxColor;
import stage.FlxStageFile.AssetArrayFormat;
import stage.FlxStageFile.AssetArrayFormat;
import haxe.crypto.Base64;
import openfl.utils.Assets;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import haxe.Json as HaxeJson;
import openfl.events.Event;
import openfl.net.FileFilter;
import openfl.net.FileReference;
import flixel.graphics.FlxGraphic;
import openfl.display.BitmapData;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxState;

using StringTools;

class StageBuilder extends FlxState
{
	var assets:Array<AssetArrayFormat> = [];
	var availableID:Int = -1;

	var assetGroup:FlxTypedGroup<DragSprite>;

	var curAssetID:Int = -1; // -1 = none

	var fileReference:FileReference;
	var sprText:FlxText;

	override public function create()
	{
		super.create();

		FlxG.autoPause = false;

		var bg = FlxGridOverlay.create(10, 10);
		add(bg);

		var lmao:FlxText = new FlxText(0, 20, 0, "Press Q for UI", 24);
		lmao.setBorderStyle(OUTLINE, FlxColor.WHITE, 2, 1);
		lmao.screenCenter(X);
		lmao.color = 0xFF000000;
		add(lmao);

		assetGroup = new FlxTypedGroup<DragSprite>();
		add(assetGroup);

		sprText = new FlxText(10, 10, 0, "null", 24);
		sprText.visible = false;
		sprText.color = 0xFF000000;
		add(sprText);

		FlxG.stage.window.onDropFile.add(function(path:String) {
			trace("combobulating asset with path: " + path);

			var bitmap:BitmapData = BitmapData.fromFile(path);
			var graph:FlxGraphic = FlxGraphic.fromBitmapData(bitmap);

			var temp:DragSprite = new DragSprite(0, 0, graph);
			temp.screenCenter();
			temp.ID = availableID + 1;

			//var name = path.split("\\"); // wtf

			var data:AssetArrayFormat = {
				id: temp.ID,
				name: "donk",
				path: path,
				sprite: temp
			};

			temp.data = data;

			assetGroup.add(temp);
			assets.push(data);

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
		/*
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
		*/

		if (FlxG.mouse.wheel != 0)
		{
			FlxG.camera.zoom += (FlxG.mouse.wheel / 10);
		}

		if (FlxG.keys.justPressed.R)
		{
			FlxG.camera.zoom = 1.0;
		}

		if (FlxG.keys.justPressed.ONE)
			exportJSON();
		if (FlxG.keys.justPressed.TWO)
			fromJSON();
		if (FlxG.keys.justPressed.R)
		{
			for (asset in assetGroup)
			{
				asset.kill();
				assetGroup.remove(asset);
				asset.destroy();
				trace("killed asset " + asset.data.id);
			}
		}

		if (FlxG.keys.justPressed.Q)
		{
			if (curAssetID > -1)
				super.openSubState(new StageBuilderSubstate(assets[curAssetID].sprite));
			else
				super.openSubState(new StageBuilderSubstate());
		}

		assetGroup.forEach(function(asset:DragSprite)
		{
			if (asset.dragActive)
				curAssetID = asset.data.id;
			else
				curAssetID = -1;
		});
	}

	public function fromJSON()
	{
		fileReference = new FileReference();
		fileReference.addEventListener(Event.SELECT, function(e:Event)
		{
			fileReference.load();
			var data:FileFormat = HaxeJson.parse(fileReference.data.toString());

			switch (data.format)
			{
				case "json":
				{
					availableID = -1;

					if (assetGroup.members.length > 0)
					{
						for (asset in assetGroup)
						{
							asset.kill();
							assetGroup.remove(asset);
							asset.destroy();
							trace("killed asset " + asset.data.id);
						}
					}

					for (asset in data.assets)
					{
						var bitmap:BitmapData = BitmapData.fromFile(asset.assetPath);
						var graph:FlxGraphic = FlxGraphic.fromBitmapData(bitmap);

						var temp:DragSprite = new DragSprite(asset.x, asset.y, graph);
						temp.ID = availableID + 1;

						var data:AssetArrayFormat = {
							id: temp.ID,
							name: asset.assetName,
							path: asset.assetPath,
							sprite: temp
						};

						temp.data = data;

						assetGroup.add(temp);
						assets.push(data);
						availableID++;
					}
				}
			}
		});

		fileReference.browse([
			new FileFilter("StageBuilder JSON or StageBuilder JSON with Base64 support", "json")
		]);
	}

	function exportJSON()
	{
		var fileData:String = FlxStageFile.generateJSON(Json, assets);

		fileReference = new FileReference();
		fileReference.addEventListener(Event.COMPLETE, onSaveComplete);
		fileReference.addEventListener(Event.CANCEL, onSaveCancel);
		fileReference.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		fileReference.save(fileData, "output" + ".json");
	}

	function onSaveComplete(_):Void
	{
		fileReference.removeEventListener(Event.COMPLETE, onSaveComplete);
		fileReference.removeEventListener(Event.CANCEL, onSaveCancel);
		fileReference.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		fileReference = null;
		FlxG.log.notice("Successfully saved stage data!");
	}

	function onSaveCancel(_):Void
	{
		fileReference.removeEventListener(Event.COMPLETE, onSaveComplete);
		fileReference.removeEventListener(Event.CANCEL, onSaveCancel);
		fileReference.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		fileReference = null;
	}

	function onSaveError(_):Void
	{
		fileReference.removeEventListener(Event.COMPLETE, onSaveComplete);
		fileReference.removeEventListener(Event.CANCEL, onSaveCancel);
		fileReference.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		fileReference = null;
		FlxG.log.error("An error occured whilst saving stage data!");
	}
}
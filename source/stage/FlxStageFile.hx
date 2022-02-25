package stage;

import haxe.crypto.Base64;
import openfl.utils.ByteArray;
import openfl.display.BitmapData;
import flixel.FlxG;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.net.FileReference;

using StringTools;

typedef AssetArrayFormat = 
{
    id:Int,
    name:String,
    path:String,
    ?sprite:flixel.FlxSprite,
    ?base64:String
}

typedef JSONFormat =
{
	id:Int,
	width:Float,
	height:Float,
	x:Float,
	y:Float,
	assetName:String,
	assetPath:String,
	base64Data:String
}

typedef FileFormat = 
{
    assets:Array<JSONFormat>,
    generatedBy:String,
    format:String
}

enum FileTypes
{
    Json;
    JsonBase64;
    Archive;
}

class FlxStageFile
{
    static var file:FileReference;

	public static function generateJSON(format:FileTypes, assetArray:Array<AssetArrayFormat>):String
    {
        var assets = assetArray;
		var data:String = null;

        switch (format)
        {
            case Json:
            {
                var jsonFile:FileFormat = {
                    assets: [],
					generatedBy: "FlxStageBuilder v" + lime.app.Application.current.meta.get("version"),
                    format: "json"
                }

                for (asset in assets)
                {
                    var temp:JSONFormat = {
                        id: asset.id,
                        assetName: asset.name,
                        assetPath: asset.path,
                        width: asset.sprite.width,
                        height: asset.sprite.height,
                        x: asset.sprite.x,
                        y: asset.sprite.y,
                        base64Data: null
                    }

                    jsonFile.assets.push(temp);
                }

                data = haxe.Json.stringify(jsonFile, "\t").trim();
            }
			default:
				data = "null";
		}

		return data;
	}
}

/*
	function generateDumbassJson()
	{
		var doink:Array<Dynamic> = [];

		var pas = {
			assets: [],
			generatedBy: "FlxStageBuilder v0.1",
			format: "json+base64"
		}

		for (i in 0...dumb.length)
		{
			var tempObj:JSONFormat = {
				assetName: "d",
				assetPath: "dumb",
				bitmapData: null,
				width: dumb[i].width,
				height: dumb[i].height,
				x: dumb[i].x,
				y: dumb[i].y,
				id: i
			}

			pas.assets.push(tempObj);
		}
	}

	var data = Json.stringify(pas, "\t").trim();

		file = new FileReference();
		file.addEventListener(Event.COMPLETE, onSaveComplete);
		file.addEventListener(Event.CANCEL, onSaveCancel);
		file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		file.save(data, "stagebuilderOutput" + ".json");

	function onSaveComplete(_):Void
	{
		file.removeEventListener(Event.COMPLETE, onSaveComplete);
		file.removeEventListener(Event.CANCEL, onSaveCancel);
		file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		file = null;
		FlxG.log.notice("Successfully saved data!");
	}

    function onSaveCancel(_):Void
    {
	    file.removeEventListener(Event.COMPLETE, onSaveComplete);
	    file.removeEventListener(Event.CANCEL, onSaveCancel);
	    file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
	    file = null;
    }

    function onSaveError(_):Void
    {
        file.removeEventListener(Event.COMPLETE, onSaveComplete);
        file.removeEventListener(Event.CANCEL, onSaveCancel);
        file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
        file = null;
        FlxG.log.error("Problem saving data");
    }
*/
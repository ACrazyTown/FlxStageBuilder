package stage;

import flixel.FlxSprite;
import openfl.net.FileFilter;
import flixel.graphics.FlxGraphic;
import openfl.display.BitmapData;
import haxe.Json;
import stage.FlxStageFile.FileFormat;
import openfl.events.Event;
import openfl.net.FileReference;
import flixel.group.FlxSpriteGroup;

class FlxStage extends FlxSpriteGroup
{
    private var fileReference:FileReference;
    //private var assets:FlxStage;

    public function new(X:Float = 0, Y:Float = 0)
    {
        //assets = this;
        super(X, Y);
    }

    /**
     * Function that adds assets to the stage via a JSON file.
     * @param jsonPath The path to the JSON file.
     * @param clearStage Should the current assets get removed? (Optional)
    **/
    public function fromJSON(jsonPath:String, ?clearStage:Bool = false)
    {
        var data:FileFormat = Json.parse(jsonPath);

        switch (data.format)
        {
            case "json":
            {
                if (clearStage)
                {
                    for (asset in this)
                    {
                        asset.kill();
                        remove(asset);
                        asset.destroy();
                    }
                }

                for (asset in data.assets)
                {
                    var bitmap:BitmapData;
                    bitmap = BitmapData.fromFile(asset.assetPath);

                    var graphic:FlxGraphic = FlxGraphic.fromBitmapData(bitmap);

                    var sprite:FlxSprite = new FlxSprite(asset.x, asset.y).loadGraphic(graphic);
                    add(sprite);
                }
            }
        }
    }

    /*
    public function fromJSONf()
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
                    if (members.length > 0)
                        clear();

                    for (asset in data.assets)
                    {
                        var bitmap:BitmapData;
                        bitmap = BitmapData.fromFile(asset.assetPath);

                        var graph:FlxGraphic = FlxGraphic.fromBitmapData(bitmap);

                        var temp:FlxDragSprite = new FlxDragSprite(asset.x, asset.y, graph);
                    }
                }
			}
		});

		fileReference.browse([
			new FileFilter("StageBuilder JSON or StageBuilder JSON with Base64 support", "json")
		]);
    }
    */
}
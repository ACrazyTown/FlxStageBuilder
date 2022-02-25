package stagebuilder;

import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;

class StageBuilderSubstate extends FlxSubState
{
    var curAsset:FlxSprite;

    public function new(?asset:FlxSprite)
    {
        super();

        if (asset != null)
            curAsset = asset;

        var overlay:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        overlay.alpha = 0.8;
        add(overlay);
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if (FlxG.keys.justPressed.Q)
        {
            close();
        }
    }
}
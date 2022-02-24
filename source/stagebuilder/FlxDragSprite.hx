package stagebuilder;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;

class FlxDragSprite extends FlxSprite
{
	public var dragActive:Bool = false;

	private var initX:Float = 0;
	private var initY:Float = 0;

	private var initMouseX:Float = 0;
	private var initMouseY:Float = 0;

	public function new(X:Float = 0, Y:Float = 0, Graphic:FlxGraphicAsset)
	{
		super(X, Y);
		loadGraphic(Graphic);
	}

	override function update(elapsed:Float)
	{
		checkDrag();
		super.update(elapsed);
	}

	function checkDrag()
	{
		if (FlxG.mouse.overlaps(this))
		{
			if (FlxG.mouse.justPressed)
			{
				dragActive = !dragActive;

				initX = x;
				initY = y;

				initMouseX = FlxG.mouse.x;
				initMouseY = FlxG.mouse.y;
			}
		}

		if (dragActive)
		{
			x = initX + (FlxG.mouse.x - initMouseX);
			y = initY + (FlxG.mouse.y - initMouseY);
		}
	}
}
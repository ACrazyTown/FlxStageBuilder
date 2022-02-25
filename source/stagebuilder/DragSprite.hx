package stagebuilder;

import stage.FlxStageFile.AssetArrayFormat;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;

class DragSprite extends FlxSprite
{
	public var dragActive:Bool = false;
	public var data:AssetArrayFormat;

	private var initX:Float = 0;
	private var initY:Float = 0;

	private var initMouseX:Float = 0;
	private var initMouseY:Float = 0;

	private var colorTween:FlxTween;
	private var regularColor:FlxColor;

	public function new(X:Float = 0, Y:Float = 0, Graphic:FlxGraphicAsset)
	{
		super(X, Y);
		loadGraphic(Graphic);
	
		regularColor = this.color;

		colorTween = FlxTween.color(this, 0.01, FlxColor.WHITE, FlxColor.WHITE);
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

			if (!colorTween.active)
			{
				colorTween = FlxTween.color(this, 1, FlxColor.WHITE, FlxColor.TRANSPARENT, {onComplete: function(t:FlxTween)
				{
					colorTween = FlxTween.color(this, 1, FlxColor.TRANSPARENT, FlxColor.WHITE);
				}});
			}
		}
		else
		{
			if (this.color != FlxColor.WHITE)
			{
				if (colorTween.active)
					colorTween.cancel();

				this.color = FlxColor.WHITE;
				this.alpha = 1.0;
			}
		}
	}
}
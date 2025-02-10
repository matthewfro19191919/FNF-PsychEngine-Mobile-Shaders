package debug;

import flixel.FlxG;
import openfl.Lib;
import haxe.Timer;
import openfl.text.TextField;
import openfl.text.TextFormat;

/**
	The FPS class provides an easy-to-use monitor to display
	the current frame rate of an OpenFL project
**/
class FPSCounter extends TextField
{
	/**
		The current frame rate, expressed using frames-per-second
	**/
	public var currentFPS(default, null):Int;

	/**
		The current memory usage (WARNING: this is NOT your total program memory usage, rather it shows the garbage collector memory)
	**/
	public var memoryMegas(get, never):Float;

    @:noCompletion private var lastFramerateUpdateTime:Float;
    @:noCompletion private var updateTime:Int;
	@:noCompletion private var framesCount:Int;
	@:noCompletion private var prevTime:Int;

	public function new(x:Float = 10, y:Float = 10, color:Int = 0x000000)
	{
		super();

		this.x = x;
		this.y = y;

		currentFPS = 0;
		selectable = false;
		mouseEnabled = false;
		defaultTextFormat = new TextFormat("_sans", 14, color);
		autoSize = LEFT;
		multiline = true;
		text = "FPS: ";

		lastFramerateUpdateTime = Timer.stamp();
		prevTime = Lib.getTimer();
		updateTime = prevTime + 500;
	}


	public dynamic function updateText():Void { // so people can override it in hscript
		text = 'FPS: ${currentFPS}'
		+ '\nMemory: ${flixel.util.FlxStringUtil.formatBytes(memoryMegas)}';

		textColor = 0xFFFFFFFF;
		if (currentFPS < FlxG.stage.window.frameRate * 0.5)
			textColor = 0xFFFF0000;
	}

	private override function __enterFrame(deltaTime:Float):Void
	{
		// Flixel keeps reseting this to 60 on focus gained
		if (FlxG.stage.window.frameRate != ClientPrefs.data.framerate && FlxG.stage.window.frameRate != FlxG.game.focusLostFramerate)
			FlxG.stage.window.frameRate = ClientPrefs.data.framerate;

		var currentTime = openfl.Lib.getTimer();
		framesCount++;

        if (currentTime >= updateTime) {
            var elapsed = currentTime - prevTime;
            currentFPS = Math.ceil((framesCount * 1000) / elapsed);
            framesCount = 0;
            prevTime = currentTime;
            updateTime = currentTime + 500;
        }

		// Set Update and Draw framerate to the current FPS every 1.5 second to prevent "slowness" issue
		if ((FlxG.updateFramerate >= currentFPS + 5 || FlxG.updateFramerate <= currentFPS - 5)
			&& haxe.Timer.stamp() - lastFramerateUpdateTime >= 1.5 && currentFPS >= 30)
		{
			FlxG.updateFramerate = FlxG.drawFramerate = currentFPS;
			lastFramerateUpdateTime = haxe.Timer.stamp();
		}

		updateText();
	}

	inline function get_memoryMegas():Float
		return cpp.vm.Gc.memInfo64(cpp.vm.Gc.MEM_INFO_USAGE);
}

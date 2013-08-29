package ;

import ca.esdot.runnermark.RunnerEngine;
import com.asliceofcrazypie.flash.TilesheetStage3D;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.display3D.Context3DRenderMode;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.Lib;
import flash.text.TextField;
import flash.text.TextFormat;
import openfl.Assets;
import ru.stablex.sxdl.SparrowParser;
import ru.stablex.sxdl.SxClip;
import ru.stablex.sxdl.SxStage;
import utils.FPS;

/**
 * ...
 * @author AS3Boyan
 */

class RunnerMark extends Sprite 
{	
	var engine:RunnerEngine;
	var prevTime:Int;
	var stats:FPS;
	var runner:SxClip;
	static public var sxStage:SxStage;
	
	public function new()
	{
		super();
		
		//runner = new SxClip();
		//
		//runner.addAnimation("run", [
		//RunnerMark.sxStage.getTile("Runner.swf/0000"),
		//RunnerMark.sxStage.getTile("Runner.swf/0001"),
		//RunnerMark.sxStage.getTile("Runner.swf/0002"),
		//RunnerMark.sxStage.getTile("Runner.swf/0003"),
		//RunnerMark.sxStage.getTile("Runner.swf/0004"),
		//RunnerMark.sxStage.getTile("Runner.swf/0005"),
		//RunnerMark.sxStage.getTile("Runner.swf/0006"),
		//RunnerMark.sxStage.getTile("Runner.swf/0007"),
		//RunnerMark.sxStage.getTile("Runner.swf/0008"),
		//RunnerMark.sxStage.getTile("Runner.swf/0009"),
		//RunnerMark.sxStage.getTile("Runner.swf/0010"),
		//RunnerMark.sxStage.getTile("Runner.swf/0011"),
		//RunnerMark.sxStage.getTile("Runner.swf/0012"),
		//RunnerMark.sxStage.getTile("Runner.swf/0013"),
		//RunnerMark.sxStage.getTile("Runner.swf/0014"),
		//RunnerMark.sxStage.getTile("Runner.swf/0015")
		//], 30);
		//runner.play("run");
		//sxStage.addChild(runner);
				
		addEventListener(Event.ADDED_TO_STAGE, onAdded);
	}
	
	private function onAdded(e:Event):Void 
	{
		removeEventListener(Event.ADDED_TO_STAGE, onAdded);
		
		//runner.x = stage.stageWidth / 2;
		//runner.y = stage.stageHeight / 2;
		
		#if flash11
		TilesheetStage3D.init(stage, 0, 5, init, Context3DRenderMode.AUTO);
		#else
		init();
		#end
	}
	
	function init(?result:String):Void
	{
		sxStage = new SxStage();
		new SparrowParser(sxStage, Assets.getText("img/RunnerMark.xml"), Assets.getBitmapData("img/RunnerMark.png"));
		sxStage.lockSprites();
		
		createScene();
	}
	
	private function onEnterFrame(e:Event):Void 
	{
		var elapsed:Float = Lib.getTimer() - prevTime;
		prevTime = Lib.getTimer();
		
		engine.fps = stats.fps;
		engine.step(elapsed);
		stats.score = engine.runnerScore;
        sxStage.render(Lib.current.graphics);
	}
	
	function restartEngine():Void
	{
		while(numChildren > 0) removeChildAt(0);
		sxStage.freeChildren(true);
		createScene();
	}
	
	function createScene():Void
	{
		RunnerEngine.targetFPS = 58; 
		
		engine = new RunnerEngine(stage.stageWidth, stage.stageHeight);
		engine.onComplete = onEngineComplete;
		sxStage.addChild(engine);
		
		prevTime = Lib.getTimer();
		
		createStats();
		addEventListener(Event.ENTER_FRAME, onEnterFrame);
	}
	
	function createStats():Void 
	{
		if (stats == null) stats = new utils.FPS(10,10,0xffffff);
		Lib.current.addChild(stats);
	}
	
	function onEngineComplete():Void
	{
		while(numChildren > 0) removeChildAt(0);
		sxStage.freeChildren(true);
		removeEventListener(Event.ENTER_FRAME, onEnterFrame);
		
		var bg:Bitmap = new Bitmap(Assets.getBitmapData("img/scoreBg.png"));
		bg.x = Std.int((stage.stageWidth - bg.width)/2);
		bg.y = Std.int((stage.stageHeight - bg.height)/2);
		addChild(bg);
		
		var tf:TextFormat = new TextFormat("_sans", 48, 0xFFFFFF, true);
		var score:TextField = new TextField();
		score.defaultTextFormat = tf;
		score.text = ""+engine.runnerScore;
		score.width = 300;
		score.height = 50;
		score.x = Std.int(bg.x + (bg.width - score.textWidth) / 2);
		score.y = Std.int(bg.y + (bg.height - score.textHeight) / 2);
		addChild(score);
		
		stage.addEventListener(MouseEvent.CLICK, onRestartClicked);
	}
	
	function onRestartClicked(event:MouseEvent):Void 
	{
		stage.removeEventListener(MouseEvent.CLICK, onRestartClicked);
		restartEngine();	
	}
	
	public static function main() 
	{
		// static entry point
		Lib.current.stage.align = flash.display.StageAlign.TOP_LEFT;
		Lib.current.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		Lib.current.addChild(new RunnerMark());
	}
}

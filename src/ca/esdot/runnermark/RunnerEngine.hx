package ca.esdot.runnermark;

import ca.esdot.runnermark.sprites.EnemySprite;
import ca.esdot.runnermark.sprites.GenericSprite;
import ca.esdot.runnermark.sprites.RunnerSprite;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.GradientType;
import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Matrix;
import flash.Lib;
import haxe.ds.StringMap.StringMap;
import ru.stablex.sxdl.SxObject;
import ru.stablex.sxdl.SxTile;

/**
 * ...
 * @author AS3Boyan
 */
class RunnerEngine extends SxObject
{
	static inline var SPEED:Float = 0.33;
	
	var bgStrip1:SxObject;
	var bgStrip2:SxObject;
	
	var steps:Int;
	var groundY:Int;
	
	var spritePool:StringMap<Array<GenericSprite>>;
	var tilePool:StringMap<Array<SxObject>>;
	var groundList:Array<SxObject>;
	var particleList:Array<SxObject>;
	var enemyList:Array<GenericSprite>;
	
	var incrementDelay:Int;
	var maxIncrement:Int;
	var lastIncrement:Int;
	var runner:RunnerSprite;
	var lastGroundPiece:SxObject;
	var stageHeight:Int;
	var stageWidth:Int;
	//var sky:Bitmap;
	
	static public var targetFPS:Int;
	public var runnerScore(default, default):Int;
	public var fps:Int;
	public var onComplete:Dynamic;
	
	public function new(_stageWidth:Int, _stageHeight:Int) 
	{
		super();
		
		lastIncrement = Lib.getTimer() + 2000;
		fps = -1;
		steps = 0;
		runnerScore = 0;
		incrementDelay = 250;
		maxIncrement = 12000;
		
		spritePool = new StringMap<Array<GenericSprite>>();
		tilePool = new StringMap<Array<SxObject>>();
		groundList = new Array<SxObject>();
		particleList = new Array<SxObject>();
		enemyList = new Array<GenericSprite>();
		
		createChildren();
		
		stageWidth = _stageWidth;
		stageHeight = _stageHeight;
		
		//sky.width = stageWidth;
		//sky.height = stageHeight;
		
		bgStrip1.y = stageHeight - Std.int(bgStrip1.height/2) - 50;
		bgStrip2.y = stageHeight - Std.int(bgStrip2.height/2) - 50;
		
		//Create Runner
		groundY = Std.int(stageHeight - 50);
		runner.x = stageWidth * .2;
		runner.y = groundY - 65;
		runner.groundY = Std.int(runner.y);
		runner.enemyList = enemyList;
		
		addGround(3);
		
		addParticles(32);
	}
	
	public function createChildren():Void
	{
		//var skyData:BitmapData = createSkyData();
		//sky = new Bitmap(skyData);
		
		var bitmap1, bitmap2;

		//BG Strip 1
		bgStrip1 = new SxObject();
		bitmap1 =  new SxObject();
		bitmap1.tile = RunnerMark.sxStage.getTile("bg1");
		bitmap1.scaleX = 2;
		bitmap1.scaleY = 2;
		bitmap2 = new SxObject();
		bitmap2.tile = RunnerMark.sxStage.getTile("bg1");
		bitmap2.scaleX = 2;
		bitmap2.scaleY = 2;
		bitmap1.x = bitmap1.width / 2;
		bitmap2.x = bitmap1.x + bitmap1.width;
		bgStrip1.addChild(bitmap1);
		bgStrip1.addChild(bitmap2);
		addChild(bgStrip1);
		
		//BG Strip 2
		bgStrip2 = new SxObject();
		bitmap1 =  new SxObject();
		bitmap1.tile = RunnerMark.sxStage.getTile("bg2");
		bitmap1.scaleX = 2;
		bitmap1.scaleY = 2;
		bitmap2 = new SxObject();
		bitmap2.tile = RunnerMark.sxStage.getTile("bg2");
		bitmap2.scaleX = 2;
		bitmap2.scaleY = 2;
		bitmap1.x = bitmap1.width / 2;
		bitmap2.x = bitmap1.x + bitmap1.width;
		bgStrip2.addChild(bitmap1);
		bgStrip2.addChild(bitmap2);
		addChild(bgStrip2);
		
		//Runner
		runner = new RunnerSprite();
		
		var tiles:Array<SxTile> = new Array();
		
		for (i in 0...16)
		{
			tiles.push(RunnerMark.sxStage.getTile("Runner.swf/00" + (i < 10?"0" : "") + Std.string(i)));
		}
		
		runner.addAnimation("run", tiles, 30);
		runner.play("run");
		addChild(runner);
	}
	
	function createGroundPiece():SxObject 
	{
		var sprite:SxObject = null;// = getTile("ground");
		if (sprite == null)
			sprite = new SxObject();
			sprite.tile = RunnerMark.sxStage.getTile("ground");
		
		addChildAt(sprite, getChildIndex(bgStrip2) + 1);
		return sprite; 
	}
	
	function createParticle():SxObject 
	{
		var sprite:SxObject = null;// = getTile("cloud");
		if (sprite == null)
			sprite = new SxObject();
			sprite.tile = RunnerMark.sxStage.getTile("cloud");
		
		addChild(sprite);
		return sprite;
	}
	
	function createEnemy():EnemySprite 
	{
		var sprite:EnemySprite = null;// = cast getSprite("Enemy");
		if (sprite == null)
			sprite = new EnemySprite();
			
			var tiles:Array<SxTile> = new Array();
		
			for (i in 0...16)
			{
				tiles.push(RunnerMark.sxStage.getTile("Enemy.swf/00" + (i < 10?"0" : "") + Std.string(i)));
			}
			
			sprite.addAnimation("run", tiles, 30);
			sprite.play("run");
			
		sprite.scaleX = sprite.scaleY  = 0.6 + 0.4 * Math.random();
		//sprite.mirror = Math.random() > 0.5 ? 1 : 0;
		
		addChildAt(sprite, getChildIndex(runner) - 1);
		return sprite;
	}
	
	function updateEnemies(elapsed:Float):Void 
	{ 
		var enemy:EnemySprite;
		var i = enemyList.length-1;
		while (i >= 0) 
		{
			enemy = cast enemyList[i];
			enemy.x -= elapsed * .33;
			//enemy.update();
			//Loop to other edge of screen
			if (enemy.x < -enemy.width)
				enemy.x = stageWidth + 20;
			i--;
		}
	}
	
	function updateParticles(elapsed:Float):Void 
	{
		if (steps % 3 == 0)
			addParticles(3);
		
		//Move Particls
		var p:SxObject;
		var i = particleList.length-1;
		while (i >= 0) 
		{
			p = particleList[i];
			p.x -= elapsed * SPEED * .2;
			p.alpha -= .01;
			p.scaleX -= .01;
			p.scaleY -= .01;
			//Remove Particle
			if (p.alpha < 0 || p.scaleX < 0 || p.scaleY < 0) {
				particleList.splice(i, 1);
				putTile(p);
			}
			i--;
		}
	}
	
	function updateGround(elapsed:Float)
	{
		//Add platforms
		if (steps % (fps > 30? 100 : 50) == 0)
			addGround(1, Std.int(stageHeight * .25 + stageHeight * .5 * Math.random()));
		
		//Move Ground
		var ground:SxObject;
		var i = groundList.length-1;
		while (i >= 0) 
		{
			ground = groundList[i];
			ground.x -= elapsed * SPEED;
			//Remove ground
			if (ground.x < -ground.width/2) {
				groundList.splice(i, 1);
				putTile(ground);
			}
			i--;
		}
		//Add Ground
		var lastX:Float = (lastGroundPiece != null)? lastGroundPiece.x + lastGroundPiece.width/2 : 0;
		if (lastX < stageWidth) 
			addGround(1, 0);
	}
	
	function updateBg(elapsed:Float):Void 
	{
		bgStrip1.x -= elapsed * SPEED * .25;
		if (bgStrip1.x < -bgStrip1.width/2){ bgStrip1.x = 0; }

		bgStrip2.x -= elapsed * SPEED * .5;
		if (bgStrip2.x < -bgStrip2.width / 2) { bgStrip2.x = 0; }
	}
	
	public function step(elapsed:Float) 
	{
		steps++;

		if(enemyList.length > 3)
			runnerScore = targetFPS * 10 + enemyList.length;
		else if (fps > 0)
			runnerScore = fps * 10;
		
		runner.rotation += 0.1;
		//updateBg(elapsed);
		if(enemyList != null) updateEnemies(elapsed);
		if(groundList != null) updateGround(elapsed);
		//updateParticles(elapsed);
		
		var increment:Int = Lib.getTimer() - lastIncrement;
		if (fps >= targetFPS && increment > incrementDelay) {
			//+ Math.floor(enemyList.length/50)
			addEnemies(25);
			lastIncrement = Lib.getTimer();
		} 
		else if (fps < targetFPS && enemyList.length < 3 && increment > incrementDelay) {
			// add 3 enemies even if the device is slow
			addEnemies(1);
			incrementDelay = increment + 500;
			lastIncrement = Lib.getTimer();
		} 
		else if (increment > maxIncrement) {
			//Test is Complete!
			if (onComplete != null) onComplete();
			stopEngine();
		}
	}
	
	function stopEngine():Void 
	{
		RunnerMark.sxStage.freeChildren();
		
		while(numChildren > 0)
			removeChildAt(0);
	}
	
	function addGround(numPieces:Int, height:Int = 0):Void 
	{
		var lastX:Float = 0;
		if(lastGroundPiece != null)
			lastX = Std.int(lastGroundPiece.x + lastGroundPiece.width / 2 - 1);
		
		var piece:SxObject = null;
		for (i in 0...numPieces)
		{
			piece = createGroundPiece(); 
			piece.y = groundY + piece.height / 2 - height;
			piece.x = lastX + piece.width / 2;
			lastX += Std.int(piece.width/2 - 1);
			groundList.push(piece);
		}
		if (height == 0) lastGroundPiece = piece; 
	}
	
	function addParticles(numParticles:Int):Void 
	{
		var p:SxObject;
		for (i in 0...numParticles)
		{
			p = createParticle(); 
			p.x = runner.x - 40;
			p.y = runner.y + runner.height / 4 + runner.height * .25 * Math.random() - 10;
			particleList.push(p);
			p.scaleX = 0.6;
			p.scaleY = 0.6;
			p.alpha = 0.6;
		}
	}
	
	
	public function addEnemies(numEnemies:Int = 1):Void 
	{
		var enemy:EnemySprite;
		for (i in 0...numEnemies) 
		{
			enemy = createEnemy(); 
			enemy.y = groundY - enemy.height/2 + 12;
			enemy.x = stage.stageWidth - 50 + Math.random() * 100;
			enemy.groundY = Std.int(enemy.y);
			enemy.y = -enemy.height;
			enemyList.push(enemy);
		}
	}	
	
	function createSkyData():BitmapData 
	{
		var m:Matrix = new Matrix();
		m.createGradientBox(64, 64, Math.PI/2);
		var rect:Sprite = new Sprite();
		rect.graphics.beginGradientFill(GradientType.LINEAR, [0x0, 0x1E095E], [1, .5], [0, 255], m);
		rect.graphics.drawRect(0, 0, 128, 128);
		var col = 0;
		var skyData:BitmapData = new BitmapData(128, 128, false, col);
		skyData.draw(rect);
		return skyData;
	}
	
	
	public var numEnemies(get_numEnemies, null):Int;
	function get_numEnemies():Int {
		return enemyList.length;
	}
	
	//Simple Pooling Functions
	public function getSprite(type:String):GenericSprite {

		if (spritePool.exists(type))
			return spritePool.get(type).pop();
		return null;
	}
	
	public function putSprite(sprite:GenericSprite):Void 
	{
		if (sprite.parent != null)
			sprite.parent.removeChild(sprite);
		//Rewind before we return ;)
		sprite.x = sprite.y = 0;
		sprite.scaleX = sprite.scaleY = 1;
		sprite.alpha = 1;
		sprite.rotation = 0;
		
		//Put in pool
		
		//if(!spritePool.exists("Enemy"))
			//spritePool.set("Enemy", new Array<GenericSprite>());
		//spritePool.get("Enemy").push(sprite);
	}

	public function getTile(type:String):SxObject 
	{
		if (tilePool.exists(type))
			return tilePool.get(type).pop();
		return null;
	}
	
	public function putTile(sprite:SxObject):Void 
	{
		if (sprite.parent != null)
			sprite.parent.removeChild(sprite);
		//Rewind before we return ;)
		sprite.x = sprite.y = 0;
		sprite.scaleX = sprite.scaleY = 1;
		sprite.alpha = 1;
		sprite.rotation = 0;
		
		//Put in pool
		if(!tilePool.exists(sprite.name))
			tilePool.set(sprite.name, new Array<SxObject>());
		tilePool.get(sprite.name).push(sprite);
	}
}
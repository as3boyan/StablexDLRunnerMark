package ca.esdot.runnermark.sprites;

import ru.stablex.sxdl.SxClip;

/**
 * ...
 * @author AS3Boyan
 */
class GenericSprite extends SxClip
{
	public var groundY:Int;
	var gravity:Float;
	var isJumping:Bool;
	var velY:Float;
	
	public function new() 
	{
		super();
		
		gravity = 1;
		velY = 0;
	}
	
}

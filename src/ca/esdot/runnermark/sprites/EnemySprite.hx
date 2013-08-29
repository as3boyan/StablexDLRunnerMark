package ca.esdot.runnermark.sprites;

/**
 * ...
 * @author AS3Boyan
 */
class EnemySprite extends GenericSprite
{

	public function new() 
	{
		super();
	}
	
	override public function update(tileDataIdx:Int):Int 
	{
		velY += gravity;
		y += velY; 
		if (y > groundY) {
			y = groundY;
			isJumping = false;
			velY = 0;
		}
		
		if (!isJumping && y == groundY && Math.random() < .02) {
			velY = -height * .25;
			isJumping = true;
		}
		
		dirty = true;
		return super.update(tileDataIdx);
	}
	
}
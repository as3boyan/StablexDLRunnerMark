package ca.esdot.runnermark.sprites;

/**
 * ...
 * @author AS3Boyan
 */
class RunnerSprite extends GenericSprite
{
	public var enemyList:Array<GenericSprite>;

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
		
		if(enemyList != null && !isJumping) 
		{
			var w = width;
			for (enemy in enemyList) 
			{
				if (enemy.x > x && enemy.x - x < w * 1.5) {
					velY = -22;
					isJumping = true;
					break;
				}
			}
		}
		
		dirty = true;
		
		return super.update(tileDataIdx);
	}
	
}
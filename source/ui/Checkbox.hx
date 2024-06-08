package ui;

import flixel.util.FlxTimer;
import flixel.FlxSprite;

class Checkbox extends FlxSprite
{
    public var sprTracker:FlxSprite;
    public var checked:Bool = false;

    public function new(tracking:FlxSprite)
    {
        super();

        frames = Paths.getSparrowAtlas('options menu/checkboxanim');
		animation.addByPrefix("unchecked", "checkbox0", 24, false);
		animation.addByPrefix("unchecking", "checkbox anim reverse", 24, false);
		animation.addByPrefix("checking", "checkbox anim0", 24, false);
		animation.addByPrefix("checked", "checkbox finish", 24, false);
        
        setGraphicSize(Std.int(0.9 * width));
        
        updateHitbox();
        
        this.sprTracker = tracking;
        scrollFactor.set();

        animationFinished(checked ? 'checking' : 'unchecking');
        animation.finishCallback = animationFinished;

        antialiasing = true;
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if(sprTracker != null)
            setPosition(sprTracker.x + sprTracker.width + 5, sprTracker.y - (sprTracker.height / 4));

        if(checked) {
			if(animation.curAnim.name != 'checked' && animation.curAnim.name != 'checking') {
				animation.play('checking', true);
				offset.set(34, 25);
			}
		} else if(animation.curAnim.name != 'unchecked' && animation.curAnim.name != 'unchecking') {
			animation.play("unchecking", true);
			offset.set(25, 28);
		}
    }

    private function animationFinished(name:String)
        {
            switch(name)
            {
                case 'checking':
                    animation.play('checked', true);
                    offset.set(3, 12);
    
                case 'unchecking':
                    animation.play('unchecked', true);
                    offset.set(0, 2);
            }
        }
}
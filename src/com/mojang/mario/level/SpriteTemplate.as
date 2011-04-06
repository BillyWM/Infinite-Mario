package com.mojang.mario.level {

import com.mojang.mario.LevelScene;
import com.mojang.mario.sprites.*;

public class SpriteTemplate
{
    public var lastVisibleTick:int = -1;
    public var sprite:JSprite;
    public var isDead:Boolean = false;
    private var winged:Boolean;
    
    private var type:int;
    
    public function SpriteTemplate(type:int, winged:Boolean)
    {
        this.type = type;
        this.winged = winged;
    }
    
    public function spawn(world:LevelScene, x:int, y:int, dir:int):void
    {
        if (isDead) return;

        if (type==Enemy.ENEMY_FLOWER)
        {
            sprite = new FlowerEnemy(world, x*16+15, y*16+24);
        }
        else
        {
            sprite = new Enemy(world, x*16+8, y*16+15, dir, type, winged);
        }
        sprite.spriteTemplate = this;
        world.addSprite(sprite);
    }
}
}

package com.mojang.mario.sprites {

import com.mojang.mario.Art;
import com.mojang.mario.LevelScene;


public class FireFlower extends JSprite
{
    private var width:int = 4;
    internal var height:int = 24;

    private var world:LevelScene;
    public var facing:int;

    public var avoidCliffs:Boolean = false;
    private var life:int;

    public function FireFlower(world:LevelScene, x:int, y:int)
    {
        sheet = Art.items;

        this.x = x;
        this.y = y;
        this.world = world;
        xPicO = 8;
        yPicO = 15;

        xPic = 1;
        yPic = 0;
        height = 12;
        facing = 1;
        wPic  = hPic = 16;
        life = 0;
    }

    override public function collideCheck():void
    {
        var xMarioD:Number = world.mario.x - x;
        var yMarioD:Number = world.mario.y - y;
        var w:Number = 16;
        if (xMarioD > -16 && xMarioD < 16)
        {
            if (yMarioD > -height && yMarioD < world.mario.height)
            {
                world.mario.getFlower();
                spriteContext.removeSprite(this);
            }
        }
    }

    override public function move():void
    {
        if (life<9)
        {
            layer = 0;
            y--;
            life++;
            return;
        }
    }
}
}

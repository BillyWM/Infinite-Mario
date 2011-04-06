package com.mojang.mario.sprites {

import com.mojang.mario.Art;
import com.mojang.mario.LevelScene;


public class Mushroom extends JSprite
{
    private static var GROUND_INERTIA:Number = 0.89;
    private static var AIR_INERTIA:Number = 0.89;

    private var runTime:Number = 0;
    private var onGround:Boolean = false;
    private var mayJump:Boolean = false;
    private var jumpTime:int = 0;
    private var xJumpSpeed:Number = 0;
    private var yJumpSpeed:Number = 0;

    private var width:int = 4;
    internal var height:int = 24;

    private var world:LevelScene;
    public var facing:int;

    public var avoidCliffs:Boolean = false;
    private var life:int;

    public function Mushroom(world:LevelScene, x:int, y:int)
    {
        sheet = Art.items;

        this.x = x;
        this.y = y;
        this.world = world;
        xPicO = 8;
        yPicO = 15;

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
                world.mario.getMushroom();
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
        var sideWaysSpeed:Number = 1.75;
        layer = 1;
        //        Number sideWaysSpeed = onGround ? 2.5f : 1.2f;

        if (xa > 2)
        {
            facing = 1;
        }
        if (xa < -2)
        {
            facing = -1;
        }

        xa = facing * sideWaysSpeed;

        mayJump = (onGround);

        xFlipPic = facing == -1;

        runTime += (Math.abs(xa)) + 5;



        if (!_move(xa, 0)) facing = -facing;
        onGround = false;
        _move(0, ya);

        ya *= 0.85;
        if (onGround)
        {
            xa *= GROUND_INERTIA;
        }
        else
        {
            xa *= AIR_INERTIA;
        }

        if (!onGround)
        {
            ya += 2;
        }
    }

    private function _move(xa:Number, ya:Number):Boolean
    {
        while (xa > 8)
        {
            if (!_move(8, 0)) return false;
            xa -= 8;
        }
        while (xa < -8)
        {
            if (!_move(-8, 0)) return false;
            xa += 8;
        }
        while (ya > 8)
        {
            if (!_move(0, 8)) return false;
            ya -= 8;
        }
        while (ya < -8)
        {
            if (!_move(0, -8)) return false;
            ya += 8;
        }

        var collide:Boolean = false;
        if (ya > 0)
        {
            if (isBlocking(x + xa - width, y + ya, xa, 0)) collide = true;
            else if (isBlocking(x + xa + width, y + ya, xa, 0)) collide = true;
            else if (isBlocking(x + xa - width, y + ya + 1, xa, ya)) collide = true;
            else if (isBlocking(x + xa + width, y + ya + 1, xa, ya)) collide = true;
        }
        if (ya < 0)
        {
            if (isBlocking(x + xa, y + ya - height, xa, ya)) collide = true;
            else if (collide || isBlocking(x + xa - width, y + ya - height, xa, ya)) collide = true;
            else if (collide || isBlocking(x + xa + width, y + ya - height, xa, ya)) collide = true;
        }
        if (xa > 0)
        {
            if (isBlocking(x + xa + width, y + ya - height, xa, ya)) collide = true;
            if (isBlocking(x + xa + width, y + ya - height / 2, xa, ya)) collide = true;
            if (isBlocking(x + xa + width, y + ya, xa, ya)) collide = true;

            if (avoidCliffs && onGround && !world.level.isBlocking(int((x + xa + width) / 16), int((y) / 16 + 1), xa, 1)) collide = true;
        }
        if (xa < 0)
        {
            if (isBlocking(x + xa - width, y + ya - height, xa, ya)) collide = true;
            if (isBlocking(x + xa - width, y + ya - height / 2, xa, ya)) collide = true;
            if (isBlocking(x + xa - width, y + ya, xa, ya)) collide = true;

            if (avoidCliffs && onGround && !world.level.isBlocking(int((x + xa - width) / 16), int((y) / 16 + 1), xa, 1)) collide = true;
        }

        if (collide)
        {
            if (xa < 0)
            {
                x = int((x - width) / 16) * 16 + width;
                this.xa = 0;
            }
            if (xa > 0)
            {
                x = int((x + width) / 16 + 1) * 16 - width - 1;
                this.xa = 0;
            }
            if (ya < 0)
            {
                y = int((y - height) / 16) * 16 + height;
                jumpTime = 0;
                this.ya = 0;
            }
            if (ya > 0)
            {
                y = int(y / 16 + 1) * 16 - 1;
                onGround = true;
            }
            return false;
        }
        else
        {
            x += xa;
            y += ya;
            return true;
        }
    }

    private function isBlocking(_x:Number, _y:Number, xa:Number, ya:Number):Boolean
    {
        var x:int = int((_x / 16));
        var y:int = int((_y / 16));
        if (x == int((this.x / 16)) && y == int((this.y / 16))) return false;

        var blocking:Boolean = world.level.isBlocking(x, y, xa, ya);

        var block:uint = world.level.getBlock(x, y);

        return blocking;
    }

    override public function bumpCheck(xTile:int, yTile:int):void
    {
        if (x + width > xTile * 16 && x - width < xTile * 16 + 16 && yTile==int((y-1)/16))
        {
            facing = -world.mario.facing;
            ya = -10;
        }
    }

}
}

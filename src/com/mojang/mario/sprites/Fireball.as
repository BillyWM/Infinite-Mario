package com.mojang.mario.sprites {

import com.mojang.mario.Art;
import com.mojang.mario.LevelScene;


public class Fireball extends JSprite
{
    private static var GROUND_INERTIA:Number = 0.89;
    private static var AIR_INERTIA:Number = 0.89;

    private var runTime:Number = 0;
    private var onGround:Boolean = false;

    private var width:int = 4;
    internal var height:int = 24;

    private var world:LevelScene;
    public var facing:int;

    public var avoidCliffs:Boolean = false;
    public var anim:int;

    public var dead:Boolean = false;
    private var deadTime:int = 0;

    public function Fireball(world:LevelScene, x:Number, y:Number, facing:int)
    {
        sheet = Art.particles;

        this.x = x;
        this.y = y;
        this.world = world;
        xPicO = 4;
        yPicO = 4;

        yPic = 3;
        height = 8;
        this.facing = facing;
        wPic = 8;
        hPic = 8;

        xPic = 4;
        ya = 4;
    }

    override public function move():void
    {
        if (deadTime > 0)
        {
            for (var i:int = 0; i < 8; i++)
            {
                world.addSprite(new Sparkle(int((x + Math.random() * 8 - 4))+4,
                                            int((y + Math.random() * 8-4))+2,
                                            Number(Math.random() * 2 - 1-facing),
                                            Number(Math.random() *2 -1),
                                            0, 1, 5));
            }
            spriteContext.removeSprite(this);

            return;
        }

        if (facing != 0) anim++;

        var sideWaysSpeed:Number = 8;
        // Number sideWaysSpeed = onGround ? 2.5f : 1.2f;

        if (xa > 2)
        {
            facing = 1;
        }
        if (xa < -2)
        {
            facing = -1;
        }

        xa = facing * sideWaysSpeed;

        world.checkFireballCollide(this);

        xFlipPic = facing == -1;

        runTime += (Math.abs(xa)) + 5;

        xPic = (anim) % 4;



        if (!_move(xa, 0))
        {
            die();
        }
        
        onGround = false;
        _move(0, ya);
        if (onGround) ya = -10;

        ya *= 0.95;
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
            ya += 1.5;
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

    public function die():void
    {
        dead = true;

        xa = -facing * 2;
        ya = -5;
        deadTime = 100;
    }
}
}

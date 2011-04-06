package com.mojang.mario.sprites {

import com.mojang.mario.Art;
import com.mojang.mario.LevelScene;


public class BulletBill extends JSprite
{
    private var width:int = 4;
    internal var height:int = 24;

    private var world:LevelScene;
    public var facing:int = 0;

    public var avoidCliffs:Boolean = false;
    public var anim:int = 0;

    public var dead:Boolean = false;
    private var deadTime:int = 0;


    public function BulletBill(world:LevelScene, x:Number, y:Number, dir:int)
    {
        sheet = Art.enemies;

        this.x = x;
        this.y = y;
        this.world = world;
        xPicO = 8;
        yPicO = 31;

        height = 12;
        facing = 0;
        wPic = 16;
        yPic = 5;

        xPic = 0;
        ya = -5;
        this.facing = dir;
    }

    override public function collideCheck():void
    {
        if (dead) return;

        var xMarioD:Number = world.mario.x - x;
        var yMarioD:Number = world.mario.y - y;
        var w:Number = 16;
        if (xMarioD > -16 && xMarioD < 16)
        {
            if (yMarioD > -height && yMarioD < world.mario.height)
            {
                if (world.mario.ya > 0 && yMarioD <= 0 && (!world.mario.onGround || !world.mario.wasOnGround))
                {
                    world.mario.stompBill(this);
                    dead = true;

                    xa = 0;
                    ya = 1;
                    deadTime = 100;
                }
                else
                {
                    world.mario.getHurt();
                }
            }
        }
    }

    override public function move():void
    {
        if (deadTime > 0)
        {
            deadTime--;

            if (deadTime == 0)
            {
                deadTime = 1;
                for (var i:int = 0; i < 8; i++)
                {
                    world.addSprite(new Sparkle(int((x + Math.random() * 16 - 8) + 4),
                                                int((y - Math.random() * 8) + 4),
                                                Number((Math.random() * 2 - 1)),
                                                Number(Math.random() * -1),
                                                0, 1, 5));
                }
                spriteContext.removeSprite(this);
            }

            x += xa;
            y += ya;
            ya *= 0.95;
            ya += 1;

            return;
        }

        var sideWaysSpeed:Number = 4;

        xa = facing * sideWaysSpeed;
        xFlipPic = facing == -1;
        _move(xa, 0);
    }

    private function _move(xa:Number, ya:Number):Boolean
    {
        x += xa;
        return true;
    }
    
    override public function fireballCollideCheck(fireball:Fireball):Boolean
    {
        if (deadTime != 0) return false;

        var xD:Number = fireball.x - x;
        var yD:Number = fireball.y - y;

        if (xD > -16 && xD < 16)
        {
            if (yD > -height && yD < fireball.height)
            {
                return true;
            }
        }
        return false;
    }      

    override public function shellCollideCheck(shell:Shell):Boolean
    {
        if (deadTime != 0) return false;

        var xD:Number = shell.x - x;
        var yD:Number = shell.y - y;

        if (xD > -16 && xD < 16)
        {
            if (yD > -height && yD < shell.height)
            {
                //world.sound.play(Art.samples[Art.SAMPLE_MARIO_KICK], this, 1, 1, 1);
                Art.samples[Art.SAMPLE_MARIO_KICK].play();

                dead = true;

                xa = 0;
                ya = 1;
                deadTime = 100;

                return true;
            }
        }
        return false;
    }      
}
}

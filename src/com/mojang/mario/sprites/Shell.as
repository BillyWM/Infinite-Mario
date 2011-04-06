package com.mojang.mario.sprites {

import com.mojang.mario.Art;
import com.mojang.mario.LevelScene;


public class Shell extends JSprite
{
    private static var GROUND_INERTIA:Number = 0.89;
    private static var AIR_INERTIA:Number = 0.89;

    private var runTime:Number = 0;
    private var onGround:Boolean = false;

    private var width:int = 4;
    public var height:int = 24;

    private var world:LevelScene;
    public var facing:int = 0;

    public var avoidCliffs:Boolean = false;
    public var anim:int = 0;

    public var dead:Boolean = false;
    private var deadTime:int = 0;
    public var carried:Boolean = false;


    public function Shell(world:LevelScene, x:Number, y:Number, type:int)
    {
        sheet = Art.enemies;

        this.x = x;
        this.y = y;
        this.world = world;
        xPicO = 8;
        yPicO = 31;

        yPic = type;
        height = 12;
        facing = 0;
        wPic = 16;

        xPic = 4;
        ya = -5;
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
                if (facing!=0) return true;
                
//world.sound.play(Art.samples[Art.SAMPLE_MARIO_KICK], this, 1, 1, 1);
                Art.samples[Art.SAMPLE_MARIO_KICK].play();

                xa = fireball.facing * 2;
                ya = -5;
                if (spriteTemplate != null) spriteTemplate.isDead = true;
                deadTime = 100;
                hPic = -hPic;
                yPicO = -yPicO + 16;
                return true;
            }
        }
        return false;
    }    

    override public function collideCheck():void
    {
        if (carried || dead || deadTime>0) return;

        var xMarioD:Number = world.mario.x - x;
        var yMarioD:Number = world.mario.y - y;
        var w:Number = 16;
        if (xMarioD > -16 && xMarioD < 16)
        {
            if (yMarioD > -height && yMarioD < world.mario.height)
            {
                if (world.mario.ya > 0 && yMarioD <= 0 && (!world.mario.onGround || !world.mario.wasOnGround))
                {
                    world.mario.stompShell(this);
                    if (facing != 0)
                    {
                        xa = 0;
                        facing = 0;
                    }
                    else
                    {
                        facing = world.mario.facing;
                    }
                }
                else
                {
                    if (facing != 0)
                    {
                        world.mario.getHurt();
                    }
                    else
                    {
                        world.mario.kick(this);
                        facing = world.mario.facing;
                    }
                }
            }
        }
    }

    override public function move():void
    {
        if (carried)
        {
            world.checkShellCollide(this);
            return;
        }

        if (deadTime > 0)
        {
            deadTime--;

            if (deadTime == 0)
            {
                deadTime = 1;
                for (var i:int = 0; i < 8; i++)
                {
                    world.addSprite(new Sparkle(int((x + Math.random() * 16 - 8)) + 4,
                                                int((y - Math.random() * 8)) + 4,
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

        if (facing != 0) anim++;

        var sideWaysSpeed:Number = 11;
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

        if (facing != 0)
        {
            world.checkShellCollide(this);
        }

        xFlipPic = facing == -1;

        runTime += (Math.abs(xa)) + 5;

        xPic = (anim / 2) % 4 + 3;



        if (!_move(xa, 0))
        {
            //world.sound.play(Art.samples[Art.SAMPLE_SHELL_BUMP], this, 1, 1, 1);
            Art.samples[Art.SAMPLE_SHELL_BUMP].play();

            facing = -facing;
        }
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
        
        if (blocking && ya == 0 && xa!=0)
        {
            world.bump(x, y, true);
        }

        return blocking;
    }

    override public function bumpCheck(xTile:int, yTile:int):void
    {
        if (x + width > xTile * 16 && x - width < xTile * 16 + 16 && yTile == int((y - 1) / 16))
        {
            facing = -world.mario.facing;
            ya = -10;
        }
    }

    public function die():void
    {
        dead = true;

        carried = false;

        xa = -facing * 2;
        ya = -5;
        deadTime = 100;
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

                if (world.mario.carried == shell || world.mario.carried == this)
                {
                    world.mario.carried = null;
                }

                die();
                shell.die();
                return true;
            }
        }
        return false;
    }


    override public function release(mario:Mario):void
    {
        carried = false;
        facing = mario.facing;
        x += facing * 8;
    }
}
}

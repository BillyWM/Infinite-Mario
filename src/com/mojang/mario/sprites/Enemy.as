package com.mojang.mario.sprites {

import java.awt.JGraphics;

import com.mojang.mario.Art;
import com.mojang.mario.LevelScene;


public class Enemy extends JSprite
{
    public static const ENEMY_RED_KOOPA:int = 0;
    public static const ENEMY_GREEN_KOOPA:int = 1;
    public static const ENEMY_GOOMBA:int = 2;
    public static const ENEMY_SPIKY:int = 3;
    public static const ENEMY_FLOWER:int = 4;
	public static const ENEMY_BUZZY_BEETLE:int = 5;		//Might not add these...
	public static const ENEMY_FLYING_CHEEP:int = 6;
	public static const ENEMY_LAKITU:int = 7;
	public static const ENEMY_HAMMER_BRO:int = 8;

    private static var GROUND_INERTIA:Number = 0.89;
    private static var AIR_INERTIA:Number = 0.89;

    private var runTime:Number = 0;
    private var onGround:Boolean = false;
    private var mayJump:Boolean = false;
    private var jumpTime:int = 0;
    private var xJumpSpeed:Number = 0;
    private var yJumpSpeed:Number = 0;

    internal var width:int = 4;
    internal var height:int = 24;

    private var world:LevelScene;
    public var facing:int = 0;
    public var deadTime:int = 0;
    public var flyDeath:Boolean = false;

    public var avoidCliffs:Boolean = true;
    public var type:int = 0;
	public var worth:int = 0;	//points for killing

    public var winged:Boolean = true;
    private var wingTime:int = 0;
    
    public var noFireballDeath:Boolean = false;

    public function Enemy(world:LevelScene, x:int, y:int, dir:int, type:int, winged:Boolean)
    {
        this.type = type;
        sheet = Art.enemies;
        this.winged = winged;

        this.x = x;
        this.y = y;
        this.world = world;
        xPicO = 8;
        yPicO = 31;

        avoidCliffs = (type == Enemy.ENEMY_RED_KOOPA);      
		noFireballDeath = (type == Enemy.ENEMY_BUZZY_BEETLE);

		//Adding new enemies throws off his fragile ordering where enemy # = ypos on the spritesheet
		//Correct this manually per enemy...
		switch (type) {
			case Enemy.ENEMY_BUZZY_BEETLE: yPic = 7; break;

			default: yPic = type;
		}

        facing = dir;

        if (yPic > 1) height = 12;
        if (facing == 0) facing = 1;

        this.wPic = 16;
    }

    override public function collideCheck():void
    {
        if (deadTime != 0)
        {
            return;
        }

        var xMarioD:Number = world.mario.x - x;
        var yMarioD:Number = world.mario.y - y;
        var w:Number = 16;
        if (xMarioD > -width*2-4 && xMarioD < width*2+4)
        {
            if (yMarioD > -height && yMarioD < world.mario.height)
            {
                if (type != Enemy.ENEMY_SPIKY && world.mario.ya > 0 && yMarioD <= 0 && (!world.mario.onGround || !world.mario.wasOnGround))
                {
                    world.mario.stompEnemy(this);
                    if (winged)
                    {
                        winged = false;
                        ya = 0;
                    }
                    else
                    {
                        this.yPicO = 31 - (32 - 8);
                        hPic = 8;
                        if (spriteTemplate != null) spriteTemplate.isDead = true;
                        deadTime = 10;
                        winged = false;

                        if (type == Enemy.ENEMY_RED_KOOPA)
                        {
                            spriteContext.addSprite(new Shell(world, x, y, 0));
                        }
                        else if (type == Enemy.ENEMY_GREEN_KOOPA)
                        {
                            spriteContext.addSprite(new Shell(world, x, y, 1));
                        }
						else if (type == Enemy.ENEMY_BUZZY_BEETLE)
						{
                            spriteContext.addSprite(new Shell(world, x, y, Enemy.ENEMY_BUZZY_BEETLE));
						}
                    }
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
        wingTime++;
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

            if (flyDeath)
            {
                x += xa;
                y += ya;
                ya *= 0.95;
                ya += 1;
            }
            return;
        }


        var sideWaysSpeed:Number = 1.75;
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
        mayJump = (onGround);
        xFlipPic = facing == -1;
        runTime += (Math.abs(xa)) + 5;

        var runFrame:int = int(runTime / 20) % 2;

        if (!onGround)
        {
            runFrame = 1;
        }


        if (!_move(xa, 0)) facing = -facing;
        onGround = false;
        _move(0, ya);

        ya *= winged ? 0.95 : 0.85;
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
            if (winged)
            {
                ya += 0.6;
            }
            else
            {
                ya += 2;
            }
        }
        else if (winged)
        {
            ya = -10;
        }

        if (winged) runFrame = int(wingTime / 4) % 2;

        xPic = runFrame;
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

            if (avoidCliffs && onGround && !world.level.isBlocking(int((x + xa + width) / 16), int(y / 16 + 1), xa, 1)) collide = true;
        }
        if (xa < 0)
        {
            if (isBlocking(x + xa - width, y + ya - height, xa, ya)) collide = true;
            if (isBlocking(x + xa - width, y + ya - height / 2, xa, ya)) collide = true;
            if (isBlocking(x + xa - width, y + ya, xa, ya)) collide = true;

            if (avoidCliffs && onGround && !world.level.isBlocking(int((x + xa - width) / 16), int(y / 16 + 1), xa, 1)) collide = true;
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
        var x:int = int(_x / 16);
        var y:int = int(_y / 16);
        if (x == int(this.x / 16) && y == int(this.y / 16)) return false;

        var blocking:Boolean = world.level.isBlocking(x, y, xa, ya);

        var block:uint = world.level.getBlock(x, y);

        return blocking;
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
                Art.samples[Art.SAMPLE_MARIO_KICK].play();

                xa = shell.facing * 2;
                ya = -5;
                flyDeath = true;
                if (spriteTemplate != null) spriteTemplate.isDead = true;
                deadTime = 100;
                winged = false;
                hPic = -hPic;
                yPicO = -yPicO + 16;
                return true;
            }
        }
        return false;
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
                if (noFireballDeath)
				{
					return true;
				}
				else
				{
                
	                Art.samples[Art.SAMPLE_MARIO_KICK].play();

	                xa = fireball.facing * 2;
	                ya = -5;
	                flyDeath = true;
	                if (spriteTemplate != null) spriteTemplate.isDead = true;
	                deadTime = 100;
	                winged = false;
	                hPic = -hPic;
	                yPicO = -yPicO + 16;
	                return true;
				}
            }
        }
        return false;
    }

    override public function bumpCheck(xTile:int, yTile:int):void
    {
        if (deadTime != 0) return;

        if (x + width > xTile * 16 && x - width < xTile * 16 + 16 && yTile == int((y - 1) / 16))
        {
            Art.samples[Art.SAMPLE_MARIO_KICK].play();

            xa = -world.mario.facing * 2;
            ya = -5;
            flyDeath = true;
            if (spriteTemplate != null) spriteTemplate.isDead = true;
            deadTime = 100;
            winged = false;
            hPic = -hPic;
            yPicO = -yPicO + 16;
        }
    }

    override public function render(og:JGraphics, alpha:Number):void
    {
        if (winged)
        {
            var xPixel:int = int((xOld + (x - xOld) * alpha)) - xPicO;
            var yPixel:int = int((yOld + (y - yOld) * alpha)) - yPicO;

            if (type == Enemy.ENEMY_GREEN_KOOPA || type == Enemy.ENEMY_RED_KOOPA)
            {
				//Do nothing?
            }
            else
            {
                xFlipPic = !xFlipPic;
                og.drawImage6(sheet[int(wingTime / 4) % 2][4],
                             xPixel + (xFlipPic ? wPic : 0) + (xFlipPic ? 10 : -10),
                             yPixel + (yFlipPic ? hPic : 0) - 8,
                             xFlipPic ? -wPic : wPic,
                             yFlipPic ? -hPic : hPic);
                xFlipPic = !xFlipPic;
            }
        }

        super.render(og, alpha);

        if (winged)
        {
             xPixel = int((xOld + (x - xOld) * alpha)) - xPicO;
             yPixel = int((yOld + (y - yOld) * alpha)) - yPicO;

            if (type == Enemy.ENEMY_GREEN_KOOPA || type == Enemy.ENEMY_RED_KOOPA)
            {
                og.drawImage6(sheet[int(wingTime / 4) % 2][4],
                             xPixel + (xFlipPic ? wPic : 0) + (xFlipPic ? 10 : -10),
                             yPixel + (yFlipPic ? hPic : 0) - 10,
                             xFlipPic ? -wPic : wPic,
                             yFlipPic ? -hPic : hPic);
            }
            else
            {
                og.drawImage6(sheet[int(wingTime / 4) % 2][4],
                             xPixel + (xFlipPic ? wPic : 0) + (xFlipPic ? 10 : -10),
                             yPixel + (yFlipPic ? hPic : 0) - 8,
                             xFlipPic ? -wPic : wPic,
                             yFlipPic ? -hPic : hPic);
            }
        }
    }
}
}

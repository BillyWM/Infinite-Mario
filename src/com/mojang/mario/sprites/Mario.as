package com.mojang.mario.sprites {

import com.mojang.mario.Art;
import com.mojang.mario.LevelScene;
import com.mojang.mario.Scene;
import com.mojang.mario.level.*;

public class Mario extends JSprite
{
    public static var large:Boolean = false;
    public static var fire:Boolean = false;
    public static var coins:int = 0;
    public static var lives:int = 3;
    public static var levelString:String = "none";

    public static function resetStatic():void
    {
        large = false;
        fire = false;
        coins = 0;
        lives = 3;
        levelString = "none";
    }

    public static const KEY_LEFT:int = 0;
    public static const KEY_RIGHT:int = 1;
    public static const KEY_DOWN:int = 2;
    public static const KEY_UP:int = 3;
    public static const KEY_JUMP:int = 4;
    public static const KEY_SPEED:int = 5;

    private static const GROUND_INERTIA:Number = 0.89;
    private static const AIR_INERTIA:Number = 0.89;

    public var keys:Array;      // Boolean[] 
    private var runTime:Number = 0;
    public var wasOnGround:Boolean = false;
    public var onGround:Boolean = false;
    private var mayJump:Boolean = false;
    private var ducking:Boolean = false;
    private var sliding:Boolean = false;
    private var jumpTime:int = 0;
    private var xJumpSpeed:Number = 0;
    private var yJumpSpeed:Number = 0;
    private var canShoot:Boolean = false;

    public var width:int = 4;
    public var height:int = 24;

    private var world:LevelScene;
    public var facing:int = 0;
    private var powerUpTime:int = 0;

    public var xDeathPos:int = 0, yDeathPos:int = 0;

    public var deathTime:int = 0;
    public var winTime:int = 0;
    private var invulnerableTime:int = 0;

    public var carried:JSprite = null;
    private static var instance:Mario;

    public function Mario(world:LevelScene)
    {
        Mario.instance = this;
        this.world = world;
        keys = Scene.keys;
        x = 32;
        y = 0;

        facing = 1;
        setLarge(Mario.large, Mario.fire);
    }
    
    private var lastLarge:Boolean = false;
    private var lastFire:Boolean = false;
    private var newLarge:Boolean = false;
    private var newFire:Boolean = false;
    
    private function blink(on:Boolean):void
    {
        Mario.large = on?newLarge:lastLarge;
        Mario.fire = on?newFire:lastFire;
        
        if (large)
        {
            sheet = Art.mario;
            if (fire)
                sheet = Art.fireMario;

            xPicO = 16;
            yPicO = 31;
            wPic = hPic = 32;
        }
        else
        {
            sheet = Art.smallMario;

            xPicO = 8;
            yPicO = 15;
            wPic = hPic = 16;
        }

        calcPic();
    }

    internal function setLarge(large:Boolean, fire:Boolean):void
    {
        if (fire) large = true;
        if (!large) fire = false;
        
        lastLarge = Mario.large;
        lastFire = Mario.fire;
        
        Mario.large = large;
        Mario.fire = fire;

        newLarge = Mario.large;
        newFire = Mario.fire;
        
        blink(true);
    }

    override public function move():void
    {
        if (winTime > 0)
        {
            winTime++;

            xa = 0;
            ya = 0;
            return;
        }

        if (deathTime > 0)
        {
            deathTime++;
            if (deathTime < 11)
            {
                xa = 0;
                ya = 0;
            }
            else if (deathTime == 11)
            {
                ya = -15;
            }
            else
            {
                ya += 2;
            }
            x += xa;
            y += ya;
            return;
        }

        if (powerUpTime != 0)
        {
            if (powerUpTime > 0)
            {
                powerUpTime--;
                blink((int(powerUpTime / 3) & 1) == 0);
            }
            else
            {
                powerUpTime++;
                blink((int(-powerUpTime / 3) & 1) == 0);
            }

            if (powerUpTime == 0) world.paused = false;

            calcPic();
            return;
        }

        if (invulnerableTime > 0) invulnerableTime--;
        visible = (int(invulnerableTime / 2) & 1) == 0;

        wasOnGround = onGround;
        var sideWaysSpeed:Number = keys[KEY_SPEED] ? 1.2 : 0.6;
        // Number sideWaysSpeed = onGround ? 2.5f : 1.2f;

        if (onGround)
        {
            if (keys[KEY_DOWN] && large)
            {
                ducking = true;
            }
            else
            {
                ducking = false;
            }
        }

        if (xa > 2)
        {
            facing = 1;
        }
        if (xa < -2)
        {
            facing = -1;
        }

        if (keys[KEY_JUMP] || (jumpTime < 0 && !onGround && !sliding))
        {
            if (jumpTime < 0)
            {
                xa = xJumpSpeed;
                ya = -jumpTime * yJumpSpeed;
                jumpTime++;
            }
            else if (onGround && mayJump)
            {
////////////////world.sound.play(Art.samples[Art.SAMPLE_MARIO_JUMP], this, 1, 1, 1);
                Art.samples[Art.SAMPLE_MARIO_JUMP].play();
                xJumpSpeed = 0;
                yJumpSpeed = -1.9;
                jumpTime = 7;
                ya = jumpTime * yJumpSpeed;
                onGround = false;
                sliding = false;
            }
            else if (sliding && mayJump)
            {
////////////////world.sound.play(Art.samples[Art.SAMPLE_MARIO_JUMP], this, 1, 1, 1);
                Art.samples[Art.SAMPLE_MARIO_JUMP].play();
                xJumpSpeed = -facing * 6.0;
                yJumpSpeed = -2.0;
                jumpTime = -6;
                xa = xJumpSpeed;
                ya = -jumpTime * yJumpSpeed;
                onGround = false;
                sliding = false;
                facing = -facing;
            }
            else if (jumpTime > 0)
            {
                xa += xJumpSpeed;
                ya = jumpTime * yJumpSpeed;
                jumpTime--;
            }
        }
        else
        {
            jumpTime = 0;
        }

        if (keys[KEY_LEFT] && !ducking)
        {
            if (facing == 1) sliding = false;
            xa -= sideWaysSpeed;
            if (jumpTime >= 0) facing = -1;
        }

        if (keys[KEY_RIGHT] && !ducking)
        {
            if (facing == -1) sliding = false;
            xa += sideWaysSpeed;
            if (jumpTime >= 0) facing = 1;
        }

        if ((!keys[KEY_LEFT] && !keys[KEY_RIGHT]) || ducking || ya < 0 || onGround)
        {
            sliding = false;
        }
        
        if (keys[KEY_SPEED] && canShoot && Mario.fire && world.fireballsOnScreen<2)
        {
////////////world.sound.play(Art.samples[Art.SAMPLE_MARIO_FIREBALL], this, 1, 1, 1);
            Art.samples[Art.SAMPLE_MARIO_FIREBALL].play();
            world.addSprite(new Fireball(world, x+facing*6, y-20, facing));
        }
        
        canShoot = !keys[KEY_SPEED];

        mayJump = (onGround || sliding) && !keys[KEY_JUMP];

        xFlipPic = facing == -1;

        runTime += (Math.abs(xa)) + 5;
        if (Math.abs(xa) < 0.5)
        {
            runTime = 0;
            xa = 0;
        }

        calcPic();

        if (sliding)
        {
            for (var i:int = 0; i < 1; i++)
            {
                world.addSprite(new Sparkle(int((x + Math.random() * 4 - 2) + facing * 8),
                                            int((y + Math.random() * 4) - 24),
                                            Number((Math.random() * 2 - 1)),
                                            Number(Math.random() * 1), 0, 1, 5));
            }
            ya *= 0.5;
        }

        onGround = false;
        _move(xa, 0);
        _move(0, ya);

        if (y > world.level.height * 16 + 16)
        {
            die();
        }

        if (x < 0)
        {
            x = 0;
            xa = 0;
        }

        if (x > world.level.xExit * 16)
        {
            win();
        }

        if (x > world.level.width * 16)
        {
            x = world.level.width * 16;
            xa = 0;
        }

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
            ya += 3;
        }

        if (carried != null)
        {
            carried.x = x + facing * 8;
            carried.y = y - 2;
            if (!keys[KEY_SPEED])
            {
                carried.release(this);
                carried = null;
            }
        }
    }

    private function calcPic():void
    {
        var runFrame:int = 0;

        if (large)
        {
            runFrame = (int(runTime / 20)) % 4;
            if (runFrame == 3) runFrame = 1;
            if (carried == null && Math.abs(xa) > 10) runFrame += 3;
            if (carried != null) runFrame += 10;
            if (!onGround)
            {
                if (carried != null) runFrame = 12;
                else if (Math.abs(xa) > 10) runFrame = 7;
                else runFrame = 6;
            }
        }
        else
        {
            runFrame = (int(runTime / 20)) % 2;
            if (carried == null && Math.abs(xa) > 10) runFrame += 2;
            if (carried != null) runFrame += 8;
            if (!onGround)
            {
                if (carried != null) runFrame = 9;
                else if (Math.abs(xa) > 10) runFrame = 5;
                else runFrame = 4;
            }
        }

        if (onGround && ((facing == -1 && xa > 0) || (facing == 1 && xa < 0)))
        {
            if (xa > 1 || xa < -1) runFrame = large ? 9 : 7;

            if (xa > 3 || xa < -3)
            {
                for (var i:int = 0; i < 3; i++)
                {
                    world.addSprite(new Sparkle(int((x + Math.random() * 8 - 4)),
                                                int((y + Math.random() * 4)),
                                                Number((Math.random() * 2 - 1)),
                                                Number(Math.random() * -1), 0, 1, 5));
                }
            }
        }

        if (large)
        {
            if (ducking) runFrame = 14;
            height = ducking ? 12 : 24;
        }
        else
        {
            height = 12;
        }

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
            sliding = true;
            if (isBlocking(x + xa + width, y + ya - height, xa, ya)) collide = true;
            else sliding = false;
            if (isBlocking(x + xa + width, y + ya - height / 2, xa, ya)) collide = true;
            else sliding = false;
            if (isBlocking(x + xa + width, y + ya, xa, ya)) collide = true;
            else sliding = false;
        }
        if (xa < 0)
        {
            sliding = true;
            if (isBlocking(x + xa - width, y + ya - height, xa, ya)) collide = true;
            else sliding = false;
            if (isBlocking(x + xa - width, y + ya - height / 2, xa, ya)) collide = true;
            else sliding = false;
            if (isBlocking(x + xa - width, y + ya, xa, ya)) collide = true;
            else sliding = false;
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
                y = int((y - 1) / 16 + 1) * 16 - 1;
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

        if (((Level.TILE_BEHAVIORS[block & 0xff]) & Level.BIT_PICKUPABLE) > 0)
        {
            Mario.getCoin();
////////////world.sound.play(Art.samples[Art.SAMPLE_GET_COIN], new FixedSoundSource(x * 16 + 8, y * 16 + 8), 1, 1, 1);
            Art.samples[Art.SAMPLE_GET_COIN].play();
            world.level.setBlock(x, y, uint(0));
            for (var xx:int = 0; xx < 2; xx++)
                for (var yy:int = 0; yy < 2; yy++)
                    world.addSprite(new Sparkle(x * 16 + xx * 8 + int(Math.random() * 8),
                                                y * 16 + yy * 8 + int(Math.random() * 8),
                                                0, 0, 0, 2, 5));
        }

        if (blocking && ya < 0)
        {
            world.bump(x, y, large);
        }

        return blocking;
    }

    public function stompEnemy(enemy:Enemy):void
    {
        if (deathTime > 0 || world.paused) return;

        var targetY:Number = enemy.y - enemy.height / 2;
        _move(0, targetY - y);

////////world.sound.play(Art.samples[Art.SAMPLE_MARIO_KICK], this, 1, 1, 1);
        Art.samples[Art.SAMPLE_MARIO_KICK].play();
        xJumpSpeed = 0;
        yJumpSpeed = -1.9;
        jumpTime = 8;
        ya = jumpTime * yJumpSpeed;
        onGround = false;
        sliding = false;
        invulnerableTime = 1;
    }

    public function stompShell(shell:Shell):void
    {
        if (deathTime > 0 || world.paused) return;

        if (keys[KEY_SPEED] && shell.facing == 0)
        {
            carried = shell;
            shell.carried = true;
        }
        else
        {
            var targetY:Number = shell.y - shell.height / 2;
            _move(0, targetY - y);

////////////world.sound.play(Art.samples[Art.SAMPLE_MARIO_KICK], this, 1, 1, 1);
            Art.samples[Art.SAMPLE_MARIO_KICK].play();
            xJumpSpeed = 0;
            yJumpSpeed = -1.9;
            jumpTime = 8;
            ya = jumpTime * yJumpSpeed;
            onGround = false;
            sliding = false;
            invulnerableTime = 1;
        }
    }

    public function getHurt():void
    {
        if (deathTime > 0 || world.paused) return;
        if (invulnerableTime > 0) return;

        if (large)
        {
            world.paused = true;
            powerUpTime = -3 * 6;
////////////world.sound.play(Art.samples[Art.SAMPLE_MARIO_POWER_DOWN], this, 1, 1, 1);
            Art.samples[Art.SAMPLE_MARIO_POWER_DOWN].play();
            if (fire)
            {
                world.mario.setLarge(true, false);
            }
            else
            {
                world.mario.setLarge(false, false);
            }
            invulnerableTime = 32;
        }
        else
        {
            die();
        }
    }

    private function win():void
    {
        xDeathPos = int(x) ;
        yDeathPos = int(y) ;
        world.paused = true;
        winTime = 1;
        Art.stopMusic();
////////world.sound.play(Art.samples[Art.SAMPLE_LEVEL_EXIT], this, 1, 1, 1);
        Art.samples[Art.SAMPLE_LEVEL_EXIT].play();
    }

    public function die():void
    {
        xDeathPos = int(x);
        yDeathPos = int(y);
        world.paused = true;
        deathTime = 1;
        Art.stopMusic();
////////world.sound.play(Art.samples[Art.SAMPLE_MARIO_DEATH], this, 1, 1, 1);
        Art.samples[Art.SAMPLE_MARIO_DEATH].play();
    }


    public function getFlower():void
    {
        if (deathTime > 0 || world.paused) return;

        if (!fire)
        {
            world.paused = true;
            powerUpTime = 3 * 6;
////////////world.sound.play(Art.samples[Art.SAMPLE_MARIO_POWER_UP], this, 1, 1, 1);
            Art.samples[Art.SAMPLE_MARIO_POWER_UP].play();
            world.mario.setLarge(true, true);
        }
        else
        {
            Mario.getCoin();
////////////world.sound.play(Art.samples[Art.SAMPLE_GET_COIN], this, 1, 1, 1);
            Art.samples[Art.SAMPLE_GET_COIN].play();
        }
    }

    public function getMushroom():void
    {
        if (deathTime > 0 || world.paused) return;

        if (!large)
        {
            world.paused = true;
            powerUpTime = 3 * 6;
////////////world.sound.play(Art.samples[Art.SAMPLE_MARIO_POWER_UP], this, 1, 1, 1);
            Art.samples[Art.SAMPLE_MARIO_POWER_UP].play();
            world.mario.setLarge(true, false);
        }
        else
        {
            Mario.getCoin();
////////////world.sound.play(Art.samples[Art.SAMPLE_GET_COIN], this, 1, 1, 1);
            Art.samples[Art.SAMPLE_GET_COIN].play();
        }
    }

    public function kick(shell:Shell):void
    {
        if (deathTime > 0 || world.paused) return;

        if (keys[KEY_SPEED])
        {
            carried = shell;
            shell.carried = true;
        }
        else
        {
////////////world.sound.play(Art.samples[Art.SAMPLE_MARIO_KICK], this, 1, 1, 1);
            Art.samples[Art.SAMPLE_MARIO_KICK].play();
            invulnerableTime = 1;
        }
    }

    public function stompBill(bill:BulletBill):void
    {
        if (deathTime > 0 || world.paused) return;

        var targetY:Number = bill.y - bill.height / 2;
        _move(0, targetY - y);

////////world.sound.play(Art.samples[Art.SAMPLE_MARIO_KICK], this, 1, 1, 1);
        Art.samples[Art.SAMPLE_MARIO_KICK].play();
        xJumpSpeed = 0;
        yJumpSpeed = -1.9;
        jumpTime = 8;
        ya = jumpTime * yJumpSpeed;
        onGround = false;
        sliding = false;
        invulnerableTime = 1;
    }

    public function getKeyMask():uint
    {
        var mask:int = 0;
        for (var i:int = 0; i < 7; i++)
        {
            if (keys[i]) mask |= (1 << i);
        }
        return uint(mask);
    }

    public function setKeys(mask:uint):void
    {
        for (var i:int = 0; i < 7; i++)
        {
            keys[i] = (mask & (1 << i)) > 0;
        }
    }

    public static function get1Up():void
    {
        ///instance.world.sound.play(Art.samples[Art.SAMPLE_MARIO_1UP], instance, 1, 1, 1);
        Art.samples[Art.SAMPLE_MARIO_1UP].play();
        lives++;
        if (lives==99)
        {
            lives = 99;
        }
    }
    
    public static function getCoin():void
    {
        coins++;
        if (coins==100)
        {
            coins = 0;
            get1Up();
        }
    }
}

}

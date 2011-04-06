package com.mojang.mario.sprites {

import com.mojang.mario.LevelScene;

public class FlowerEnemy extends Enemy
{
    private var _tick:int;
    private var yStart:int;
    private var jumpTime:int = 0;
    private var world:LevelScene;
    
    public function FlowerEnemy(world:LevelScene, x:int, y:int)
    {
        super(world, x, y, 1, ENEMY_SPIKY, false);
        
        noFireballDeath = false;
        this.world = world;
        this.xPic = 0;
        this.yPic = 6;
        this.yPicO = 24;
        this.height = 12;
        this.width = 2;
        
        yStart = y;
        ya = -8;
        
        this.y-=1;
        
        this.layer = 0;
        
        for (var i:int=0; i<4; i++)
        {
            move();
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

        _tick++;
        
        if (y>=yStart)
        {
            y = yStart;

            var xd:int = int((Math.abs(world.mario.x-x)));
            jumpTime++;
            if (jumpTime>40 && xd>24)
            {
                ya = -8;
            }
            else
            {
                ya = 0;
            }
        }
        else
        {
            jumpTime = 0;
        }
        
        y+=ya;
        ya*=0.9;
        ya+=0.1;
        
        xPic = ((_tick/2)&1)*2+((_tick/6)&1);
    }

/*    public void render(Graphics og, Number alpha)
    {
        if (!visible) return;
        
        int xPixel = (int)(xOld+(x-xOld)*alpha)-xPicO;
        int yPixel = (int)(yOld+(y-yOld)*alpha)-yPicO;

        int a = ((tick/3)&1)*2;
//        a += ((tick/8)&1);
        og.drawImage(sheet[a*2+0][6], xPixel-8, yPixel+8, 16, 32);
        og.drawImage(sheet[a*2+1][6], xPixel+8, yPixel+8, 16, 32);
    }*/
}
}

package com.mojang.mario.sprites {

import com.mojang.mario.Art;


public class CoinAnim extends JSprite
{
    private var life:int = 10;

    public function CoinAnim(xTile:int, yTile:int)
    {
        sheet = Art.level;
        wPic = hPic = 16;

        x = xTile * 16;
        y = yTile * 16 - 16;
        xa = 0;
        ya = -6;
        xPic = 0;
        yPic = 2;
    }

    override public function move():void
    {
        if (life-- < 0)
        {
            JSprite.spriteContext.removeSprite(this);
            for (var xx:int = 0; xx < 2; xx++)
                for (var yy:int = 0; yy < 2; yy++)
                    JSprite.spriteContext.addSprite(new Sparkle(int(x) + xx * 8 + int((Math.random() * 8)),
                                                               int(y) + yy * 8 + int((Math.random() * 8)),
                                                               0, 0, 0, 2, 5));
        }

        xPic = life & 3;

        x += xa;
        y += ya;
        ya += 1;
    }
}
}

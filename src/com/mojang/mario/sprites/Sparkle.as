package com.mojang.mario.sprites {

import com.mojang.mario.Art;

public class Sparkle extends JSprite
{
    public var life:int = 0;
    public var xPicStart:int = 0;

    public function Sparkle(x:int, y:int, xa:Number, ya:Number, xPic:int, yPic:int, timeSpan:int)
    {
        sheet = Art.particles;
        this.x = x;
        this.y = y;
        this.xa = xa;
        this.ya = ya;
        this.xPic = xPic;
        xPicStart = xPic;
        this.yPic = yPic;
        this.xPicO = 4;
        this.yPicO = 4;
        
        wPic = 8;
        hPic = 8;
        life = 10 + int(Math.random()*timeSpan);
    }

    override public function move():void
    {
        if (life>10)
            xPic = 7;
        else
            xPic = xPicStart+(10-life)*4/10;
        
        if (life--<0) JSprite.spriteContext.removeSprite(this);
        
        x+=xa;
        y+=ya;
    }
}
}

package com.mojang.mario.sprites {

import com.mojang.mario.Art;

public class Particle extends JSprite
{
    public var life:int = 0;

    public function Particle(x:int, y:int, xa:Number, ya:Number, xPic:int, yPic:int)
    {
        sheet = Art.particles;
        this.x = x;
        this.y = y;
        this.xa = xa;
        this.ya = ya;
        this.xPic = xPic;
        this.yPic = yPic;
        this.xPicO = 4;
        this.yPicO = 4;
        
        wPic = 8;
        hPic = 8;
        life = 10;
    }

    override public function move():void
    {
        if (life--<0) JSprite.spriteContext.removeSprite(this);
        x+=xa;
        y+=ya;
        ya*=0.95;
        ya+=3;
    }
}
}

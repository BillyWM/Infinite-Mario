package com.mojang.mario {

import java.awt.JGraphics;
//import java.awt.GraphicsConfiguration;

import com.mojang.mario.level.BgLevelGenerator;
import com.mojang.mario.level.LevelGenerator;
import com.mojang.mario.sprites.Mario;

public class TitleScene extends Scene
{
    private var component:MarioComponent;
    private var _tick:int;
    private var bgLayer0:BgRenderer;
    private var bgLayer1:BgRenderer;
    
    public function TitleScene(component:MarioComponent)
    {
        this.component = component;
        bgLayer0 = new BgRenderer(BgLevelGenerator.createLevel(2048, 15, false, LevelGenerator.TYPE_OVERGROUND), 320, 240, 1);        
        bgLayer1 = new BgRenderer(BgLevelGenerator.createLevel(2048, 15, true, LevelGenerator.TYPE_OVERGROUND), 320, 240, 2);
    }

    override public function init():void
    {
        Art.startMusic(4);
    }

    override public function render(g:JGraphics, alpha:Number):void
    {
        bgLayer0.setCam(_tick+160, 0);
        bgLayer1.setCam(_tick+160, 0);
        bgLayer1.render(g, _tick, alpha);
        bgLayer0.render(g, _tick, alpha);
//        g.setColor(Color.decode("#8080a0"));
//        g.fillRect(0, 0, 320, 240);
        var yo:int = 16-Math.abs(int((Math.sin((_tick+alpha)/6.0)*8)));
        g.drawImage(Art.logo, 0, yo);
        g.drawImage(Art.titleScreen, 0, 120);
    }

    private function drawString(g:JGraphics, text:String, x:int, y:int, c:int):void
    {
        //var ch:Array = text.toCharArray(); // char[]
        for (var i:int = 0; i < text.length; i++)
        {
            g.drawImage(Art.font[text.charCodeAt(i) - 32][c], x + i * 8, y);
        }
    }

    private var wasDown:Boolean = true;

    override public function tick():void
    {
        _tick++;
        if (!wasDown && keys[Mario.KEY_JUMP])
        {
            component.startGame();
        }
        if (keys[Mario.KEY_JUMP])
        {
            wasDown = false;
        }
    }

    override public function getX(alpha:Number):Number
    {
        return 0;
    }

    override public function getY(alpha:Number):Number
    {
        return 0;
    }

}
}

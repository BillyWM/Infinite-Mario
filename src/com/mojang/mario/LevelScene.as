package com.mojang.mario {

import com.mojang.mario.level.*;
import com.mojang.mario.sprites.*;
import flash.display.BitmapData;
import java.awt.Color;
import java.awt.JGraphics;
import java.text.DecimalFormat;

public class LevelScene extends Scene implements SpriteContext
{
    private var sprites:Array = new Array(); // List<Sprite>
    private var spritesToAdd:Array = new Array(); // List<Sprite>
    private var spritesToRemove:Array = new Array(); // List<Sprite>

    public var level:Level;
    public var mario:Mario;
    public var xCam:Number = 0;
    public var yCam:Number = 0;
    public var xCamO:Number = 0;
    public var yCamO:Number = 0;
    public static var tmpImage:BitmapData;
    private var _tick:int;

    private var layer:LevelRenderer;
    private var bgLayer:Array = new Array(2); // BgRenderer[2]

    public var paused:Boolean = false;
    public var startTime:int = 0;
    private var timeLeft:int = 0;
  
    private var levelSeed:Number = 0;
    private var renderer:MarioComponent;
    private var levelType:int;
    private var levelDifficulty:int;

    public function LevelScene(renderer:MarioComponent, seed:Number, levelDifficulty:int, type:int)
    {

        this.levelSeed = seed;
        this.renderer = renderer;
        this.levelDifficulty = levelDifficulty;
        this.levelType = type;
    }

    [Embed(source='../../../../res/tiles.dat', mimeType='application/octet-stream')]
        private const TilesDat:Class;

    override public function init():void
    {
        Level.loadBehaviors(new TilesDat());
        level = LevelGenerator.createLevel(320, 15, levelSeed, levelDifficulty, levelType);

        if (levelType==LevelGenerator.TYPE_OVERGROUND)
            Art.startMusic(1);
        else if (levelType==LevelGenerator.TYPE_UNDERGROUND)
            Art.startMusic(2);
        else if (levelType==LevelGenerator.TYPE_CASTLE)
            Art.startMusic(3);
        

        paused = false;
        JSprite.spriteContext = this;
        sprites = new Array(); // clear();
        layer = new LevelRenderer(level, 320, 240);
        for (var i:int = 0; i < 2; i++)
        {
            var scrollSpeed:int = 4 >> i;
            var w:int = ((level.width * 16) - 320) / scrollSpeed + 320;
            var h:int = ((level.height * 16) - 240) / scrollSpeed + 240;
            var bgLevel:Level = BgLevelGenerator.createLevel(w / 32 + 1, h / 32 + 1, i == 0, levelType);
            bgLayer[i] = new BgRenderer(bgLevel, 320, 240, scrollSpeed);
        }
        mario = new Mario(this);
        sprites.push(mario);    // add
        startTime = 1;
        
        timeLeft = 200*15;

        _tick = 0;
    }

    public var fireballsOnScreen:int = 0;

    internal var shellsToCheck:Array = new Array(); // List<Shell>

    public function checkShellCollide(shell:Shell):void
    {
        shellsToCheck.push(shell); // add(shell);
    }

    internal var fireballsToCheck:Array = new Array(); // List<Fireball>

    public function checkFireballCollide(fireball:Fireball):void
    {
        fireballsToCheck.push(fireball); // add(fireball);
    }

    override public function tick():void
    {
        timeLeft--;
        if (timeLeft==0)
        {
            mario.die();
        }
        xCamO = xCam;
        yCamO = yCam;

        if (startTime > 0)
        {
            startTime++;
        }

        var targetXCam:Number = mario.x - 160;

        xCam = targetXCam;

        if (xCam < 0) xCam = 0;
        if (xCam > level.width * 16 - 320) xCam = level.width * 16 - 320;
      
        fireballsOnScreen = 0;

        for each (var sprite:JSprite in sprites)
        {
            if (sprite != mario)
            {
                var xd:Number = sprite.x - xCam;
                var yd:Number = sprite.y - yCam;
                if (xd < -64 || xd > 320 + 64 || yd < -64 || yd > 240 + 64)
                {
                    removeSprite(sprite);
                }
                else
                {
                    if (sprite is Fireball)
                    {
                        fireballsOnScreen++;
                    }
                }
            }
        }

        if (paused)
        {
            for each (sprite in sprites)
            {
                if (sprite == mario)
                {
                    sprite.tick();
                }
                else
                {
                    sprite.tickNoMove();
                }
            }
        }
        else
        {
            _tick++;
            level.tick();

            var hasShotCannon:Boolean = false;
            var xCannon:int = 0;

            for (var x:int = int(xCam / 16) - 1; x <= int((xCam + layer.width) / 16) + 1; x++)
                for (var y:int = int(yCam / 16) - 1; y <= int((yCam + layer.height) / 16) + 1; y++)
                {
                    var dir:int = 0;

                    if (x * 16 + 8 > mario.x + 16) dir = -1;
                    if (x * 16 + 8 < mario.x - 16) dir = 1;

                    var st:SpriteTemplate = level.getSpriteTemplate(x, y);

                    if (st != null)
                    {
                        if (st.lastVisibleTick != _tick - 1)
                        {
                            if (st.sprite == null || !(sprites.indexOf(st.sprite)>=0))
                            {
                                st.spawn(this, x, y, dir);
                            }
                        }

                        st.lastVisibleTick = _tick;
                    }

                    if (dir != 0)
                    {
                        var b:uint = level.getBlock(x, y);
                        if (((Level.TILE_BEHAVIORS[b & 0xff]) & Level.BIT_ANIMATED) > 0)
                        {
                            if (int((b % 16) / 4) == 3 && int(b / 16) == 0)
                            {
                                if ((_tick - x * 2) % 100 == 0)
                                {
                                    xCannon = x;
                                    for (var i:int = 0; i < 8; i++)
                                    {
                                        addSprite(new Sparkle(x * 16 + 8,
                                                              y * 16 + int((Math.random() * 16)),
                                                              Number(Math.random() * dir),
                                                              0, 0, 1, 5));
                                    }
                                    addSprite(new BulletBill(this, x * 16 + 8 + dir * 8, y * 16 + 15, dir));
                                    hasShotCannon = true;
                                }
                            }
                        }
                    }
                }

            if (hasShotCannon)
            {
                Art.samples[Art.SAMPLE_CANNON_FIRE].play();
            }

            for each (sprite in sprites)
            {
                sprite.tick();
            }

            for each (sprite in sprites)
            {
                sprite.collideCheck();
            }

            for each (var shell:Shell in shellsToCheck)
            {
                for each (sprite in sprites)
                {
                    if (sprite != shell && !shell.dead)
                    {
                        if (sprite.shellCollideCheck(shell))
                        {
                            if (mario.carried == shell && !shell.dead)
                            {
                                mario.carried = null;
                                shell.die();
                            }
                        }
                    }
                }
            }
            shellsToCheck = new Array(); // clear();

            for each (var fireball:Fireball in fireballsToCheck)
            {
                for each (sprite in sprites)
                {
                    if (sprite != fireball && !fireball.dead)
                    {
                        if (sprite.fireballCollideCheck(fireball))
                        {
                            fireball.die();
                        }
                    }
                }
            }
            fireballsToCheck = new Array();// clear();
        }

        addAll(spritesToAdd);
        removeAll(spritesToRemove);
        spritesToAdd = new Array(); // clear();
        spritesToRemove = new Array(); // clear();
    }

    private function addAll(b:Array):void {
        for each (var x:JSprite in b) {
            sprites.unshift(x);
        }
    }

    private function removeAll(b:Array):void {
        for (var i:int = sprites.length - 1; i >= 0; --i) {
            var x:JSprite = sprites[i];
            if (b.indexOf(x) >= 0) {
                sprites.splice(i, 1);
            }
        }
    }

    private var df:DecimalFormat = new DecimalFormat("00");
    private var df2:DecimalFormat = new DecimalFormat("000");

    override public function render(g:JGraphics, alpha:Number):void
    {
        var xCam:int = int((mario.xOld + (mario.x - mario.xOld) * alpha) - 160);
        var yCam:int = int((mario.yOld + (mario.y - mario.yOld) * alpha) - 120);
        if (xCam < 0) xCam = 0;
        if (yCam < 0) yCam = 0;
        if (xCam > level.width * 16 - 320) xCam = level.width * 16 - 320;
        if (yCam > level.height * 16 - 240) yCam = level.height * 16 - 240;

        for (var i:int = 0; i < 2; i++)
        {
            bgLayer[i].setCam(xCam, yCam);
            bgLayer[i].render(g, _tick, alpha);
        }

        g.translate(-xCam, -yCam);
        for each (var sprite:JSprite in sprites)
        {
            if (sprite.layer == 0) sprite.render(g, alpha);
        }
        g.translate(xCam, yCam);

        layer.setCam(xCam, yCam);
        layer.render(g, _tick, paused?0:alpha);
        layer.renderExit0(g, _tick, paused?0:alpha, mario.winTime==0);

        g.translate(-xCam, -yCam);
        for each (sprite in sprites)
        {
            if (sprite.layer == 1) sprite.render(g, alpha);
        }
        g.translate(xCam, yCam);
        g.setColor(Color.BLACK);
        layer.renderExit1(g, _tick, paused?0:alpha);
        
        drawStringDropShadow(g, "MARIO " + df.format(Mario.lives), 0, 0, 7);
        drawStringDropShadow(g, "00000000", 0, 1, 7);
        
        drawStringDropShadow(g, "COIN", 14, 0, 7);
        drawStringDropShadow(g, " "+df.format(Mario.coins), 14, 1, 7);

        drawStringDropShadow(g, "WORLD", 24, 0, 7);
        drawStringDropShadow(g, " "+Mario.levelString, 24, 1, 7);

        drawStringDropShadow(g, "TIME", 35, 0, 7);
        var time:int = (timeLeft+15-1)/15;
        if (time<0) time = 0;
        drawStringDropShadow(g, " "+df2.format(time), 35, 1, 7);


        if (startTime > 0)
        {
            var t:Number = startTime + alpha - 2;
            t = t * t * 0.6;
            renderBlackout(g, 160, 120, int(t));
        }

        if (mario.winTime > 0)
        {
            t = mario.winTime + alpha;
            t = t * t * 0.2;

            if (t > 900)
            {
                renderer.levelWon();
            }

            renderBlackout(g, int(mario.xDeathPos - xCam), int(mario.yDeathPos - yCam), int(320 - t));
        }

        if (mario.deathTime > 0)
        {
            t = mario.deathTime + alpha;
            t = t * t * 0.4;

            if (t > 1800)
            {
                renderer.levelFailed();
            }

            renderBlackout(g, int(mario.xDeathPos - xCam), int(mario.yDeathPos - yCam), int(320 - t));
        }
    }

    private function drawStringDropShadow(g:JGraphics, text:String, x:int, y:int, c:int):void
    {
        drawString(g, text, x*8+5, y*8+5, 0);
        drawString(g, text, x*8+4, y*8+4, c);
    }
    
    private function drawString(g:JGraphics, text:String, x:int, y:int, c:int):void
    {
        for (var i:int = 0; i < text.length; i++)
        {
            g.drawImage(Art.font[text.charCodeAt(i) - 32][c], x + i * 8, y);
        }
    }
    
    private function renderBlackout(g:JGraphics, x:int, y:int, radius:int):void
    {
        if (radius > 320) return;

        var xp:Array = new Array(20);   // int[]
        var yp:Array = new Array(20);   // int[]
        for (var i:int = 0; i < 16; i++)
        {
            xp[i] = x + Math.cos(i * Math.PI / 15) * radius;
            yp[i] = y + Math.sin(i * Math.PI / 15) * radius;
        }
        xp[16] = 320;
        yp[16] = y;
        xp[17] = 320;
        yp[17] = 240;
        xp[18] = 0;
        yp[18] = 240;
        xp[19] = 0;
        yp[19] = y;
        g.fillPolygon(xp, yp, xp.length);

        for (i = 0; i < 16; i++)
        {
            xp[i] = x - Math.cos(i * Math.PI / 15) * radius;
            yp[i] = y - Math.sin(i * Math.PI / 15) * radius;
        }
        xp[16] = 320;
        yp[16] = y;
        xp[17] = 320;
        yp[17] = 0;
        xp[18] = 0;
        yp[18] = 0;
        xp[19] = 0;
        yp[19] = y;

        g.fillPolygon(xp, yp, xp.length);
    }


    public function addSprite(sprite:JSprite):void
    {
        if (!(sprite is JSprite)) {
            throw new Error(sprite);
        }

        spritesToAdd.push(sprite); //add(sprite);
        sprite.tick();
    }

    public function removeSprite(sprite:JSprite):void
    {
        spritesToRemove.push(sprite); //add(sprite);
    }

    override public function getX(alpha:Number):Number
    {
        var xCam:int = int(mario.xOld + (mario.x - mario.xOld) * alpha) - 160;
        if (xCam < 0) xCam = 0;
        return xCam + 160;
    }

    override public function getY(alpha:Number):Number
    {
        return 0;
    }

    public function bump(x:int, y:int, canBreakBricks:Boolean):void
    {
        var block:uint = level.getBlock(x, y);

        if ((Level.TILE_BEHAVIORS[block & 0xff] & Level.BIT_BUMPABLE) > 0)
        {
            bumpInto(x, y - 1);
            level.setBlock(x, y, uint(4));
            level.setBlockData(x, y, uint(4));

            if (((Level.TILE_BEHAVIORS[block & 0xff]) & Level.BIT_SPECIAL) > 0)
            {
                Art.samples[Art.SAMPLE_ITEM_SPROUT].play();
                if (!Mario.large)
                {
                    addSprite(new Mushroom(this, x * 16 + 8, y * 16 + 8));
                }
                else
                {
                    addSprite(new FireFlower(this, x * 16 + 8, y * 16 + 8));
                }
            }
            else
            {
                Mario.getCoin();
                Art.samples[Art.SAMPLE_GET_COIN].play();
                addSprite(new CoinAnim(x, y));
            }
        }

        if ((Level.TILE_BEHAVIORS[block & 0xff] & Level.BIT_BREAKABLE) > 0)
        {
            bumpInto(x, y - 1);
            if (canBreakBricks)
            {
                Art.samples[Art.SAMPLE_BREAK_BLOCK].play();
                level.setBlock(x, y, uint(0));
                for (var xx:int = 0; xx < 2; xx++)
                    for (var yy:int = 0; yy < 2; yy++)
                        addSprite(new Particle(x * 16 + xx * 8 + 4,
                                               y * 16 + yy * 8 + 4,
                                               (xx * 2 - 1) * 4,
                                               (yy * 2 - 1) * 4 - 8,
                                               int((Math.random()*2)),
                                               0));
            }
            else
            {
                level.setBlockData(x, y, uint(4));
            }
        }
    }

    public function bumpInto(x:int, y:int):void
    {
        var block:uint = level.getBlock(x, y);
        if (((Level.TILE_BEHAVIORS[block & 0xff]) & Level.BIT_PICKUPABLE) > 0)
        {
            Mario.getCoin();
            Art.samples[Art.SAMPLE_GET_COIN].play();
            level.setBlock(x, y, uint(0));
            addSprite(new CoinAnim(x, y + 1));
        }

        for each (var sprite:JSprite in sprites)
        {
            sprite.bumpCheck(x, y);
        }
    }
}
}

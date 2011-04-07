package com.mojang.mario {

import flash.display.BitmapData;
import java.awt.JGraphics;

import java.text.DecimalFormat;
import java.util.Random;

import com.mojang.mario.level.ImprovedNoise;
import com.mojang.mario.level.LevelGenerator;
import com.mojang.mario.sprites.Mario;


public class MapScene extends Scene
{
    private static const TILE_GRASS:int = 0;
    private static const TILE_WATER:int = 1;
    private static const TILE_LEVEL:int = 2;
    private static const TILE_ROAD:int = 3;
    private static const TILE_DECORATION:int = 4;

    private var level:Array;    // int[][]
    private var data:Array;     // int[][] 

    private var xMario:int, yMario:int;
    private var xMarioA:int, yMarioA:int;

    private var _tick:int;
    private var staticBg:BitmapData;
    private var staticGr:JGraphics;
    private var random:Random;
    private var moveTime:int = 0;
    private var marioComponent:MarioComponent;
    private var seed:Number = 0.5;
    private var worldNumber:int;

    private var levelId:int = 0;
    private var farthest:int = 0;
    private var xFarthestCap:int = 0;
    private var yFarthestCap:int = 0;

    public function MapScene(marioComponent:MarioComponent,
                             seed:Number)
    {
        this.marioComponent = marioComponent;
        this.seed = seed;

        random = new Random(seed);
        staticBg = new BitmapData(320, 240, true, 0);
        staticGr = new JGraphics(staticBg);
    }

    override public function init():void
    {
        worldNumber = -1;
        nextWorld();
    }

    private function nextWorld():void
    {
        worldNumber++;

        if (worldNumber==8)
        {
            marioComponent.win();
            return;
        }
        
        moveTime = 0;
        levelId = 0;
        farthest = 0;
        xFarthestCap = 0;
        yFarthestCap = 0;

        seed = random.nextLong();
        random = new Random(seed);

        while (!generateLevel()) {}
        renderStatic(staticGr);
    }

    public function startMusic():void
    {
        Art.startMusic(0);
    }

    private function generateLevel():Boolean
    {
        random = new Random(seed);
        var n0:ImprovedNoise = new ImprovedNoise(random.nextLong());
        var n1:ImprovedNoise = new ImprovedNoise(random.nextLong());
        var dec:ImprovedNoise = new ImprovedNoise(random.nextLong());

        var width:int = 320 / 16 + 1;
        var height:int = 240 / 16 + 1;
        level = new Array(width); // new int[width][height];
        data = new Array(width); // new int[width][height];
        for (var i:int = 0; i < width; ++i) {
            level[i] = new Array(height);
            data[i] = new Array(height);
        }

        var xo0:Number = random.nextDouble() * 512;
        var yo0:Number = random.nextDouble() * 512;
        var xo1:Number = random.nextDouble() * 512;
        var yo1:Number = random.nextDouble() * 512;
        for (var x:int = 0; x < width; x++)
        {
            for (var y:int = 0; y < height; y++)
            {
                var xd:Number = ((x + 1) / Number(width)  - 0.5) * 2;
                var yd:Number = ((y + 1) / Number(height)  - 0.5) * 2;
                var d:Number = Math.sqrt(xd * xd + yd * yd) * 2;
                if (x == 0 || y == 0 || x >= width - 3 || y >= height - 3) d = 100;
                var t0:Number = n0.perlinNoise(x * 10.0 + xo0, y * 10.0 + yo0);
                var t1:Number = n1.perlinNoise(x * 10.0 + xo1, y * 10.0 + yo1);
                var td:Number = (t0 - t1);
                var td2:Number = (td * 2);
                level[x][y] = td2 > 0 ? TILE_WATER : TILE_GRASS;
            }
        }

        var lowestX:int = 9999;
        var lowestY:int = 9999;
        var t:int = 0;
        for (i = 0; i < 100 && t < 12; i++)
        {
             x = random.nextInt((width - 1) / 3) * 3 + 2;
             y = random.nextInt((height - 1) / 3) * 3 + 1;
            if (level[x][y] == TILE_GRASS)
            {
                if (x < lowestX)
                {
                    lowestX = x;
                    lowestY = y;
                }
                level[x][y] = TILE_LEVEL;
                data[x][y] = -1;
                t++;
            }
        }

        data[lowestX][lowestY] = -2;

        while (findConnection(width, height)) {}

        findCaps(width, height);

        if (xFarthestCap == 0) return false;

        data[xFarthestCap][yFarthestCap] = -2;
        data[xMario / 16][yMario / 16] = -11;


        for (x = 0; x < width; x++)
        {
            for (y = 0; y < height; y++)
            {
                if (level[x][y] == TILE_GRASS && (x != xFarthestCap || y != yFarthestCap - 1))
                {
                     t0 = dec.perlinNoise(x * 10.0 + xo0, y * 10.0 + yo0);
                    if (t0 > 0) level[x][y] = TILE_DECORATION;
                }
            }
        }

        return true;
    }

    private function travel(x:int, y:int, dir:int , depth:int):void
    {
        if (level[x][y] != TILE_ROAD && level[x][y] != TILE_LEVEL)
        {
            return;
        }
        if (level[x][y] == TILE_ROAD)
        {
            if (data[x][y] == 1) return;
            else data[x][y] = 1;
        }

        if (level[x][y] == TILE_LEVEL)
        {
            if (data[x][y] > 0)
            {
                if (levelId != 0 && random.nextInt(4) == 0)
                {
                    data[x][y] = -3;
                }
                else
                {
                    data[x][y] = ++levelId;
                }
            }
            else if (depth > 0)
            {
                data[x][y] = -1;
                if (depth > farthest)
                {
                    farthest = depth;
                    xFarthestCap = x;
                    yFarthestCap = y;
                }
            }
        }

        if (dir != 2) travel(x - 1, y, 0, depth++);
        if (dir != 3) travel(x, y - 1, 1, depth++);
        if (dir != 0) travel(x + 1, y, 2, depth++);
        if (dir != 1) travel(x, y + 1, 3, depth++);
    }

    private function findCaps(width:int, height:int):void
    {
        var xCap:int = -1;
        var yCap:int = -1;

        for (var x:int = 0; x < width; x++)
        {
            for (var y:int = 0; y < height; y++)
            {
                if (level[x][y] == TILE_LEVEL)
                {
                    var roads:int = 0;
                    for (var xx:int = x - 1; xx <= x + 1; xx++)
                        for (var yy:int = y - 1; yy <= y + 1; yy++)
                        {
                            if (level[xx][yy] == TILE_ROAD) roads++;
                        }

                    if (roads == 1)
                    {
                        if (xCap == -1)
                        {
                            xCap = x;
                            yCap = y;
                        }
                        data[x][y] = 0;
                    }
                    else
                    {
                        data[x][y] = 1;
                    }
                }
            }
        }

        xMario = xCap * 16;
        yMario = yCap * 16;

        travel(xCap, yCap, -1, 0);
    }

    private function findConnection(width:int, height:int):Boolean
    {
        for (var x:int = 0; x < width; x++)
        {
            for (var y:int = 0; y < height; y++)
            {
                if (level[x][y] == TILE_LEVEL && data[x][y] == -1)
                {
                    connect(x, y, width, height);
                    return true;
                }
            }
        }
        return false;
    }

    private function connect(xSource:int, ySource:int, width:int, height:int):void
    {
        var maxDist:int = 10000;
        var xTarget:int = 0;
        var yTarget:int = 0;
        for (var x:int = 0; x < width; x++)
        {
            for (var y:int = 0; y < height; y++)
            {
                if (level[x][y] == TILE_LEVEL && data[x][y] == -2)
                {
                    var xd:int = Math.abs(xSource - x);
                    var yd:int = Math.abs(ySource - y);
                    var d:int = xd * xd + yd * yd;
                    if (d < maxDist)
                    {
                        xTarget = x;
                        yTarget = y;
                        maxDist = d;
                    }
                }
            }
        }

        drawRoad(xSource, ySource, xTarget, yTarget);
        level[xSource][ySource] = TILE_LEVEL;
        data[xSource][ySource] = -2;
        return;
    }

    private function drawRoad(x0:int, y0:int, x1:int, y1:int):void
    {
        var xFirst:Boolean = random.nextBoolean();

        if (xFirst)
        {
            while (x0 > x1)
            {
                data[x0][y0] = 0;
                level[x0--][y0] = TILE_ROAD;
            }
            while (x0 < x1)
            {
                data[x0][y0] = 0;
                level[x0++][y0] = TILE_ROAD;
            }
        }
        while (y0 > y1)
        {
            data[x0][y0] = 0;
            level[x0][y0--] = TILE_ROAD;
        }
        while (y0 < y1)
        {
            data[x0][y0] = 0;
            level[x0][y0++] = TILE_ROAD;
        }
        if (!xFirst)
        {
            while (x0 > x1)
            {
                data[x0][y0] = 0;
                level[x0--][y0] = TILE_ROAD;
            }
            while (x0 < x1)
            {
                data[x0][y0] = 0;
                level[x0++][y0] = TILE_ROAD;
            }
        }
    }

    public function renderStatic(g:JGraphics):void
    {
        var map:Array = Art.map;      // Image[][]

        for (var x:int = 0; x < 320 / 16; x++)
        {
            for (var y:int = 0; y < 240 / 16; y++)
            {
                g.drawImage(map[int(worldNumber / 4)][0], x * 16, y * 16);
                if (level[x][y] == TILE_LEVEL)
                {
                    var type:int = data[x][y];
                    if (type == 0)
                    {
                        g.drawImage(map[0][7], x * 16, y * 16);
                    }
                    else if (type == -1)
                    {
                        g.drawImage(map[3][8], x * 16, y * 16);
                    }
                    else if (type == -3)
                    {
                        g.drawImage(map[0][8], x * 16, y * 16);
                    }
                    else if (type == -10)
                    {
                        g.drawImage(map[1][8], x * 16, y * 16);
                    }
                    else if (type == -11)
                    {
                        g.drawImage(map[1][7], x * 16, y * 16);
                    }
                    else if (type == -2)
                    {
                        g.drawImage(map[2][7], x * 16, y * 16 - 16);
                        g.drawImage(map[2][8], x * 16, y * 16);
                    }
                    else
                    {
                        g.drawImage(map[type - 1][6], x * 16, y * 16);
                    }
                }
                else if (level[x][y] == TILE_ROAD)
                {
                    var p0:int = isRoad(x - 1, y) ? 1 : 0;
                    var p1:int = isRoad(x, y - 1) ? 1 : 0;
                    var p2:int = isRoad(x + 1, y) ? 1 : 0;
                    var p3:int = isRoad(x, y + 1) ? 1 : 0;
                    var s:int = p0 + p1 * 2 + p2 * 4 + p3 * 8;
                    g.drawImage(map[s][2], x * 16, y * 16);
                }
                else if (level[x][y] == TILE_WATER)
                {
                    for (var xx:int = 0; xx < 2; xx++)
                    {
                        for (var yy:int = 0; yy < 2; yy++)
                        {
                             p0 = isWater(x * 2 + (xx - 1), y * 2 + (yy - 1)) ? 0 : 1;
                             p1 = isWater(x * 2 + (xx + 0), y * 2 + (yy - 1)) ? 0 : 1;
                             p2 = isWater(x * 2 + (xx - 1), y * 2 + (yy + 0)) ? 0 : 1;
                             p3 = isWater(x * 2 + (xx + 0), y * 2 + (yy + 0)) ? 0 : 1;
                             s = p0 + p1 * 2 + p2 * 4 + p3 * 8 - 1;
                            if (s >= 0 && s < 14)
                            {
                                g.drawImage(map[s][4 + ((xx + yy) & 1)], x * 16 + xx * 8, y * 16 + yy * 8);
                            }
                        }
                    }
                }
            }
        }
    }

    private var df:DecimalFormat = new DecimalFormat("00");

    override public function render(g:JGraphics, alpha:Number):void
    {
        g.drawImage(staticBg, 0, 0);
        var map:Array = Art.map;      // Image[][] 

        for (var y:int = 0; y <= 240 / 16; y++)
        {
            for (var x:int = 320 / 16; x >= 0; x--)
            {
                if (level[x][y] == TILE_WATER)
                {
                    if (isWater(x * 2 - 1, y * 2 - 1))
                    {
                        var yy:int = 4 + (_tick / 6 + y) % 4;
                        g.drawImage(map[15][yy], x * 16 - 8, y * 16 - 8);
                    }
                }
                else if (level[x][y] == TILE_DECORATION)
                {
                    var xx:int = int((_tick + y * 12) / 6) % 4;
                    yy = 10 + worldNumber % 4;
                    g.drawImage(map[xx][yy], x * 16, y * 16);
                }
                else if (level[x][y] == TILE_LEVEL && data[x][y] == -2 && _tick / 12 % 2 == 0)
                {
                    g.drawImage(map[3][7], x * 16 + 16, y * 16 - 16);
                }
            }
        }
        if (!Mario.large)
        {
            xx = int((_tick) / 6) % 2;
            g.drawImage(map[xx][1], xMario + int(xMarioA * alpha), yMario + int(yMarioA * alpha) - 6);
        }
        else
        {
            if (!Mario.fire)
            {
                xx = int(_tick / 6) % 2+2;
                g.drawImage(map[xx][0], xMario + int(xMarioA * alpha), yMario + int(yMarioA * alpha) - 6-16);
              //xx = int(_tick / 6) % 2+2;
                g.drawImage(map[xx][1], xMario + int(xMarioA * alpha), yMario + int(yMarioA * alpha) - 6);
            }
            else
            {
                xx = int(_tick / 6) % 2+4;
                g.drawImage(map[xx][0], xMario + int(xMarioA * alpha), yMario + int(yMarioA * alpha) - 6-16);
              //xx = int(_tick / 6) % 2+4;
                g.drawImage(map[xx][1], xMario + int(xMarioA * alpha), yMario + int(yMarioA * alpha) - 6);
            }
        }
        
        drawStringDropShadow(g, "MARIO " + df.format(Mario.lives), 0, 0, 7);

        drawStringDropShadow(g, "WORLD "+(worldNumber+1), 32, 0, 7);
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

    private function isRoad(x:int, y:int):Boolean
    {
        if (x < 0) x = 0;
        if (y < 0) y = 0;
        if (level[x][y] == TILE_ROAD) return true;
        if (level[x][y] == TILE_LEVEL) return true;
        return false;
    }

    private function isWater(x:int, y:int):Boolean
    {
        if (x < 0) x = 0;
        if (y < 0) y = 0;

        for (var xx:int = 0; xx < 2; xx++)
        {
            var xxx:int = (x + xx) / 2;
            for (var yy:int = 0; yy < 2; yy++)
            {
                var yyy:int = (y + yy) / 2;
                if (level[xxx][yyy] != TILE_WATER) return false;
            }
        }

        return true;
    }

    private var canEnterLevel:Boolean = false;

    override public function tick():void
    {
        xMario += xMarioA;
        yMario += yMarioA;
        _tick++;
        var x:int = xMario / 16;
        var y:int = yMario / 16;
        if (level[x][y] == TILE_ROAD)
        {
            data[x][y] = 0;
        }

        if (moveTime > 0)
        {
            moveTime--;
        }
        else
        {
            xMarioA = 0;
            yMarioA = 0;
            if (canEnterLevel && keys[Mario.KEY_JUMP])
            {
                if (level[x][y] == TILE_LEVEL && data[x][y] == -11)
                {
                }
                else
                {
                    if (level[x][y] == TILE_LEVEL && data[x][y] != 0 && data[x][y] > -10)
                    {
                        Mario.levelString = (worldNumber + 1) + "-";
                        var difficulty:int = worldNumber+1;
                        var type:int = LevelGenerator.TYPE_OVERGROUND;
						//multiplies by arbitrary big values, but we want seeds between 0 - 1, so take the reciprocal
						//of the big number by taking 1/number - billy
                        if (data[x][y] > 1 && new Random(1 / (seed + x * 313 + y * 534)).nextInt(4) == 1)
                        {
                            type = LevelGenerator.TYPE_UNDERGROUND;
                        }
                        if (data[x][y] < 0)
                        {
                            if (data[x][y] == -2)
                            {
                                Mario.levelString += "X";
                                difficulty += 2;
                            }
                            else if (data[x][y] == -1)
                            {
                                Mario.levelString += "?";
                            }
                            else
                            {
                                Mario.levelString += "#";
                                difficulty += 1;
                            }

                            type = LevelGenerator.TYPE_CASTLE;
                        }
                        else
                        {
                            Mario.levelString += data[x][y];
                        }

                        Art.stopMusic();
						//Same reciprocal trick as before - Billy
                        marioComponent.startLevel(1 / (seed * x * y + x * 31871 + y * 21871), difficulty, type);
                    }
                }
            }
            canEnterLevel = !keys[Mario.KEY_JUMP];

            if (keys[Mario.KEY_LEFT])
            {
                keys[Mario.KEY_LEFT] = false;
                tryWalking(-1, 0);
            }
            if (keys[Mario.KEY_RIGHT])
            {
                keys[Mario.KEY_RIGHT] = false;
                tryWalking(1, 0);
            }
            if (keys[Mario.KEY_UP])
            {
                keys[Mario.KEY_UP] = false;
                tryWalking(0, -1);
            }
            if (keys[Mario.KEY_DOWN])
            {
                keys[Mario.KEY_DOWN] = false;
                tryWalking(0, 1);
            }
        }
    }

    public function tryWalking(xd:int, yd:int):void
    {
        var x:int = xMario / 16;
        var y:int = yMario / 16;
        var xt:int = xMario / 16 + xd;
        var yt:int = yMario / 16 + yd;

        if (level[xt][yt] == TILE_ROAD || level[xt][yt] == TILE_LEVEL)
        {
            if (level[xt][yt] == TILE_ROAD)
            {
                if ((data[xt][yt] != 0) && (data[x][y] != 0 && data[x][y] > -10)) return;
            }
            xMarioA = xd * 8;
            yMarioA = yd * 8;
            moveTime = calcDistance(x, y, xd, yd) * 2 + 1;
        }
    }

    private function calcDistance(x:int, y:int, xa:int, ya:int):int
    {
        var distance:int = 0;
        while (true)
        {
            x += xa;
            y += ya;
            if (level[x][y] != TILE_ROAD) return distance;
            if (level[x - ya][y + xa] == TILE_ROAD) return distance;
            if (level[x + ya][y - xa] == TILE_ROAD) return distance;
            distance++;
        }
        return distance;
    }

    override public function getX(alpha:Number):Number
    {
        return 160;
    }

    override public function getY(alpha:Number):Number
    {
        return 120;
    }

    public function levelWon():void
    {
        var x:int = xMario / 16;
        var y:int = yMario / 16;
        if (data[x][y] == -2)
        {
            nextWorld();
            return;
        }
        if (data[x][y] != -3) data[x][y] = 0;
        else data[x][y] = -10;
        renderStatic(staticGr);
    }
}
}

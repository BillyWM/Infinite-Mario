package com.mojang.mario.level {

import java.util.Random;

import com.mojang.mario.sprites.Enemy;


public class LevelGenerator
{
    public static const TYPE_OVERGROUND:int = 0;
    public static const TYPE_UNDERGROUND:int = 1;
    public static const TYPE_CASTLE:int = 2;

    private static var levelSeedRandom:Random = new Random();
    public static var lastSeed:Number;

    public static function createLevel(width:int, height:int, seed:Number, difficulty:int, type:int):Level
    {
        var levelGenerator:LevelGenerator = new LevelGenerator(width, height);
        return levelGenerator.createLevel(seed, difficulty, type);
    }

    private var width:int;
    private var height:int;
    internal var level:Level = new Level(width, height);
    internal var random:Random;

    private static const ODDS_STRAIGHT:int = 0;
    private static const ODDS_HILL_STRAIGHT:int = 1;
    private static const ODDS_TUBES:int = 2;
    private static const ODDS_JUMP:int = 3;
    private static const ODDS_CANNONS:int = 4;
    private var odds:Array = new Array(5); //int[5];
    private var totalOdds:int;
    private var difficulty:int;
    private var type:int;

    public function LevelGenerator(width:int, height:int)
    {
        this.width = width;
        this.height = height;
    }

    private function createLevel(seed:Number, difficulty:int, type:int):Level
    {
        this.type = type;
        this.difficulty = difficulty;
        odds[ODDS_STRAIGHT] = 20;
        odds[ODDS_HILL_STRAIGHT] = 10;
        odds[ODDS_TUBES] = 2 + 1 * difficulty;
        odds[ODDS_JUMP] = 2 * difficulty;
        odds[ODDS_CANNONS] = -10 + 5 * difficulty;

        if (type != LevelGenerator.TYPE_OVERGROUND)
        {
            odds[ODDS_HILL_STRAIGHT] = 0;
        }

        for (var i:int = 0; i < odds.length; i++)
        {
            if (odds[i] < 0) odds[i] = 0;
            totalOdds += odds[i];
            odds[i] = totalOdds - odds[i];
        }

        lastSeed = seed;
        level = new Level(width, height);
        random = new Random(seed);

        var length:int = 0;
        length += buildStraight(0, level.width, true);
        while (length < level.width - 64)
        {
            length += buildZone(length, level.width - length);
        }

        var floor:int = height - 1 - random.nextInt(4);

        level.xExit = length + 8;
        level.yExit = floor;

        for (var x:int = length; x < level.width; x++)
        {
            for (var y:int = 0; y < height; y++)
            {
                if (y >= floor)
                {
                    level.setBlock(x, y, uint((1 + 9 * 16)));
                }
            }
        }

        if (type == LevelGenerator.TYPE_CASTLE || type == LevelGenerator.TYPE_UNDERGROUND)
        {
            var ceiling:int = 0;
            var run:int = 0;
            for (x = 0; x < level.width; x++)
            {
                if (run-- <= 0 && x > 4)
                {
                    ceiling = random.nextInt(4);
                    run = random.nextInt(4) + 4;
                }
                for (y = 0; y < level.height; y++)
                {
                    if ((x > 4 && y <= ceiling) || x < 1)
                    {
                        level.setBlock(x, y, uint((1 + 9 * 16)));
                    }
                }
            }
        }

        fixWalls();

        return level;
    }

    private function buildZone(x:int, maxLength:int):int
    {
        var t:int = random.nextInt(totalOdds);
        var type:int = 0;
        for (var i:int = 0; i < odds.length; i++)
        {
            if (odds[i] <= t)
            {
                type = i;
            }
        }

        switch (type)
        {
            case ODDS_STRAIGHT:
                return buildStraight(x, maxLength, false);
            case ODDS_HILL_STRAIGHT:
                return buildHillStraight(x, maxLength);
            case ODDS_TUBES:
                return buildTubes(x, maxLength);
            case ODDS_JUMP:
                return buildJump(x, maxLength);
            case ODDS_CANNONS:
                return buildCannons(x, maxLength);
        }
        return 0;
    }

    private function buildJump(xo:int, maxLength:int):int
    {
        var js:int = random.nextInt(4) + 2;
        var jl:int = random.nextInt(2) + 2;
        var length:int = js * 2 + jl;

        var hasStairs:Boolean = random.nextInt(3) == 0;

        var floor:int = height - 1 - random.nextInt(4);
        for (var x:int = xo; x < xo + length; x++)
        {
            if (x < xo + js || x > xo + length - js - 1)
            {
                for (var y:int = 0; y < height; y++)
                {
                    if (y >= floor)
                    {
                        level.setBlock(x, y, uint((1 + 9 * 16)));
                    }
                    else if (hasStairs)
                    {
                        if (x < xo + js)
                        {
                            if (y >= floor - (x - xo) + 1)
                            {
                                level.setBlock(x, y, uint((9 + 0 * 16)));
                            }
                        }
                        else
                        {
                            if (y >= floor - ((xo + length) - x) + 2)
                            {
                                level.setBlock(x, y, uint((9 + 0 * 16)));
                            }
                        }
                    }
                }
            }
        }

        return length;
    }

    private function buildCannons(xo:int, maxLength:int):int
    {
        var length:int = random.nextInt(10) + 2;
        if (length > maxLength) length = maxLength;

        var floor:int = height - 1 - random.nextInt(4);
        var xCannon:int = xo + 1 + random.nextInt(4);
        for (var x:int = xo; x < xo + length; x++)
        {
            if (x > xCannon)
            {
                xCannon += 2 + random.nextInt(4);
            }
            if (xCannon == xo + length - 1) xCannon += 10;
            var cannonHeight:int = floor - random.nextInt(4) - 1;

            for (var y:int = 0; y < height; y++)
            {
                if (y >= floor)
                {
                    level.setBlock(x, y, uint((1 + 9 * 16)));
                }
                else
                {
                    if (x == xCannon && y >= cannonHeight)
                    {
                        if (y == cannonHeight)
                        {
                            level.setBlock(x, y, uint((14 + 0 * 16)));
                        }
                        else if (y == cannonHeight + 1)
                        {
                            level.setBlock(x, y, uint((14 + 1 * 16)));
                        }
                        else
                        {
                            level.setBlock(x, y, uint((14 + 2 * 16)));
                        }
                    }
                }
            }
        }

        return length;
    }

    private function buildHillStraight(xo:int, maxLength:int):int
    {
        var length:int = random.nextInt(10) + 10;
        if (length > maxLength) length = maxLength;

        var floor:int = height - 1 - random.nextInt(4);
        for (var x:int = xo; x < xo + length; x++)
        {
            for (var y:int = 0; y < height; y++)
            {
                if (y >= floor)
                {
                    level.setBlock(x, y, uint((1 + 9 * 16)));
                }
            }
        }

        addEnemyLine(xo + 1, xo + length - 1, floor - 1);

        var h:int = floor;

        var keepGoing:Boolean = true;

        var occupied:Array = new Array(length);
        while (keepGoing)
        {
            h = h - 2 - random.nextInt(3);

            if (h <= 0)
            {
                keepGoing = false;
            }
            else
            {
                var l:int = random.nextInt(5) + 3;
                var xxo:int = random.nextInt(length - l - 2) + xo + 1;

                if (occupied[xxo - xo] || occupied[xxo - xo + l] || occupied[xxo - xo - 1] || occupied[xxo - xo + l + 1])
                {
                    keepGoing = false;
                }
                else
                {
                    occupied[xxo - xo] = true;
                    occupied[xxo - xo + l] = true;
                    addEnemyLine(xxo, xxo + l, h - 1);
                    if (random.nextInt(4) == 0)
                    {
                        decorate(xxo - 1, xxo + l + 1, h);
                        keepGoing = false;
                    }
                    for (x = xxo; x < xxo + l; x++)
                    {
                        for (y = h; y < floor; y++)
                        {
                            var xx:int = 5;
                            if (x == xxo) xx = 4;
                            if (x == xxo + l - 1) xx = 6;
                            var yy:int = 9;
                            if (y == h) yy = 8;

                            if (level.getBlock(x, y) == 0)
                            {
                                level.setBlock(x, y, uint((xx + yy * 16)));
                            }
                            else
                            {
                                if (level.getBlock(x, y) == uint((4 + 8 * 16))) level.setBlock(x, y, uint((4 + 11 * 16)));
                                if (level.getBlock(x, y) == uint((6 + 8 * 16))) level.setBlock(x, y, uint((6 + 11 * 16)));
                            }
                        }
                    }
                }
            }
        }

        return length;
    }

    private function addEnemyLine(x0:int, x1:int, y:int):void
    {
        for (var x:int = x0; x < x1; x++)
        {
            if (random.nextInt(35) < difficulty + 1)
            {
                var type:int = random.nextInt(4);
                if (difficulty < 1)
                {
                    type = Enemy.ENEMY_GOOMBA;
                }
                else if (difficulty < 3)
                {
                    type = random.nextInt(3);
                }
                level.setSpriteTemplate(x, y, new SpriteTemplate(type, random.nextInt(35) < difficulty));
            }
        }
    }

    private function buildTubes(xo:int, maxLength:int):int
    {
        var length:int = random.nextInt(10) + 5;
        if (length > maxLength) length = maxLength;

        var floor:int = height - 1 - random.nextInt(4);
        var xTube:int = xo + 1 + random.nextInt(4);
        var tubeHeight:int = floor - random.nextInt(2) - 2;
        for (var x:int = xo; x < xo + length; x++)
        {
            if (x > xTube + 1)
            {
                xTube += 3 + random.nextInt(4);
                tubeHeight = floor - random.nextInt(2) - 2;
            }
            if (xTube >= xo + length - 2) xTube += 10;

            if (x == xTube && random.nextInt(11) < difficulty + 1)
            {
                level.setSpriteTemplate(x, tubeHeight, new SpriteTemplate(Enemy.ENEMY_FLOWER, false));
            }

            for (var y:int = 0; y < height; y++)
            {
                if (y >= floor)
                {
                    level.setBlock(x, y, uint((1 + 9 * 16)));
                }
                else
                {
                    if ((x == xTube || x == xTube + 1) && y >= tubeHeight)
                    {
                        var xPic:int = 10 + x - xTube;
                        if (y == tubeHeight)
                        {
                            level.setBlock(x, y, uint((xPic + 0 * 16)));
                        }
                        else
                        {
                            level.setBlock(x, y, uint((xPic + 1 * 16)));
                        }
                    }
                }
            }
        }

        return length;
    }

    private function buildStraight(xo:int, maxLength:int, safe:Boolean):int
    {
        var length:int = random.nextInt(10) + 2;
        if (safe) length = 10 + random.nextInt(5);
        if (length > maxLength) length = maxLength;

        var floor:int = height - 1 - random.nextInt(4);
        for (var x:int = xo; x < xo + length; x++)
        {
            for (var y:int = 0; y < height; y++)
            {
                if (y >= floor)
                {
                    level.setBlock(x, y, uint((1 + 9 * 16)));
                }
            }
        }

        if (!safe)
        {
            if (length > 5)
            {
                decorate(xo, xo + length, floor);
            }
        }

        return length;
    }

    private function decorate(x0:int, x1:int, floor:int):void
    {
        if (floor < 1) return;

        var rocks:Boolean = true;

        addEnemyLine(x0 + 1, x1 - 1, floor - 1);

        var s:int = random.nextInt(4);
        var e:int = random.nextInt(4);

        if (floor - 2 > 0)
        {
            if ((x1 - 1 - e) - (x0 + 1 + s) > 1)
            {
                for (var x:int = x0 + 1 + s; x < x1 - 1 - e; x++)
                {
                    level.setBlock(x, floor - 2, uint((2 + 2 * 16)));
                }
            }
        }

        s = random.nextInt(4);
        e = random.nextInt(4);

        if (floor - 4 > 0)
        {
            if ((x1 - 1 - e) - (x0 + 1 + s) > 2)
            {
                for (x = x0 + 1 + s; x < x1 - 1 - e; x++)
                {
                    if (rocks)
                    {
                        if (x != x0 + 1 && x != x1 - 2 && random.nextInt(3) == 0)
                        {
                            if (random.nextInt(4) == 0)
                            {
                                level.setBlock(x, floor - 4, uint((4 + 2 + 1 * 16)));
                            }
                            else
                            {
                                level.setBlock(x, floor - 4, uint((4 + 1 + 1 * 16)));
                            }
                        }
                        else if (random.nextInt(4) == 0)
                        {
                            if (random.nextInt(4) == 0)
                            {
                                level.setBlock(x, floor - 4, uint((2 + 1 * 16)));
                            }
                            else
                            {
                                level.setBlock(x, floor - 4, uint((1 + 1 * 16)));
                            }
                        }
                        else
                        {
                            level.setBlock(x, floor - 4, uint((0 + 1 * 16)));
                        }
                    }
                }
            }
        }

        var length:int = x1 - x0 - 2;

    }

    private function fixWalls():void
    {
        var blockMap:Array = new Array(width + 1);
        for (var x:int = 0; x < width + 1; x++)
        {
            blockMap[x] = new Array(height + 1);
            for (var y:int = 0; y < height + 1; y++)
            {
                var blocks:int = 0;
                for (var xx:int = x - 1; xx < x + 1; xx++)
                {
                    for (var yy:int = y - 1; yy < y + 1; yy++)
                    {
                        if (level.getBlockCapped(xx, yy) == uint((1 + 9 * 16))) blocks++;
                    }
                }
                blockMap[x][y] = blocks == 4;
            }
        }
        blockify(level, blockMap, width + 1, height + 1);
    }

    private function blockify(level:Level, blocks:Array, width:int, height:int):void
    {
        var to:int = 0;
        if (type == LevelGenerator.TYPE_CASTLE)
        {
            to = 4 * 2;
        }
        else if (type == LevelGenerator.TYPE_UNDERGROUND)
        {
            to = 4 * 3;
        }

        var b:Array = new Array(2);
        b[0] = new Array(2);
        b[1] = new Array(2);

        for (var x:int = 0; x < width; x++)
        {
            for (var y:int = 0; y < height; y++)
            {
                for (var xx:int = x; xx <= x + 1; xx++)
                {
                    for (var yy:int = y; yy <= y + 1; yy++)
                    {
                        var _xx:int = xx;
                        var _yy:int = yy;
                        if (_xx < 0) _xx = 0;
                        if (_yy < 0) _yy = 0;
                        if (_xx > width - 1) _xx = width - 1;
                        if (_yy > height - 1) _yy = height - 1;
                        b[xx - x][yy - y] = blocks[_xx][_yy];
                    }
                }

                if (b[0][0] == b[1][0] && b[0][1] == b[1][1])
                {
                    if (b[0][0] == b[0][1])
                    {
                        if (b[0][0])
                        {
                            level.setBlock(x, y, uint((1 + 9 * 16 + to)));
                        }
                        else
                        {
                            // KEEP OLD BLOCK!
                        }
                    }
                    else
                    {
                        if (b[0][0])
                        {
                            level.setBlock(x, y, uint((1 + 10 * 16 + to)));
                        }
                        else
                        {
                            level.setBlock(x, y, uint((1 + 8 * 16 + to)));
                        }
                    }
                }
                else if (b[0][0] == b[0][1] && b[1][0] == b[1][1])
                {
                    if (b[0][0])
                    {
                        level.setBlock(x, y, uint((2 + 9 * 16 + to)));
                    }
                    else
                    {
                        level.setBlock(x, y, uint((0 + 9 * 16 + to)));
                    }
                }
                else if (b[0][0] == b[1][1] && b[0][1] == b[1][0])
                {
                    level.setBlock(x, y, uint((1 + 9 * 16 + to)));
                }
                else if (b[0][0] == b[1][0])
                {
                    if (b[0][0])
                    {
                        if (b[0][1])
                        {
                            level.setBlock(x, y, uint((3 + 10 * 16 + to)));
                        }
                        else
                        {
                            level.setBlock(x, y, uint((3 + 11 * 16 + to)));
                        }
                    }
                    else
                    {
                        if (b[0][1])
                        {
                            level.setBlock(x, y, uint((2 + 8 * 16 + to)));
                        }
                        else
                        {
                            level.setBlock(x, y, uint((0 + 8 * 16 + to)));
                        }
                    }
                }
                else if (b[0][1] == b[1][1])
                {
                    if (b[0][1])
                    {
                        if (b[0][0])
                        {
                            level.setBlock(x, y, uint((3 + 9 * 16 + to)));
                        }
                        else
                        {
                            level.setBlock(x, y, uint((3 + 8 * 16 + to)));
                        }
                    }
                    else
                    {
                        if (b[0][0])
                        {
                            level.setBlock(x, y, uint((2 + 10 * 16 + to)));
                        }
                        else
                        {
                            level.setBlock(x, y, uint((0 + 10 * 16 + to)));
                        }
                    }
                }
                else
                {
                    level.setBlock(x, y, uint((0 + 1 * 16 + to)));
                }
            }
        }
    }
}
}

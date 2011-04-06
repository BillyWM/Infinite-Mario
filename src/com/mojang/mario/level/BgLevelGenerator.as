package com.mojang.mario.level {

import java.util.Random;


public class BgLevelGenerator
{
    private static var levelSeedRandom:Random = new Random();

    public static function createLevel(width:int, height:int, distant:Boolean, type:int):Level
    {
        var levelGenerator:BgLevelGenerator = new BgLevelGenerator(width, height, distant, type);
        return levelGenerator.createLevel(levelSeedRandom.nextLong());
    }

    private var width:int;
    private var height:int;
    private var distant:Boolean;
    private var type:int;

    public function BgLevelGenerator(width:int, height:int, distant:Boolean, type:int)
    {
        this.width = width;
        this.height = height;
        this.distant = distant;
        this.type = type;
    }

    private function createLevel(seed:Number):Level
    {
        var level:Level = new Level(width, height);
        var random:Random = new Random(seed);

        switch (type)
        {
            case LevelGenerator.TYPE_OVERGROUND:
            {

                var range:int = distant ? 4 : 6;
                var offs:int = distant ? 2 : 1;
                var oh:int = random.nextInt(range) + offs;
                var h:int = random.nextInt(range) + offs;
                for (var x:int = 0; x < width; x++)
                {
                    oh = h;
                    while (oh == h)
                    {
                        h = random.nextInt(range) + offs;
                    }
                    for (var y:int = 0; y < height; y++)
                    {
                        var h0:int = (oh < h) ? oh : h;
                        var h1:int = (oh < h) ? h : oh;
                        if (y < h0)
                        {
                            if (distant)
                            {
                                var s:int = 2;
                                if (y < 2) s = y;
                                level.setBlock(x, y, uint((4 + s * 8)));
                            }
                            else
                            {
                                level.setBlock(x, y, uint(5));
                            }
                        }
                        else if (y == h0)
                        {
                             s = h0 == h ? 0 : 1;
                            s += distant ? 2 : 0;
                            level.setBlock(x, y, uint(s));
                        }
                        else if (y == h1)
                        {
                             s = h0 == h ? 0 : 1;
                            s += distant ? 2 : 0;
                            level.setBlock(x, y, uint((s + 16)));
                        }
                        else
                        {
                             s = y > h1 ? 1 : 0;
                            if (h0 == oh) s = 1 - s;
                            s += distant ? 2 : 0;
                            level.setBlock(x, y, uint((s + 8)));
                        }
                    }
                }
                break;
            }
            case LevelGenerator.TYPE_UNDERGROUND:
            {
                if (distant)
                {
                    var tt:int = 0;
                    for (x = 0; x < width; x++)
                    {
                        if (random.nextDouble() < 0.75) tt = 1 - tt;
                        for (y = 0; y < height; y++)
                        {
                            var t:int = tt;
                            var yy:int = y - 2;
                            if (yy < 0 || yy > 4)
                            {
                                yy = 2;
                                t = 0;
                            }
                            level.setBlock(x, y, uint((4 + t + (3 + yy) * 8)));
                        }
                    }
                }
                else
                {
                    for (x = 0; x < width; x++)
                    {
                        for (y = 0; y < height; y++)
                        {
                             t = x % 2;
                             yy = y-1;
                            if (yy < 0 || yy > 7)
                            {
                                yy = 7;
                                t = 0;
                            }
                            if (t == 0 && yy > 1 && yy < 5)
                            {
                                t = -1;
                                yy = 0;
                            }
                            level.setBlock(x, y, uint((6 + t + (yy) * 8)));
                        }
                    }
                }
                break;
            }
            case LevelGenerator.TYPE_CASTLE:
            {
                if (distant)
                {
                    for (x = 0; x < width; x++)
                    {
                        for (y = 0; y < height; y++)
                        {
                             t = x % 2;
                             yy = y - 1;
                            if (yy>2 && yy<5)
                            {
                                yy = 2;
                            }
                            else if (yy>=5)
                            {
                                yy-=2;
                            }
                            if (yy < 0)
                            {
                                t = 0;
                                yy = 5;
                            }
                            else if (yy > 4)
                            {
                                t = 1;
                                yy = 5;
                            }
                            else if (t<1 && yy==3)
                            {
                                t = 0;
                                yy = 3;
                            }
                            else if (t<1 && yy>0 && yy<3)
                            {
                                t = 0;
                                yy = 2;
                            }
                            level.setBlock(x, y, uint((1+t + (yy + 4) * 8)));
                        }
                    }
                }
                else
                {
                    for (x = 0; x < width; x++)
                    {
                        for (y = 0; y < height; y++)
                        {
                             t = x % 3;
                             yy = y - 1;
                            if (yy>2 && yy<5)
                            {
                                yy = 2;
                            }
                            else if (yy>=5)
                            {
                                yy-=2;
                            }
                            if (yy < 0)
                            {
                                t = 1;
                                yy = 5;
                            }
                            else if (yy > 4)
                            {
                                t = 2;
                                yy = 5;
                            }
                            else if (t<2 && yy==4)
                            {
                                t = 2;
                                yy = 4;
                            }
                            else if (t<2 && yy>0 && yy<4)
                            {
                                t = 4;
                                yy = -3;
                            }
                            level.setBlock(x, y, uint((1 + t + (yy + 3) * 8)));
                        }
                    }
                }
                break;
            }
        }
        return level;
    }
}
}

package com.mojang.mario.level {


import flash.utils.ByteArray;

public class Level
{
    public static const BIT_DESCRIPTIONS:Array = [
        "BLOCK UPPER", //
        "BLOCK ALL", //
        "BLOCK LOWER", //
        "SPECIAL", //
        "BUMPABLE", //
        "BREAKABLE", //
        "PICKUPABLE", //
        "ANIMATED",//
    ];

    public static var TILE_BEHAVIORS:ByteArray;

    public static const BIT_BLOCK_UPPER:int = 1 << 0;
    public static const BIT_BLOCK_ALL:int = 1 << 1;
    public static const BIT_BLOCK_LOWER:int = 1 << 2;
    public static const BIT_SPECIAL:int = 1 << 3;
    public static const BIT_BUMPABLE:int = 1 << 4;
    public static const BIT_BREAKABLE:int = 1 << 5;
    public static const BIT_PICKUPABLE:int = 1 << 6;
    public static const BIT_ANIMATED:int = 1 << 7;
    private static const FILE_HEADER:int = 0x271c4178;

    public var width:int;
    public var height:int;
    public var map:Array;
    public var data:Array;
    public var spriteTemplates:Array;
    public var xExit:int;
    public var yExit:int;

    public function Level(width:int, height:int)
    {        
        this.width = width;
        this.height = height;
        xExit = 10;
        yExit = 10;
        map = new Array(width);
        data = new Array(width);
        spriteTemplates = new Array(width);
        for (var i:int = 0; i < width; ++i) {
            map[i] = new Array(height);
            data[i] = new Array(height);
            spriteTemplates[i] = new Array(height);
            for (var j:int = 0; j < height; ++j) {
                map[i][j] = 0;
                data[i][j] = 0;
                spriteTemplates[i][j] = null;
            }
        }
    }

    public static function loadBehaviors(behaviors:ByteArray):void
    {     
        TILE_BEHAVIORS = behaviors;
    }

    public function tick():void
    {
        
        for (var x:int = 0; x < width; x++)
        {
            for (var y:int = 0; y < height; y++)
            {
                if (uint(data[x][y]) > 0) data[x][y]--;
            }
        }
    }

    public function getBlockCapped(x:int, y:int):uint
    {
        
        if (x < 0) x = 0;
        if (y < 0) y = 0;
        if (x >= width) x = width - 1;
        if (y >= height) y = height - 1;
        return uint(map[x][y]);
    }

    public function getBlock(x:int, y:int):uint
    {
        
        if (x < 0) x = 0;
        if (y < 0) return 0;
        if (x >= width) x = width - 1;
        if (y >= height) y = height - 1;
        return uint(map[x][y]);
    }

    public function setBlock(x:int, y:int, b:uint):void
    {
        
        if (x < 0) return;
        if (y < 0) return;
        if (x >= width) return;
        if (y >= height) return;
        map[x][y] = b;
    }

    public function setBlockData(x:int, y:int, b:uint):void
    {
        
        if (x < 0) return;
        if (y < 0) return;
        if (x >= width) return;
        if (y >= height) return;
        data[x][y] = b;
    }

    public function isBlocking(x:int, y:int, xa:Number, ya:Number):Boolean
    {
        
        var block:uint = getBlock(x, y);
        var blocking:Boolean = ((TILE_BEHAVIORS[block & 0xff]) & BIT_BLOCK_ALL) > 0;
        blocking ||= (ya > 0) && ((TILE_BEHAVIORS[block & 0xff]) & BIT_BLOCK_UPPER) > 0;
        blocking ||= (ya < 0) && ((TILE_BEHAVIORS[block & 0xff]) & BIT_BLOCK_LOWER) > 0;
        return blocking;
    }

    public function getSpriteTemplate(x:int, y:int):SpriteTemplate
    {
        
        if (x < 0) return null;
        if (y < 0) return null;
        if (x >= width) return null;
        if (y >= height) return null;
        return spriteTemplates[x][y];
    }

    public function setSpriteTemplate(x:int, y:int, spriteTemplate:SpriteTemplate):void
    {
        
        if (x < 0) return;
        if (y < 0) return;
        if (x >= width) return;
        if (y >= height) return;
        spriteTemplates[x][y] = spriteTemplate;
    }
}
}

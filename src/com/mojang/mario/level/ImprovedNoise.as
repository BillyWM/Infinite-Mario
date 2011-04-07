package com.mojang.mario.level {

import java.util.*;

public final class ImprovedNoise
{
    public function ImprovedNoise(seed:Number)
    {
        shuffle(seed);
    }
    
    public function noise(x:Number, y:Number, z:Number):Number
    {
        var X:int = int(Math.floor(x) & 255), // FIND UNIT CUBE THAT
        Y:int = int(Math.floor(y) & 255), // CONTAINS POINT.
        Z:int = int(Math.floor(z) & 255);
        x -= Math.floor(x); // FIND RELATIVE X,Y,Z
        y -= Math.floor(y); // OF POINT IN CUBE.
        z -= Math.floor(z);
        var u:Number = fade(x), // COMPUTE FADE CURVES
        v:Number = fade(y), // FOR EACH OF X,Y,Z.
        w:Number = fade(z);
        var A:int = p[X] + Y, AA:int = p[A] + Z, AB:int = p[A + 1] + Z, // HASH COORDINATES OF
        B:int = p[X + 1] + Y, BA:int = p[B] + Z, BB:int = p[B + 1] + Z; // THE 8 CUBE CORNERS,

        return lerp(w, lerp(v, lerp(u, grad(p[AA], x, y, z), // AND ADD
                grad(p[BA], x - 1, y, z)), // BLENDED
                lerp(u, grad(p[AB], x, y - 1, z), // RESULTS
                        grad(p[BB], x - 1, y - 1, z))),// FROM  8
                lerp(v, lerp(u, grad(p[AA + 1], x, y, z - 1), // CORNERS
                        grad(p[BA + 1], x - 1, y, z - 1)), // OF CUBE
                        lerp(u, grad(p[AB + 1], x, y - 1, z - 1), grad(p[BB + 1], x - 1, y - 1, z - 1))));
    }

    internal function fade(t:Number):Number
    {
        return t * t * t * (t * (t * 6 - 15) + 10);
    }

    internal function lerp(t:Number, a:Number, b:Number):Number
    {
        return a + t * (b - a);
    }

    internal function grad(hash:int, x:Number, y:Number, z:Number):Number
    {
        var h:int = hash & 15; // CONVERT LO 4 BITS OF HASH CODE
        var u:Number = h < 8 ? x : y, // INTO 12 GRADIENT DIRECTIONS.
            v:Number = h < 4 ? y : h == 12 || h == 14 ? x : z;
        return ((h & 1) == 0 ? u : -u) + ((h & 2) == 0 ? v : -v);
    }

    internal var p:Array = new Array(512);     // int[512]
  
    public function perlinNoise(x:Number, y:Number):Number
    {
        var n:Number = 0;

        for (var i:int = 0; i < 8; i++)
        {
            var stepSize:Number = 64.0 / ((1 << i));
            n += noise(x / stepSize, y / stepSize, 128) * 1.0 / (1 << i);
        }
        
        return n;
    }
    
    public function shuffle(seed:Number):void
    {
        var random:Random = new Random(seed);
        var permutation:Array = new Array(256); // int[256]
        for (var i:int=0; i<256; i++)
        {
            permutation[i] = i;
        }

        for (i=0; i<256; i++)
        {
            var j:int = random.nextInt(256-i)+i;
            var tmp:int = permutation[i];
            permutation[i] = permutation[j];
            permutation[j] = tmp;
            p[i+256] = p[i] = permutation[i];
        }
    }
}
}

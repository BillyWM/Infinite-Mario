package com.mojang.mario {

    //import com.mojang.sonar.SoundListener;
    import java.awt.JGraphics;

    // abstract implements SoundListener
    public class Scene {

        public static var keys:Array = new Array(16); // boolean[16] 

        public function toggleKey(key:int, isPressed:Boolean):void {
            keys[key] = isPressed;
        }

        // abstract
        public function init():void {}

        // abstract
        public function tick():void {}

        // abstract
        public function render(og:JGraphics, alpha:Number):void {}

        // - - - SoundSource <<interface>>

        public function getX(alpha:Number):Number { throw new Error("getX"); }
        public function getY(alpha:Number):Number { throw new Error("getY"); }
    }
}

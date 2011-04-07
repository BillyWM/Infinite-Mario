package com.mojang.mario {
    import flash.display.Sprite;

    public class AppletLauncher extends Sprite {
        //private static final long serialVersionUID = -2238077255106243788L;

        private var mario:MarioComponent;
        private var started:Boolean = false;

        public function init():void {
        }

        public function start():void {
            if (!started) {
                started = true;
                mario = new MarioComponent(640, 480);
                addChild(mario); //setContentPane(mario);

                mario.start();
            }
        }

        public function stop():void {
            if (started) {
                started = false;
                mario.stop();
            }
        }
    }
}

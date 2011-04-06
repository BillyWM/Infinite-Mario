package com.mojang.mario {

    import com.mojang.mario.sprites.*;
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.FocusEvent;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import java.awt.Color;
    import java.awt.JGraphics;
    import java.util.Random;

    /**
     */
    public class MarioComponent extends Sprite {

        private var running:Boolean = false;
        private var scene:Scene;
        private var focused:Boolean = false;
        private var mapScene:MapScene;

        public function MarioComponent(width:int, height:int) {
            graphics.drawRect(0, 0, width, height);
        }

        private function toggleKey(keyCode:int, isPressed:Boolean):void {
            if (keyCode == 37) {  // KeyboardEvent.VK_LEFT
                scene.toggleKey(Mario.KEY_LEFT, isPressed);
            }
            if (keyCode == 39) { // KeyboardEvent.VK_RIGHT
                scene.toggleKey(Mario.KEY_RIGHT, isPressed);
            }
            if (keyCode == 40) {  // KeyboardEvent.VK_DOWN
                scene.toggleKey(Mario.KEY_DOWN, isPressed);
            }
            if (keyCode == 38) {  // KeyboardEvent.VK_UP
                scene.toggleKey(Mario.KEY_UP, isPressed);
            }
            if (keyCode == 65) {  // KeyboardEvent.VK_A
                scene.toggleKey(Mario.KEY_SPEED, isPressed);
            }
            if (keyCode == 83) {  // KeyboardEvent.VK_S
                scene.toggleKey(Mario.KEY_JUMP, isPressed);
            }
        }

        public function paint(g:JGraphics):void {
        }

        public function update(g:JGraphics):void {
        }

        public function start():void {
            if (!running) {
                running = true;
                run();
            }
        }

        public function stop():void {
            Art.stopMusic();
            running = false;
        }

        private function run():void {
            mapScene = new MapScene(this, new Random().nextLong());
            scene = mapScene;
            Art.init();

            var image:BitmapData = new BitmapData(320, 240);
            addChild(new Bitmap(image));

            var og:JGraphics = new JGraphics(image);
            addEventListener(MouseEvent.CLICK, onClick);
            addEventListener(KeyboardEvent.KEY_DOWN, keyPressed);
            addEventListener(KeyboardEvent.KEY_UP, keyReleased);
            addEventListener(FocusEvent.FOCUS_IN, focusGained);
            addEventListener(FocusEvent.FOCUS_OUT, focusLost);
            toTitle();

            var tick:int = 0;
            addEventListener(Event.ENTER_FRAME, function(e:Event):void {
                var alpha:Number = 1;
                ++tick;
                scene.tick();
                og.setColor(Color.WHITE);
                og.fillRect(0, 0, 320, 240);
                scene.render(og, alpha);
                if (!hasFocus() && int(tick/12)%2==0) {
                    var msg:String = "CLICK TO PLAY";
                    drawString(og, msg, 160 - msg.length * 4 + 1, 110 + 1, 0);
                    drawString(og, msg, 160 - msg.length * 4, 110, 7);
                }
                og.setColor(Color.BLACK);
            });
        }

        private function drawString(g:JGraphics, text:String, x:int, y:int, c:int):void {
            for (var i:int = 0; i < text.length; i++) {
                g.drawImage(Art.font[text.charCodeAt(i) - 32][c], x + i * 8, y);
            }
        }

        public function keyPressed(arg0:KeyboardEvent):void {
            toggleKey(arg0.keyCode, true);
        }

        public function keyReleased(arg0:KeyboardEvent):void {
            toggleKey(arg0.keyCode, false);
        }

        public function startLevel(seed:Number, difficulty:int, type:int):void {
            scene = new LevelScene(this, seed, difficulty, type);
            scene.init();
        }

        public function levelFailed():void {
            scene = mapScene;
            mapScene.startMusic();
            Mario.lives--;
            if (Mario.lives == 0) {
                lose();
            }
        }

        public function focusGained(arg0:FocusEvent):void {
            focused = true;
        }

        public function focusLost(arg0:FocusEvent):void {
            focused = false;
        }

        public function levelWon():void {
            scene = mapScene;
            mapScene.startMusic();
            mapScene.levelWon();
        }

        public function win():void {
            scene = new WinScene(this);
            scene.init();
        }

        public function toTitle():void {
            Mario.resetStatic();
            scene = new TitleScene(this);
            scene.init();
        }

        public function lose():void {
            scene = new LoseScene(this);
            scene.init();
        }

        public function startGame():void {
            scene = mapScene;
            mapScene.startMusic();
            mapScene.init();
        }

        private function hasFocus():Boolean {
            return focused;
        }

        private function onClick(e:MouseEvent):void {
            stage.focus = this;
        }
    }
}

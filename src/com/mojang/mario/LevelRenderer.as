package com.mojang.mario {

    import com.mojang.mario.level.*;
    import flash.display.BitmapData;
    import java.awt.Color;
    import java.awt.JGraphics;
    import java.util.Random;

    public class LevelRenderer {

        private var xCam:int;
        private var yCam:int;
        private var image:BitmapData;
        private var g:JGraphics;
        private static const transparent:uint = 0x00000000; // new Color(0, 0, 0, 0);
        private var level:Level;
        private var random:Random = new Random();
        public var renderBehaviors:Boolean = false;
        internal var width:int;
        internal var height:int;

        public function LevelRenderer(level:Level,  width:int, height:int) {
            this.width = width;
            this.height = height;
            this.level = level;
            image = new BitmapData(width, height, true, 0);
            g = new JGraphics(image);
            updateArea(0, 0, width, height);
        }

        public function setCam(xCam:int, yCam:int):void {
            var xCamD:int = this.xCam - xCam;
            var yCamD:int = this.yCam - yCam;
            this.xCam = xCam;
            this.yCam = yCam;
            g.copyArea(0, 0, width, height, xCamD, yCamD);
            if (xCamD < 0) {
                if (xCamD < -width)
                    xCamD = -width;
                updateArea(width + xCamD, 0, -xCamD, height);
            } else if (xCamD > 0) {
                if (xCamD > width)
                    xCamD = width;
                updateArea(0, 0, xCamD, height);
            }
            if (yCamD < 0) {
                if (yCamD < -width)
                    yCamD = -width;
                updateArea(0, height + yCamD, width, -yCamD);
            } else if (yCamD > 0) {
                if (yCamD > width)
                    yCamD = width;
                updateArea(0, 0, width, yCamD);
            }
        }

        private function updateArea(x0:int, y0:int, w:int, h:int):void {
            g.setBackground(transparent);
            g.clearRect(x0, y0, w, h);
            var xTileStart:int = (x0 + xCam) / 16;
            var yTileStart:int = (y0 + yCam) / 16;
            var xTileEnd:int = (x0 + xCam + w) / 16;
            var yTileEnd:int = (y0 + yCam + h) / 16;
            for (var x:int = xTileStart; x <= xTileEnd; x++) {
                for (var y:int = yTileStart; y <= yTileEnd; y++) {
                    var b:int = level.getBlock(x, y) & 0xff;
                    if (((Level.TILE_BEHAVIORS[b]) & Level.BIT_ANIMATED) == 0) {
                        var xx:int = b % 16;
                        var yy:int = b / 16;
                        g.drawImage(Art.level[xx][yy], (x << 4) - xCam, (y << 4) - yCam);
                    }
                }
            }
        }

        public function render(g:JGraphics, tick:int, alpha:Number):void {
            g.drawImage(image, 0, 0);
            for (var x:int = xCam / 16; x <= (xCam + width) / 16; x++)
                for (var y:int = yCam / 16; y <= (yCam + height) / 16; y++) {
                    var b:uint = level.getBlock(x, y);
                    if (((Level.TILE_BEHAVIORS[b & 0xff]) & Level.BIT_ANIMATED) > 0) {
                        var animTime:int = int((tick / 3)) % 4;
                        if (int((b % 16) / 4) == 0 && int(b / 16) == 1) {
                            animTime = (int(tick / 2) + int((x + y) / 8)) % 20;
                            if (animTime > 3)
                                animTime = 0;
                        }
                        if (int((b % 16) / 4) == 3 && int(b / 16) == 0) {
                            animTime = 2;
                        }
                        var yo:int = 0;
                        if (x >= 0 && y >= 0 && x < level.width && y < level.height) yo = level.data[x][y];
                        if (yo > 0) yo = int((Math.sin((yo - alpha) / 4.0 * Math.PI) * 8));
                        var xx:int = int((b % 16) / 4) * 4 + animTime;
                        var yy:int = b / 16;
                        g.drawImage(Art.level[xx][yy], (x << 4) - xCam, (y << 4) - yCam - yo);
                    }
                    /* else if (b == Level.TILE_BONUS)
                       {
                       int animTime = (tick / 3) % 4;
                       int yo = 0;
                       if (x >= 0 && y >= 0 && x < level.width && y < level.height) yo = level.data[x][y];
                       if (yo > 0) yo = (int) (Math.sin((yo - alpha) / 4.0f * Math.PI) * 8);
                       g.drawImage(Art.mapSprites[(4 + animTime)][0], (x << 4) - xCam, (y << 4) - yCam - yo);
                       }*/
                    if (renderBehaviors) {
                        if (((Level.TILE_BEHAVIORS[b & 0xff]) & Level.BIT_BLOCK_UPPER) > 0) {
                            g.setColor(Color.RED);
                            g.fillRect((x << 4) - xCam, (y << 4) - yCam, 16, 2);
                        }
                        if (((Level.TILE_BEHAVIORS[b & 0xff]) & Level.BIT_BLOCK_ALL) > 0) {
                            g.setColor(Color.RED);
                            g.fillRect((x << 4) - xCam, (y << 4) - yCam, 16, 2);
                            g.fillRect((x << 4) - xCam, (y << 4) - yCam + 14, 16, 2);
                            g.fillRect((x << 4) - xCam, (y << 4) - yCam, 2, 16);
                            g.fillRect((x << 4) - xCam + 14, (y << 4) - yCam, 2, 16);
                        }
                        if (((Level.TILE_BEHAVIORS[b & 0xff]) & Level.BIT_BLOCK_LOWER) > 0) {
                            g.setColor(Color.RED);
                            g.fillRect((x << 4) - xCam, (y << 4) - yCam + 14, 16, 2);
                        }
                        if (((Level.TILE_BEHAVIORS[b & 0xff]) & Level.BIT_SPECIAL) > 0) {
                            g.setColor(Color.PINK);
                            g.fillRect((x << 4) - xCam + 2 + 4, (y << 4) - yCam + 2 + 4, 4, 4);
                        }
                        if (((Level.TILE_BEHAVIORS[b & 0xff]) & Level.BIT_BUMPABLE) > 0) {
                            g.setColor(Color.BLUE);
                            g.fillRect((x << 4) - xCam + 2, (y << 4) - yCam + 2, 4, 4);
                        }
                        if (((Level.TILE_BEHAVIORS[b & 0xff]) & Level.BIT_BREAKABLE) > 0) {
                            g.setColor(Color.GREEN);
                            g.fillRect((x << 4) - xCam + 2 + 4, (y << 4) - yCam + 2, 4, 4);
                        }
                        if (((Level.TILE_BEHAVIORS[b & 0xff]) & Level.BIT_PICKUPABLE) > 0) {
                            g.setColor(Color.YELLOW);
                            g.fillRect((x << 4) - xCam + 2, (y << 4) - yCam + 2 + 4, 4, 4);
                        }
                        if (((Level.TILE_BEHAVIORS[b & 0xff]) & Level.BIT_ANIMATED) > 0) {
                        }
                    }
                }
        }

        public function repaint(x:int, y:int, w:int, h:int):void {
            updateArea(x * 16 - xCam, y * 16 - yCam, w * 16, h * 16);
        }

        public function setLevel(level:Level):void {
            this.level = level;
            updateArea(0, 0, width, height);
        }

        public function renderExit0(g:JGraphics, tick:int, alpha:Number, bar:Boolean):void {
            for (var y:int = level.yExit - 8; y < level.yExit; y++) {
                g.drawImage(Art.level[12][y == level.yExit - 8 ? 4 : 5], (level.xExit << 4) - xCam - 16, (y << 4) - yCam);
            }
            var yh:int = level.yExit * 16 - int(((Math.sin((tick + alpha) / 20) * 0.5 + 0.5) * 7 * 16)) - 8;
            if (bar) {
                g.drawImage(Art.level[12][3], (level.xExit << 4) - xCam - 16, yh - yCam);
                g.drawImage(Art.level[13][3], (level.xExit << 4) - xCam, yh - yCam);
            }
        }

        public function renderExit1(g:JGraphics, tick:int, alpha:Number):void {
            for (var y:int = level.yExit - 8; y < level.yExit; y++) {
                g.drawImage(Art.level[13][y == level.yExit - 8 ? 4 : 5], (level.xExit << 4) - xCam + 16, (y << 4) - yCam);
            }
        }
    }
}

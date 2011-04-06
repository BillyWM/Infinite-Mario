package com.mojang.mario {

    import com.mojang.mario.level.*;
    import flash.display.BitmapData;
    import java.awt.Color;
    import java.awt.JGraphics;
    import java.util.Random;

    public class BgRenderer {

        private var xCam:int;
        private var yCam:int;
        private var image:BitmapData;
        private var g:JGraphics;
        private static const transparent:uint = 0x00000000; // new Color(0, 0, 0, 0);
        private var level:Level;
        private var random:Random = new Random();
        public var renderBehaviors:Boolean = false;
        private var width:int;
        private var height:int;
        private var distance:int;

        public function BgRenderer(level:Level,  width:int, height:int, distance:int) {
            this.distance = distance;
            this.width = width;
            this.height = height;
            this.level = level;
            image = new BitmapData(width, height, true, 0);
            g = new JGraphics(image);
            updateArea(0, 0, width, height);
        }

        public function setCam(xCam:int, yCam:int):void {
            xCam /= distance;
            yCam /= distance;
            var xCamD:int = this.xCam - xCam;
            var yCamD:int = this.yCam - yCam;
            this.xCam = xCam;
            this.yCam = yCam;
            g.copyArea(0, 0, width, height, xCamD, yCamD);
            if (xCamD < 0) {
                if (xCamD < -width) xCamD = -width;
                updateArea(width + xCamD, 0, -xCamD, height);
            } else if (xCamD > 0) {
                if (xCamD > width) xCamD = width;
                updateArea(0, 0, xCamD, height);
            }
            if (yCamD < 0) {
                if (yCamD < -width) yCamD = -width;
                updateArea(0, height + yCamD, width, -yCamD);
            } else if (yCamD > 0) {
                if (yCamD > width) yCamD = width;
                updateArea(0, 0, width, yCamD);
            }
        }

        private function updateArea(x0:int, y0:int, w:int, h:int):void {
            g.setBackground(transparent);
            g.clearRect(x0, y0, w, h);
            var xTileStart:int = (x0 + xCam) / 32;
            var yTileStart:int = (y0 + yCam) / 32;
            var xTileEnd:int = (x0 + xCam + w) / 32;
            var yTileEnd:int = (y0 + yCam + h) / 32;
            for (var x:int = xTileStart; x <= xTileEnd; x++) {
                for (var y:int = yTileStart; y <= yTileEnd; y++) {
                    var b:int = level.getBlock(x, y) & 0xff;
                    var bx:int = b % 8;
                    var by:int = b / 8;
                    g.drawImage(Art.bg[bx][by], (x << 5) - xCam, (y << 5) - yCam-16);
                }
            }
        }

        public function render(g:JGraphics, tick:int, alpha:Number):void {
            g.drawImage(image, 0, 0);
        }

        public function setLevel(level:Level):void {
            this.level = level;
            updateArea(0, 0, width, height);
        }
    }
}

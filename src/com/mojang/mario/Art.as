package com.mojang.mario {

    //import com.mojang.sonar.SoundEngine;
    import flash.display.BitmapData;
    import flash.geom.Matrix;
    import flash.media.SoundChannel;

    /**
     */
    public class Art {
        public static const SAMPLE_BREAK_BLOCK:int = 0;
        public static const SAMPLE_GET_COIN:int = 1;
        public static const SAMPLE_MARIO_JUMP:int = 2;
        public static const SAMPLE_MARIO_STOMP:int = 3;
        public static const SAMPLE_MARIO_KICK:int = 4;
        public static const SAMPLE_MARIO_POWER_UP:int = 5;
        public static const SAMPLE_MARIO_POWER_DOWN:int = 6;
        public static const SAMPLE_MARIO_DEATH:int = 7;
        public static const SAMPLE_ITEM_SPROUT:int = 8;
        public static const SAMPLE_CANNON_FIRE:int = 9;
        public static const SAMPLE_SHELL_BUMP:int = 10;
        public static const SAMPLE_LEVEL_EXIT:int = 11;
        public static const SAMPLE_MARIO_1UP:int = 12;
        public static const SAMPLE_MARIO_FIREBALL:int = 13;

        public static var mario:Array; // BitmapData[][];
        public static var smallMario:Array; // BitmapData[][];
        public static var fireMario:Array; // BitmapData[][];
        public static var enemies:Array; // BitmapData[][];
        public static var items:Array; // BitmapData[][];
        public static var level:Array; // BitmapData[][];
        public static var particles:Array; // BitmapData[][];
        public static var font:Array; // BitmapData[][];
        public static var bg:Array; // BitmapData[][];
        public static var map:Array; // BitmapData[][];
        public static var endScene:Array; // BitmapData[][];
        public static var gameOver:Array; // BitmapData[][];
        public static var logo:BitmapData;
        public static var titleScreen:BitmapData;

        private static var channel:SoundChannel;

        [Embed(source='../../../../res/snd/breakblock.mp3')] private static const Sound0:Class;
        [Embed(source='../../../../res/snd/coin.mp3')] private static const Sound1:Class;
        [Embed(source='../../../../res/snd/jump.mp3')] private static const Sound2:Class;
        [Embed(source='../../../../res/snd/stomp.mp3')] private static const Sound3:Class;
        [Embed(source='../../../../res/snd/kick.mp3')] private static const Sound4:Class;
        [Embed(source='../../../../res/snd/powerup.mp3')] private static const Sound5:Class;
        [Embed(source='../../../../res/snd/powerdown.mp3')] private static const Sound6:Class;
        [Embed(source='../../../../res/snd/death.mp3')] private static const Sound7:Class;
        [Embed(source='../../../../res/snd/sprout.mp3')] private static const Sound8:Class;
        [Embed(source='../../../../res/snd/cannon.mp3')] private static const Sound9:Class;
        [Embed(source='../../../../res/snd/bump.mp3')] private static const Sound10:Class;
        [Embed(source='../../../../res/snd/exit.mp3')] private static const Sound11:Class;
        [Embed(source='../../../../res/snd/1-up.mp3')] private static const Sound12:Class;
        [Embed(source='../../../../res/snd/fireball.mp3')] private static const Sound13:Class;

        public static var samples:Array = new Array(14); // SonarSample[100]

        [Embed(source='../../../../res/mus/smb3map1.mp3')] private static const Song0:Class;
        [Embed(source='../../../../res/mus/smwovr1.mp3')] private static const Song1:Class;
        [Embed(source='../../../../res/mus/smb3undr.mp3')] private static const Song2:Class;
        [Embed(source='../../../../res/mus/smwfortress.mp3')] private static const Song3:Class;
        [Embed(source='../../../../res/mus/smwtitle.mp3')] private static const Song4:Class;

        private static var songs:Array = new Array(5); // Sequence[]


        [Embed(source='../../../../res/endscene.gif')] private static const Image0:Class;
        [Embed(source='../../../../res/font.gif')] private static const Image1:Class;
        [Embed(source='../../../../res/gameovergost.gif')] private static const Image2:Class;
        [Embed(source='../../../../res/logo.gif')] private static const Image3:Class;
        [Embed(source='../../../../res/title.gif')] private static const Image4:Class;
        [Embed(source='../../../../res/bgsheet.png')] private static const Image5:Class;
        [Embed(source='../../../../res/enemysheet.png')] private static const Image6:Class;
        [Embed(source='../../../../res/firemariosheet.png')] private static const Image7:Class;
        [Embed(source='../../../../res/itemsheet.png')] private static const Image8:Class;
        [Embed(source='../../../../res/mapsheet.png')] private static const Image9:Class;
        [Embed(source='../../../../res/mariosheet.png')] private static const Image10:Class;
        [Embed(source='../../../../res/particlesheet.png')] private static const Image11:Class;
        [Embed(source='../../../../res/racoonmariosheet.png')] private static const Image12:Class;
        [Embed(source='../../../../res/smallmariosheet.png')] private static const Image13:Class;
        [Embed(source='../../../../res/worldmap.png')] private static const Image14:Class;

        public static function init():void {


            mario = cutImage(new Image10().bitmapData, 32, 32);
            smallMario = cutImage(new Image13().bitmapData, 16, 16);
            fireMario = cutImage(new Image7().bitmapData, 32, 32);
            enemies = cutImage(new Image6().bitmapData, 16, 32);
            items = cutImage(new Image8().bitmapData, 16, 16);
            level = cutImage(new Image9().bitmapData, 16, 16);
            map = cutImage(new Image14().bitmapData, 16, 16);
            particles = cutImage(new Image11().bitmapData, 8, 8);
            bg = cutImage(new Image5().bitmapData, 32, 32);
            logo = new Image3().bitmapData;
            titleScreen = new Image4().bitmapData;
            font = cutImage(new Image1().bitmapData, 8, 8);
            endScene = cutImage(new Image0().bitmapData, 96, 96);
            gameOver = cutImage(new Image2().bitmapData, 96, 64);

            samples[SAMPLE_BREAK_BLOCK] = new Sound0();
            samples[SAMPLE_GET_COIN] = new Sound1();
            samples[SAMPLE_MARIO_JUMP] = new Sound2();
            samples[SAMPLE_MARIO_STOMP] = new Sound3();
            samples[SAMPLE_MARIO_KICK] = new Sound4();
            samples[SAMPLE_MARIO_POWER_UP] = new Sound5();
            samples[SAMPLE_MARIO_POWER_DOWN] = new Sound6();
            samples[SAMPLE_MARIO_DEATH] = new Sound7();
            samples[SAMPLE_ITEM_SPROUT] = new Sound8();
            samples[SAMPLE_CANNON_FIRE] = new Sound9();
            samples[SAMPLE_SHELL_BUMP] = new Sound10();
            samples[SAMPLE_LEVEL_EXIT] = new Sound11();
            samples[SAMPLE_MARIO_1UP] = new Sound12();
            samples[SAMPLE_MARIO_FIREBALL] = new Sound13();

            songs[0] = new Song0();
            songs[1] = new Song1();
            songs[2] = new Song2();
            songs[3] = new Song3();
            songs[4] = new Song4();
        }


        /**
         * Returns an array of BitmapData objects of the specified width and height
         */
        private static function cutImage(source:BitmapData, xSize:int, ySize:int):Array {
            var xx:int = source.width / xSize;
            var yy:int = source.height / ySize;

            var images:Array = new Array(xx);
            for (var x:int = 0; x < xx; x++) {
                images[x] = new Array(yy);
                for (var y:int = 0; y < yy; y++) {
                    var image:BitmapData = new BitmapData(xSize, ySize, true, 0);
                    var matrix:Matrix = new Matrix();
                    matrix.translate(-x * xSize, -y * ySize);
                    image.draw(source, matrix);
                    images[x][y] = image;
                }
            }
            return images;
        }

        public static function startMusic(song:int):void {
            stopMusic();
            channel = songs[song].play(0, 100);
        }

        public static function stopMusic():void {
            if (channel != null) {
                channel.stop();
                channel = null;
            }
        }
    }
}

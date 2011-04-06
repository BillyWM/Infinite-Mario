package java.awt {

    /**
     */
    public class Color {

        /** 黒 */
        public static const BLACK:uint = 0x000000;

        /** 青 */
        public static const BLUE:uint = 0x00FF00;

        /** 赤 */
        public static const RED:uint = 0xFF0000;

        /** 緑 */
        public static const GREEN:uint = 0x0000FF;

        /** 黄 */
        public static const YELLOW:uint = 0xFF00FF;

        /** 白 */
        public static const WHITE:uint = 0xFFFFFF;

        /** グレー */
        public static const GRAY:uint = 0x888888;

        /** 明るいグレー */
        public static const LIGHT_GRAY:uint = 0xEEEEEE;

        /** ピンク */
        public static const PINK:uint = 0xFFFF88;

        /** RGBからHSBをつくる
         * @param r 色の赤色成分(0〜255)
         * @param g 色の緑色成分(0〜255)
         * @param b 色の青色成分(0〜255)
         * @return HSB配列([0]=hue, [1]=saturation, [2]=brightness)
         */
        public static function RGBtoHSB(r:int, g:int, b:int):Array {
            var cmax:Number = Math.max(r, g, b);
            var cmin:Number = Math.min(r, g, b);
            var brightness:Number = cmax / 255.0;
            var hue:Number = 0;
            var saturation:Number = (cmax != 0) ? (cmax - cmin) / cmax : 0;
            if (saturation != 0) {
                var redc:Number = (cmax - r) / (cmax - cmin);
                var greenc:Number = (cmax - g) / (cmax - cmin);
                var bluec:Number = (cmax - b) / (cmax - cmin);
                if (r == cmax) {
                    hue = bluec - greenc;
                } else if (g == cmax) {
                    hue = 2.0 + redc - bluec;
                } else {
                    hue = 4.0 + greenc - redc;
                }
                hue = hue / 6.0;
                if (hue < 0) {
                    hue = hue + 1.0;
                }
            }
            return [hue, saturation, brightness];
        }

        /** HSBからRGBを作成する
         * @param hue 色の色相成分(小数部 * 360度が色相角度)
         * @param saturation 色の彩度(0.0 〜 1.0 の範囲の数)
         * @param brightness 色の明度(0.0 〜 1.0 の範囲の数)
         * @return RGBカラー
         */
        public static function HSBtoRGB(hue:Number, saturation:Number, brightness:Number):uint {
            var r:int = 0;
            var g:int = 0;
            var b:int = 0;
            if (saturation == 0) {
                r = g = b = brightness * 255.0 + 0.5;
            } else {
                var h:Number = (hue - Math.floor(hue)) * 6.0;
                var f:Number = h - Math.floor(h);
                var p:Number = brightness * (1.0 - saturation);
                var q:Number = brightness * (1.0 - saturation * f);
                var t:Number = brightness * (1.0 - (saturation * (1.0 - f)));
                switch (int(h)) {
                case 0:
                    r = brightness * 255.0 + 0.5;
                    g = t * 255.0 + 0.5;
                    b = p * 255.0 + 0.5;
                    break;
                case 1:
                    r = q * 255.0 + 0.5;
                    g = brightness * 255.0 + 0.5;
                    b = p * 255.0 + 0.5;
                    break;
                case 2:
                    r = p * 255.0 + 0.5;
                    g = brightness * 255.0 + 0.5;
                    b = t * 255.0 + 0.5;
                    break;
                case 3:
                    r = p * 255.0 + 0.5;
                    g = q * 255.0 + 0.5;
                    b = brightness * 255.0 + 0.5;
                    break;
                case 4:
                    r = t * 255.0 + 0.5;
                    g = p * 255.0 + 0.5;
                    b = brightness * 255.0 + 0.5;
                    break;
                case 5:
                    r = brightness * 255.0 + 0.5;
                    g = p * 255.0 + 0.5;
                    b = q * 255.0 + 0.5;
                    break;
                }
            }
            return (r << 16) | (g << 8) | (b << 0);
        }

        public function Color(...args) {}
    }
}

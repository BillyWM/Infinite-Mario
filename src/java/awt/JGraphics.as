package java.awt {
    import flash.display.Shape;
    import flash.display.BitmapData;
    import flash.display.Bitmap;
    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.geom.Rectangle;

    /** BitmapDataのうえに、java.awt.Graphicsのようなインターフェース
     * を実現するもの。Infinite Mario Brosで使っているものしか実装して
     * ないので汎用性はありません。
     */
    public class JGraphics {

        /** 描画先 */
        private var dst:BitmapData;

        /** 背景色 */
        private var bgcolor:uint = 0xFFFFFFFF;
        /** 描画色 */
        private var fgcolor:uint = 0xFF000000;

        /** 平行移動量x */
        private var tx:int = 0;
        /** 平行移動量y */
        private var ty:int = 0;

        /** fillPolygon用のワークエリア */
        private var off:Shape = new Shape();

        /** ビットマップデータを指定して構築
         * @param bd 描画先
         */
        public function JGraphics(bd:BitmapData) { this.dst = bd; }

        // - - -

        /**
         */
        public function setColor(color:uint):void {
            fgcolor = color;
        }

        /**
         */
        public function fillRect(x:int, y:int, w:int, h:int):void {
            dst.fillRect(new Rectangle(x, y, w, h), fgcolor);
        }

        /**
         */
        public function drawImage6(src:BitmapData, x:int, y:int, w:int, h:int):void {
            // そのまま描けば良いとき(ex.右を向いているマリオ)
            if (w == src.width && h == src.height) {
                drawImage(src, x, y);
            } else {
                // 左右反転または上下反転してるとき(ex.左を向いている敵)
                var matrix:Matrix = new Matrix(w < 0 ? -1 : 1, 0, 0, h < 0 ? -1 : 1);
                if (Math.abs(w) != src.width || Math.abs(h) != src.height) {
                    // 拡大縮小しているとき(ex.潰れた敵)
                    matrix.scale(Math.abs(w) / src.width, Math.abs(h) / src.height);
                }
                matrix.translate(x, y);
                matrix.translate(tx, ty);
                dst.draw(src, matrix);
            }
        }

        /** ビットマップイメージを描画
         */
        public function drawImage(src:BitmapData, x:int, y:int):void {
            // drawよりcopyのほうが高速
            dst.copyPixels(src, src.rect, new Point(x+tx, y+ty), null, null, true);
        }

        /** スクロール
         */
        public function copyArea(x:int, y:int, width:int, height:int, dx:int, dy:int):void {
            dst.copyPixels(dst, new Rectangle(x, y, width, height), new Point(x+dx, y+dy));
        }

        /** 背景色
         */
        public function setBackground(color:uint):void {
            bgcolor = color;
        }

        /** 矩形を背景色で塗りつぶす
         */
        public function clearRect(x:int, y:int, w:int, h:int):void {
            dst.fillRect(new Rectangle(x, y, w, h), bgcolor);
        }

        /** 平行移動
         * @see JSprite#render()
         * これに対応するのはとりあえずdrawImageだけでいいみたい
         */
        public function translate(x:int, y:int):void {
            this.tx += x;
            this.ty += y;
        }

        /** 多角形塗りつぶし
         * これが呼ばれるのはブラックアウトのとき
         */
        public function fillPolygon(xp:Array, yp:Array, size:int):void {
            off.graphics.clear();
            var x0:int = xp[0];
            var y0:int = yp[0];
            off.graphics.moveTo(x0, y0);
            off.graphics.beginFill(fgcolor);
            for (var i:int = 1; i < size; ++i) {
                off.graphics.lineTo(xp[i], yp[i]);
            }
            off.graphics.lineTo(x0, y0);
            off.graphics.endFill();
            dst.draw(off);
        }
    }
}

package java.util {

    /** 再現性のある擬似乱数
     * TODO: これちゃんとつくらないと
     */
    public class Random {

        public function Random(seed:int=1) {
        }

        public function nextBoolean():Boolean {
            return nextDouble() < 0.5;
        }

        public function nextInt(n:int):int {
            return nextDouble() * n;
        }

        /**
         * @return 次のseedになればいい
         */
        public function nextLong():Number {
            return nextDouble();
        }

        public function nextDouble():Number {
            return Math.random();
        }
    }
}

package java.util {

    /** 再現性のある擬似乱数
     * TODO: これちゃんとつくらないと
     */
    public class Random {

		private var Seed:Number = 0.5;

        public function Random(seed:Number = 0) {
			if (seed == 0) seed = Math.random();
			Seed = seed;
        }

        public function nextBoolean():Boolean {
			Seed = nextDouble();
            return Seed < 0.5;
        }

        public function nextInt(n:int):int {
            Seed = nextDouble();
			return int(Seed * n);
        }

        /**
         * @return 次のseedになればいい
         */
        public function nextLong():Number {
            return Seed = nextDouble();
        }

        public function nextDouble():Number {
			if (Seed <= 0) Seed = 0.0001;
			if (Seed >= 1) Seed = 0.9999999;
            return Seed = ((69621 * int(Seed * 0x7FFFFFFF)) % 0x7FFFFFFF) / 0x7FFFFFFF;
			//return Seed = Math.random();
        }
    }
}

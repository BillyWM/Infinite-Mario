package java.text {

    public class DecimalFormat {

        private var fmt:String;

        public function DecimalFormat(fmt:String) {
            this.fmt = fmt;
        }

        public function format(n:Number):String {
            var s:String = "0" + n;
            return s.substring(s.length - fmt.length);
        }
    }
}

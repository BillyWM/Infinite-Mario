package com.mycompany {
    import flash.display.DisplayObject;
    import flash.display.MovieClip;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    import flash.text.TextField;
    import flash.utils.getDefinitionByName;

    public class MyFactory extends MovieClip {

        private var tf:TextField;

        public function MyFactory() {
            stop();
            stage.stageFocusRect = false;
            addEventListener(Event.ENTER_FRAME, onEnterFrame);
            tf = new TextField();
            addChild(tf);
        }

        public function onEnterFrame(event:Event):void {
            if (framesLoaded == totalFrames) {
                removeEventListener(Event.ENTER_FRAME, onEnterFrame);
                removeChild(tf);
                nextFrame();
                init();
            } else {
                var percent:Number = root.loaderInfo.bytesLoaded / root.loaderInfo.bytesTotal;
                percent = int(100 * percent);
                tf.text = "Loading... " + percent + "%";
            }
        }

        private function init():void {
            var mainClass:Class = Class(getDefinitionByName("Root"));
            if (mainClass) {
                var app:Object = new mainClass();
                addChild(app as DisplayObject);
            }
        }
    }
}

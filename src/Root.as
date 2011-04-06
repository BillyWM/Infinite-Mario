package {
    import flash.display.Sprite;
    import com.mojang.mario.AppletLauncher;

    [SWF(width="320", height="240", backgroundColor="#FFFFFF")]
    [Frame(factoryClass="com.mycompany.MyFactory")]
    public class Root extends Sprite {

        public function Root() {
            //stage.stageFocusRect = false;
            var a:AppletLauncher = new AppletLauncher();
            addChild(a);
            a.start();
        }
    }
}

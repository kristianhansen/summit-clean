import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class SummitCleanApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function getInitialView() as [Views] or [Views, InputDelegates] {
        return [ new SummitCleanView() ];
    }

    // Called when the user changes settings in the Connect IQ phone app.
    function onSettingsChanged() as Void {
        WatchUi.requestUpdate();
    }
}

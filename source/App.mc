using Toybox.Application;
using Toybox.WatchUi;
using Toybox.Application.Storage;

class HevyApp extends Application.AppBase {

    function initialize() {
        Application.AppBase.initialize();
    }

    function onStart(state) {
    }

    function onStop(state) {
    }

    function getInitialView() {
        var apiKey = Storage.getValue("hevy_api_key");
        if (apiKey == null || apiKey.equals("")) {
            return [new SettingsView()];
        }
        return [new RoutineListView(), new RoutineListDelegate()];
    }
}

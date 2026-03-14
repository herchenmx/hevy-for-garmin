using Toybox.Application;
using Toybox.WatchUi;
using Toybox.Application.Storage;

class HevyApp extends Application.AppBase {

    function initialize() {
        Application.AppBase.initialize();
    }

    function onStart(state) {
        // TODO: replace hardcoded key with Properties.getValue("hevy_api_key") before release
        Storage.setValue("hevy_api_key", "f2c7ebb3-6f13-4505-9fe1-31e26277dd17");
    }

    function onStop(state) {
    }

    function getInitialView() {
        var networkManager = new NetworkManager(Storage.getValue("hevy_api_key"));
        var view = new FolderListView(networkManager);
        return [view, new FolderListDelegate(view, networkManager)];
    }
}

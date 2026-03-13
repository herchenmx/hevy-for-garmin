import Toybox.Application as App;
import Toybox.Lang as Lang;
import Toybox.System as Sys;
import Toybox.WatchUi as WatchUi;

class MyHevyApp extends App.AppBase {
    hidden var settings;
    hidden var routines;

    function initialize() {
        settings = new Settings();
        routines = [];
    }

    function onStart() {
        if (settings.getApiKey() == "") {
            WatchUi.showSettings(settings);
        } else {
            fetchRoutines();
        }
    }

    function fetchRoutines() {
        var api = new HevyApi(settings.getApiKey());
        api.getRoutines(function(response) {
            if (response.isSuccess()) {
                routines = response.getData();
                displayRoutines();
            } else {
                WatchUi.showMessage("Error fetching routines");
            }
        });
    }

    function displayRoutines() {
        // Logic to display routines and exercises
    }
}
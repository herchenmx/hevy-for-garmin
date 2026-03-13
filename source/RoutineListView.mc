import Toybox.System as Sys;
import Toybox.Lang as Lang;
import Toybox.WatchUi as WatchUi;
import Toybox.Communications as Comm;
import Toybox.Storage as Storage;

class HevyApp extends WatchUi.Application {
    hidden var apiKey;
    hidden var routines;

    function initialize() {
        // Load API key from storage
        apiKey = Storage.readString("hevy_api_key");
        // Fetch routines if API key is set
        if (apiKey != null) {
            fetchRoutines();
        } else {
            showSettingsScreen();
        }
    }

    function showSettingsScreen() {
        // Implement settings screen to enter API key
    }

    function fetchRoutines() {
        // Fetch routines from Hevy API
        var url = "https://api.hevy.com/v1/routines";
        var request = Comm.HttpRequest(url, Comm.HttpRequestMethod.GET);
        request.setHeader("Authorization", "Bearer " + apiKey);
        request.send(this, "onFetchRoutinesResponse");
    }

    function onFetchRoutinesResponse(response) {
        if (response.getStatusCode() == 200) {
            routines = response.getBody();
            displayRoutines();
        } else {
            // Handle error
        }
    }

    function displayRoutines() {
        // Display routines and allow user to select one
    }

    function logSet(routineId, exerciseId, setData) {
        // Log the set locally or send to Hevy API
        var url = "https://api.hevy.com/v1/workouts";
        var request = Comm.HttpRequest(url, Comm.HttpRequestMethod.POST);
        request.setHeader("Authorization", "Bearer " + apiKey);
        request.setBody(Lang.toJson(setData));
        request.send(this, "onLogSetResponse");
    }

    function onLogSetResponse(response) {
        if (response.getStatusCode() == 200) {
            // Successfully logged
        } else {
            // Handle error
        }
    }

    function syncData() {
        // Sync locally stored data with Hevy API when connected
    }
}
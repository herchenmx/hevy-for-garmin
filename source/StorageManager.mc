import Toybox.Application as App;
import Toybox.Lang as Lang;
import Toybox.System as Sys;
import Toybox.Graphics as Gfx;
import Toybox.WatchUi as WatchUi;
import Toybox.Http as Http;
import Toybox.Storage as Storage;

class HevyApp extends App.AppBase {
    hidden var apiKey;
    hidden var routines;
    hidden var localData;

    function initialize() {
        App.AppBase.initialize();
        apiKey = Storage.readString("apiKey");
        localData = Storage.readObject("localData") || [];
        fetchRoutines();
    }

    function fetchRoutines() {
        if (apiKey) {
            var url = "https://api.hevy.com/v1/routines";
            var request = Http.Request(url);
            request.setHeader("Authorization", "Bearer " + apiKey);
            request.send(this, "onFetchRoutines");
        } else {
            // Show settings screen if API key is not set
            showSettingsScreen();
        }
    }

    function onFetchRoutines(response) {
        if (response.getStatusCode() == 200) {
            routines = response.getBody();
            displayRoutines();
        } else {
            // Handle error
            Sys.println("Error fetching routines: " + response.getStatusCode());
        }
    }

    function displayRoutines() {
        // Code to display routines on the watch
        // For each routine, show exercises and sets
    }

    function showSettingsScreen() {
        // Code to display settings screen for API key input
    }

    function logSet(exerciseId, setData) {
        // Log the set data locally if offline
        localData.push({exerciseId: exerciseId, setData: setData});
        Storage.writeObject("localData", localData);
        // Optionally, post to Hevy API if online
        postWorkout();
    }

    function postWorkout() {
        if (isConnected()) {
            // Code to post completed workout to Hevy API
            var url = "https://api.hevy.com/v1/workouts";
            var request = Http.Request(url);
            request.setHeader("Authorization", "Bearer " + apiKey);
            request.setBody(Lang.toJson(localData));
            request.send(this, "onPostWorkout");
        }
    }

    function onPostWorkout(response) {
        if (response.getStatusCode() == 200) {
            // Clear local data after successful post
            localData = [];
            Storage.writeObject("localData", localData);
        } else {
            // Handle error
            Sys.println("Error posting workout: " + response.getStatusCode());
        }
    }

    function isConnected() {
        // Check for internet connection
        return Sys.isConnected();
    }
}
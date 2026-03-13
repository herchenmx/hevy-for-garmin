class HevyApp extends App {
    hidden var apiKey;
    hidden var routines;
    hidden var localData;

    // Constructor
    function initialize() {
        apiKey = Settings.get("hevy_api_key");
        localData = new LocalStorage();
        fetchRoutines();
    }

    // Fetch routines from Hevy API
    function fetchRoutines() {
        if (apiKey != null) {
            var url = "https://api.hevy.com/v1/routines";
            Http.get(url, {
                "Authorization": "Bearer " + apiKey
            }, function(response) {
                if (response.statusCode == 200) {
                    routines = response.body;
                    displayRoutines();
                } else {
                    // Handle error
                    displayError("Failed to fetch routines");
                }
            });
        } else {
            displayError("API Key not set");
        }
    }

    // Display routines on the watch
    function displayRoutines() {
        // Code to display routines and exercises
    }

    // Log a set
    function logSet(exerciseId, setData) {
        // Code to log the set
        postWorkout();
    }

    // Post completed workout to Hevy API
    function postWorkout() {
        var url = "https://api.hevy.com/v1/workouts";
        Http.post(url, {
            "Authorization": "Bearer " + apiKey,
            "Content-Type": "application/json"
        }, workoutData, function(response) {
            if (response.statusCode != 200) {
                // Save locally if failed
                localData.save(workoutData);
            }
        });
    }

    // Sync local data when reconnected
    function syncLocalData() {
        // Code to sync local data with Hevy API
    }
}

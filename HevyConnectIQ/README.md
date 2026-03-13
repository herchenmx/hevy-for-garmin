### Step 1: App Structure

1. **Create the Project**: Use the Connect IQ SDK to create a new project.
2. **Define the Manifest**: Ensure your `manifest.xml` includes permissions for internet access and local storage.

### Step 2: Create the Settings Screen

You need a settings screen to enter the Hevy API key. This can be done using a simple text input.

```monkeyc
class SettingsScreen extends Ui.Screen {
    hidden var apiKey;

    function initialize() {
        // Initialize the screen
        apiKey = Settings.get("hevy_api_key", "");
    }

    function onShow() {
        // Display the settings UI
        this.addText("Enter Hevy API Key:");
        this.addTextInput("API Key", apiKey);
        this.addButton("Save", saveSettings);
    }

    function saveSettings() {
        apiKey = this.getTextInput("API Key");
        Settings.set("hevy_api_key", apiKey);
        this.close();
    }
}
```

### Step 3: Fetch Routines from Hevy API

You will need to create a function to fetch routines from the Hevy API using the stored API key.

```monkeyc
function fetchRoutines(apiKey) {
    var url = "https://api.hevy.com/v1/routines";
    var request = Http.Request(url);
    request.setHeader("Authorization", "Bearer " + apiKey);
    
    var response = request.send();
    if (response.getStatusCode() == 200) {
        return response.getBody();
    } else {
        // Handle error
        return null;
    }
}
```

### Step 4: Display Routines and Log Sets

You can create a screen to display the fetched routines and allow the user to log sets.

```monkeyc
class RoutinesScreen extends Ui.Screen {
    hidden var routines;

    function initialize(routines) {
        this.routines = routines;
    }

    function onShow() {
        foreach (routine in routines) {
            this.addText(routine.name);
            foreach (exercise in routine.exercises) {
                this.addText(exercise.name + ": " + exercise.sets);
                this.addButton("Log Set", function() {
                    logSet(exercise);
                });
            }
        }
    }

    function logSet(exercise) {
        // Logic to log the set
        // Save locally if offline
    }
}
```

### Step 5: Post Completed Workout to Hevy API

After logging the sets, you need to post the completed workout back to the Hevy API.

```monkeyc
function postWorkout(apiKey, workoutData) {
    var url = "https://api.hevy.com/v1/workouts";
    var request = Http.Request(url);
    request.setHeader("Authorization", "Bearer " + apiKey);
    request.setHeader("Content-Type", "application/json");
    request.setBody(workoutData);
    
    var response = request.send();
    if (response.getStatusCode() != 200) {
        // Handle error
    }
}
```

### Step 6: Handle Offline Storage and Syncing

You can use local storage to save the workout data when offline and sync it when the connection is restored.

```monkeyc
function saveLocally(workoutData) {
    // Save workoutData to local storage
}

function syncData(apiKey) {
    // Check for internet connection
    if (isConnected()) {
        // Fetch local data and post to Hevy API
        var localData = loadLocally();
        foreach (data in localData) {
            postWorkout(apiKey, data);
        }
        // Clear local storage after successful sync
    }
}
```

### Step 7: Main Application Logic

Finally, you need to tie everything together in your main application logic.

```monkeyc
class MyApp extends App {
    hidden var apiKey;

    function initialize() {
        apiKey = Settings.get("hevy_api_key", "");
        if (apiKey == "") {
            new SettingsScreen().show();
        } else {
            var routines = fetchRoutines(apiKey);
            if (routines != null) {
                new RoutinesScreen(routines).show();
            }
        }
    }
}
```

### Conclusion

This is a basic outline of how you can create a Garmin Connect IQ app that interacts with the Hevy API. You will need to handle various edge cases, such as error handling, user feedback, and UI improvements. Additionally, ensure you comply with the Hevy API's usage policies and guidelines. 

Make sure to test your app thoroughly on a compatible Garmin device to ensure it works as expected.
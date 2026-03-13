using Toybox.Application.Storage;

class StorageManager {

    static function getApiKey() {
        return Storage.getValue("hevy_api_key");
    }

    static function setApiKey(apiKey) {
        Storage.setValue("hevy_api_key", apiKey);
    }

    static function getPendingWorkouts() {
        var data = Storage.getValue("pending_workouts");
        if (data == null) {
            return [];
        }
        return data;
    }

    static function savePendingWorkout(workoutData) {
        var pending = getPendingWorkouts();
        pending.add(workoutData);
        Storage.setValue("pending_workouts", pending);
    }

    static function clearPendingWorkouts() {
        Storage.setValue("pending_workouts", null);
    }
}

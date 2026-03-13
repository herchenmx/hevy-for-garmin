using Toybox.System;

class SetLogger {
    hidden var _networkManager;

    function initialize(networkManager) {
        _networkManager = networkManager;
    }

    function logSet(exerciseId, setData) {
        var workoutData = {
            "exercise_id" => exerciseId,
            "sets" => [setData]
        };
        StorageManager.savePendingWorkout(workoutData);
    }

    function syncPending() {
        var pending = StorageManager.getPendingWorkouts();
        if (pending.size() > 0) {
            _networkManager.postWorkout(pending[0], method(:onPostResponse));
        }
    }

    function onPostResponse(responseCode, data) {
        if (responseCode == 200) {
            StorageManager.clearPendingWorkouts();
        } else {
            System.println("Failed to post workout: " + responseCode);
        }
    }
}

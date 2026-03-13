using Toybox.Communications as Comm;
using Toybox.System;

class NetworkManager {
    hidden var _apiKey;

    function initialize(apiKey) {
        _apiKey = apiKey;
    }

    function fetchRoutines(callback) {
        var url = "https://api.hevy.com/v1/routines";
        var options = {
            :method => Comm.HTTP_REQUEST_METHOD_GET,
            :headers => {
                "api-key" => _apiKey
            },
            :responseType => Comm.HTTP_RESPONSE_CONTENT_TYPE_JSON
        };
        Comm.makeWebRequest(url, null, options, callback);
    }

    function postWorkout(workoutData, callback) {
        var url = "https://api.hevy.com/v1/workouts";
        var options = {
            :method => Comm.HTTP_REQUEST_METHOD_POST,
            :headers => {
                "api-key" => _apiKey,
                "Content-Type" => "application/json"
            },
            :responseType => Comm.HTTP_RESPONSE_CONTENT_TYPE_JSON
        };
        Comm.makeWebRequest(url, workoutData, options, callback);
    }
}

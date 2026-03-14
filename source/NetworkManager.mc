using Toybox.Communications as Comm;
using Toybox.System;

class NetworkManager {
    hidden var _hevyApiKey;

    function initialize(hevyApiKey) {
        _hevyApiKey = hevyApiKey;
    }

    // --- Supabase reads ---

    hidden function supabaseGet(path, callback) {
        var url = AppConstants.SUPABASE_URL + path;
        var options = {
            :method => Comm.HTTP_REQUEST_METHOD_GET,
            :headers => {
                "apikey" => AppConstants.SUPABASE_KEY,
                "Authorization" => "Bearer " + AppConstants.SUPABASE_KEY
            },
            :responseType => Comm.HTTP_RESPONSE_CONTENT_TYPE_JSON
        };
        Comm.makeWebRequest(url, null, options, callback);
    }

    // Returns array of {id, index, title}
    function fetchFolders(callback) {
        supabaseGet("/rest/v1/routine_folders?select=id,index,title&order=index.asc", callback);
    }

    // Returns array of {id, title, folder_id} ordered by most recently updated
    function fetchRoutinesByFolder(folderId, callback) {
        supabaseGet("/rest/v1/routines?select=id,title,folder_id&folder_id=eq." + folderId + "&order=updated_at.desc", callback);
    }

    // Returns array with one item: full routine including exercises JSONB
    function fetchRoutine(routineId, callback) {
        supabaseGet("/rest/v1/routines?id=eq." + routineId, callback);
    }

    // Returns array with one item: most recent workout for a given routine
    function fetchLatestWorkoutForRoutine(routineId, callback) {
        supabaseGet("/rest/v1/workouts?routine_id=eq." + routineId + "&order=start_time.desc&limit=1", callback);
    }

    // Triggers manual re-sync from Hevy API via Edge Function
    function triggerSync(callback) {
        var url = AppConstants.SUPABASE_URL + "/functions/v1/sync-hevy";
        var options = {
            :method => Comm.HTTP_REQUEST_METHOD_POST,
            :headers => {
                "apikey" => AppConstants.SUPABASE_KEY,
                "Authorization" => "Bearer " + AppConstants.SUPABASE_KEY,
                "Content-Type" => "application/json"
            },
            :responseType => Comm.HTTP_RESPONSE_CONTENT_TYPE_JSON
        };
        Comm.makeWebRequest(url, null, options, callback);
    }

    // --- Hevy writes ---

    function postWorkout(workoutData, callback) {
        var url = AppConstants.HEVY_API_URL + "/workouts";
        var options = {
            :method => Comm.HTTP_REQUEST_METHOD_POST,
            :headers => {
                "api-key" => _hevyApiKey,
                "Content-Type" => "application/json"
            },
            :responseType => Comm.HTTP_RESPONSE_CONTENT_TYPE_JSON
        };
        Comm.makeWebRequest(url, workoutData, options, callback);
    }
}

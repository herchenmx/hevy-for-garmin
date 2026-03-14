using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;

// Shows exercises from a routine with reference numbers from the last workout.
// Scroll up/down to move between exercises. Back to exit.
class WorkoutSessionView extends WatchUi.View {
    hidden var _networkManager;
    hidden var _routineId;
    hidden var _routineTitle;
    hidden var _exercises;       // from routine (exercise names + planned sets)
    hidden var _lastWorkout;     // exercises from latest matching workout
    hidden var _selectedIndex;
    hidden var _statusText;

    function initialize(networkManager, routineId, routineTitle, exercises) {
        View.initialize();
        _networkManager = networkManager;
        _routineId = routineId;
        _routineTitle = routineTitle;
        _exercises = exercises;
        _lastWorkout = null;
        _selectedIndex = 0;
        _statusText = "Loading last...";
        _networkManager.fetchLatestWorkoutForRoutine(routineId, method(:onLastWorkoutFetched));
    }

    function onLayout(dc) {
    }

    function onUpdate(dc) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();
        var w = dc.getWidth();
        var h = dc.getHeight();

        // Header: routine title
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
        dc.drawText(w / 2, h / 8, Graphics.FONT_XTINY, _routineTitle,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        if (_exercises == null || _exercises.size() == 0) {
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
            dc.drawText(w / 2, h / 2, Graphics.FONT_SMALL, "No exercises",
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
            return;
        }

        var exercise = _exercises[_selectedIndex];
        var exTitle = exercise["title"];
        if (exTitle == null) { exTitle = "Exercise"; }

        // Exercise counter
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
        dc.drawText(w / 2, h * 2 / 8, Graphics.FONT_XTINY,
            (_selectedIndex + 1) + "/" + _exercises.size(),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Exercise name
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(w / 2, h / 2, Graphics.FONT_SMALL, exTitle,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Reference sets from last workout
        var refText = _statusText;
        var lastEx = getLastWorkoutExercise(exTitle);
        if (lastEx != null) {
            var sets = lastEx["sets"];
            if (sets != null && sets.size() > 0) {
                var setCount = sets.size();
                var firstSet = sets[0];
                var weight = firstSet["weight_kg"];
                var reps = firstSet["reps"];
                if (weight != null && reps != null) {
                    refText = "Last: " + setCount + "×" + formatWeight(weight) + "kg×" + reps;
                } else if (reps != null) {
                    refText = "Last: " + setCount + " sets × " + reps + " reps";
                } else {
                    refText = "Last: " + setCount + " sets";
                }
            }
        } else if (_lastWorkout != null) {
            refText = "No prev. data";
        }

        dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_BLACK);
        dc.drawText(w / 2, h * 3 / 4, Graphics.FONT_XTINY, refText,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    // Find the matching exercise from last workout by title
    hidden function getLastWorkoutExercise(exerciseTitle) {
        if (_lastWorkout == null) { return null; }
        var lastExercises = _lastWorkout["exercises"];
        if (lastExercises == null) { return null; }
        for (var i = 0; i < lastExercises.size(); i++) {
            var ex = lastExercises[i];
            if (ex["title"] != null && ex["title"].equals(exerciseTitle)) {
                return ex;
            }
        }
        return null;
    }

    hidden function formatWeight(w) {
        var rounded = (w * 100.0 + 0.5).toNumber();
        var intPart = rounded / 100;
        var frac = rounded - (intPart * 100);
        if (frac == 0) { return intPart.toString(); }
        if (frac % 10 == 0) { return intPart.toString() + "." + (frac / 10).toString(); }
        var fracStr = frac.toString();
        if (frac < 10) { fracStr = "0" + fracStr; }
        return intPart.toString() + "." + fracStr;
    }

    function onLastWorkoutFetched(responseCode, data) {
        if (responseCode == 200 && data != null && data.size() > 0) {
            _lastWorkout = data[0];
        }
        _statusText = "";
        WatchUi.requestUpdate();
    }

    function scrollUp() {
        if (_exercises != null && _exercises.size() > 0) {
            _selectedIndex = (_selectedIndex - 1 + _exercises.size()) % _exercises.size();
            WatchUi.requestUpdate();
        }
    }

    function scrollDown() {
        if (_exercises != null && _exercises.size() > 0) {
            _selectedIndex = (_selectedIndex + 1) % _exercises.size();
            WatchUi.requestUpdate();
        }
    }
}

class WorkoutSessionDelegate extends WatchUi.BehaviorDelegate {
    hidden var _view;

    function initialize(view) {
        BehaviorDelegate.initialize();
        _view = view;
    }

    function onPreviousPage() {
        _view.scrollUp();
        return true;
    }

    function onNextPage() {
        _view.scrollDown();
        return true;
    }

    function onBack() {
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
        return true;
    }
}

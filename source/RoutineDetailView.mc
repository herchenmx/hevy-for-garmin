using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Timer;

class RoutineDetailView extends WatchUi.View {
    hidden var _networkManager;
    hidden var _routineId;
    hidden var _routineTitle;
    hidden var _exercises;
    hidden var _selectedIndex;
    hidden var _statusText;
    hidden var _scrollOffset;
    hidden var _scrollTimer;
    hidden var _titleScrolling;
    hidden var _screenWidth;
    hidden var _titleWidth;

    function initialize(networkManager, routineId, routineTitle) {
        View.initialize();
        _networkManager = networkManager;
        _routineId = routineId;
        _routineTitle = routineTitle;
        _exercises = [];
        _selectedIndex = 0;
        _statusText = "Loading...";
        _scrollOffset = 0;
        _scrollTimer = null;
        _titleScrolling = false;
        _screenWidth = 0;
        _titleWidth = 0;
        _networkManager.fetchRoutine(routineId, method(:onRoutineFetched));
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

    function onLayout(dc) {
    }

    function onUpdate(dc) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();
        var w = dc.getWidth();
        var h = dc.getHeight();

        if (_screenWidth == 0) {
            _screenWidth = w;
        }

        // Routine title at top with horizontal scrolling if needed
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
        _titleWidth = dc.getTextWidthInPixels(_routineTitle, Graphics.FONT_XTINY);
        if (_titleWidth > w && !_titleScrolling) {
            _scrollTimer = new Timer.Timer();
            _scrollTimer.start(method(:onTitleScroll), 40, true);
            _titleScrolling = true;
        }
        var titleX = (w / 2) - _scrollOffset;
        dc.drawText(titleX, h / 8, Graphics.FONT_XTINY, _routineTitle,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        if (_exercises.size() == 0) {
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
            dc.drawText(w / 2, h / 2, Graphics.FONT_SMALL, _statusText,
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
            return;
        }

        // Show Start Workout screen for the last item
        if (_selectedIndex == _exercises.size()) {
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
            dc.drawText(w / 2, h / 2, Graphics.FONT_MEDIUM, "\u25B6 Start Workout",
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
            dc.drawText(w / 2, h * 7 / 8, Graphics.FONT_XTINY, "Select to begin",
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
            return;
        }

        var exercise = _exercises[_selectedIndex];
        var exTitle = exercise["title"];
        if (exTitle == null) { exTitle = "Exercise"; }

        // Exercise index
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
        dc.drawText(w / 2, h * 2 / 8, Graphics.FONT_XTINY,
            (_selectedIndex + 1) + "/" + _exercises.size(),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Exercise name
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(w / 2, h / 2, Graphics.FONT_SMALL, exTitle,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Sets summary
        var sets = exercise["sets"];
        if (sets != null && sets.size() > 0) {
            var setCount = sets.size();
            var firstSet = sets[0];
            var weight = firstSet["weight_kg"];
            var reps = firstSet["reps"];
            var setInfo;
            if (weight != null && reps != null) {
                setInfo = setCount + " sets · " + formatWeight(weight) + "kg × " + reps;
            } else if (reps != null) {
                setInfo = setCount + " sets · " + reps + " reps";
            } else {
                setInfo = setCount + " sets";
            }
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
            dc.drawText(w / 2, h * 3 / 4, Graphics.FONT_XTINY, setInfo,
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }
    }

    function onTitleScroll() as Void {
        _scrollOffset += 2;
        if (_scrollOffset > _titleWidth) {
            _scrollOffset = -50;
        }
        WatchUi.requestUpdate();
    }

    function onRoutineFetched(responseCode, data) {
        if (responseCode == 200 && data != null && data.size() > 0) {
            var routine = data[0];
            var exercises = routine["exercises"];
            if (exercises != null) {
                _exercises = exercises;
                _selectedIndex = 0;
            }
        } else {
            _statusText = "Error: " + responseCode;
            System.println("Routine detail error: " + responseCode);
        }
        if (_exercises.size() == 0 && responseCode == 200) {
            _statusText = "No exercises";
        }
        WatchUi.requestUpdate();
    }

    function scrollUp() {
        var total = _exercises.size() + 1;
        if (total > 1) {
            _selectedIndex = (_selectedIndex - 1 + total) % total;
            WatchUi.requestUpdate();
        }
    }

    function scrollDown() {
        var total = _exercises.size() + 1;
        if (total > 1) {
            _selectedIndex = (_selectedIndex + 1) % total;
            WatchUi.requestUpdate();
        }
    }

    function isAtStartScreen() {
        return _selectedIndex == _exercises.size();
    }

    function startWorkout() {
        var sessionView = new WorkoutSessionView(_networkManager, _routineId, _routineTitle, _exercises);
        WatchUi.pushView(
            sessionView,
            new WorkoutSessionDelegate(sessionView),
            WatchUi.SLIDE_LEFT
        );
    }
}

class RoutineDetailDelegate extends WatchUi.BehaviorDelegate {
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

    function onSelect() {
        if (_view.isAtStartScreen()) {
            _view.startWorkout();
        }
        return true;
    }
}

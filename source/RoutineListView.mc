using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;

class RoutineListView extends WatchUi.View {
    hidden var _networkManager;
    hidden var _folderId;
    hidden var _folderTitle;
    hidden var _routines;
    hidden var _selectedIndex;
    hidden var _statusText;

    function initialize(networkManager, folderId, folderTitle) {
        View.initialize();
        _networkManager = networkManager;
        _folderId = folderId;
        _folderTitle = folderTitle;
        _routines = [];
        _selectedIndex = 0;
        _statusText = "Loading...";
        _networkManager.fetchRoutinesByFolder(folderId, method(:onRoutinesFetched));
    }

    function onLayout(dc) {
    }

    function onUpdate(dc) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();
        var w = dc.getWidth();
        var h = dc.getHeight();

        // Folder name at top
        if (_folderTitle != null) {
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
            dc.drawText(w / 2, h / 5, Graphics.FONT_XTINY, _folderTitle,
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }

        if (_routines.size() == 0) {
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
            dc.drawText(w / 2, h / 2, Graphics.FONT_SMALL, _statusText,
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
            return;
        }

        var routine = _routines[_selectedIndex];
        var title = routine["title"];
        if (title == null) { title = "Routine"; }

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
        dc.drawText(w / 2, h * 2 / 5, Graphics.FONT_XTINY,
            (_selectedIndex + 1) + "/" + _routines.size(),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(w / 2, h / 2, Graphics.FONT_SMALL, title,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
        dc.drawText(w / 2, h * 3 / 4, Graphics.FONT_XTINY, "Select to start",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    function onRoutinesFetched(responseCode, data) {
        if (responseCode == 200 && data != null) {
            // Supabase returns a plain array
            _routines = data;
            _selectedIndex = 0;
        } else {
            _statusText = "Error: " + responseCode;
            System.println("Routines error: " + responseCode);
        }
        if (_routines.size() == 0) {
            _statusText = "No routines";
        }
        WatchUi.requestUpdate();
    }

    function getSelectedRoutine() {
        if (_routines.size() > 0) {
            return _routines[_selectedIndex];
        }
        return null;
    }

    function scrollUp() {
        if (_routines.size() > 0) {
            _selectedIndex = (_selectedIndex - 1 + _routines.size()) % _routines.size();
            WatchUi.requestUpdate();
        }
    }

    function scrollDown() {
        if (_routines.size() > 0) {
            _selectedIndex = (_selectedIndex + 1) % _routines.size();
            WatchUi.requestUpdate();
        }
    }
}

class RoutineListDelegate extends WatchUi.BehaviorDelegate {
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

    function onSelect() {
        var routine = _view.getSelectedRoutine();
        if (routine != null) {
            WatchUi.pushView(
                new RoutineDetailView(routine),
                new RoutineDetailDelegate(),
                WatchUi.SLIDE_LEFT
            );
        }
        return true;
    }

    function onBack() {
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
        return true;
    }
}

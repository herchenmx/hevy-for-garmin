using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.Application.Storage;
using Toybox.System;

class RoutineListView extends WatchUi.View {
    hidden var _routines;
    hidden var _networkManager;
    hidden var _statusText;

    function initialize() {
        View.initialize();
        _routines = [];
        _statusText = "Loading...";
        var apiKey = Storage.getValue("hevy_api_key");
        if (apiKey != null) {
            _networkManager = new NetworkManager(apiKey);
            _networkManager.fetchRoutines(method(:onRoutinesFetched));
        } else {
            _statusText = "No API Key";
        }
    }

    function onLayout(dc) {
    }

    function onUpdate(dc) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();
        if (_routines.size() == 0) {
            dc.drawText(
                dc.getWidth() / 2,
                dc.getHeight() / 2,
                Graphics.FONT_SMALL,
                _statusText,
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
            );
        } else {
            dc.drawText(
                dc.getWidth() / 2,
                dc.getHeight() / 2,
                Graphics.FONT_SMALL,
                _routines.size() + " Routines",
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
            );
        }
    }

    function onRoutinesFetched(responseCode, data) {
        if (responseCode == 200 && data != null) {
            var routines = data["routines"];
            if (routines != null) {
                _routines = routines;
            }
        } else {
            _statusText = "Error: " + responseCode;
            System.println("Error fetching routines: " + responseCode);
        }
        WatchUi.requestUpdate();
    }
}

class RoutineListDelegate extends WatchUi.BehaviorDelegate {
    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onMenu() {
        return true;
    }
}

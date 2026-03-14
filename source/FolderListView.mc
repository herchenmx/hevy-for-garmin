using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;

class FolderListView extends WatchUi.View {
    hidden var _folders;
    hidden var _networkManager;
    hidden var _statusText;
    hidden var _selectedIndex;

    function initialize(networkManager) {
        View.initialize();
        _networkManager = networkManager;
        _folders = [];
        _statusText = "Loading...";
        _selectedIndex = 0;
        _networkManager.fetchFolders(method(:onFoldersFetched));
    }

    function onLayout(dc) {
    }

    function onUpdate(dc) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();
        var w = dc.getWidth();
        var h = dc.getHeight();

        if (_folders.size() == 0) {
            dc.drawText(w / 2, h / 2, Graphics.FONT_SMALL, _statusText,
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
            return;
        }

        var folder = _folders[_selectedIndex];
        var title = folder["title"];
        if (title == null) { title = "Folder"; }

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
        dc.drawText(w / 2, h / 4, Graphics.FONT_XTINY,
            (_selectedIndex + 1) + "/" + _folders.size(),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(w / 2, h / 2, Graphics.FONT_SMALL, title,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
        dc.drawText(w / 2, h * 3 / 4, Graphics.FONT_XTINY, "Select folder",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    function onFoldersFetched(responseCode, data) {
        if (responseCode == 200 && data != null) {
            // Supabase returns a plain array
            _folders = data;
            _selectedIndex = 0;
        } else {
            _statusText = "Error: " + responseCode;
            System.println("Error fetching folders: " + responseCode);
        }
        WatchUi.requestUpdate();
    }

    function getSelectedFolder() {
        if (_folders.size() > 0) {
            return _folders[_selectedIndex];
        }
        return null;
    }

    function scrollUp() {
        if (_folders.size() > 0) {
            _selectedIndex = (_selectedIndex - 1 + _folders.size()) % _folders.size();
            WatchUi.requestUpdate();
        }
    }

    function scrollDown() {
        if (_folders.size() > 0) {
            _selectedIndex = (_selectedIndex + 1) % _folders.size();
            WatchUi.requestUpdate();
        }
    }
}

class FolderListDelegate extends WatchUi.BehaviorDelegate {
    hidden var _view;
    hidden var _networkManager;

    function initialize(view, networkManager) {
        BehaviorDelegate.initialize();
        _view = view;
        _networkManager = networkManager;
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
        var folder = _view.getSelectedFolder();
        if (folder != null) {
            var folderId = folder["id"];
            var folderTitle = folder["title"];
            var routineView = new RoutineListView(_networkManager, folderId, folderTitle);
            WatchUi.pushView(
                routineView,
                new RoutineListDelegate(routineView),
                WatchUi.SLIDE_LEFT
            );
        }
        return true;
    }
}

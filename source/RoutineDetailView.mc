using Toybox.WatchUi;
using Toybox.Graphics;

class RoutineDetailView extends WatchUi.View {
    hidden var _routine;

    function initialize(routine) {
        View.initialize();
        _routine = routine;
    }

    function onLayout(dc) {
    }

    function onUpdate(dc) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();
        var name = "Routine";
        if (_routine != null) {
            var title = _routine["title"];
            if (title != null) {
                name = title;
            }
        }
        dc.drawText(
            dc.getWidth() / 2,
            dc.getHeight() / 2,
            Graphics.FONT_SMALL,
            name,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }
}

class RoutineDetailDelegate extends WatchUi.BehaviorDelegate {
    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onBack() {
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
        return true;
    }
}

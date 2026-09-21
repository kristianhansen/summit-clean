import Toybox.ActivityMonitor;
import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.WatchUi;
import Toybox.Weather;

// Summit Clean v1: big white time, themed accent, step-goal bezel arc,
// date + native weather, and two user-configurable bottom fields.
// Layout is fractional so it scales to fenix 7S (240) and 7X (280).
// Redraws once a minute only: no per-second updates, no background work.
class SummitCleanView extends WatchUi.WatchFace {

    private var _accent as Number = 0xFF5500;
    private var _left as Number = 0;
    private var _right as Number = 1;

    function initialize() {
        WatchFace.initialize();
    }

    function onUpdate(dc as Dc) as Void {
        loadSettings();

        var w = dc.getWidth();
        var h = dc.getHeight();
        var cx = w / 2;
        var cy = h / 2;

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        drawStepArc(dc, cx, cy, w);
        drawTime(dc, cx, cy);
        drawDateAndWeather(dc, cx, h);
        drawField(dc, cx - (w * 0.16).toNumber(), h, _left);
        drawField(dc, cx + (w * 0.16).toNumber(), h, _right);
    }

    // ---- settings -------------------------------------------------------

    private function loadSettings() as Void {
        _accent = accentFor(readNum("ThemeColor", 0));
        _left = readNum("FieldLeft", 0);
        _right = readNum("FieldRight", 1);
    }

    private function readNum(key as String, fallback as Number) as Number {
        var v = Application.Properties.getValue(key);
        return (v instanceof Number) ? v : fallback;
    }

    // Channel values chosen from the MIP-friendly palette (00/55/AA/FF).
    private function accentFor(i as Number) as Number {
        switch (i) {
            case 1:  return 0x00AAFF;  // cyan
            case 2:  return 0x00FF55;  // green
            case 3:  return 0xFFFFFF;  // white
            default: return 0xFF5500;  // orange
        }
    }

    // ---- drawing --------------------------------------------------------

    // Thin arc around the bezel showing progress to the step goal.
    private function drawStepArc(dc as Dc, cx as Number, cy as Number, w as Number) as Void {
        var info = ActivityMonitor.getInfo();
        var steps = info.steps;
        var goal = info.stepGoal;
        if (steps == null || goal == null || goal == 0) {
            return;
        }
        var pct = steps.toFloat() / goal.toFloat();
        if (pct > 1.0) { pct = 1.0; }

        var pen = w / 40;
        var r = (w / 2) - pen;
        dc.setPenWidth(pen);

        dc.setColor(0x555555, Graphics.COLOR_BLACK);
        dc.drawCircle(cx, cy, r);

        dc.setColor(_accent, Graphics.COLOR_BLACK);
        if (pct >= 1.0) {
            dc.drawCircle(cx, cy, r);
        } else if (pct > 0.0) {
            var end = 90 - (360 * pct).toNumber();
            dc.drawArc(cx, cy, r, Graphics.ARC_CLOCKWISE, 90, end);
        }
        dc.setPenWidth(1);
    }

    private function drawTime(dc as Dc, cx as Number, cy as Number) as Void {
        var t = System.getClockTime();
        var hour = t.hour;
        if (!System.getDeviceSettings().is24Hour) {
            hour = hour % 12;
            if (hour == 0) { hour = 12; }
        }
        var s = Lang.format("$1$:$2$", [hour.format("%02d"), t.min.format("%02d")]);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(cx, cy, Graphics.FONT_NUMBER_THAI_HOT, s,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    private function drawDateAndWeather(dc as Dc, cx as Number, h as Number) as Void {
        var now = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        var s = Lang.format("$1$ $2$ $3$", [now.day_of_week, now.month, now.day]).toUpper();
        s = s + tempString();
        dc.setColor(_accent, Graphics.COLOR_BLACK);
        dc.drawText(cx, (h * 0.24).toNumber(), Graphics.FONT_SMALL, s,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    // Garmin's built-in weather: no account, API key, or permission needed.
    private function tempString() as String {
        if (!(Toybox has :Weather)) { return ""; }
        var c = Weather.getCurrentConditions();
        if (c == null || c.temperature == null) { return ""; }
        var t = c.temperature;  // Celsius
        if (System.getDeviceSettings().temperatureUnits == System.UNIT_STATUTE) {
            t = t * 9 / 5 + 32;
        }
        return "  " + t.toNumber().toString() + "\u00B0";
    }

    // Value on top, small gray label underneath.
    private function drawField(dc as Dc, x as Number, h as Number, id as Number) as Void {
        var pair = fieldValue(id);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(x, (h * 0.75).toNumber(), Graphics.FONT_SMALL, pair[0],
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
        dc.drawText(x, (h * 0.84).toNumber(), Graphics.FONT_XTINY, pair[1],
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    // 0 steps, 1 battery, 2 heart rate, 3 calories
    private function fieldValue(id as Number) as Array<String> {
        if (id == 1) {
            return [System.getSystemStats().battery.toNumber().toString() + "%", "BATT"];
        }
        if (id == 2) {
            var hr = null;
            var it = ActivityMonitor.getHeartRateHistory(1, true);
            var sample = it.next();
            if (sample != null && sample.heartRate != ActivityMonitor.INVALID_HR_SAMPLE) {
                hr = sample.heartRate;
            }
            return [(hr == null) ? "--" : hr.toString(), "HR"];
        }
        if (id == 3) {
            var cal = ActivityMonitor.getInfo().calories;
            return [(cal == null) ? "--" : cal.toString(), "CAL"];
        }
        var steps = ActivityMonitor.getInfo().steps;
        return [(steps == null) ? "--" : steps.toString(), "STEPS"];
    }
}

package org.openscales.core.history {
import org.openscales.core.basetypes.Resolution;
import org.openscales.geometry.basetypes.Bounds;

/**
 * @private
 */
public class HistoryItem {

    private var _resolution:Resolution;
    private var _bounds:Bounds;

    public function HistoryItem(resolution:Resolution, bounds:Bounds) {
        _resolution = resolution;
        _bounds = bounds;
    }

    public function get resolution():Resolution {
        return _resolution;
    }

    public function set resolution(value:Resolution):void {
        _resolution = value;
    }

    public function get bounds():Bounds {
        return _bounds;
    }

    public function set bounds(value:Bounds):void {
        _bounds = value;
    }
}
}

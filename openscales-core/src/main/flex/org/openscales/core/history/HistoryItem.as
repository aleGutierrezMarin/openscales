/**
 * Created with IntelliJ IDEA.
 * User: a505816
 * Date: 11/04/12
 * Time: 14:37
 * To change this template use File | Settings | File Templates.
 */
package org.openscales.core.history {
import org.openscales.core.basetypes.Resolution;
import org.openscales.geometry.basetypes.Bounds;

public class HistoryItem {

    private var _resolution:Resolution;
    private var _bounds:Bounds;

    public function HistoryItem() {
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

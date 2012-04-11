package org.openscales.core.history {
import org.openscales.core.Map;
import org.openscales.core.events.MapEvent;

/**
 *
 */
public class NavigationHistoryLogger {

    private var _map:Map;

    public function NavigationHistoryLogger(length:uint) {
    }

    public function get map():Map {
        return _map;
    }

    public function set map(value:Map):void {
        if(_map)_map.removeEventListener(MapEvent.RELOAD, onMapReload);
        _map = value;
        if(_map)_map.addEventListener(MapEvent.RELOAD, onMapReload);
    }

    private function onMapReload(event:MapEvent):void {

    }

}
}

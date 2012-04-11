/**
 * Created with IntelliJ IDEA.
 * User: a505816
 * Date: 11/04/12
 * Time: 14:37
 * To change this template use File | Settings | File Templates.
 */
package org.openscales.core.history {
import org.openscales.core.Map;
import org.openscales.core.events.MapEvent;

public class NavigationHistoryLogger {

    private var _map:Map;
    private var _history:Vector.<HistoryItem>;

    public function NavigationHistoryLogger(size:uint) {
        _history = new Vector.<HistoryItem>(size);
    }

    public function stepForward():void{

    }

    public function stepBackward():void{

    }

    private function onMapReload(event:MapEvent):void {

    }

    public function get map():Map {
        return _map;
    }

    public function set map(value:Map):void {
        if (_map)_map.removeEventListener(MapEvent.RELOAD, onMapReload);
        _map = value;
        if (_map)_map.addEventListener(MapEvent.RELOAD, onMapReload);
    }


}
}

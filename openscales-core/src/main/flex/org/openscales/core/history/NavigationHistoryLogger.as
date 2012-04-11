package org.openscales.core.history {
import org.openscales.core.Map;
import org.openscales.core.events.MapEvent;

/**
 * This class can hold navigation history in the map. History can be browsed backward and forward.
 *
 * <p>You need to set the <code>map</code> property for the history to start. You can specify history length in constructor</p>
 *
 * <p><code>NavigationHistoryLogger</code> instances save map's resolution and extent on every <code>MapEvent.RELOAD</code>.</p>
 */
public class NavigationHistoryLogger {

    private var _map:Map;
    private var _history:Vector.<HistoryItem>;
    private var _current:uint = NaN;
    private var _maxItems:uint;
    private var _skipReload:Boolean = false;

    /**
     * Class constructor. History won't start before its <code>map</code> is set.
     *
     * @param size The size of the history. this value can not be changed after.
     */
    public function NavigationHistoryLogger(size:uint = 20) {
        _maxItems = size > 0 ? size : 0;
    }

    /**
     * This method goes one step forward in the history.
     * <p>It will set the map resolution and extent.</p>
     * <p>Calling this method when the history is at its end will do nothing.</p>
     */
    public function stepForward():void {
        if(!_map ||!_history)return;
        if(_current < _history.length-1){
            _skipReload = true;
            _current++;
            _map.resolution = _history[_current].resolution;
            _map.zoomToExtent(_history[_current].bounds); 
        }
    }

    /**
     * This method goes one step backward in the history.
     * <p>It will set the map resolution and extent.</p>
     * <p>Calling this method when the history is at its beginning will do nothing.</p>
     */
    public function stepBackward():void {
        if(!_map ||!_history)return;
        if(_current > 0){
             _skipReload = true;
            _current--;
            _map.resolution = _history[_current].resolution;
            _map.zoomToExtent(_history[_current].bounds);
        }
    }

    public function isAtEnd():Boolean{
        if(!_history)return true;
        return(_current==_history.length-1);
    }

    public function isAtBeginning():Boolean{
        return _current==0;
    }

    /**
     * @private
     */
    private function onMapReload(event:MapEvent):void {
        if(_skipReload){
            _skipReload = false;
            return;
        }

        if (!_map || !_history)return;
        var item:HistoryItem = new HistoryItem(_map.resolution, _map.extent);
		if (_current < _history.length - 1) {
			_history = _history.slice(0, _current+1);
		}
		if (_history.length >= _maxItems) {
            _history.shift();
            _current = _history.length - 1;
        }
        _history.push(new HistoryItem(event.map.resolution, event.map.extent));
        _current++;
    }



    /**
     * The map for which navigation history will be logged. This property must be set for history to start.
     */
    public function get map():Map {
        return _map;
    }

    /**
     * @private
     */
    public function set map(value:Map):void {
        if (_map)_map.removeEventListener(MapEvent.RELOAD, onMapReload);
        _map = value;
        if (!_map) return;
        _map.addEventListener(MapEvent.RELOAD, onMapReload);
        _history = new Vector.<HistoryItem>();
        _history.push(new HistoryItem(_map.resolution, _map.extent));
        _current = 0;

    }

}
}

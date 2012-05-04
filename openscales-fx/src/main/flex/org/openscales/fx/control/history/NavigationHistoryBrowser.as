package org.openscales.fx.control.history {
import flash.events.Event;
import flash.events.MouseEvent;

import org.openscales.core.Map;
import org.openscales.core.events.MapEvent;
import org.openscales.core.history.NavigationHistoryLogger;
import org.openscales.fx.control.Control;

import spark.components.Button;

public class NavigationHistoryBrowser extends Control {

    /**
     * This button will go one step forward in history when clicked
     */
    [SkinPart(required="true")]
    public var forwardButton:Button;

    /**
     * This button will go one step backward in history when clicked
     */
    [SkinPart(required="true")]
    public var backwardButton:Button;

    private var _historyLogger:NavigationHistoryLogger;
    private var _size:uint = 10;

    public function NavigationHistoryBrowser() {

    }

    protected function onForwardButtonClick(event:MouseEvent):void {
        _historyLogger.stepForward();
        backwardButton.enabled = !_historyLogger.isAtBeginning();
        forwardButton.enabled = !_historyLogger.isAtEnd();
    }

    protected function onBackwardButtonClick(event:MouseEvent):void {
        _historyLogger.stepBackward();
        backwardButton.enabled = !_historyLogger.isAtBeginning();
        forwardButton.enabled = !_historyLogger.isAtEnd();
    }

    override protected function onCreationComplete(event:Event):void {
        super.onCreationComplete(event);
        initializeLogger();
    }

    override protected function partAdded(partName:String, instance:Object):void {
        super.partAdded(partName, instance);
        if(instance == forwardButton){
            forwardButton.addEventListener(MouseEvent.CLICK, onForwardButtonClick);
			forwardButton.enabled = false;
        }else if(instance == backwardButton){
            backwardButton.addEventListener(MouseEvent.CLICK, onBackwardButtonClick);
			backwardButton.enabled = false;
        }
    }

    override protected function partRemoved(partName:String, instance:Object):void {
        super.partRemoved(partName, instance);
    }

	protected function onMapReload(event:MapEvent):void{
		backwardButton.enabled = !_historyLogger.isAtBeginning();
		forwardButton.enabled = !_historyLogger.isAtEnd();
	}
	
    private function initializeLogger():void {
        _historyLogger = new NavigationHistoryLogger(_size);
		
		
        if(_map)_historyLogger.map = _map;
    }

    /**
     * Size of the history
     */
    public function get size():uint {
        return _size;
    }

    /**
     * @private
     */
    public function set size(value:uint):void {
        _size = value;
        initializeLogger();
    }


    [Bindable]
    override public function get map():Map {
        return super.map;
    }

    override public function set map(value:Map):void {
        if(_map)_map.removeEventListener(MapEvent.RELOAD, onMapReload);
        super.map = value;
        if(_historyLogger)_historyLogger.map = value;
		if(_map)_map.addEventListener(MapEvent.RELOAD, onMapReload);

    }
}
}

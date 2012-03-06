if(typeof OpenScalesBinder == "undefined") {
    OpenScalesBinder = function() {
        this.viewer = null;
        this.listeners = {};
    };
    OpenScalesBinder.prototype = {
        addEventListener:function(type, callback, scope) {
            var args = [];
            var numOfArgs = arguments.length;
            for(var i=0; i<numOfArgs; i++){
                args.push(arguments[i]);
            }        
            args = args.length > 3 ? args.splice(3, args.length-1) : [];
            if(typeof this.listeners[type] != "undefined") {
                this.listeners[type].push({scope:scope, callback:callback, args:args});
            } else {
                this.listeners[type] = [{scope:scope, callback:callback, args:args}];
            }
        },
        removeEventListener:function(type, callback, scope) {
            if(typeof this.listeners[type] != "undefined") {
                var numOfCallbacks = this.listeners[type].length;
                var newArray = [];
                for(var i=0; i<numOfCallbacks; i++) {
                    var listener = this.listeners[type][i];
                    if(listener.scope == scope && listener.callback == callback) {
    
                    } else {
                        newArray.push(listener);
                    }
                }
                this.listeners[type] = newArray;
            }
        },
        dispatch:function(type, value, target) {
            var numOfListeners = 0;
            console.debug(type);
            var event = {
                type:type,
                target:target,
                value:value
            };
            var args = [];
            var numOfArgs = arguments.length;
            for(var i=0; i<numOfArgs; i++){
                args.push(arguments[i]);
            };                
            args = args.length > 2 ? args.splice(2, args.length-1) : [];
            args = [event].concat(args);
            if(typeof this.listeners[type] != "undefined") {
                var numOfCallbacks = this.listeners[type].length;
                for(var i=0; i<numOfCallbacks; i++) {
                    var listener = this.listeners[type][i];
                    if(listener && listener.callback) {
                        listener.args = args.concat(listener.args);
                        listener.callback.apply(listener.scope, listener.args);
                        numOfListeners += 1;
                    }
                }
            }
        },
        getEvents:function() {
            var str = "";
            for(var type in this.listeners) {
                var numOfCallbacks = this.listeners[type].length;
                for(var i=0; i<numOfCallbacks; i++) {
                    var listener = this.listeners[type][i];
                    str += listener.scope && listener.scope.className ? listener.scope.className : "anonymous";
                    str += " listen for '" + type + "'\n";
                }
            }
            return str;
        }
    };
}
VIEWERID = new OpenScalesBinder();
VIEWERID.viewer = document.getElementById("UID");
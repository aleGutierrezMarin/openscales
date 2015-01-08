
Title 1
=======

Title 2
-------

This is an AS3 code

.. code-block:: as3

	override public function destroy():void {
		this._components.length = 0;
		this._components = null;
	}


This is an MXML code

.. code-block:: mxml

	<?xml version="1.0" encoding="utf-8"?>
	<s:Group xmlns="http://openscales.org" xmlns:fx="http://ns.adobe.com/mxml/2009" xmlns:s="library://ns.adobe.com/flex/spark"
			 creationComplete="initMap()" width="100%" height="100%">
		
		<Map id="fxMap" width="100%" height="100%" zoom="3" center="4.833,45.767">
			
			<Mapnik name="Mapnik" proxy="http://openscales.org/proxy.php?url="/>
			<MousePosition x="10" y="{height-20}" displayProjection="EPSG:900913"/>
			<Spinner id="spinner" x="{width / 2}" y="{height / 2}"/>
			
			<DragHandler/>
			<ClickHandler/>
			<WheelHandler/>
			
			<TraceInfo id="traceInfo" x="{width-200}" y="0" />

			<PanZoom id="panZoom" x="10" y="10" />

		</Map>
		
	</s:Group>
	
This is an image

.. image:: _static/logo.png

This is a `link <http://google.com>`_ 
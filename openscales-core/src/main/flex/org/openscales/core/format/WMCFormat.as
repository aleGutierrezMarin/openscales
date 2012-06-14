package org.openscales.core.format
{
	import org.openscales.core.basetypes.Resolution;
	import org.openscales.core.layer.Layer;
	import org.openscales.core.layer.ogc.WFS;
	import org.openscales.core.layer.ogc.WMS;
	import org.openscales.core.layer.ogc.WMTS;
	import org.openscales.core.utils.Trace;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.geometry.basetypes.Size;
	import org.openscales.geometry.basetypes.Unit;
	import org.openscales.proj4as.ProjProjection;

	/**
	 * This class read and write WMC files
	 * 
	 * Supported WMC format : 1.1.0
	 * 
	 */
	public class WMCFormat extends Format
	{
		
		private var _wmcFile:XML;
		
		// Extension Perser
		
		// GeneralType
		private var _windowSize:Size;
		private var _generalBbox:Bounds;
		
		// LayerList
		private var _layerList:Vector.<Layer>;
		
		public function WMCFormat()
		{
		}
		
		
		/**
		 * Get the list of Layers
		 */
		public function get layerList():Vector.<Layer>
		{
			return this._layerList;
		}
		
		public function set wmcFile(value:XML):void
		{
			this._wmcFile = value;
		}
		
		public function get wmcFile():XML
		{
			return this._wmcFile;
		}
		
		public function get windowSize():Size
		{
			return this._windowSize;
		}
		
		public function get generalBbox():Bounds
		{
			return this._generalBbox;
		}
		
		override public function read(data:Object):Object{
			this.wmcFile = new XML(data);
			if(this.wmcFile.*::General.length() > 0)
			{
				var general:XML = this.wmcFile.*::General[0];
				if(general.*::Window.length() > 0)
				{
					var window:XML = general.*::Window[0];
					if(window.@height.length()> 0 && window.@width.length() > 0)
					{
						this._windowSize = new Size(window.@width[0], window.@height[0]);
					}
				}


				if(general.*::BoundingBox.length() > 0)
				{
					var bbox:XML = general.*::BoundingBox[0];
					if(bbox.@SRS.length() > 0 && bbox.@minx.length() > 0 && bbox.@miny.length() > 0 && bbox.@maxx.length() > 0 && bbox.@maxy.length() > 0)
					{
						this._generalBbox = new Bounds(bbox.@minx, bbox.@miny, bbox.@maxx, bbox.@maxy, bbox.@SRS);
					}
				}
				if(general.*::Extension.length() > 0)
				{
					this.parseGeneralExtension(general.*::Extension[0]);
				}
				
			}
			
			this._layerList = parseLayerListSection(this.wmcFile);
			
			return null;
		}
		
		public function parseLayer(layer:XML):Layer
		{
			var service:String = "";
			var version:String = "";
			var url:String = "";
			var hidden:Boolean = false;
			if(layer.@hidden.length() > 0 && layer.@hidden == "1")
			{
				hidden = true;
			}
			/*if(layer.@queryable.length() > 0 && layer.@queryable == "0")
			{
				return null;
			}*/
			if (layer.*::Server.length() > 0)
			{
				var server:XML = layer.*::Server[0];
				if(server.@service.length() > 0)
				{
					service = server.@service;
				}
				if(server.@version.length() > 0)
				{
					version = server.@version;
				}
				if(server.*::OnlineResource.length() > 0)
				{
					var onlineRessource:XML = server.*::OnlineResource[0];
					var xlinkNS:Namespace = new Namespace("xlink", "http://www.w3.org/1999/xlink");
					onlineRessource.addNamespace(xlinkNS);
					if (onlineRessource.@xlinkNS::href.length() > 0)
					{
						url = onlineRessource.@xlinkNS::href[0];
					}
				}
			}
			var name:String = "";
			var title:String = "";
			var abstract:String = "";
			var minScaleDenominator:Number = NaN;
			var maxScaleDenominator:Number = NaN;
			var srs:String = "";
			var availableProjections:Vector.<String> = new Vector.<String>();
			//var formatList:Vector.<String> = new Vector.<String>();
			var format:String = "";
			if(layer.*::Name.length() > 0)
			{
				name = layer.*::Name[0];
			}
			if(layer.*::Title.length() > 0)
			{
				title = layer.*::Title[0];
			}
			if(layer.*::MinScaleDenominator.length() > 0)
			{
				minScaleDenominator = layer.*::MinScaleDenominator[0];
			}
			if(layer.*::MaxScaleDenominator.length() > 0)
			{
				maxScaleDenominator = layer.*::MaxScaleDenominator[0];
			}
			if(layer.*::Abstract.length() > 0){
				abstract = layer.*::Abstract[0];
			}
			if (layer.*::SRS.length() > 0)
			{
				srs = layer.*::SRS[0];
				availableProjections.push(srs);
			}
			if (layer.*::FormatList.length() > 0)
			{
				var formats:XMLList = layer.*::FormatList;
				if(formats.*::Format.length() > 0)
				{
					var currentFormat:XMLList = formats.*::Format;
					var formatLength:Number = currentFormat.length();
					for (var j:int = 0; j < formatLength; ++j)
					{
						if(currentFormat[j].@current.length() > 0)
						{
							if (currentFormat[j].@current == 1)
							{
								format = currentFormat[j];
								
								// In flash we cannot display tiff so use jpeg instead
								if (format == "image/tiff")
								{
									format = "image/jpeg"
								}
							}
						}
					}
				}
			}
			var layerToAdd:Layer;
			switch (service) {
				case "OGC:WMS":
					var wms:WMS = new WMS(title,url,name,"",format);
					wms.version = version;
					wms.projection = srs;
					wms.abstract = (abstract && abstract.length>0) ? abstract : null;
					wms.availableProjections = availableProjections;
					wms.transparent = true;
					wms.minResolution = new Resolution(Unit.getResolutionFromScaleDenominator(minScaleDenominator), ProjProjection.getProjProjection("EPSG:4326"));
					wms.maxResolution = new Resolution(Unit.getResolutionFromScaleDenominator(maxScaleDenominator),  ProjProjection.getProjProjection("EPSG:4326"));
					layerToAdd = wms;
					break;
				case "OGC:WFS":
					var wfs:WFS = new WFS(title,url,name,version);
					wfs.projection = srs;
					wfs.abstract = (abstract && abstract.length>0) ? abstract : null;
					wfs.availableProjections = availableProjections;
					wfs.minResolution = new Resolution(Unit.getResolutionFromScaleDenominator(minScaleDenominator), ProjProjection.getProjProjection("EPSG:4326"));
					wfs.maxResolution = new Resolution(Unit.getResolutionFromScaleDenominator(maxScaleDenominator), ProjProjection.getProjProjection("EPSG:4326"));
					layerToAdd = wfs;
					break;
				case "OGC:WMTS":
					var style:String;
					if (layer.*::StyleList.length() > 0)
					{
						var styles:XMLList = layer.*::StyleList;
						if(styles.*::Style.length() > 0)
						{
							var currentStyle:XMLList = styles.*::Style;
							var styleLength:Number = currentStyle.length();
							for (var k:int = 0; k < styleLength; ++k)
							{
								if(currentStyle[k].@current.length() > 0)
								{
									if (currentStyle[k].@current == 1)
									{
										style = currentStyle[k].*::Name;
									}
								}
							}
						}
					}
					var wmts:WMTS = new WMTS(title,url,name,"");
					wmts.abstract = (abstract && abstract.length>0) ? abstract : null;
					wmts.style = style;
					if (srs != "")
					{
						wmts.projection = srs;
					}
					wmts.minResolution = new Resolution(Unit.getResolutionFromScaleDenominator(minScaleDenominator), ProjProjection.getProjProjection("EPSG:4326"));
					wmts.maxResolution = new Resolution(Unit.getResolutionFromScaleDenominator(maxScaleDenominator), ProjProjection.getProjProjection("EPSG:4326"));
					wmts.format = format;
					layerToAdd = wmts;
					break;
				default:
					Trace.debug("Service layer : "+service+" not supported");
					layerToAdd = new Layer(name);
					layerToAdd.displayedName = title;
					layerToAdd.abstract = abstract;
					layerToAdd.url = url;
					layerToAdd.name = name;
					layerToAdd.minResolution = new Resolution(Unit.getResolutionFromScaleDenominator(minScaleDenominator), ProjProjection.getProjProjection("EPSG:4326"));
					layerToAdd.maxResolution= new Resolution(Unit.getResolutionFromScaleDenominator(maxScaleDenominator), ProjProjection.getProjProjection("EPSG:4326"));
					layerToAdd.projection = srs;
					layerToAdd.availableProjections = availableProjections;
					break;
			}
			
			if(layer.*::Extension.length() > 0)
			{
				layerToAdd = this.parseLayerExtension(layer.*::Extension[0], layerToAdd, service);
			}
			if (layerToAdd)
				layerToAdd.visible = !hidden;
			return layerToAdd;
		}
		
		public function parseLayerListSection(xml:XML):Vector.<Layer>{
			
			var layers:Vector.<Layer>;
			
			if(xml.*::LayerList.length() > 0)
			{
				var layerList:XML = xml.*::LayerList[0];
				if(layerList.*::Layer.length() > 0)
				{
					if (layerList.*::Layer.length() > 0)
					{
						var listOfLayers:XMLList = layerList.*::Layer;
						var listLength:Number = listOfLayers.length();
						layers = new Vector.<Layer>();
						for (var i:int = 0; i<listLength; ++i)
						{
							var layer:XML = listOfLayers[i];
							var layerToAdd:Layer = this.parseLayer(layer);
							if (layerToAdd)
								layers.push(layerToAdd);
						}
					}
				}
			}
			
			return layers;
		}
		
		public function parseGeneralExtension(extensionData:XML):void
		{
			
		}
		
		public function parseLayerExtension(extensionData:XML, layer:Layer, service:String):Layer
		{
			return layer;
		}
	}
}
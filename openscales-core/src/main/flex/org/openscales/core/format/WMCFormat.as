package org.openscales.core.format
{
	import org.openscales.core.Trace;
	import org.openscales.core.format.wmcExtension.IWMCExtension;
	import org.openscales.core.layer.Layer;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.geometry.basetypes.Size;
	import org.openscales.geometry.basetypes.Unit;
	import org.openscales.proj4as.Proj4as;
	import org.openscales.proj4as.ProjProjection;
	import org.openscales.core.Trace;
	import org.openscales.core.layer.Layer;
	import org.openscales.core.layer.ogc.WMS;
	import org.openscales.core.basetypes.Resolution;
	import org.openscales.core.layer.Layer;

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
		private var _generalExtension:IWMCExtension;
		private var _layerExtension:IWMCExtension;
		
		// GeneralType
		private var _windowSize:Size;
		private var _generalBbox:Bounds;
		
		// LayerList
		private var _layerList:Vector.<Layer>;
		
		public function WMCFormat(generalExtension:IWMCExtension = null, layerExtension:IWMCExtension = null)
		{
			this._generalExtension = generalExtension;
			this._layerExtension = layerExtension;
		}
		
		public function get generalExtension():IWMCExtension
		{
			return this._generalExtension;	
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
			if(this.wmcFile..*::General.length() > 0)
			{
				var general:XML = this.wmcFile..*::General[0];
				if(general..*::Window.length() > 0)
				{
					var window:XML = general..*::Window[0];
					if(window..@height.length()> 0 && window..@width.length() > 0)
					{
						this._windowSize = new Size(window..@width[0], window..@height[0]);
					}
				}



				if(general..*::BoundingBox.length() > 0)
				{
					var bbox:XML = general..*::BoundingBox[0];
					if(bbox..@SRS.length() > 0 && bbox..@minx.length() > 0 && bbox..@miny.length() > 0 && bbox..@maxx.length() > 0 && bbox..@maxy.length() > 0)
					{
						this._generalBbox = new Bounds(bbox..@minx, bbox..@miny, bbox..@maxx, bbox..@maxy, bbox..@SRS);
					}
				}
				
				if (this._generalExtension != null)
				{
					this._generalExtension.parseGeneralTypeExtension(general);
				}
			}
			if(this.wmcFile..*::LayerList.length() > 0)
			{
				var layerList:XML = wmcFile..*::LayerList[0];
				if(layerList..*::Layer.length() > 0)
				{
					if (layerList..*::Layer.length() > 0)
					{
						var listOfLayers:XMLList = layerList..*::Layer;
						var listLength:Number = listOfLayers.length();
						this._layerList = new Vector.<Layer>();
						for (var i:int = 0; i<listLength; ++i)
						{
							var layer:XML = listOfLayers[i];
							var service:String = "";
							var version:String = "";
							var url:String = "";
							if (layer..*::Server.length() > 0)
							{
								var server:XML = layer..*::Server[0];
								if(server..@service.length() > 0)
								{
									service = server..@service;
								}
								if(server..@version.length() > 0)
								{
									version = server..@version;
								}
								if(server..*::OnlineResource.length() > 0)
								{
									var onlineRessource:XML = server..*::OnlineResource[0];
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
							var minScaleDenominator:Number = NaN;
							var maxScaleDenominator:Number = NaN;
							var srs:String = "";
							//var formatList:Vector.<String> = new Vector.<String>();
							var format:String = "";
							if(layer..*::Name.length() > 0)
							{
								name = layer..*::Name[0];
							}
							if(layer..*::Title.length() > 0)
							{
								title = layer..*::Title[0];
							}
							if(layer..*::MinScaleDenominator.length() > 0)
							{
								minScaleDenominator = layer..*::MinScaleDenominator[0];
							}
							if(layer..*::MaxScaleDenominator.length() > 0)
							{
								maxScaleDenominator = layer..*::MaxScaleDenominator[0];
							}
							if (layer..*::SRS.length() > 0)
							{
								srs = layer..*::SRS[0];
							}
							if (layer..*::FormatList.length() > 0)
							{
								var formats:XMLList = layer..*::FormatList;
								if(formats..*::Format.length() > 0)
								{
									var currentFormat:XMLList = formats..*::Format;
									var formatLength:Number = currentFormat.length();
									for (var j:int = 0; j < formatLength; ++j)
									{
										if(currentFormat[j]..@current.length() > 0)
										{
											if (currentFormat[j]..@current == 1)
											{
												format = currentFormat[i];
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
									wms.minResolution = new Resolution(1/minScaleDenominator, srs);
									wms.maxResolution = new Resolution(1/maxScaleDenominator, srs);
									layerToAdd = wms;
									break;
								case "OGC:WFS":
									
									break;
								case "OGC:WMTS":
									
									break;
								default:
									Trace.debug("Service layer : "+service+" not supported");
									break;
							}
							this._layerList.push(layerToAdd);
						}
					}
				}
			}
			return null
		}
		
		

	}
}
package org.openscales.core.format
{
	import org.openscales.core.Map;
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
		
		// Namespaces
		private var _wmcNS:Namespace;
		private var _xlinkNS:Namespace;
		private var _sldNS:Namespace;
		
		// WMC version
		public const VERSION:String = "1.1.0"
		
		public function WMCFormat()
		{
			this.wmcNS = new Namespace("", "http://www.opengeospatial.net/context");						
			this.xlinkNS = new Namespace("xlink","http://www.w3.org/1999/xlink");
			this.sldNS = new Namespace("sld","http://www.opengeospatial.net/sld");
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
			if(layer.@hidden.length() > 0)
			{
				hidden = layer.@hidden == "true" || layer.@hidden == "1";
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
				case "OGC:WMS;Cached":
					var wmsc:WMS = new WMS(title,url,name,"",format);
					wmsc.version = version;
					wmsc.projection = srs;
					wmsc.abstract = (abstract && abstract.length>0) ? abstract : null;
					wmsc.availableProjections = availableProjections;
					wmsc.transparent = true;
					wmsc.minResolution = new Resolution(Unit.getResolutionFromScaleDenominator(minScaleDenominator), ProjProjection.getProjProjection("EPSG:4326"));
					wmsc.maxResolution = new Resolution(Unit.getResolutionFromScaleDenominator(maxScaleDenominator),  ProjProjection.getProjProjection("EPSG:4326"));
					wmsc.generateResolutions(21, wmsc.maxResolution.value);
					wmsc.tiled = true;
					layerToAdd = wmsc;
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
					if(style) wmts.style = style;
					if (srs != "")
					{
						wmts.projection = srs;
					}
					wmts.minResolution = new Resolution(Unit.getResolutionFromScaleDenominator(minScaleDenominator), ProjProjection.getProjProjection("EPSG:4326"));
					wmts.maxResolution = new Resolution(Unit.getResolutionFromScaleDenominator(maxScaleDenominator), ProjProjection.getProjProjection("EPSG:4326"));
					if(format)wmts.format = format;
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
			if (layerToAdd) layerToAdd.visible = !hidden;
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
		
		/**
		 * Write a WMC XML based on a context Object
		 * 
		 * @param the context, context is Object type like {map:Map, title:string, id:string}
		 * 
		 * @return An XML object or null if an error occured
		 */
		override public function write(context:Object):Object{
			if(!context["map"] || !context["title"] || !context["id"]){
				Trace.error("Context object structure is wrong");
				return null;
			}
			if(!(context["map"] is Map)){
				Trace.error("context[\"map\"] must be map type");
				return null;	
			}
			// Build root node
			var xmlSaveContext:XML = buildViewContextNode(context["id"]);
			
			// Build general nodes mandatories
			var xmlGeneral:XML = buildGeneralNode(context["map"].extent, context["title"]);	
			xmlGeneral.appendChild(buildWindowNode(context["map"].width, context["map"].height));
			xmlSaveContext.appendChild(xmlGeneral);			
			
			// Build list layers node
			var layerList:XML = buildLayerListNode();
			
			for each (var layer:Layer in context["map"].layers){
				var layerNode:XML;
				
				if (layer is WMS){
					layerNode = buildLayerNode((layer as WMS).available, !(layer as WMS).visible, 
						(layer as WMS).name, (layer as WMS).displayedName, (layer as WMS).url, 
						"OGC:WMS", (layer as WMS).version);
				}
				if (layer is WFS){
					layerNode = buildLayerNode((layer as WFS).available, !(layer as WFS).visible, 
						(layer as WFS).name, (layer as WFS).displayedName, (layer as WFS).url, 
						"OGC:WFS", (layer as WFS).version);
				}
				if (layer is WMTS){
					layerNode = buildLayerNode((layer as WMTS).available, !(layer as WMTS).visible, 
						(layer as WMTS).layer, (layer as WMTS).displayedName, (layer as WMTS).url, 
						"OGC:WMTS", "1.0.0");
				}
				
				layerList.appendChild(layerNode);
			}
			
			xmlSaveContext.appendChild(layerList);
			
			return xmlSaveContext;
		}
		
		/**
		 * Build root node (view context)
		 * 
		 * @param the id of the context
		 * 
		 * @return An XML object
		 */
		public function buildViewContextNode(idContext:String):XML{
			var xmlWMC:XML = <ViewContext></ViewContext>;
			xmlWMC.@id = idContext;
			xmlWMC.@version = VERSION;
			
			xmlWMC.setNamespace(wmcNS);
			
			xmlWMC.addNamespace(sldNS);
			xmlWMC.addNamespace(xlinkNS);
			
			return xmlWMC;
		}	
		
		/**
		 * Build general node for the root node
		 * 
		 * @param the bounding box for a map
		 * @param the title of the context
		 * 
		 * @calls buildBoundingBoxNode to build boundingbox node
		 * 
		 * @return An XML object
		 */
		public function buildGeneralNode(bounds:Bounds, title:String):XML{
			var general:XML = <General></General>;
			
			// Mandatories elements
			general.appendChild(buildBoundingBoxNode(bounds));
			general.appendChild((new XML(<Title></Title>).appendChild(title)));
			
			return general;
		}		
		
		/**
		 * Build window node for the general node
		 * 
		 * @param the width of the window
		 * @param the height of the window
		 * 
		 * @return An XML object
		 */
		public function buildWindowNode(width:int, height:int):XML{
			var window:XML = <Window></Window>;
			window.@width = width;
			window.@height = height;
			return window;
		}
		
		/**
		 * Build boundingbox node for the general node
		 * 
		 * @param the bounding box for a map
		 * 
		 * @return An XML object
		 */
		public function buildBoundingBoxNode(bounds:Bounds):XML{
			var boundingBox:XML =  <BoundingBox></BoundingBox>;
			boundingBox.@SRS = bounds.projection.srsCode;
			boundingBox.@minx = bounds.left;
			boundingBox.@miny = bounds.bottom;
			boundingBox.@maxx = bounds.right;
			boundingBox.@maxy = bounds.top;
			return boundingBox;
		}
		
		/**
		 * Build keywords node for the general node
		 * 
		 * @param the array of keywords values
		 * 
		 * @return An XML object
		 */
		public function buildKeywordListNode(keywords:Array):XML{
			var keywordList:XML = <KeywordList></KeywordList>;
			for each (var keyword:String in keywords){
				var xml:XML = <Keyword></Keyword>;
				xml.appendChild(keyword);
				keywordList.appendChild(xml);
			}
			
			return keywordList;
		}
		
		/**
		 * Build description url node for the general node
		 * 
		 * @param the url of the description
		 * @param the format (e.g, text/plain) of the description, could be null
		 * 
		 * @calls buildURLNode to build attributes and the online resource node
		 * 
		 * @return An XML object
		 */
		public function buildDescriptionURLNode(href:String, format:String=null):XML{
			return buildURLNode(new XML(<DescriptionURL></DescriptionURL>), href, format)
		}
		
		/**
		 * Build logo url node for the general node
		 * 
		 * @param the url of the logo
		 * @param the format (e.g, image/png) of the description, could be null
		 * @param the width of the logo, could be null
		 * @param the height of the logo, could be null
		 * 
		 * @calls buildURLNode to build attributes and the online resource node
		 * 
		 * @return An XML object
		 */
		public function buildLogoURLNode(href:String, format:String=null, width:int=NaN, 
									 height:int=NaN):XML{
			return buildURLNode(new XML(<LogoURL></LogoURL>), href, format, width, height)
		}
		
		/**
		 * Build a generic url node
		 * 
		 * @param the node to set attributes
		 * @param the url of the node
		 * @param the format (e.g, image/png or text/plain) of the description, could be null
		 * @param the width if url is an image, could be null
		 * @param the height if url is an image, could be null
		 * 
		 * @calls buildOnlineResourceNode to build the online resource node
		 * 
		 * @return An XML object
		 */
		private function buildURLNode(xml:XML, href:String, format:String=null, width:int=NaN, 
								  height:int=NaN):XML{						
			if(width){
				xml.@width=width;
			}
			if(height){
				xml.@height=height;
			}
			if(format){
				xml.@format=format;
			}
			
			xml.appendChild(buildOnlineResourceNode(href));			
			
			return xml;
		}
		
		/**
		 * Build a generic online resource node
		 * 
		 * @param the url of the online ressource		 * 
		 * 
		 * @return An XML object
		 */
		public function buildOnlineResourceNode(url:String):XML{
			var onlineResource:XML = <OnlineResource></OnlineResource>;
			onlineResource.@xlinkNS::type= "simple";
			onlineResource.@xlinkNS::href = url;
			
			return onlineResource;
		}
		
		/**
		 * Build contact information node for the general node
		 * 
		 * @param the first and last name of the person
		 * @param the organization of the person
		 * @param the position of the person
		 * @param the address type of the person/organization
		 * @param the address of the person/organization
		 * @param the city of the person/organization
		 * @param the state or province of the person/organization
		 * @param the post code of the person/organization
		 * @param the voice telephone of the person/organization
		 * @param the facsimile of the person/organization
		 * @param the electronic mail of the person/organization
		 * 
		 * @calls buildContactPersonPrimaryNode to build contact person primary node
		 * @calls buildContactAddressNode to build contact address node
		 * 
		 * @return An XML object
		 */
		public function buildContactInformationNode(person:String, organization:String, position:String,
												addressType:String, address:String, city:String, 
												stateOrProvince:String, postCode:String, 
												country:String,voiceTelephone:String, 
												facsimileTelephone:String, 
												electronicMailAddress:String):XML{
			var contactInformation:XML = <ContactInformation></ContactInformation>;
			
			var contactPersonPrimary:XML = buildContactPersonPrimaryNode(person, organization);
			
			var contactPosition:XML = <ContactPosition></ContactPosition>;
			contactPosition.appendChild(position);
			
			var contactAddress:XML = buildContactAddressNode(addressType,address,city, stateOrProvince,postCode, country);
			
			var contactVoiceTelephone:XML = <ContactVoiceTelephone></ContactVoiceTelephone>;
			contactVoiceTelephone.appendChild(voiceTelephone);
			
			var contactFacsimileTelephone:XML = <ContactFacsimileTelephone></ContactFacsimileTelephone>;
			contactFacsimileTelephone.appendChild(facsimileTelephone);
			
			var contactElectronicMailAddress:XML = <ContactElectronicMailAddress></ContactElectronicMailAddress>;
			contactElectronicMailAddress.appendChild(electronicMailAddress);
			
			contactInformation.appendChild(contactPersonPrimary);
			contactInformation.appendChild(contactPosition);
			contactInformation.appendChild(contactAddress);
			contactInformation.appendChild(contactVoiceTelephone);
			contactInformation.appendChild(contactFacsimileTelephone);
			contactInformation.appendChild(contactElectronicMailAddress);
			
			return contactInformation;
		}
		
		/**
		 * Build contact person primary node for the contact information node
		 * 
		 * @param the first and last name of the person
		 * @param the organization of the person
		 * 
		 * @return An XML object
		 */
		public function buildContactPersonPrimaryNode(person:String, organization:String ):XML{
			var contactPersonPrimary:XML = <ContactPersonPrimary></ContactPersonPrimary>;
			
			var contactPerson:XML = <ContactPerson></ContactPerson>;
			contactPerson.appendChild(person);
			
			var contactOrganization:XML = <ContactOrganization></ContactOrganization>;
			contactOrganization.appendChild(organization);
			
			contactPersonPrimary.appendChild(contactPerson);
			contactPersonPrimary.appendChild(contactOrganization);
			
			return contactPersonPrimary;
		}
		
		
		/**
		 * Build contact address node for the contact information node
		 * 
		 * @param the address type of the person/organization
		 * @param the address of the person/organization
		 * @param the city of the person/organization
		 * @param the state or province of the person/organization
		 * @param the post code of the person/organization
		 * @param the voice telephone of the person/organization
		 * @param the facsimile of the person/organization
		 * @param the electronic mail of the person/organization
		 * 
		 * @return An XML object
		 */
		public function buildContactAddressNode(aAddressType:String, aAddress:String, aCity:String, 
											aStateOrProvince:String, aPostCode:String, 
											aCountry:String):XML{
			var contactAddress:XML = <ContactAddress></ContactAddress>;
			
			var addressType:XML = <AddressType></AddressType>;
			addressType.appendChild(aAddressType);
			
			var address:XML = <Address></Address>;
			address.appendChild(aAddress);
			
			var city:XML = <City></City>;
			city.appendChild(aCity);
			
			var stateOrProvince:XML = <StateOrProvince></StateOrProvince>;
			stateOrProvince.appendChild(aStateOrProvince);
			
			var postCode:XML = <PostCode></PostCode>;
			postCode.appendChild(aPostCode);
			
			var country:XML = <Country></Country>;
			country.appendChild(aCountry);
			
			contactAddress.appendChild(addressType);
			contactAddress.appendChild(address);
			contactAddress.appendChild(city);
			contactAddress.appendChild(stateOrProvince);
			contactAddress.appendChild(postCode);
			contactAddress.appendChild(country);
			
			return contactAddress;
		}
		
		/**
		 * Build extension node for the general node and a layer node
		 * 
		 * @param the xml fragment extension
		 * 
		 * @return An XML object
		 */
		public function buildExtensionNode(customXML:XML):XML{
			var extension:XML = <Extension></Extension>;		
			extension.appendChild(customXML);
			
			return extension;
		}
		
		/**
		 * Build layer list node
		 * 
		 * @return An XML object
		 */
		public function buildLayerListNode():XML{
			var layerList:XML = <LayerList></LayerList>;
			
			return layerList;
		}
		
		/**
		 * Build layer node for a layer list node
		 * 
		 * @param if the layer is queryable
		 * @param if the layer is hidden
		 * @param name of the layer
		 * @param the title of the layer
		 * @param the url of the server
		 * @param the service type of the server
		 * @param the version of the server
		 * @param the title of the server, could be null
		 * 
		 * @calls buildServerLayerNode build the server node
		 * 
		 * @return An XML object
		 */
		public function buildLayerNode(queryable:Boolean, hidden:Boolean,
								   name:String, title:String, urlServer:String, 
								   serviceServer:String, versionServer:String, 
								   titleServer:String=null):XML{
			var layer:XML = <Layer></Layer>;
			layer.@queryable = (queryable) ? 1 : 0;
			layer.@hidden = (hidden) ? 1 : 0;
			
			var serverLayer:XML = buildServerLayerNode(urlServer, serviceServer, versionServer, titleServer); 
			
			var nameLayer:XML = <Name></Name>; 
			nameLayer.appendChild(name);
			
			var titleLayer:XML = <Title></Title>; 
			titleLayer.appendChild(title);
			
			// Mandatories elements in layer
			layer.appendChild(serverLayer);
			layer.appendChild(nameLayer);
			layer.appendChild(titleLayer);
			
			return layer;
		}
		
		/**
		 * Build server node for a layer node
		 * 
		 * @param the url of the server
		 * @param the service type of the server
		 * @param the version of the server
		 * @param the title of the server, could be null
		 * 
		 * @return An XML object
		 */
		public function buildServerLayerNode(url:String, service:String, version:String, title:String=null):XML{
			var serverLayer:XML = <Server></Server>;
			
			serverLayer.appendChild(buildOnlineResourceNode(url));
			serverLayer.@service=service;
			serverLayer.@version=version;
			if(title){
				serverLayer.@title=title;
			}
			
			return serverLayer;
		}
		
		/**
		 * Build abstract node for a layer node
		 * 
		 * @param the abstract value of the node, could be null
		 * 
		 * @return An XML object
		 */
		public function buildAbstractLayerNode(abstract:String=null):XML{
			var abstractLayer:XML;
			if(abstract){
				abstractLayer =  <Abstract></Abstract>;
				abstractLayer.appendChild(abstract);
			}
			
			return abstractLayer;
		}
		
		/**
		 * Build data url node for a layer node
		 * 
		 * @param the url of the data
		 * @param the format (e.g, image/png or text/plain) of the description, could be null
		 * @param the width if url is an image, could be null
		 * @param the height if url is an image, could be null
		 * 
		 * @return An XML object
		 */
		public function buildDataURLLayerNode(href:String, format:String=null, width:int=NaN, height:int=NaN):XML{
			return buildURLNode(new XML(<DataURL></DataURL>), href, format)
		}
		
		/**
		 * Build metadata url node for a layer node
		 * 
		 * @param the url of the metadata
		 * @param the format (e.g, text/xml) of the description, could be null
		 * 
		 * @return An XML object
		 */
		public function buildMetadataURLLayerNode(href:String, format:String=null, width:int=NaN, height:int=NaN):XML{				
			return buildURLNode(new XML(<MetadataURL></MetadataURL>), href, format)
		}
		
		/**
		 * Build SRS node for a layer node
		 * 
		 * @param the srs code, could be null
		 * 
		 * @return An XML object
		 */
		public function buildSRSLayerNode(SRS:String=null):XML{
			var SRSLayer:XML;
			if(SRS){
				SRSLayer = <SRS></SRS>;
				SRSLayer.appendChild(SRS);
			}
			
			return SRSLayer;
		}
		
		/**
		 * Build dimension list node for a layer
		 * 
		 * @param the dimensions array, elements in dimensions are Object types like {name:string, units:string, unitSym:string, userValue:string, mydefault:string, multipleValues:boolean, nearestValue:boolean, current:boolean}
		 * 
		 * @return An XML object
		 */
		public function buildDimensionListLayerNode(dimensions:Array):XML{
			var dimensionListLayer:XML;
			
			for each (var dimension:Object in dimensions){		
				// Fields are mandatories
				if(!dimension["name"] || !dimension["units"] || !dimension["unitSym"] || !dimension["userValue"]){
					Trace.error("name, units, unitSym and userValue are mandatories fields");					
					continue;
				}
				
				if(!dimensionListLayer){
					dimensionListLayer = <DimensionList></DimensionList>;
				}
				
				var dimensionLayer:XML = <Dimension></Dimension>;
				dimensionLayer.appendChild(dimension["value"]);
				
				dimensionLayer.@name = dimension["name"];
				dimensionLayer.@units = dimension["units"];
				dimensionLayer.@unitSym = dimension["unitSym"];
				dimensionLayer.@userValue = dimension["userValue"];
				dimensionLayer.@default = dimension["mydefault"];
				dimensionLayer.@multipleValues = dimension["multipleValues"];
				dimensionLayer.@nearestValue = dimension["nearestValue"];		
				dimensionLayer.@current = dimension["current"];	
				
				dimensionListLayer.appendChild(dimensionLayer);
			}
			
			return dimensionListLayer;
		}
		
		/**
		 * Build a format list for a layer node 
		 * 
		 * @param the formats array, elements in formats are Object types like {current:boolean, value:string}
		 * 
		 * @return An XML object
		 */		
		public function buildFormatListLayerNode(formats:Array):XML{ 
			var formatListLayer:XML;
			
			for each (var format:Object in formats){
				if(!formatListLayer){
					formatListLayer  = <FormatList></FormatList>;
				}
				var xml:XML = <Format></Format>;
				xml.@current = (format["current"]) ? 1 : 0;
				xml.appendChild(format["value"]);
				formatListLayer.appendChild(xml);
			}
			
			
			return formatListLayer;
		}
		
		/**
		 * Build a style list for a layer node 
		 * 
		 * @param the styles array, styles in formats are Object types like
		 * if not SLD style {name:string, title:string, abstract:string, legendURL:{href:string, format:string, width:int, height:int}}
		 * if SLD style {SLDName:string, SLDTitle:string, SLDURL:String or StyledLayerDescriptor:xml or FeatureTypeStyle:xml}
		 * 
		 * @calls buildURLNode to build attributes and the online resource node
		 * 
		 * @return An XML object
		 */		
		public function buildStyleListLayerNode(styles:Array):XML{ 
			var styleListLayer:XML;
			
			for each (var style:Object in styles){
				if(!style["SLDURL"] && !style["StyledLayerDescriptor"] && !style["FeatureTypeStyle"]){
					if(!styleListLayer){
						styleListLayer  = <StyleList></StyleList>;
					}
					
					if(!style["name"] || !style["title"]){
						Trace.error("name and title are mandatories fields");	
						continue;
					}
					
					var xml:XML = <Style></Style>;
					xml.@current = (style["current"]) ? 1 : 0;
					xml.appendChild(new XML(<Name></Name>).appendChild(style["name"]));
					xml.appendChild(new XML(<Title></Title>).appendChild(style["title"]));
					if(style["abstract"]){
						xml.appendChild(new XML(<Abstract></Abstract>).appendChild(style["abstract"]));
					}
					if(style["legendURL"]){
						xml.appendChild(buildURLNode(new XML(<LegendURL></LegendURL>), style["legendURL"]["href"], style["legendURL"]["format"],
							style["legendURL"]["width"], style["legendURL"]["height"]));
					}
					
					styleListLayer.appendChild(xml);
				}else{
					if((style["SLDURL"] && style["StyledLayerDescriptor"] && !style["FeatureTypeStyle"]) ||
						(style["SLDURL"] && !style["StyledLayerDescriptor"] && style["FeatureTypeStyle"]) ||
						(!style["SLDURL"] && style["StyledLayerDescriptor"] && style["FeatureTypeStyle"]) ||
						(style["SLDURL"] && style["StyledLayerDescriptor"] && style["FeatureTypeStyle"])){
						Trace.error("SLDURL or StyledLayerDescriptor or FeatureTypeStyle: one of them must be chosen");
						continue;
					}else{
						if(!styleListLayer){
							styleListLayer  = <StyleList></StyleList>;
						}
						
						var xmlStyle:XML = <Style></Style>;
						xmlStyle.@current = (style["current"]) ? 1 : 0;
						var xmlSLD:XML = <SLD></SLD>;
						
						if(style["SLDName"]){
							xmlSLD.appendChild(new XML(<Name></Name>).appendChild(style["SLDName"]));
						}
						if(style["SLDTitle"]){
							xmlSLD.appendChild(new XML(<Title></Title>).appendChild(style["SLDTitle"]));
						}
						if(style["SLDURL"]){
							xmlSLD.appendChild(buildOnlineResourceNode(style["SLDURL"]));
						}
						if(style["StyledLayerDescriptor"]){
							xmlSLD.appendChild(style["StyledLayerDescriptor"]);
						}
						if(style["FeatureTypeStyle"]){
							xmlSLD.appendChild(style["FeatureTypeStyle"]);
						}
						
						xmlStyle.appendChild(xmlSLD);
						styleListLayer.appendChild(xmlStyle);
					}
				}
				
			}
			
			return styleListLayer;
		}
		
		/**
		 * Build min scale denominator node for a layer node, ref. to SLD schema
		 * 
		 * @param the min scale denominator, could be null
		 * 
		 * @return An XML object
		 */
		public function buildMinScalesDenominatorLayerNode(minScale:Number=NaN):XML{
			var minScaleDenominator:XML;
			if(minScale){
				minScaleDenominator = <MinScaleDenominator></MinScaleDenominator>
				minScaleDenominator.appendChild(minScale);
			}	
			
			return minScaleDenominator;
		}
		
		/**
		 * Build max scale denominator node for a layer node, ref. to SLD schema
		 * 
		 * @param the max scale denominator, could be null
		 * 
		 * @return An XML object
		 */
		public function buildMaxScalesDenominatorLayerNode(maxScale:Number=NaN):XML{
			var maxScaleDenominator:XML;
			if(maxScale){
				maxScaleDenominator = <MaxScaleDenominator></MaxScaleDenominator>;
				maxScaleDenominator.appendChild(maxScale);
			}
			
			return maxScaleDenominator;
		}
		
		// Getters/Setters
		public function get sldNS():Namespace
		{
			return _sldNS;
		}
		
		public function set sldNS(value:Namespace):void
		{
			_sldNS = value;
		}
		
		public function get xlinkNS():Namespace
		{
			return _xlinkNS;
		}
		
		public function set xlinkNS(value:Namespace):void
		{
			_xlinkNS = value;
		}
		
		public function get wmcNS():Namespace
		{
			return _wmcNS;
		}
		
		public function set wmcNS(value:Namespace):void
		{
			_wmcNS = value;
		}

	}
}
package org.openscales.core.format.wmc.writer
{
	import org.openscales.core.utils.Trace;

	public class WMC110Writer
	{
		public const VERSION:String = "1.1.0"
		
		private var _wmcns:Namespace;
		private var _xlinkns:Namespace;
		private var _sldns:Namespace;
		
		public function WMC110Writer()
		{
			this.wmcns = new Namespace("", "http://www. opengeospatial.net/context");						
			this.xlinkns = new Namespace("xlink","http://www.w3.org/1999/xlink");
			this.sldns = new Namespace("sld","http://www. opengeospatial.net/sld");
		}	
		
		/**
		 * Build root node (view context)
		 * 
		 * @param the id of the context
		 * 
		 * @return An XML object
		 */
		public function buildViewContext(idContext:String):XML{
			var xmlWMC:XML = <ViewContext></ViewContext>;
			xmlWMC.@id = idContext;
			xmlWMC.@version = VERSION;
			
			xmlWMC.setNamespace(wmcns);
			
			xmlWMC.addNamespace(this.sldns);
			xmlWMC.addNamespace(this._xlinkns);
			
			return xmlWMC;
		}	
	
		/**
		 * Build general node for the root node
		 * 
		 * @param the SRS of the context
		 * @param the bottom lef corner X of the context
		 * @param the bottom lef corner Y of the context
		 * @param the top right corner X of the context
		 * @param the top right corner Y of the context
		 * @param the title of the context
		 * 
		 * @calls buildBoundingBox to build boundingbox node
		 * 
		 * @return An XML object
		 */
		public function buildGeneral(SRS:String, minx:Number, miny:Number, maxx:Number, 
									 maxy:Number, title:String):XML{
			var general:XML = <General></General>;
			
			// Mandatories elements
			general.appendChild(buildBoundingBox(SRS, minx, miny, maxx, maxy));
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
		public function buildWindow(width:int, height:int):XML{
			var window:XML = <Window></Window>;
			window.@width = width;
			window.@height = height;
			return window;
		}
		
		/**
		 * Build boundingbox node for the general node
		 * 
		 * @param the SRS of the context
		 * @param the bottom lef corner X of the context
		 * @param the bottom lef corner Y of the context
		 * @param the top right corner X of the context
		 * @param the top right corner Y of the context
		 * 
		 * @return An XML object
		 */
		public function buildBoundingBox(SRS:String, minx:Number, miny:Number, maxx:Number, 
										 maxy:Number):XML{
			var boundingBox:XML =  <BoundingBox></BoundingBox>;
			boundingBox.@SRS = SRS;
			boundingBox.@minx = minx;
			boundingBox.@miny = miny;
			boundingBox.@maxx = maxx;
			boundingBox.@maxy = maxy;
			return boundingBox;
		}
		
		/**
		 * Build keywords node for the general node
		 * 
		 * @param the array of keywords values
		 * 
		 * @return An XML object
		 */
		public function buildKeywordList(keywords:Array):XML{
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
		 * @calls buildURL to build attributes and the online resource node
		 * 
		 * @return An XML object
		 */
		public function buildDescriptionURL(href:String, format:String=null):XML{
			return buildURL(new XML(<DescriptionURL></DescriptionURL>), href, format)
		}
		
		/**
		 * Build logo url node for the general node
		 * 
		 * @param the url of the logo
		 * @param the format (e.g, image/png) of the description, could be null
		 * @param the width of the logo, could be null
		 * @param the height of the logo, could be null
		 * 
		 * @calls buildURL to build attributes and the online resource node
		 * 
		 * @return An XML object
		 */
		public function buildLogoURL(href:String, format:String=null, width:int=NaN, 
									 height:int=NaN):XML{
			return buildURL(new XML(<LogoURL></LogoURL>), href, format, width, height)
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
		 * @calls buildOnlineResource to build the online resource node
		 * 
		 * @return An XML object
		 */
		private function buildURL(xml:XML, href:String, format:String=null, width:int=NaN, 
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
			
			xml.appendChild(buildOnlineResource(href));			
			
			return xml;
		}
		
		/**
		 * Build a generic online resource node
		 * 
		 * @param the url of the online ressource		 * 
		 * 
		 * @return An XML object
		 */
		public function buildOnlineResource(url:String):XML{
			var onlineResource:XML = <OnlineResource></OnlineResource>;
			onlineResource.@xlinkns::type= "simple";
			onlineResource.@xlinkns::href = url;
			
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
		 * @calls buildContactPersonPrimary to build contact person primary node
		 * @calls buildContactAddress to build contact address node
		 * 
		 * @return An XML object
		 */
		public function buildContactInformation(person:String, organization:String, position:String,
												 addressType:String, address:String, city:String, 
												 stateOrProvince:String, postCode:String, 
												 country:String,voiceTelephone:String, 
												 facsimileTelephone:String, 
												 electronicMailAddress:String):XML{
			var contactInformation:XML = <ContactInformation></ContactInformation>;
			
			var contactPersonPrimary:XML = buildContactPersonPrimary(person, organization);
			
			var contactPosition:XML = <ContactPosition></ContactPosition>;
			contactPosition.appendChild(position);
			
			var contactAddress:XML = buildContactAddress(addressType,address,city, stateOrProvince,postCode, country);
			
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
		public function buildContactPersonPrimary(person:String, organization:String ):XML{
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
		public function buildContactAddress(aAddressType:String, aAddress:String, aCity:String, 
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
		public function buildExtension(customXML:XML):XML{
			var extension:XML = <Extension></Extension>;		
			extension.appendChild(customXML);
			
			return extension;
		}
		
		/**
		 * Build layer list node
		 * 
		 * @return An XML object
		 */
		public function buildLayerList():XML{
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
		 * @calls buildServerLayer build the server node
		 * 
		 * @return An XML object
		 */
		public function buildLayer(queryable:Boolean, hidden:Boolean,
								   name:String, title:String, urlServer:String, 
								   serviceServer:String, versionServer:String, 
								   titleServer:String=null):XML{
			var layer:XML = <Layer></Layer>;
			layer.@queryable = (queryable) ? 1 : 0;
			layer.@hidden = (hidden) ? 1 : 0;
									
			var serverLayer:XML = buildServerLayer(urlServer, serviceServer, versionServer, titleServer); 
			
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
		public function buildServerLayer(url:String, service:String, version:String, title:String=null):XML{
			var serverLayer:XML = <Server></Server>;
			
			serverLayer.appendChild(buildOnlineResource(url));
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
		public function buildAbstractLayer(abstract:String=null):XML{
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
		public function buildDataURLLayer(href:String, format:String=null, width:int=NaN, height:int=NaN):XML{
			return buildURL(new XML(<DataURL></DataURL>), href, format)
		}
		
		/**
		 * Build metadata url node for a layer node
		 * 
		 * @param the url of the metadata
		 * @param the format (e.g, text/xml) of the description, could be null
		 * 
		 * @return An XML object
		 */
		public function buildMetadataURLLayer(href:String, format:String=null, width:int=NaN, height:int=NaN):XML{				
			return buildURL(new XML(<MetadataURL></MetadataURL>), href, format)
		}
		
		/**
		 * Build SRS node for a layer node
		 * 
		 * @param the srs code, could be null
		 * 
		 * @return An XML object
		 */
		public function buildSRSLayer(SRS:String=null):XML{
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
		public function buildDimensionListLayer(dimensions:Array):XML{
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
		public function buildFormatListLayer(formats:Array):XML{ 
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
		 * @calls buildURL to build attributes and the online resource node
		 * 
		 * @return An XML object
		 */		
		public function buildStyleListLayer(styles:Array):XML{ 
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
						xml.appendChild(buildURL(new XML(<LegendURL></LegendURL>), style["legendURL"]["href"], style["legendURL"]["format"],
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
						
						var xml:XML = <Style></Style>;
						xml.@current = (style["current"]) ? 1 : 0;
						var xmlSLD:XML = <SLD></SLD>;
						
						if(style["SLDName"]){
							xmlSLD.appendChild(new XML(<Name></Name>).appendChild(style["SLDName"]));
						}
						if(style["SLDTitle"]){
							xmlSLD.appendChild(new XML(<Title></Title>).appendChild(style["SLDTitle"]));
						}
						if(style["SLDURL"]){
							xmlSLD.appendChild(buildOnlineResource(style["SLDURL"]));
						}
						if(style["StyledLayerDescriptor"]){
							xmlSLD.appendChild(style["StyledLayerDescriptor"]);
						}
						if(style["FeatureTypeStyle"]){
							xmlSLD.appendChild(style["FeatureTypeStyle"]);
						}
						
						xml.appendChild(xmlSLD);
						styleListLayer.appendChild(xml);
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
		public function buildMinScalesDenominatorLayer(minScale:Number=NaN):XML{
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
		public function buildMaxScalesDenominatorLayer(maxScale:Number=NaN):XML{
			var maxScaleDenominator:XML;
			if(maxScale){
				maxScaleDenominator = <MaxScaleDenominator></MaxScaleDenominator>;
				maxScaleDenominator.appendChild(maxScale);
			}
			
			return maxScaleDenominator;
		}
		
		public function get wmcns():Namespace
		{
			return _wmcns;
		}
		
		public function set wmcns(value:Namespace):void
		{
			_wmcns = value;
		}
		
		public function get xlinkns():Namespace
		{
			return _xlinkns;
		}
		
		public function set xlinkns(value:Namespace):void
		{
			_xlinkns = value;
		}
		
		public function get sldns():Namespace
		{
			return _sldns;
		}
		
		public function set sldns(value:Namespace):void
		{
			_sldns = value;
		}
	}
}
package org.openscales.core.format
{
	import org.openscales.core.basetypes.maps.HashMap;
	
	/**
	 * Format class used to read GMD format.
	 */
	public class GMDFormat extends Format
	{
		public function GMDFormat()
		{
			super();
		}
		
		
		/**
		 * - fileIdentifier
		 * - language
		 * - characterSet
		 * - hierarchyLevel
		 * - hierarchyLevelName
		 * - dateStamp
		 * - metadataStandardName
		 * - metadataStandardVersion
		 * - referenceSystemInfo (only parse the "gmd:code" XML tag)
		 * - identificationInfo
		 * 		- title
		 * 		- identifier
		 * 		- abstract
		 * 		- spatialRepresentationType
		 * 		- spatialResolution
		 * 		- language
		 * 		- characterSet
		 * 		- topicCategory
		 * 		- extent
		 * - distributionInfo
		 * 		- distributionFormat
		 * 			- name
		 * 			- version
		 * 		- transferOptions
		 * 			- onLine
		 * 				- linkage
		 * 				- function
		 * 	- dataQualityInfo
		 * 		- lineage
		 * 			- statement
		 */
		override public function read(data:Object):Object
		{
			if(!data)return null;
			
			var xml:XML = new XML(data);
			var records:Vector.<HashMap> = new Vector.<HashMap>();
			var record:HashMap = new HashMap();
			
			var gmdNS:Namespace = xml.namespace("gmd");
			var cswNS:Namespace = xml.namespace("csw");
			var gcoNS:Namespace;
			
			var searchResult:XML = xml.cswNS::SearchResults[0];
			if (!searchResult)
				return null;
			
			var dataRecords:XMLList = searchResult.gmdNS::MD_Metadata;
			var recordData:XML;
			for each(recordData in dataRecords){
				record = new HashMap();
				
				// Parse fileIdentifier
				var fileIdentifierData:XMLList = data.gmdNS::fileIdentifier;
				if (fileIdentifierData.length() > 0)
				{
					gcoNS = xml.namespace("gco");
					var characterString:XMLList = fileIdentifierData[0].gcoNS::CharacterString;
					if (characterString.length() >  0)
					{
						record.put("fileIdentifier",characterString[0].toString());
					}
				}
				
				// Parse language
				var languageData:XMLList = data.gmdNS::language;
				if (languageData.length > 0)
				{
					var languageCodeData:XMLList = languageData[0].gmdNS::LanguageCode;
					if (languageCodeData.length() > 0)
					{
						record.put("language",languageCodeData[0].toString());
					}
				}
				
				// Parse characterSet
				var characterSetData:XMLList = data.gmdNS::characterSet;
				if (characterSetData.length() > 0)
				{
					var characterSetCodeData:XMLList = characterSetData[0].gmdNS::MD_CharacterSetCode;
					if (characterSetCodeData.length() > 0)
					{
						record.put("characterSet", characterSetCodeData[0].toString());
					}
				}
				
				// Parse hierarchyLevel
				var hierarchyLevelsData:XMLList = data.gmdNS::hierarchyLevel;
				if (hierarchyLevelsData.length() > 0)
				{
					var hierarchyLevels:Vector.<String> = new Vector.<String>();
					var hierarchyLevelData:XML;
					for each (hierarchyLevelData in hierarchyLevelsData)
					{
						var scopeCode:XMLList = hierarchyLevelData.gmdNS::MD_ScopeCode;
						if (scopeCode.length() > 0)
						{
							hierarchyLevels.push(scopeCode[0].toString());
						}
					}
					record.put("hierarchyLevel", hierarchyLevels);
				}
				
				// Parse hierarchyLevelName
				var hierarchyLevelNamesData:XMLList = data.gmdNS::hierarchyLevelName;
				if (hierarchyLevelNamesData.length() > 0)
				{
					var hierarchyLevelNames:Vector.<String> = new Vector.<String>();
					var hierarchyLevelNameData:XML;
					for each (hierarchyLevelNameData in hierarchyLevelNamesData)
					{
						gcoNS = xml.namespace("gco");
						var characterStringForHierarchyLevelName:XMLList = hierarchyLevelNameData.gcoNS::CharacterString;
						if (characterStringForHierarchyLevelName.length() > 0)
						{
							hierarchyLevelNames.push(characterStringForHierarchyLevelName[0].toString());
						}
					}
					record.put("hierarchyLevelName",hierarchyLevelNames);
				}
				
				// Parse dateStamp
				var dateStampData:XMLList = data.gmdNS::dateStamp;
				if (dateStampData.length() > 0)
				{
					gcoNS = xml.namespace("gco");
					var dateData:XMLList = dateStampData[0].gcoNS::Date;
					if (dateData.length() > 0)
					{
						record.put("dateStamp", dateData[0].toString());
					}
				}
				
				// Parse metadataStandardName
				var metadataStandardNameData:XMLList = data.gmdNS::metadataStandardName;
				if (metadataStandardNameData.length() > 0)
				{
					gcoNS = xml.namespace("gco");
					var characterStringForMetadataStandardNameData:XMLList = metadataStandardNameData[0].gcoNS::CharacterString;
					if (characterStringForMetadataStandardNameData.length() > 0)
					{
						record.put("metadataStandardName", characterStringForMetadataStandardNameData[0].toString());
					}
				}
				
				// Parse metadataStandardVersion
				var metadataStandardVersionData:XMLList = data.gmdNS::metadataStandardVersion;
				if (metadataStandardVersionData.length() > 0)
				{
					gcoNS = xml.namespace("gco");
					var characterStringForMetadataStandardVersionData:XMLList = metadataStandardVersionData[0].gcoNS::CharacterString;
					if (characterStringForMetadataStandardVersionData.length() > 0)
					{
						record.put("metadataStandardVersion", characterStringForMetadataStandardVersionData[0].toString());
					}
				}
				
				// Parse referenceSystemInfo
				// only parse the "gmd:code" XML tag
				var referenceSystemInfosData:XMLList = data.gmdNS::referenceSystemInfo;
				if (referenceSystemInfosData.length() > 0)
				{
					var referenceSystemInfos:Vector.<Object> = new Vector.<Object>;
					var referenceSystemInfoData:XML;
					for each (referenceSystemInfoData in referenceSystemInfosData)
					{
						var referenceSystemData:XMLList = referenceSystemInfoData.gmdNS::MD_ReferenceSystem;
						if (referenceSystemData.length() > 0)
						{
							var referenceSystemIdentifierData:XMLList = referenceSystemData[0].gmdNS::referenceSystemIdentifier;
							if (referenceSystemIdentifierData.length() > 0)
							{
								var rsIdentifierData:XMLList = referenceSystemIdentifierData[0].gmdNS::RS_Identifier;
								if (rsIdentifierData.length() > 0)
								{
									var codeData:XMLList = rsIdentifierData[0].gmdNS::code;
									if (codeData.length() > 0)
									{
										var gmxNS:Namespace = xml.namespace("gmx");
										var anchorData:XMLList = codeData[0].gmxNS::Anchor;
										if (anchorData.length() > 0)
										{
											var xlinkNS:Namespace = xml.namespace("xlink");
											var anchor:HashMap = new HashMap;
											anchor.put("href", anchorData[0].xlinkNS.@href);
											anchor.put("name", anchorData[0].toString());
											referenceSystemInfos.push(anchor);
										}else
										{
											referenceSystemInfos.push(codeData[0].toString());
										}
									}
								}
							}
						}
					}
					record.put("referenceSystemInfo", referenceSystemInfos);
				}
				// Parse identificationInfo
					// Parse title
					// Parse identifier
					// Parse abstract
					// Parse spatialRepresentationType
					// Parse spatialResolution
					// Parse language
					// Parse characterSet
					// Parse topicCategory
					// Parse extent
				// Parse distributionInfo
					// Parse distributionFormat
						// Parse name
						// Parse version
					// Parse transferOptions
						// Parse onLine
							// Parse linkage
							// Parse function
				// Parse dataQualityInfo
					// Parse lineage
						// Parse statement
					
					
				records.push(record);
			}
			return records
		}
	}
}
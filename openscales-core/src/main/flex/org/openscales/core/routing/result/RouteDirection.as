package br.com.delta.openscales.result
{
	import org.openscales.geometry.basetypes.Location;

	public class RouteDirection
	{

		public var direction:String;
		public var instruction:String;
		public var hasTolls:Boolean = false;
		public var travelDistance:Number;
		public var travelDuration:Number;
		public var travelMode:String;
		public var towardsRoadName:String;
		public var maneuverPoint:Location;
		
		//				{
		//					"compassDirection": "northeast",
		//					"details": [
		//						{
		//							"compassDegrees": 47,
		//							"endPathIndices": [
		//								3
		//							],
		//							"maneuverType": "DepartStart",
		//							"mode": "Driving",
		//							"names": [
		//								"Rua Bento da Rocha"
		//							],
		//							"roadType": "Street",
		//							"startPathIndices": [
		//								0
		//							]
		//						}
		//					],
		//					"exit": "",
		//					"iconType": "Auto",
		//					"instruction": {
		//						"formattedText": null,
		//						"maneuverType": "DepartStart",
		//						"text": "Depart Rua Bento da Rocha toward Rua Comendador Jo\u00e3o Cintra"
		//					},
		//					"maneuverPoint": {
		//						"type": "Point",
		//						"coordinates": [
		//							-22.436103,
		//							-46.822984
		//						]
		//					},
		//					"sideOfStreet": "Unknown",
		//					"tollZone": "",
		//					"towardsRoadName": "Rua Comendador Jo\u00e3o Cintra",
		//					"transitTerminus": "",
		//					"travelDistance": 0.196,
		//					"travelDuration": 34,
		//					"travelMode": "Driving"
		//				},
		
	}
}
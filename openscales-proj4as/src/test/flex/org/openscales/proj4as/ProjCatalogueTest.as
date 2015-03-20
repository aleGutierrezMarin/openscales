package org.openscales.proj4as
{
	import org.flexunit.asserts.assertEquals;

	public class ProjCatalogueTest
	{		
		[BeforeClass]
		public static function setUpBeforeClass():void
		{
			ProjCatalogue.loadCatalogue();
		}
		
		[AfterClass]
		public static function tearDownAfterClass():void
		{
		}
		
		[Test]
		public function shouldDefineWGS84UnitsAsDegrees():void{
			assertEquals("WGS84 units should be degrees", "degrees", ProjProjection.getProjProjection("WGS84").projParams.units);
		}
		
		[Test]
		public function shouldDefineIGNFWGS84UnitsAsDegrees():void{
			assertEquals("IGNF:WGS84 units should be degrees", "degrees", ProjProjection.getProjProjection("IGNF:WGS84").projParams.units);
		}
		
		[Test]
		public function shouldDefineIGNFWGS84GUnitsAsDegrees():void{
			assertEquals("IGNF:WGS84G units should be degrees", "degrees", ProjProjection.getProjProjection("IGNF:WGS84G").projParams.units);
		}
		
	}
}
package org.openscales.core.format
{
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertNotNull;
	import org.flexunit.asserts.assertNull;
	import org.openscales.core.layer.Layer;
	import org.openscales.proj4as.ProjProjection;

	public class FormatTest
	{		
		public var truc:Format;
		public var data:Object;
		public var intProj:ProjProjection;
		public var extProj:ProjProjection;
		public var texte: String;
		
		public function FormatTest() {}
		
		[Before]
		public function setUp():void
		{
			texte='coucou';
			truc= new Format();
			data= new Object();
			intProj= new ProjProjection('inter');
			extProj= new ProjProjection('exter');
			
		}
		
		[After]
		public function tearDown():void
		{
			texte=null;
			truc=null;
			data= null;
			intProj=null;
			extProj=null;
		}
		
		
		[Test]
		public function returnproj():void
		{
			truc.setExternalProjection(extProj);
			truc.setInternalProjection(intProj);
			
			assertNotNull('projection should not be null',truc.externalProjection);
			assertNotNull('projection should not be null',truc.internalProjection);
		}
		
		[Test]
		public function returnprojtest():void
		{
			
			truc.setExternalProjection(extProj);
			truc.setInternalProjection(intProj);
			truc.setExternalProjection(texte);
			truc.setInternalProjection(texte);
			
			assertNull('projection should not be null',truc.externalProjection);
			assertNull('projection should not be null',truc.internalProjection);
		}
		
		[Test]
		public function returnprojNull():void
		{
			truc.setExternalProjection(null);
			truc.setInternalProjection(null);
			
			assertNull('projection should be null',truc.externalProjection);
			assertNull('projection should be null',truc.internalProjection);
		}
		
		
		[Test]
		public function projshouldBeEqual():void
		{
			truc.setExternalProjection(extProj);
			truc.setInternalProjection(intProj);
			
			
			assertEquals('projections should not equals',extProj,truc.externalProjection);
			assertEquals('projections should not equals',intProj,truc.internalProjection);
		}
		
		[Test]
		public function returnprojtestwithObject():void
		{
			var obj1:Object= new Object();
			
			var obj:Object= new Object();
			
			truc.setExternalProjection(obj);
			truc.setInternalProjection(obj1);
			
			assertNull('projection should not be null',truc.externalProjection);
			assertNull('projection should not be null',truc.internalProjection);
		}
		
		
		
		[Test]
		public function returnprojtestwithLayer():void
		{
			truc.setExternalProjection(extProj);
			truc.setInternalProjection(intProj);
			
			var obj1:Layer= new Layer('l1');			
			var obj:Layer= new Layer('l2');
			
			truc.setExternalProjection(obj);
			truc.setInternalProjection(obj1);
			
			assertNull('projection should not be null',truc.externalProjection);
			assertNull('projection should not be null',truc.internalProjection);
		}
		
		
	}
}
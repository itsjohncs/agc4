package AGC4
{
	import flash.geom.Point;
	public class WinCombo
	{
		public var winner:int = 0;
		public var points:Array = new Array(4);
		public function WinCombo()
		{
			for (var i:int = 0; i < points.length; i++)
				points[i] = new Point();
		}
	}
}
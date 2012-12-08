package AGC4
{
	import AGC4.WinCombo;
	import SoftFX.*;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	public class AntiGravC4
	{
		// The constructor
		public function AntiGravC4()
		{
			// Create the 2 dimensional array, and fill it with zeroes
			var iX:int;
			for (iX = 0; iX < Width; iX++)
			{
				Grid[iX] = new Array(Height);
				var iY:int;
				for (iY = 0; iY < Height; iY++)
				{
					Grid[iX][iY] = 0;
				}
			}
		}
		
		/* The offsets of the first and last cell in each row.
		   (To form the shape of the grid, count the amount of
		   blank spots on the left and right side of each row
		   and you'll get it) */
		private var Offsets:Array = new Array(4, 4, 2, 2, 0, 0, 0, 2, 2, 4, 4);

		// Holds the array of movieclips that make up the actual game grid
		private var cellGrid:Array = new Array(11);
		private var cellGrid_Populated:Boolean = false;
		private var cellGrid_Parent:DisplayObjectContainer;
		
		// The player names
		public var Player1:String = "Player 1";
		public var Player2:String = "Player 2";
		
		// Whose turn it is
		public var turn:int = 1;
		
		// Swaps the turn variable's value between 1 and 2
		public function swapTurn():int
		{
			return turn = (turn == 1 ? 2 : 1);
		}
		
		// The dimensions of the board, cannot be changed from 11, don't try
		public const Width:int = 11;
		public const Height:int = 11;
		public const Length:int = 11;
		
		
		// Gets the contents of a cell, if the cell is not a playable area an error will be thrown
		public function GetCell(zX:int, zY:int):int
		{
			if (zX > Offsets[zY] - 1 && zX < Width - Offsets[zY])
			{
				return Grid[zX][zY];
			}
			else
			{
				throw new Error("Point Out of Bounds");
			}
		}
		
		/* Sets the contents of a cell, if the cell is not a playable are an
		   error will be thrown. If zValue is invalid an error will be thrown.
		   If the cell cannot be set due to rules of the game (is not connected
		   to a border), will return -1 */
		public function SetCell(zX:int, zY:int, zValue:int):int
		{
			if (zX > Offsets[zY] - 1 && zX < Width - Offsets[zY])
			{
				if (zValue < 0 || zValue > 2)
				{
					throw new Error("Invalid Argument: zValue");
				}
				else
				{
					if (CheckValid(zX,zY))
					{						
						// If the cellGrid is populated with displayobjects...
						if (cellGrid_Populated)
						{
							cellGrid_Parent.removeChild(cellGrid[zX][zY]);
							
							var newPiece:MovieClip;
							switch(zValue)
							{
								case 0:
									newPiece = new Cell();
									break;
								case 1:
									newPiece = new GreenCell();
									break;
								case 2:
									newPiece = new RedCell();
									break;
							}
							newPiece.x = cellGrid[zX][zY].x;
							newPiece.y = cellGrid[zX][zY].y;
							cellGrid[zX][zY] = newPiece;
							cellGrid_Parent.addChild(newPiece);
						}
						
						return Grid[zX][zY] = zValue;
					}
					else
					{
						return -1;
					}
				}
			}
			else
			{
				throw new Error("Point Out of Bounds: " + zX + "," + zY);
			}
		}
		
		public function ClearGrid():void
		{
			if (!cellGrid_Populated) throw new Error("A grid has not yet been created.");
			
			for (var iY:int = 0; iY < Offsets.length; iY++)
			{
				for (var iX:int = Offsets[iY]; iX < Offsets.length - Offsets[iY]; iX++)
				{
					cellGrid_Parent.removeChild(cellGrid[iX][iY]);
					cellGrid[iX][iY] = null;
				}
			}
			
			cellGrid_Populated = false;
		}
		
		public function CreateGrid(zX:Number, zY:Number, zParent:DisplayObjectContainer, zClickEvent:Function):void
		{
			if (cellGrid_Populated) throw new Error("Grid already created. Each instance of AntiGravC4 may only control 1 grid.");
			
			for (var i:int = 0; i < cellGrid.length; i++) cellGrid[i] = new Array(11);

			for (var iY:int = 0; iY < Offsets.length; iY++)
			{
				for (var iX:int = Offsets[iY]; iX < Offsets.length - Offsets[iY]; iX++)
				{
					cellGrid[iX][iY] = new Cell();
					cellGrid[iX][iY].x = zX + (iX * cellGrid[iX][iY].width) + (iX * 3);
					cellGrid[iX][iY].y = zY + (iY * cellGrid[iX][iY].height) + (iY * 3);
					
					cellGrid[iX][iY].gridX = iX;
					cellGrid[iX][iY].addEventListener(MouseEvent.CLICK, zClickEvent);
					zParent.addChild(cellGrid[iX][iY]);
				}
			}
			
			cellGrid_Populated = true;
			cellGrid_Parent = zParent;
		}
		
		public function WinFade(cmb:WinCombo):void
		{
			var winFader:FadeFX = new FadeFX();
			for (var iX:int = 0; iX < Width; iX++)
			{
				for (var iY:int = 0; iY < Height; iY++)
				{
					if (cellGrid[iX][iY] == null) continue;
					var winSpot:Boolean = false;
					for (var iZ:int = 0; iZ < cmb.points.length; iZ++)
					{
						if (cmb.points[iZ].x == iX && cmb.points[iZ].y == iY)
							winSpot = true;
					}
					if (!winSpot) winFader.addTarget(cellGrid[iX][iY]);
				}
			}
			winFader.fadeStop = 0.25;
			winFader.start(-0.0075,20);
		}
		
		// Checks to see if a player has won. Will return 0 if nobody has won, 1 if player one has won etc.
		public function CheckWin():WinCombo
		{
			var cmb:WinCombo = new WinCombo();
			
			var iX:int;
			for (iX = 0; iX < Width; iX++)
			{
				var iY:int;
				for (iY = 0; iY < Height; iY++)
				{
					var curP:int = Grid[iX][iY];
					if (curP == 0) continue;
					
					// Check right
					if (iX <= Width - 4)
					{
						if (Grid[iX][iY] == curP && Grid[iX+1][iY] == curP && Grid[iX+2][iY] == curP && Grid[iX+3][iY] == curP)
						{
							cmb.winner = curP;
							
							cmb.points[0].x = iX;
							cmb.points[0].y = iY;
							
							cmb.points[1].x = iX + 1;
							cmb.points[1].y = iY;
							
							cmb.points[2].x = iX + 2;
							cmb.points[2].y = iY;
							
							cmb.points[3].x = iX + 3;
							cmb.points[3].y = iY;
							
							return cmb;
						}
					}
					
					// Check down
					if (iY <= Height - 4)
					{
						if (Grid[iX][iY] == curP && Grid[iX][iY+1] == curP && Grid[iX][iY+2] == curP && Grid[iX][iY+3] == curP)
						{
							cmb.winner = curP;
							
							cmb.points[0].x = iX;
							cmb.points[0].y = iY;
							
							cmb.points[1].x = iX;
							cmb.points[1].y = iY + 1;
							
							cmb.points[2].x = iX;
							cmb.points[2].y = iY + 2;
							
							cmb.points[3].x = iX;
							cmb.points[3].y = iY + 3;
							
							return cmb;
						}
					}
					
					// Check right-down (diagnoally)
					if (iX <= Width - 4 && iY <= Height - 4)
					{
						if (Grid[iX][iY] == curP && Grid[iX+1][iY+1] == curP && Grid[iX+2][iY+2] == curP && Grid[iX+3][iY+3] == curP)
						{
							cmb.winner = curP;
							
							cmb.points[0].x = iX;
							cmb.points[0].y = iY;
							
							cmb.points[1].x = iX + 1;
							cmb.points[1].y = iY + 1;
							
							cmb.points[2].x = iX + 2;
							cmb.points[2].y = iY + 2;
							
							cmb.points[3].x = iX + 3;
							cmb.points[3].y = iY + 3;
							
							return cmb;
						}
					}
					
					// Check right-up (diagonally)
					if (iX <= Width - 4 && iY >= 4)
					{
						if (Grid[iX][iY] == curP && Grid[iX+1][iY-1] == curP && Grid[iX+2][iY-2] == curP && Grid[iX+3][iY-3] == curP)
						{
							cmb.winner = curP;
							
							cmb.points[0].x = iX;
							cmb.points[0].y = iY;
							
							cmb.points[1].x = iX + 1;
							cmb.points[1].y = iY - 1;
							
							cmb.points[2].x = iX + 2;
							cmb.points[2].y = iY - 2;
							
							cmb.points[3].x = iX + 3;
							cmb.points[3].y = iY - 3;
							
							return cmb;
						}
					}
				}
			}
			
			cmb.winner = 0;
			return cmb;
		}

		// The playing pieces
		var Grid:Array = new Array(Width);
		
		// Check to see if a move is valid
		function CheckValid(zX:int, zY:int):Boolean
		{
			// Check to see that the cell is in a valid area, if not, throw an error
			if (!(zX > Offsets[zY] - 1 && zX < Width - Offsets[zY])) throw new Error("Point Out of Bounds");
			
			// Check to see if its hugging the edge of the row
			if (zX == 0 || zX == Width - 1 || zY == 0 || zY == Height - 1) return true;

			// Iterators
			var iX:int;
			var iY:int;
			
			// Check to the right border
			var invalid:Boolean = false;
			for (iX = zX + 1; iX < Width - Offsets[zY]; iX++)
				if (Grid[iX][zY] == 0) invalid = true;
			if (!invalid) return true;

			// Check to the left border
			invalid = false;
			for (iX = zX - 1; iX > Offsets[zY] - 1; iX--)
				if (Grid[iX][zY] == 0) invalid = true;
			if (!invalid) return true;

			// Check to the top border
			invalid = false;
			for (iY = zY - 1; iY > Offsets[zX] - 1; iY--)
				if (Grid[zX][iY] == 0) invalid = true;
			if (!invalid) return true;

			// Check to the bottom border
			invalid = false;
			for (iY = zY + 1; iY < Height - Offsets[zX]; iY++)
				if (Grid[zX][iY] == 0) invalid = true;
			if (!invalid) return true;

			return false;
		}
	}
}
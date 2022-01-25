package de.peote.world.view;

import haxe.io.Bytes;
import haxe.io.BytesData;


import de.peote.view.PeoteView;
import de.peote.view.Param;
import de.peote.view.displaylist.DType;
import de.peote.view.displaylist.I_Displaylist;

import haxe.Timer;

/**
 * ...
 * @author Sylvio Sell
 */
class View implements I_View
{

	var peoteView:PeoteView;
	var startTime:Float;
	
	var center_x:Int;
	var center_y:Int;
	
	var yOffset:Int = 0;// 55;
	var xOffset:Int = 0;// 55;
	
	public function new(peoteView:PeoteView, startTime:Float) 
	{
		this.startTime = startTime;
		this.peoteView = peoteView;
	}
	
	public function init(max_t_size:Int, max_b_size:Int, max_l_size:Int, max_r_size:Int):Void
	{
		trace('View init: $max_t_size, $max_b_size, $max_l_size, $max_r_size');
		// -----------------------------------------------------
		// ---------------- PROGRAM SHADER ---------------------
		// -----------------------------------------------------
		//peoteView.setProgram(0, "assets/lyapunov_01.frag");
		
		// -----------------------------------------------------
		// ------------------- IMAGES --------------------------
		// -----------------------------------------------------
		peoteView.setImage(0, "assets/img/tileset.png", 512, 512);
		
		// -----------------------------------------------------
		// ---------------- DISPLAYLISTS -----------------------
		// -----------------------------------------------------
		peoteView.setDisplaylist( { displaylist:0, type:DType.ANIM|DType.ZINDEX|DType.RGBA,
			elements:65536, programs:1, segments:10,
			//x:100, y:70,
			//w:350, h:150,
			blend:0, z:0,
			renderBackground:true,
			r:0.1,g:0.5,b:0.8, a:0.8,
			enable:true
		});
		
		resize(max_t_size, max_b_size, max_l_size, max_r_size);
	}
	
	public function resize(t_size:Int, b_size:Int, l_size:Int, r_size:Int):Void
	{
		trace('VIEW  - resize: $t_size, $b_size, $l_size, $r_size ');
		peoteView.setDisplaylist( { displaylist:0,
			x: 0,
			y: 0,
			w: (l_size + r_size - 1) * 32 + 16,//  +111,
			h: (t_size + b_size - 1) * 32 + 16,//  +111, 
			xOffset: xOffset,
			yOffset: yOffset,
		});
		center_x = (l_size-1) * 32 + 8;
		center_y = (t_size-1) * 32 + 8;
	}
	
	public inline function addElement(elementNr:Int, x:Int, y:Int, graphicNr:Int, z:Int):Void
	{
		trace( 'View addElement - elementNr:$elementNr x:$x  y:$y graphicNr:$graphicNr z:$z');
		peoteView.setElement( { element:elementNr, displaylist:0,
			x:center_x + x * 32,
			y:center_y + y * 32,
			z: z,
			w:32, h:32,
			image:0,
			tile:graphicNr,
			time: Timer.stamp() - startTime // start time
		});
		
	}
	public function addElementAt(elementNr:Int, atElementNr:Int, graphicNr:Int, z:Int):Void
	{
		var param:Param = peoteView.getElement( { element:atElementNr, displaylist:0} );
		trace( 'View addElementAt - elementNr:$elementNr x:${param.x}  y:${param.y} graphicNr:$graphicNr z:$z');
		peoteView.setElement( { element:elementNr, displaylist:0,
			x:param.x,
			y:param.y,
			z: z,
			w:32, h:32,
			image:0,
			tile:graphicNr,
			time: Timer.stamp() - startTime // start time
		});
		
	}
	public function delElement(elementNr:Int):Void
	{
		//trace( 'delElement - elementNr:$elementNr' );
		peoteView.delElement({element:elementNr, displaylist:0} );
	}
	
	public function moveElementTo(elementNr:Int, toElementNr:Int, speed:Int):Void
	{
		var paramElement:Param = peoteView.getElement( { element:elementNr, displaylist:0 } );
		var param:Param = peoteView.getElement( { element:toElementNr, displaylist:0} );

		//if ( paramElement.time < Timer.stamp() - startTime + speed/100)
		//{
			trace( 'moveElementTo - elementNr:$elementNr toElementNr:$toElementNr x:${param.x}  y:${param.y}');
			peoteView.setElement( { element:elementNr, displaylist:0,
				time: Timer.stamp() - startTime, // start time
				z:1,
				end: {
					x:param.x,
					y:param.y,
					time: Timer.stamp() - startTime + speed/100
				}
			});
		//}
		/*else
		{
			trace("IS in MOVE");
			if (paramElement.x != param.x || paramElement.y != param.y)
			{
				
			}
		}*/
	}

	public function scrollTop():Void
	{
		yOffset += 32; center_y -= 32;
		peoteView.setDisplaylist( { displaylist:0,
			xOffset: xOffset,
			yOffset: yOffset,
		});
	}
	
	public function scrollBottom():Void
	{
		yOffset -= 32; center_y += 32;
		peoteView.setDisplaylist( { displaylist:0,
			xOffset: xOffset,
			yOffset: yOffset,
		});
	}
	
	public function scrollLeft():Void
	{
		xOffset += 32; center_x -= 32;
		peoteView.setDisplaylist( { displaylist:0,
			xOffset: xOffset,
			yOffset: yOffset,
		});
	}
	
	public function scrollRight():Void
	{
		xOffset -= 32; center_x += 32;
		peoteView.setDisplaylist( { displaylist:0,
			xOffset: xOffset,
			yOffset: yOffset,
		});
	}
	
	public function scrollDisplay():Void
	{
		var dl:I_Displaylist = peoteView.getDisplaylist( { displaylist:0 } );
		peoteView.setDisplaylist( { displaylist:0,
			xOffset: xOffset dl.xOffset,
			yOffset: yOffset dl.Offset,
		});
	}
	
	
	// TODO
	public function updateElement(elementNr:Int, xnew:Int, ynew:Int):Void
	{
		/*peoteView.setElement( { element:elementNr, displaylist:0,
			end: {
				x:200 + xnew * 32,
				y:200 + ynew * 32,
				time: Timer.stamp() - startTime + 5
			}
		});*/
		
	}
	
}
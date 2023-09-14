using Godot;
using System;

namespace GodotCore {
	namespace Menu {
		public partial class TestMenu : Node
		{

			[Export] public PageController pageController;

			#region Godot Functions
            
			public override void _UnhandledInput(InputEvent @event) {
				if(@event is InputEventKey eventKey) {
					if(eventKey.Pressed) {
						if(eventKey.Keycode == Key.F) {
                            pageController.TurnPageOn(PageType.Loading);
                        }
                        else if (eventKey.Keycode == Key.G) {
                            pageController.TurnPageOff(PageType.Loading);
                        }
                        else if (eventKey.Keycode == Key.H) {
                            pageController.TurnPageOff(PageType.Loading, PageType.Menu); // Crossfade
                        }
                        else if (eventKey.Keycode == Key.J) {
                            pageController.TurnPageOff(PageType.Loading, PageType.Menu, true); // Turn off the first completely, then turn on the other
                        }
                    }
				}
			}
            

			#endregion

		}
	}
}

using Godot;
using GodotCore.Menu;
using GodotCore.Scene;
namespace GodotCore {
    namespace Session {
        public partial class TestSession : Node
        {
            [Export] public SessionController sessionController;

            public override void _UnhandledInput(InputEvent @event) {
                if (@event is InputEventKey eventKey) {
                    if (eventKey.Pressed) {
                        if (eventKey.Keycode == Key.I) {
                            GD.Print(sessionController.fps);
                        }

                    }
                }
            }
        }
    }
}

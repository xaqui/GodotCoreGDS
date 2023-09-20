using Godot;
using GodotCore.Menu;

namespace GodotCore {
	namespace Scene {
		public partial class TestScene : Node
		{
            [Export] public SceneController sceneController;

            #region Godot Functions

            public override void _UnhandledInput(InputEvent @event) {
                if (@event is InputEventKey eventKey) {
                    if (eventKey.Pressed) {
                        if (eventKey.Keycode == Key.O) {
                            sceneController.Load(SceneType.Level2, (_scene) => {
                                GD.Print("Scene [" + _scene + "] loaded from Test script!");
                            }, false, PageType.Loading);
                        }
                        else if (eventKey.Keycode == Key.L) {
                            sceneController.Load(SceneType.Level1, (_scene) => {
                                GD.Print("Scene [" + _scene + "] loaded from Test script!");
                            });
                        }
                       
                    }
                }
            }

            #endregion
        }
    }
}

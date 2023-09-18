using Godot;

namespace GodotCore {
    namespace Data {
        public partial class TestDataPersistance : Node{
            [Export] DataPersistanceController dataPersistanceController;

            public override void _Ready() {
                dataPersistanceController.LoadGame();
            }

            public override void _UnhandledInput(InputEvent @event) {
                if (@event is InputEventKey eventKey) {
                    if (eventKey.Pressed) {
                        if (eventKey.Keycode == Key.S) {
                            dataPersistanceController.SaveGame();
                        }
                        else if (eventKey.Keycode == Key.L) {
                            dataPersistanceController.LoadGame();
                        }
                    }
                }
            }
        }

    }
}

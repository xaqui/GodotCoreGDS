using Godot;
namespace GodotCore {
	namespace Audio {
		public partial class TestAudio : Node{
			[Export] public AudioController audioController;
            public override void _UnhandledInput(InputEvent @event) {
                if (@event is InputEventKey eventKey) {
                    if (eventKey.Pressed) {
                        if (eventKey.Keycode == Key.T) {
                            audioController.PlayAudio(AudioType.ST_01, true);
                        }
                        else if (eventKey.Keycode == Key.G) {
                            audioController.StopAudio(AudioType.ST_01, true);
                        }
                        else if (eventKey.Keycode == Key.B) {
                            audioController.RestartAudio(AudioType.ST_01, true);
                        }
                        else if (eventKey.Keycode == Key.Y) {
                            audioController.PlayAudio(AudioType.SFX_01);
                        }
                        else if (eventKey.Keycode == Key.H) {
                            audioController.StopAudio(AudioType.SFX_01);
                        }
                        else if (eventKey.Keycode == Key.N) {
                            audioController.RestartAudio(AudioType.SFX_01);
                        }
                    }
                }
            }
        }
	}
}

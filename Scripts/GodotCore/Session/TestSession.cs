using Godot;
using GodotCore.Menu;
using GodotCore.Scene;
using System;

public partial class TestSession : Node
{
    [Export] public SessionController sessionController;
    // Called when the node enters the scene tree for the first time.
    public override void _Ready()
	{
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
	}
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

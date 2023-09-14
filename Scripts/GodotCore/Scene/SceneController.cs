using Godot;
using System;

public partial class SceneController : Node
{

    [Export] bool debug;

    #region Godot Functions

	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
	}
    #endregion

    #region Public Functions

    #endregion

    #region Private Functions
    private void Log(string _msg) {
        if (!debug) return;
        GD.Print("[SceneController]: " + _msg);
    }
    private void LogWarning(string _msg) {
        if (!debug) return;
        GD.PushWarning("[SceneController]: " + _msg);
    }
    #endregion
}

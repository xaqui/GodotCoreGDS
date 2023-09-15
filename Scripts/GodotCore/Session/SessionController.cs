using Godot;
using System;

public partial class SessionController : Node
{
    [Export] private bool debug;
    public SessionController Instance;

    private long m_SessionStartTime; // in seconds
    private double m_FPS;

    public long sessionStartTime {
        get {
            return m_SessionStartTime;
        }
    }

    public double fps {
        get {
            return m_FPS;
        }
    }

    #region Godot Functions
    public override void _Ready()
	{
        Configure();
	}

	public override void _Process(double delta)
	{
        m_FPS = Engine.GetFramesPerSecond();
    }

    #endregion

    #region Public Functions
    #endregion

    #region Private Functions

    private void Configure() {
        if (Instance == null) {
            Instance = this;
            StartSession();
        }
        else {
            QueueFree();
        }
    }
    private void StartSession() {
        m_SessionStartTime = EpochSeconds();
        DateTime start = new DateTime(1970,1,1,0,0,0,DateTimeKind.Utc);
        Log("Started Session. Session Start time : " + start.AddSeconds(m_SessionStartTime).ToLocalTime());

    }

    private long EpochSeconds() {
        var _epoch = System.DateTimeOffset.UtcNow;
        return _epoch.ToUnixTimeSeconds();
    }

    private void Log(string _msg) {
        if (!debug) return;
        GD.Print("[SessionController]: " + _msg);
    }
    private void LogWarning(string _msg) {
        if (!debug) return;
        GD.PushWarning("[SessionController]: " + _msg);
    }
    #endregion


}

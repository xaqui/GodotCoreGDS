using Godot;

[Tool]
[GlobalClass]
public partial class AudioTrack : AudioStreamPlayer {
    [Export]
    public AudioObject[] audio;
}
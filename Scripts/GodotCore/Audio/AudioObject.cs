using Godot;
using GodotCore.Audio;

[Tool]
[GlobalClass]
public partial class AudioObject : Resource {
    [Export]
    public AudioType type;
    [Export]
    public AudioStream audioStream;
}
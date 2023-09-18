using Godot;
using GodotCore.Data;
public partial class Counter : Node, IDataPersistance
{
	[Export] private Label lCounter;
	private int counter =-1;

	public override void _Process(double delta)
	{
		lCounter.Text = counter.ToString();
	}
    public override void _UnhandledInput(InputEvent @event) {
        if (@event is InputEventKey eventKey) {
            if (eventKey.Pressed) {
                if (eventKey.Keycode == Key.U) {
                    counter+=1;
                }
            }
        }
    }


    #region Data Persistance Interface
    public void LoadData(GameData data) {
		counter = data.counter;
        GD.Print("Test");
    }

    public void SaveData(GameData data) {
		data.counter = counter;
    }
    #endregion
}

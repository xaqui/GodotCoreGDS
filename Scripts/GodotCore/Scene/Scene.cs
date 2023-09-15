using Godot;
using System;

namespace GodotCore {
	namespace Scene {
		public partial class Scene : Node{
            
            public static event Action<Node> _onSceneLoaded;
            public override void _Ready(){
                _onSceneLoaded?.Invoke(this);
            }

		}    
    }
}

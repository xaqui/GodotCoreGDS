using Godot;
using GodotCore.Menu;
using GodotCore.Scene;
using System.Threading.Tasks;

public partial class SceneController : Node
{
    #region Scene Paths
    // ----------- Hardcoded Values ------------ //
    const string LEVEL1_NAME = "Level1";
    const string LEVEL2_NAME = "Level2";

    const string LEVEL1_PATH = "res://Scenes/"+LEVEL1_NAME+".tscn";
    const string LEVEL2_PATH = "res://Scenes/"+LEVEL2_NAME+".tscn";

    // ----------------------------------------- //
    #endregion

    public delegate void SceneLoadDelegate(SceneType _type); // Callback signature for the function that will be called back

    public static SceneController Instance;

    [Export] public bool debug;

    [Export] private PageController menu;
    private SceneType m_TargetScene;
    private PageType m_LoadingPage;
    private SceneLoadDelegate m_SceneLoadDelegate;
    private bool m_SceneIsLoading;


    private string currentSceneName {
        get {
            return GetTree().CurrentScene.Name;
        }
    }

    #region Godot Functions

    // Called when the node enters the scene tree for the first time.
    public override void _Ready()
	{
        if (Instance == null) {
            Instance = this;
        }
        else {
            QueueFree();
        }
        Scene._onSceneLoaded += OnSceneLoaded;
        CheckPageControllerIntegrity();
        Log(currentSceneName);
	}

    #endregion

    #region Public Functions
    public void Load(SceneType _scene,
                                SceneLoadDelegate _sceneLoadDelegate = null,
                                bool _reload = false,
                                PageType _loadingPage = PageType.None) {
        if (_loadingPage != PageType.None && menu == null) {
            LogWarning("Error loading page: invalid set of parameters - Trying to set up a loading screen but Menu is invalid.");
            return;
        }

        if (!SceneCanBeLoaded(_scene, _reload)) {
            LogWarning("Tried to load scene [" + _scene + "] but it cannot be loaded.");
            return;
        }
        // Initialization
        m_SceneIsLoading = true;
        m_TargetScene = _scene;
        m_LoadingPage = _loadingPage;
        m_SceneLoadDelegate = _sceneLoadDelegate;

        WaitForLoadingPageAsync().ContinueWith((t) => {},
            TaskScheduler.FromCurrentSynchronizationContext());

    }

    #endregion

    #region Private Functions

    private void CheckPageControllerIntegrity() {
        if(menu == null) {
            LogWarning("Page Controller reference is missing.");
        }
    }
    private async void OnSceneLoaded(Node _scene) {
        if (m_TargetScene == SceneType.None) return; // Scene was loaded by a System other than SceneController, don't respond to that
        
        SceneType _sceneType = NameToSceneType(_scene.Name);
        if (m_TargetScene != _sceneType) return;

        if (m_SceneLoadDelegate != null) {
            try {
                m_SceneLoadDelegate(_sceneType);
            }
            catch (System.Exception) {
                LogWarning("Unable to respond with sceneLoadDelegate after scene [" + _sceneType + "] loaded.");
            }
        }

        if (m_LoadingPage != PageType.None) {
            await Task.Delay(1000); // Hardcoded wait for fade-out animation of loading page
            menu.TurnPageOff(m_LoadingPage);
        }

        m_SceneIsLoading = false;
    }

    async Task WaitForLoadingPageAsync() {
        if (m_LoadingPage != PageType.None) {
            menu.TurnPageOn(m_LoadingPage);
            while (!menu.PageIsOn(m_LoadingPage)) {
                await Task.Delay(1000);
            }
        }
        string _targetScenePath = SceneNameToPath(SceneTypeToName(m_TargetScene));
        CallDeferred("DeferredGoToScene", _targetScenePath);
    }

    private void DeferredGoToScene(string path) {
        GetTree().CurrentScene.Free();

        ResourceLoader.LoadThreadedRequest(path);
        WaitForSceneLoadAsync(path).ContinueWith((t) => { },
            TaskScheduler.FromCurrentSynchronizationContext());
    }

    async Task WaitForSceneLoadAsync(string path) {
        Godot.Collections.Array progress = new Godot.Collections.Array();
        while(ResourceLoader.LoadThreadedGetStatus(path, progress) == ResourceLoader.ThreadLoadStatus.InProgress) {
            Log("Loading... "+ progress[0]);
            await Task.Delay(1);
        }
        ResourceLoader.ThreadLoadStatus finishStatus = ResourceLoader.LoadThreadedGetStatus(path);

        if (finishStatus.Equals(ResourceLoader.ThreadLoadStatus.InvalidResource)) {
            LogWarning("Scene: " + path + " : INVALID RESOURCE ");
            return;
        } else if (finishStatus.Equals(ResourceLoader.ThreadLoadStatus.Failed)) {
            LogWarning("Scene: " + path + " : Loading FAILED ");
            return;
        }
        Log("Scene " + path + " : Resource loaded successfully!");
        PackedScene loadedScene = ResourceLoader.LoadThreadedGet(path) as PackedScene;
        if (loadedScene == null) return;

        var instance = loadedScene.Instantiate();

        GetTree().Root.AddChild(instance, true);
        GetTree().CurrentScene = instance; //  To make it compatible with the SceneTree.change_scene() API.

    }

    private bool SceneCanBeLoaded(SceneType _scene, bool _reload) {
        string _targetSceneName = SceneTypeToName(_scene);
        if (currentSceneName == _targetSceneName && !_reload) {
            Log("You are trying to load a scene [" + _scene + "] which is already active. This specific scene is set to NOT be reloaded.");
            return false;
        }
        else if (_targetSceneName == string.Empty) {
            LogWarning("The scene you are trying to load [" + _scene + "] is not valid.");
            return false;
        }
        else if (m_SceneIsLoading) {
            LogWarning("Unable to load scene [" + _scene + "]. Another scene [" + m_TargetScene + "] is already loading.");
            return false;
        }
        return true;
    }

    private string SceneNameToPath(string _sceneName) {
        switch (_sceneName) {
            case LEVEL1_NAME: return LEVEL1_PATH;
            case LEVEL2_NAME: return LEVEL2_PATH;
            default:
                LogWarning("Node named [" + _sceneName + "] does not contain a path for a valid scene.");
                return string.Empty;
        } 
    }

    private SceneType NameToSceneType(string _sceneName) {
        switch (_sceneName) {
            case LEVEL1_NAME: return SceneType.Level1;
            case LEVEL2_NAME: return SceneType.Level2;
                default:
                LogWarning("Node named [" + _sceneName + "] does not contain a type for a valid scene.");
                return SceneType.None;
        }
    }

    private string SceneTypeToName(SceneType _scene) {
        switch (_scene) {
            case SceneType.Level1: return LEVEL1_NAME;
            case SceneType.Level2: return LEVEL2_NAME;
            default:
                LogWarning("Scene [" + _scene + "] does not contain a name for a valid scene.");
                return string.Empty;
        }
    }

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

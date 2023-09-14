using Godot;
using System;
using System.Threading.Tasks;

namespace GodotCore {
    namespace Menu {
        public partial class Page : Control
        {
            public static readonly string FLAG_ON = "On";
            public static readonly string FLAG_OFF = "Off";
            public static readonly string FLAG_NONE = "None";

            [Export] public bool debug;
            [Export] public PageType type;
            [Export] public bool useAnimation;
            public string targetState { get; private set; }

            private AnimationPlayer m_AnimationPlayer;
            private bool m_IsOn;

            public bool isOn {
                get {
                    return m_IsOn;
                }
                private set {
                    m_IsOn = value;
                }
            }


            #region Godot Functions
            public override void _Ready() {
                CheckAnimatorIntegrity();
            }
            #endregion

            #region Public Functions 
            /// <summary>
            /// Plays an animation to turn ON or OFF this Page, then awaits for the animation to finish, 
            /// and then turns ON or OFF the *visibility* of the Node accordingly.
            /// Requires that an AnimationPlayer reference with the corresponding animations.
            /// </summary>
            /// <param name="_on">If true, we're animating the Page turning ON, else we're animating turning OFF</param>
            public void Animate(bool _on) {
                if (useAnimation) {
                    if (_on) {
                        m_AnimationPlayer.Play("fadeIn");

                    } else {
                        m_AnimationPlayer.Play("fadeOut");
                    }
                    
                    WaitForAnimationEndAsync(_on).ContinueWith((t) => {
                        Log("Animation finished");
                    }, TaskScheduler.FromCurrentSynchronizationContext());
                }
                else {
                    if (!_on) {
                        Visible = false;
                        isOn = false;
                    }
                    else {
                        isOn = true;
                    }
                }
            }
            #endregion

            #region Private Functions
            async Task<bool> WaitForAnimationEndAsync(bool _on) {
                var isPlaying = true;
                while (isPlaying) {
                    isPlaying = m_AnimationPlayer.CurrentAnimation == String.Empty;
                    await Task.Delay(1000);
                }
                targetState = FLAG_NONE;

                Log("Page [" + type + "] finished transitioning to " + (_on ? "on" : "off"));

                if (!_on) {
                    isOn = false;
                    Visible = false;
                }
                else {
                    isOn = true;
                }
                return true;
            }
            
            private void CheckAnimatorIntegrity() {
                if (useAnimation) {
                    foreach (Node child in GetChildren()) {
                        if(child.GetType() == typeof(AnimationPlayer)) {
                            m_AnimationPlayer = (AnimationPlayer)child;
                        }
                    }

                    if (m_AnimationPlayer == null) {
                        LogWarning("Using animation for page [" + type + "] but Animator component is missing.");
                    }
                }
            }

            private void Log(string _msg) {
                if (!debug) return;
                GD.Print("[Page]: " + _msg);
            }
            private void LogWarning(string _msg) {
                if (!debug) return;
                GD.PushWarning("[Page]: " + _msg);
            }

            #endregion

        }
    }
}

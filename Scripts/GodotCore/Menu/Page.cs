using Godot;
using System;

namespace GodotCore {
    namespace Menu {
        public partial class Page : Node2D
        {
            public static readonly string FLAG_ON = "On";
            public static readonly string FLAG_OFF = "Off";
            public static readonly string FLAG_NONE = "None";

            [Export] public bool debug;
            [Export] public PageType type;
            [Export] public bool useAnimation;
            public string targetState { get; private set; }

            //private Animator m_Animator;
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


            #region Unity Functions
            private void OnEnable() {
                CheckAnimatorIntegrity();
            }
            #endregion

            #region Public Functions 
            /// <summary>
            /// Plays an animation to turn ON or OFF this Page, then awaits for the animation to finish, 
            /// and then turns ON or OFF the gameObject accordingly.
            /// Requires that an Animator component with the corresponding animations and a Bool parameter "on".
            /// </summary>
            /// <param name="_on">If true, we're animating the Page turning ON, else we're animating turning OFF</param>
            public void Animate(bool _on) {
                if (useAnimation) {
                    m_AnimationPlayer.Set("on", true);
                    //m_Animator.SetBool("on", _on);
                    /*
                    StopCoroutine("AwaitAnimation");
                    StartCoroutine("AwaitAnimation", _on);*/
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
            /*
            private IEnumerator AwaitAnimation(bool _on) {
                targetState = _on ? FLAG_ON : FLAG_OFF;

                // Wait for the animator to reach target state
                while (!m_Animator.GetCurrentAnimatorStateInfo(0).IsName(targetState)) {
                    yield return null;
                }

                // Wait for the animator to finish animating
                while (m_Animator.GetCurrentAnimatorStateInfo(0).normalizedTime < 1) {
                    yield return null;
                }

                targetState = FLAG_NONE;

                Log("Page [" + type + "] finished transitioning to " + (_on ? "on" : "off"));

                if (!_on) {
                    isOn = false;
                    gameObject.SetActive(false);
                }
                else {
                    isOn = true;
                }

            }
            */
            private void CheckAnimatorIntegrity() {
                if (useAnimation) {
                    //m_Animator = GetComponent<Animator>();
                    
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
                GD.Print("{ WARNING } [Page]: " + _msg);
            }

            #endregion*/

        }
    }
}

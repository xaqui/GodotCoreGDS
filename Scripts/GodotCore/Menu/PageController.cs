using Godot;
using System.Collections;
using System.Threading.Tasks;

namespace GodotCore {
	namespace Menu {
        public partial class PageController : Node {

            public static PageController Instance;

            [Export] public bool debug;
            [Export] public PageType entryPage;
            [Export] public Page[] pages;

            private Hashtable m_Pages; // Relation between PageTypes and Pages

            #region Godot Functions
            public override void _Ready() {
                if (Instance == null) {
                    Instance = this;
                    m_Pages = new Hashtable();
                    RegisterAllPages();
                    if (entryPage != PageType.None) {
                        TurnPageOn(entryPage);
                    }
                } else {
                    QueueFree();
                }
            }
            #endregion

            #region Public Functions

            public void TurnPageOn(PageType _type) {
                if (_type == PageType.None) return;
                if (!PageExists(_type)) {
                    LogWarning("Trying to turn on page not registered: " + _type);
                    return;
                }
                Page _page = GetPage(_type);
                _page.Visible = true;
                _page.Animate(true);
                Log("Turned Page on: " + _type);
            }

            /// <summary>
            /// Turns a Page off.
            /// If another Page is provided, that one will be turned on after turning the first off.
            /// </summary>
            /// <param name="_off">The page to turn off</param>
            /// <param name="_on">(optional) The page to turn on</param>
            /// <param name="_waitForExit">(optional) Wether it should wait for the first page to be completely off before starting to turn on the next one.</param>
            public void TurnPageOff(PageType _off, PageType _on = PageType.None, bool _waitForExit = false) {
                if (_off == PageType.None) return;
                if (!PageExists(_off)) {
                    LogWarning("Trying to turn off page not registered: " + _off);
                    return;
                }
                Page _offPage = GetPage(_off);
                if (_offPage.Visible) {
                    _offPage.Animate(false);
                }

                if (_on != PageType.None) {
                    if (_waitForExit) {
                        Page _onPage = GetPage(_on);
                        WaitForPageExitAsync(_onPage, _offPage).ContinueWith((t) => {
                            Log("Page exit finished. Went from "+_offPage.type + " to "+ _onPage.type);
                        },TaskScheduler.FromCurrentSynchronizationContext());
                    }
                    else {
                        TurnPageOn(_on);
                    }
                }
            }

            public bool PageIsOn(PageType _type) {
                if (!PageExists(_type)) {
                    LogWarning("You are trying to detect if a page is on [" + _type + "], but it has not been registered.");
                    return false;
                }

                return GetPage(_type).isOn;
            }
            #endregion

            #region Private Functions
            /// <summary>Waits for the _off page to be finished turning off before turning on the _on page</summary>
            async Task<bool> WaitForPageExitAsync(Page _on, Page _off) {
                var exited = false;
                while (!exited) {
                    exited = _off.targetState == Page.FLAG_NONE; 
                    await Task.Delay(1000);
                }
                TurnPageOn(_on.type);
                return exited;
            }

            private void RegisterAllPages() {
                foreach (Page page in pages) {
                    RegisterPage(page);
                }
            }

            private void RegisterPage(Page _page) {
                if (PageExists(_page.type)) {
                    LogWarning("Trying to register a page [" + _page.type + "] that has already been registered: " + _page.Name);
                    return;
                }
                m_Pages.Add(_page.type, _page);
                Log("Registered new page successfully: " + _page.type);
            }

            private Page GetPage(PageType _type) {
                if (!PageExists(_type)) {
                    LogWarning("Trying to get a page that has not been registered: " + _type);
                    return null;
                }
                return (Page) m_Pages[_type];
            }

            private bool PageExists(PageType _type) {
                return m_Pages.ContainsKey(_type);
            }
            private void Log(string _msg) {
                if (!debug) return;
                GD.Print("[PageController]: " + _msg);
            }
            private void LogWarning(string _msg) {
                if (!debug) return;
                GD.PushWarning("[PageController]: " + _msg);
            }

            #endregion

        }

    }
}

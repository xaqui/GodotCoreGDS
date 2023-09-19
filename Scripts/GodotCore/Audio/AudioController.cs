using Godot;
using System.Collections;
using System.Threading.Tasks;

namespace GodotCore {
	namespace Audio {
        [Tool]
        public partial class AudioController : Node{
            public static AudioController Instance;

            [Export] private bool debug;


            [Export] public AudioTrack[] tracks;

            private Hashtable m_AudioTable; // relationship between audio types (key) and audio tracks (value)
            private Hashtable m_JobTable; // relationship between audio types (key) and audio jobs (value) (Task)


            private class AudioJob {
                public AudioAction action;
                public AudioType type;
                public bool fade;
                public int delay;

                public AudioJob(AudioAction _action, AudioType _type, bool _fade, int _delay) {
                    action = _action;
                    type = _type;
                    fade = _fade;
                    delay = _delay;
                }
            }

            private enum AudioAction {
                START,
                STOP,
                RESTART
            }

            #region Godot Functions
            public override void _Ready(){
                if(Instance == null) {
                    Configure();
                }
	        }
            #endregion

            #region Public Functions
            public void PlayAudio(AudioType _type, bool _fade = false, int delayTimeInSeconds = 0) {
                AddJob(new AudioJob(AudioAction.START, _type, _fade, delayTimeInSeconds));
            }
            public void StopAudio(AudioType _type, bool _fade = false, int delayTimeInSeconds = 0) {
                AddJob(new AudioJob(AudioAction.STOP, _type, _fade, delayTimeInSeconds));
            }
            public void RestartAudio(AudioType _type, bool _fade = false, int delayTimeInSeconds = 0) {
                AddJob(new AudioJob(AudioAction.RESTART, _type, _fade, delayTimeInSeconds));
            }
            #endregion

            #region Private Functions
            private void Configure() {
                Instance = this;
                m_AudioTable = new Hashtable();
                m_JobTable = new Hashtable();
                GenerateAudioTable();
            }
            /*
            private void CleanUp() {
                if (m_JobTable != null) {
                    foreach (DictionaryEntry _entry in m_JobTable) {
                        Task _job = (Task) _entry.Value;
                        _job.Dispose();
                    }
                }
            }*/
            private void GenerateAudioTable() {
                foreach (AudioTrack track in tracks) {
                    foreach (AudioObject obj in track.audio) {
                        // do not duplicate keys
                        if (m_AudioTable.ContainsKey(obj.type)) {
                            LogWarning("Trying to register the same AudioType twice: " + obj.type);
                        }
                        else {
                            m_AudioTable.Add(obj.type, track);
                            Log("Registering audio  [" + obj.type + "] Success");
                        }
                    }
                }
            }

            private async Task RunAudioJob(AudioJob _job) {
                await Task.Delay(_job.delay);

                AudioTrack _track = (AudioTrack) m_AudioTable[_job.type];
                
                switch (_job.action) {
                    case AudioAction.START:
                        _track.Stream = GetAudioStreamFromAudioTrack(_job.type, _track);
                        _track.Play();
                        break;
                    case AudioAction.STOP:
                        if (!_job.fade) {
                            _track.Stop();
                        }
                        break;
                    case AudioAction.RESTART:
                        _track.Stop();
                        _track.Play();
                        break;
                }


                if (_job.fade) {
                    float _initialValue = _job.action == AudioAction.START || _job.action == AudioAction.RESTART ? -80.0f : 0.0f;
                    float _targetValue = _initialValue == -80.0f ? 0 : -80;
                    float durationInSeconds = 2.0f;
                    float _timer = 0.0f;
                    while (_timer <= durationInSeconds) {
                        _track.VolumeDb = Mathf.Lerp(_initialValue, _targetValue, _timer / durationInSeconds);
                        _timer += (float)GetProcessDeltaTime();
                        await Task.Delay(1);
                    }
                    if (_job.action == AudioAction.STOP) {
                        _track.Stop();
                    }
                }

                m_JobTable.Remove(_job.type);
                Log("Job Count: " + m_JobTable.Count);
            }

            private void AddJob(AudioJob _job) {
                // remove conflicting jobs
                RemoveConflictingJobs(_job.type);

                // start job
                Task jobRunner = RunAudioJob(_job);
                m_JobTable.Add(_job.type, jobRunner);
                Log("Starting job on [" + _job.type + "] with the operation: " + _job.action);
            }

            private void RemoveJob(AudioType _type) {
                if (!m_JobTable.ContainsKey(_type)) {
                    LogWarning("Trying to stop a Job [" + _type + "] that is not running");
                    return;
                }

                Task runningJob = (Task) m_JobTable[_type];
                m_JobTable.Remove(_type);
                Log("Removed job of type "+ _type);
            }

            private void RemoveConflictingJobs(AudioType _type) {
                // Same audio type
                if (m_JobTable.ContainsKey(_type)) {
                    Log("Removed conflicting job " + _type + " - reason: same audio type");
                    RemoveJob(_type);
                }
                // Same audio source
                AudioType _conflictedAudio = AudioType.None;
                foreach (DictionaryEntry _entry in m_JobTable) {
                    AudioType _audioType = (AudioType) _entry.Key;
                    AudioTrack _audioTrackInUse = (AudioTrack) m_AudioTable[_audioType];
                    AudioTrack _audioTrackNeeded = (AudioTrack) m_AudioTable[_type];
                    if (_audioTrackNeeded == _audioTrackInUse) {
                        // We have a conflict
                        _conflictedAudio |= _audioType;
                    }
                }
                if (_conflictedAudio != AudioType.None) {
                    Log("Removed conflicting job " + _type + " - reason: same audio source");
                    RemoveJob(_conflictedAudio);
                }
            }

            private AudioStream GetAudioStreamFromAudioTrack(AudioType _type, AudioTrack _track) {
                foreach (AudioObject _obj in _track.audio) {
                    if (_obj.type == _type) {

                        return _obj.audioStream;
                    }
                }
                return null;
            }


            private void Log(string _msg) {
                if (!debug) return;
                GD.Print("[AudioController]: " + _msg);
            }
            private void LogWarning(string _msg) {
                if (!debug) return;
                GD.PushWarning("[AudioController]: " + _msg);
            }
            #endregion
        }
	}
}

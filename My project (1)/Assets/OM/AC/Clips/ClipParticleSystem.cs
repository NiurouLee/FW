using UnityEngine;
#if UNITY_EDITOR
using UnityEditor;
#endif

namespace OM.AC.Demos
{
    [System.Serializable]
    [ACClipCreate("Custom/Particle System", "Particle System")]
    public class ClipParticleSystem : ACClip
    {
        [SerializeField,CheckForNull] private Transform target;

     
        protected override void OnEnter()
        {
            base.OnEnter();
        }

        protected override void OnUpdate(ACEvaluateState state, float timelineTime, float clipTime, float normalizedClipTime, bool previewMode)
        {
            if(state != ACEvaluateState.Running) return;
            if (IsValid())
            {
                target.gameObject.SetActive(true);
                var psList = target.GetComponentsInChildren<ParticleSystem>();
                foreach (var ps in psList) 
                {
                    ps.Simulate(clipTime);
#if UNITY_EDITOR
                    SceneView.RepaintAll();
#endif
                }
            }
        }

        public override void OnPreviewModeChanged(bool previewMode)
        {
            
        }

        public override bool CanBePlayedInPreviewMode()
        {
            return false;
        }

        public override bool IsValid()
        {
            return target != null;
        }

        public override Component GetTarget()
        {
            return target;
        }

        public override void SetTarget(GameObject newTarget)
        {
            target = newTarget.transform;
        }
    }
}
using NFramework.Core.ILiveing;
using NFramework.Module.EntityModule;
using NFramework.Module.Event;

namespace NFramework.Module.Combat
{


    public enum AnimationType
    {
        Idle,
        Walk,
        Attack,
        Dead,
    }

    public class AnimationComponent : Entity, IAwakeSystem
    {
        public AnimationType currentType;

        public void PlayAnimation(AnimationType inType, float speed = 1f)
        {
            currentType = inType;
            bool isLoop = currentType == AnimationType.Idle || currentType == AnimationType.Walk ? true : false;
            Framework.Instance.GetModule<EventD>().D.Publish(ref new SyncAnimation(GetParent<Combat>().id, inType, speed, isLoop));
        }

        public void Awake()
        {

        }
    }
}

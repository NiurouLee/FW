using NFramework.Core.ILiveing;
using NFramework.Module.EntityModule;
using NFramework.Module.TimerModule;

namespace NFramework.Module.Combat
{
    public class StatusLifeTimeComponent : Entity, IAwakeSystem, IDestroySystem
    {
        public long lifeTimer;

        public void Awake()
        {
            long lifeTime = GetParent<StatusAbility>().duration;
            lifeTimer = Framework.Instance.GetModule<TimerModule>().NewOnceTimer(lifeTime, GetParent<StatusAbility>().EndAbility);
        }

        public void Destroy()
        {
            Framework.Instance.GetModule<TimerModule>().RemoveTimer(lifeTimer);
        }

    }
}
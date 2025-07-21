using NFramework.Module.EntityModule;
using NFramework.Module.TimerModule;
using NFramework.Core.ILiveing;

namespace NFramework.Module.Combat
{
    public class StatusLifeTimeComponent : Entity, IAwakeSystem, IDestroySystem
    {
        public long LifeTimer;
        public void Awake()
        {
            long lifeTime = GetParent<StatusAbility>().duration;
            LifeTimer = Framework.Instance.GetModule<TimerModule>().NewOnceTimer(lifeTime, GetParent<StatusAbility>().EndAbility);
        }

        public void Destroy()
        {
            Framework.Instance.GetModule<TimerModule>().RemoveTimer(LifeTimer);
        }

    }
}
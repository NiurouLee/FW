
using System;
using NFramework.Core.ILiveing;
using NFramework.Module.EntityModule;
using NFramework.Module.TimerModule;

namespace NFramework.Module.Combat
{
    public partial class ItemAbility : Entity, IAbility, IAwakeSystem<>
    {
        public bool Enable { get; set; }
        public Combat Owner => GetParent<Combat>();
        public ItemConfigObject itemConfigObject;
        private List<StatusAbility> _statusList = new List<StatusAbility>();

        public void ActivateAbility()
        {
            throw new NotImplementedException();
        }

        public void EndAbility()
        {
            throw new NotImplementedException();
        }

        public Entity CreateExecution()
        {
            throw new NotImplementedException();
        }
    }
}

using NFramework.Core.ILiveing;
using UnityEngine;
namespace NFramework.Module.Combat
{
    public class AbilityEffectActionTriggerComponent : Entity, IAwake
    {
        public Effect Effect => GetParent<AbilityEffect>().effect;
        public ActionPointType ActionPointType => Effect.ActtionPointType;
        public Combat Owner => GetParent<AbilityEffect>().Owner;

        public override void Awake()
        {
            Owner.ListenActionPoint(ActionPointType, OnActionPointTrigger);
        }

        public override void OnDestroy()
        {
            Owner.UnListenActionPoint(ActionPointType, OnActionPointTrigger);
        }

        private void OnActionPointTrigger(Entity action)
        {
            GetParent<AblilityEffect>().TryAssignEffectToOwner();
        }

    }
}
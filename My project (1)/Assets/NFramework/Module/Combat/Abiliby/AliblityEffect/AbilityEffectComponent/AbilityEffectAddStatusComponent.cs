
using NFramework.Core.ILiveing;

namespace NFramework.Module.Combat
{
    public class AbilityEffectAddStatusComponent : Entity
    {
        public Combat Owner => GetParent<AbilityEffect>().Owner;

        public void OnAssignEffect(EffectAssignAction effectAssignAction)
        {
            if (this.Owner.addStatusActionAbility.TryMakeAction(out var action))
            {
                effectAssignAction.FillDataToAction(action);
                action.sourceAbility = effectAssignAction.sourceAbility;
                action.ApplyAddStatus();
            }
        }
    }
}

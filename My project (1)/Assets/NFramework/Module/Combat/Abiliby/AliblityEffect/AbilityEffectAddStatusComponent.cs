using System;
using System.Collections.Generic;
using NFramework.Module.EntityModule;

namespace NFramework.Module.Combat
{
    public class AbilityEffectAddStatusComponent : Entity
    {
        public Combat Owner => this.GetParent<AbilityEffect>().Owner;

        public void OnAssignEffect(EffectAssignAction effectAssignAction)
        {
            if (Owner.addStatusActionAbility.TryMakeaction(out var action))
            {
            }
        }

    }
}
using NFramework.Core.ILiveing;
using NFramework.Module.EntityModule;
using UnityEngine;

namespace NFramework.Module.Combat
{
    public class AbilityEffectDamageComponent : Entity
    {
        public DamageEffect DamageEffect => GetParent<AbilityEffect>().effect as DamageEffect;
        public string DamageValueFormula => DamageEffect.DamageValueFormula;
        public Combat Owner => GetParent<AbilityEffect>().Owner;
        public int GetDamageValue()
        {

            return Mathf.CeilToInt(Expressionu.Evaluate<float>(DamageValueFormula, GetParent<AbilityEffect>().GetParamsDict()));
        }

        public void OnAssignEffect(EffectAssignAction effectAssigAction)
        {
            if (Owner.damageActionAbility.TryMakeAction(out var damageAction))
            {
                effectAssigAction.FillDataToAction(damageAction);
                damageAction.damageSource = DamageSource.Skill;
                damageAction.ApplyDamage();
            }
        }
    }
}
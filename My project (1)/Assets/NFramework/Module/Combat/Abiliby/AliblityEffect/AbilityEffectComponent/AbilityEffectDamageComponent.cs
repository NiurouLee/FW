using NFramework.Core.ILiveing;
using UnityEngine;
namespace NFramework.Module.Combat
{
    public class AbilityEffectDamageComponent : Entity
    {
        public DamageEffect DamageEffect => GetParent<AbilityEffect>().effect as DamageEffect;
        public string DamageValueFormula => DamageEffect.DamageValueFormula;
        public Combat Owner => Getparent<AbilityEffect>().Owner;
        public int GetDamageValue()
        {

            return Mathf.CeilToInt(ExpressionUtili.Evaluate<float>(DamageValueFormula, GetParent<AbilityEffect>().GetParamsDict()));
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
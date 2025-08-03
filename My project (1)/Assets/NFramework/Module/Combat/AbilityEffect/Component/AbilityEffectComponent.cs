using System.Collections.Generic;
using DG.Tweening.Core;
using NFramework.Core.ILiveing;
using NFramework.Module.EntityModule;

namespace NFramework.Module.Combat
{
    public class AbilityEffectComponent : Entity, IAwakeSystem<List<Effect>>
    {
        public List<AbilityEffect> AbilityEffectList = new List<AbilityEffect>();
        public AbilityEffect DamageAbilityEffect;
        public AbilityEffect CureAbilityEffect;

        public void Awake(List<Effect> a)
        {
            if (a == null)
                return;
            foreach (var item in a)
            {
                AbilityEffect abilityEffect = parent.AddChild<AbilityEffect, Effect>(item);
                this.AddEffect(abilityEffect);

                if (abilityEffect.effect is DamageEffect)
                {
                    DamageAbilityEffect = abilityEffect;
                }

                if (abilityEffect.effect is CureEffect)
                {
                    CureAbilityEffect = abilityEffect;
                }
            }
        }

        public void EnableEffect()
        {
            foreach (var item in AbilityEffectList)
            {
                item.EnableEffect();

            }
        }

        public void AddEffect(AbilityEffect abilityEffect)
        {
            AbilityEffectList.Add(abilityEffect);
        }

        public AbilityEffect GetEffect(int index = 0)
        {
            return AbilityEffectList[index];
        }


        public void TryAssignAllEffectToTarget(Combat target)
        {
            if (AbilityEffectList.Count > 0)
            {
                foreach (var item in AbilityEffect)
                {
                    item.TryAssignAllEffectToTarget(target);
                }
            }
        }

        public void TryAssingAllEffectToTarget(Combat target)
        {
            if (AbilityEffectList.Count > 0)
            {
                foreach (var item in AbilityEffectList)
                {
                    item.TryAssignEffectToTarget(target);
                }
            }
        }

        public void TryAssignAllEffectToTarget(Combat inTatget, IActionExecution inAbilityItem)
        {
            if (AbilityEffectList.Count > 0)
            {
                foreach (var item in AbilityEffectList)
                {
                    item.TryAssinEffectToTarget(Target, inAbilityItem);
                }
            }
        }

        public void TryAssinAllEffectToTarget(Combat inTarget, AbilityItem inAbilityItem)
        {
            if (AbilityEffectList.Count > 0)
            {
                foreach (var item in AbilityEffectList)
                {
                    item.TryAssignEffectToTarget(Target, inAbilityItem);
                }
            }
        }
        public void TryAssingEffectToTargetByIndex(Combat inTarget, int inIndex)
        {
            AbilityEffectList[index].TryAssinEffectToTarget(target);
        }
    }

}

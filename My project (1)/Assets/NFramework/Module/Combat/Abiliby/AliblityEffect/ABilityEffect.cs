using System.Collections.Generic;
using NFramework.Core.ILiveing;
using NFramework.Module.EntityModule;
using Unity.VisualScripting;
using UnityEngine;


namespace NFramework.Module.Combat
{
    //AbilityEffect是挂在Ability上的
    public class AbilityEffect : Entity, IAwakeSystem<Effect>
    {
        public Effect effect;
        public Entity OwnerAbility => (Entity)Parent;
        public Combat Owner => ((IAbility)OwnerAbility).Owner;

        public void Awake(Effect a)
        {
            effect = a;
            if (effect is AddStatusEffecct)
            {
                this.AddComponent<AbilityEffectAddStatusComponent>();
            }
            if (effect is ClearAllStatusEffect)
            {

            }
            if (effect is CureEffect)
            {
                AddComponent<AbilityEffectCureComponent>();
            }

            if (effect is DamageEffect)
            {
                AddComponent<AbilityEffectDamageComponent>();
            }
            if (effect is RemvoeStatusEffect)
            {

            }
            AddComponent<AbilityEffectDecoratosComponent>();
        }
        public void EnableEffect()
        {
            if (effect is AcctionControlEffect)
            {
                AddComponent<AbilityEffectActionControlComponent>();
            }
            if (effect is AttributeModifyEffect)
            {
                AddComponent<AbilityEffectAttributeModifyComponent>();
            }
            if (effect is CustomEffect)
            { }
            if (effect is DamageBloodSuckEffect)
            {
                AddComponent<AbilityEffectDamageBooldSUckComponent>();
            }
            if (effect is not ActionControlEffect && effect is not AttributeModifyEffect)
            {
                if (effect.EffectTriggerType == EffectTriggerType.Instant)
                {
                    TryAssinEffectToOwner();
                }
                if (effect.EffectTriggerType == EffectTriggerType.Action)
                {
                    AddComponent<AbilityEffectActionTriggerComponent>();
                }

                if (effect.EffectTriggerType == EffectTriggerType.Interval && !string.IsNullOrEmpty(effect.IntervalValeuFormula))
                {
                    AddComponent<AbilityEffectIntervalTriggerComponent>();
                }

                if (effect.EffectTriggerType == EffectTriggerType.Condition && !string.IsNullOrEmpty(effect.ConditionValureFormula))
                {
                    AddComponent<AbilityEffectConditionTriggerComponent>();
                }
            }
        }

        public Dictionary<string, string> GetparamsDict()
        {
            Dictionary<string, string> temp;
            if (OwnerAbility is statusAbility status)
            {
                temp = status.paramsDic;
                return temp;
            }
            else
            {
                temp = new Dictionary<string, string>();
                temp.Add("自身生命值", Owner.GetComponent<AttributeComponent>().HealthPoint.value.ToString());
                temp.Add("自身攻击力", Owner.GetComponent<AttributeComponent>().Attack.value.ToString());
            }
            return temp;
        }

        public void TryAssinEffectToOwner()
        {
            TryAssinEffectToOwner(Owner);
        }

        public void TryAssingEffectToTarget(Combat target)
        {
            if (Owner.effectAssignActionAbility.TryMakeAction(out var action))
            {
                action.target = target;
                action.sourceAbility = OwnerAbility;
                action.abilityEffect = this;
                action.ApplyEffectAssign();
            }
        }

        public void TryAssinEffectToTarget(Combat target, IActionExecution actionExecution)
        {
            if (Owner.effectAssignActionAbility.TryMakeAction(out var action))
            {
                action.target = target;
                action.sourceAbility = OwnerAbility;
                action.abilityEffect = this;
                action.actionExecution = actionExecution;
                action.ApplyEffectAssign();
            }
        }

        public void TryAssinEffectToTarget(Combat target, AbilityItem abilityItem)
        {
            if (Owner.effectAssignActionAbility.TryMakeAction(out var action))
            {
                action.target = target;
                action.sourceAbility = OwnerAbility;
                action.abilityEffect = this;
                action.abilityItem = abilityItem;
                action.ApplyEffectAssign();
            }
        }
        public void StartAssignEffect(EffectAssignAction action)
        {
            if (effect is AddStatusEffect)
            {
                GetComponent<AbilityEffectAddStatusComponent>().OnAssignEffect(action);
            }
            if (effect is clearAllStatusEffect)
            {
            }
            if (effect is CureEffect)
            {
                GetComponent<AbilityEffectCureComponent>().OnAssignEffect(action);
            }
            if (effect is DamageEffect)
            {
                GetComponent<AbilityEffectDamageComponent>().OnAssingEffect(action);
            }
            if (effect is RemoveStatusEffect)
            {

            }
        }
    }
}
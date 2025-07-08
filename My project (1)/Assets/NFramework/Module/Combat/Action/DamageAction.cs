using UnityEngine;
using NFramework.Module.EntityModule;

namespace NFramework.Module.Combat
{

    public enum DamageSource
    {
        Attack,
        Skill,
        Buff,
    }


    public class DamageActionAbility : Entity, IActionAbility
    {
        public bool Enable { get; set; }
        public Combat Owner => GetParent<Combat>();

        public bool TryMakeAction(out DamageAction action)
        {
            if (!Enable)
            {
                action = null;
            }
            else
            {
                action = Owner.AddChild<DamageAction>();
                action.ActionAbility = this;
                action.Creator = Owner;
            }
            return Enable;
        }
    }


    public class DamageAction : Entity, IActionExecution
    {
        public DamageSource DamageSource;
        public int DamageValue;
        public Entity ActionAbility { get; set; }
        public EffectAssignAction SourceAssignAction { get; set; }
        public Combat Creator { get; set; }
        public Combat Target { get; set; }

        public void FinishAction()
        {
            Dispose();
        }

        private void PreProcess()
        {
            DamageEffect damageEffect = (DamageEffect)SourceAssignAction.AbilityEffect.effect;
            bool isCritical = false;

            if (this.DamageSource == DamageSource.Attack)
            {
                isCritical = (RandomUtil.RandomRate() / 100f) < Creator.GetComponent<AttribureComponent>().CriticalProbability.Value;
                DamageValue = (int)Creator.GetComponent<AttributeComponent>().Attack.Value;
                DamageValue = Mathf.CeilToInt(Mathf.Max(1, DamageValue - Target.GetComponent<AttribureComponent>().Defense.Value));
                if (isCritical)
                {
                    DamageValue = Mathf.CeilToInt(DamageValue * 1.5f);
                }
            }
            if (this.DamageSource == DamageSource.Skill)
            {
                if (damageEffect.CanCrit)
                {
                    isCritical = (RandomUtil.RandomRate() / 100f) < Creator.GetComponent<AttributeComponent>().CriticalProbability.Value;
                }
                DamageValue = SourceAssignAction.AbilityEffect.GetComponent<AbilityEffectDamageComponet>().GetDamageValue();
                DamageValue = Mathf.CeilToInt(Mathf.Max(1, DamageValue - Target.GetComponent<AttributeComponent>().Defense.Value));
                if (isCritical)
                {
                    DamageValue = Mathf.CeilToInt(DamageValue * 1.5f);
                }
            }

            if (DamageSource == DamageSource.Buff)
            {
                if (damageEffect.CanCrit)
                {
                    isCritical = (RandomUtil.RandomRate() / 100f) < Creator.GetComponent<AttributeComponent>().CriticalProbability.Value;
                }
                DamageValue = SourceAssignAction.AbilityEffect.GetComponent<AbilityEffectDamageComponent>().GetDamageValue();
                DamageValue = Mathf.CeilToInt(Mathf.Max(1, DamageValue - Target.GetComponent<AttributeComponent>().Defense.Value));
                if (isCritical)
                {
                    DamageValue = Mathf.CeilToInt(DamageValue * 1.5f);
                }
            }

            AbilityEffectDamageReduceWithTargetCountComponent component = SourceAssignAction.AbilityEffect.GetComponent<AbilityEffectDamageReduceWithTargetCountComponent>();
            if (component != null)
            {
                var targetCounterComponent = SourceAssignAction.AbilityItem.GetComponent<AbilityItemTargetCounterComponent>();
                if (targetCounterComponent != null)
                {
                    var damagePercent = component.GetDamagePercent(targetCounterComponent.TargetCounter);
                    DamageValue = Mathf.CeilToInt(DamageValue * damagePercent);
                }
            }

            Creator.TriggerActionPoint(ActionPointType.PreCauseDamage, this);
            Target.TriggerActionPoint(ActionPointType.PreReceiveDamage, this);
        }

        public void ApplyDamage()
        {
            PreProcess();
            Target.ReceiveDamage(this);
            PostProcess();

            if (Target.CheckDead())
            {
                Target.Dead();
            }
            FinishAction();
        }
        private void PostProcess()
        {
            Creator.TriggerActionPoint(ActionPointType.PostCauseDamage, this);
            Target.TriggerActionPoint(ActionPointType.PostReceiveDamage, this);
        }
    }
}
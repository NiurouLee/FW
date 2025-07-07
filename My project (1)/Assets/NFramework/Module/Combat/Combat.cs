using System;
using NFramework.Core.ILiveing;
using NFramework.Module.EntityModule;
using NFramework.Module.Event;
using UnityEngine;

namespace NFramework.Module.Combat
{
    public class Combat : Entity, IAwakeSystem
    {
        public HealthPoint CurrentHealth;
        public ActionControlType ActionControlType;
        public EffectAssignActionAbility EffectAssignActionAbility;
        public AddStatusActionAbility AddStatusActionAbility;
        public SpellSkillActionAbility SpellSkillActionAbility;
        public SpellItemActionAbility SpellItemActionAbility;
        public DamageActionAbility DamageActionAbility;
        public CureActionAbility CureActionAbility;
        public SkillExecution SpellingSkillExecution;
        public TransformComponent TransformComponent => GetComponent<TransformComponent>();
        public OrcaComponent OrcaComponent => GetComponent<OrcaComponent>();
        public AnimationComponent AnimationComponent => GetComponent<AnimationComponent>();
        public AttributeComponent AttributeComponent => GetComponent<AttributeComponent>();
        public AABBComponent AABBComponent => GetComponent<AABBComponent>();
        public TagComponent TagComponent => GetComponent<TagComponent>();


        public void Awake()
        {
            Framework.Instance.GetModule<EventD>().D.Publish(ref new SyncCreateCombat(this.Id));
            AddComponent<TransformComponent>();
            AddComponent<OrcaComponent>()
            AddComponent<AnimationComponent>();
            AABB aabb = new AABB(new Vector2(-1, -1), new Vector2(1, 1));
            AddComponent<AABBComponent>(aabb);
            AddComponent<AttributeComponent>();
            AddComponent<ConditionComponent>();
            AddComponent<MotionComponent>();
            AddComponent<StatusComponent>();
            AddComponent<SkillComponent>();
            AddComponent<ExecutionComponent>();
            AddComponent<ExecutionComponent>();
            AddComponent<ItemComponent>();
            AddComponent<SpellSkillComponent>();
            AddComponent<JoystickComponent>();

            CurrentHealth = AddChild<HealthPoint>();

            EffectAssignActionAbility = AttachAction<EffectAssignActionAbility>();
            AddStatusActionAbility = AttachAction<AddStatusActionAbility>();

            SpellSkillActionAbility = AttachAction<SpellSkillActionAbility>();
            SpellItemActionAbility = AttachAction<SpellItemActionAbility>();
            DamageActionAbility = AttachAction<DamageActionAbility>();
            CureActionAbility = AttachAction<CureActionAbility>();

            OrcaComponent.AddAgent2D(TransformComponent.position);

            ListenActionPoint(ActionPointType.PostReceiveDamage, e =>
            {
                var damageAction = e as DamageAction;
                Framework.Instance.GetModule<EventD>().D.Publish(ref new SyncDamage(this.Id, damageAction.DamageValue));
            });

            ListenActionPoint(ActionPointType.PostReceiveCure, e =>
            {
                var cureAction = e as CureAction;
                Framework.Instance.GetModule<EventD>().D.Publish(ref new SyncCure(this.Id, cureAction.CureValue));
            });
        }


        public void Dead()
        {
            Framework.Instance.GetModule<EventD>().D.Publish(ref new SyncDeleteCombat(this.Id));
            GetParent<CombatContext>().RemoveCombat(this.Id);
        }


        public void ReceiveDamage(IActionExecution actionExecution)
        {
            var damageAction = actionExecution as DamageAction;
            CurrentHealth.Minus(damageAction.DamageValue);
        }

        public void ReceiveCure(IActionExecution actionExecution)
        {
            var cureAction = actionExecution as CureAction;
            CurrentHealth.Add(cureAction.CureValue);
        }

        public bool CheckDead()
        {
            return CurrentHealth.CurrentHealth <= 0;
        }

        public T AttachAbility<T>(object configObject) where T : Entity, IAbility, IAwakeSystem<object>
        {
            var ability = AddChild<T, object>(configObject);
            ability.AddComponent<AbilityLevelComponent>();
            return ability;
        }


        public T AttachAction<T>() where T : Entity, IActionAbility
        {
            var action = AddChild<T>();
            action.AddComponent<ActionComponent, Type>(typeof(T));
            action.Enable = true;
            return action;
        }


        public StatusAbility AttachStatus(int statusId)
        {
            return GetComponent<StatusComponent>().AttachStatus(statusId);
        }

        public StatusAbility GetStatus(int statusId, int index = 0)
        {
            return GetComponent<StatusComponent>().GetStatus(statusId, index);
        }

        public void OnStatueRemove(StatusAbility statusAbility)
        {
            GetComponent<StatusComponent>().OnStatusRemove(statusAbility);
        }
        public bool HasStatus(int statusId)
        {
            return GetComponent<StatusComponent>().HasStatus(statusId);
        }

        public void OnStatuesChanged(StatusAbility statusAbility)
        {
            GetComponent<StatusComponent>().OnStatuesChanged(statusAbility);
        }


        public SkillAbility AttachSkill(int skillId)
        {
            return GetComponent<SkillComponent>().AttachSkill(skillId);
        }

        public SkillAbility GetSkill(int skillId)
        {
            return GetComponent<SkillCOmponent>().GetSkill(skillId);
        }


        public ExecutionConfigObject AttachExecution(int executionId)
        {
            return GetComponent<ExecutionComponent>().AttachExecution(executionId);
        }

        public ExecutionConfigObject GetExecution(int executionID)
        {
            return GetComponent<ExecutionComponent>().GetExecution(executionID);
        }

        public ItemAbility AttachItem(int itemID)
        {
            return GetComponent<ItemComponent>().AttachItem(itemID);
        }

        public ItemAbility GetItem(int itemID)
        {
            return GetComponent<ItemComponent>().GetItem(itemID);
        }


        #region ActionPoint
        public void ListenActionPoint(ActionPointType type, Action<Entity> action)
        {
            GetComponent<ActionPointComponent>().ListenActionPoint(type, action);

        }

        public void UnListenActionPoint(ActionPointType type, Action<Entity> action)
        {
            GetComponent<ActionPointComponent>().UnListenActionPoint(type, action);
        }

        public void TriggerActionPoint(ActionPointType type, Entity action)
        {
            GetComponent<ActionPointComponent>().TriggerActionPoint(type, action);
        }
        #endregion


        public void ListenCondition(ConditionType type, Action action, object obj = null)
        {
            GetComponent<ConditionComponent>().AddListener(type, action, obj);
        }

        public void UnListenCondition(ConditionType type, Action action)
        {
            GetComponent<ConditionComponent>().RemoveListener(type, action);
        }
    }
}
using System;
using System.Collections.Generic;
using NFramework.Core.ILiveing;
using NFramework.Module.EntityModule;
using Unity.VisualScripting;
using UnityEngine;


namespace NFramework.Module.Combat
{
    public class SkillExecution : Entity, IAbilityExecution, IAwakeSystem<SkillAbility>
    {
        public Entity Ability { get; set; }
        public Combat Owner => GetParent<Combat>();
        public SkillAbility SkillAbility => (SkillAbility)Ability;
        public ExecutionConfigObject executionConfigObject;
        public List<Combat> TargetList = new List<Combat>();
        public Vector3 inputPoint;
        public float inputDirection;
        public bool ActionOccupy = true;

        public void Awake(SkillAbility a)
        {
            Ability = a;
        }

        public void LoadExecutionEffect()
        {
            AddComponent<ExecutionEffectComponent>();
            Framework.Instance.GetModule<TimeModule>().NewOnceTimer((long)executionConfigObject.TotalTime * 1000, this.EndExecute);
        }

        public void BeginExecute()
        {
            GetParent<Combat>().SpellingSkillExecution = this;
            if (SkillAbility != null)
            {
                SkillAbility.Spelling = true;
            }
            GetComponent<ExecutionEffectComponent>().BeginExecute();
        }

        public void EndExecute()
        {
            TargetList.Clear();
            GetParent<Combat>().SpellingSkillExecution = null;
            if (SkillAbility != null)
            { SkillAbility.Spelling = false; }
            Dispose();
        }

        public void SpawnCollisionItem(ExecuteClipData clipData)
        {
            var abilityItem = Owner.GetParent<CombatContext>().AddAbilityItem(this, clipData);
            if (clipData.CollisionExecuteData.MoveType == CollisionMoveType.FixedPosition)
            {
                FixedPostionItem(abilityItem);
            }
            if (clipData.CollisionExecuteData.MoveType == CollisionMoveType.FixedDirection)
            {
                FixedDirectionItem(abilityItem);
            }
            if (clipData.CollisionExecuteData.MoveType == CollisionMoveType.TargetFly)
            {
                TargetFlyItem(abilityItem);
            }
            if (clipData.CollisionExecuteData.MoveType == CollisionMoveType.ForwardFly)
            {
                ForwardFlyItem(abilityItem);
            }
            if (clipData.CollisionExecuteData.MoveType == CollisionMoveType.PathFly)
            {
                PathFlyItem(abilityItem);
            }
        }

        private void TargetFlyItem(AbilityItem abilityItem)
        {
            abilityItem.TransformComponent.position = Owner.TransformComponent.position;
            ExecuteClipData clipData = abilityItem.GetComponent<AbilityItemCollisionExecuteComponent>().ExectteClipData;
            abilityItem.AddComponent<AbilityItemMoveWithDoTweenComponent>().DoMoveToWithTime(TargetList[0].TransformComponent, clipData.Duration);

        }

        private void ForwardFlyItem(AbilityItem AbilityItem)
        {
            AbilityItem.TransformComponent.position = Owner.TransformComponent.position;
            var x = Mathf.Sin(Mathf.Deg2Rad * inputDirection);
            var y = Mathf.Cos(Mathf.Deg2Rad * inputDirection);
            AbilityItem.AddComponent<AbilityItemMoveWithDotweenComponent>().DoMoveTo(Description, 1f).OnMoveFinish(() =>
            {
                AbilityItem.Dispose();
            });
        }

        private void PathFlyItem(AbilityItem abilityItem)
        {
            abilityItem.TransformComponent.position = Owner.TransformComponent.position;
            var clipData = abilityItem.GetComponent<AbilityItemColl>();
            var pointList = clipData.CollisionExecuteData.GetPointList();
            var angle = Owner.TransformComponent.rotation.eulerAngles.y - 90;
            abilityItem.TransformComponent.position = pointList[0].position;
            var moveComp = abilityItem.AddComponent<AbilityItemBezierMoveComponent>();
            moveComp.abilityItem = abilityItem;
            moveComp.pointList = pointList;
            moveComp.originPosition = Owner.TransformComponent.position;
            moveComp.rotateAgree = angle * MathF.PI / 180;
            moveComp.speed = clipData.Duration / 10;
            moveComp.DoMove();
            abilityItem.AddComponent<AbilityItemLifeTimeComponent, long>((long)(clipData.Duration * 1000));
        }

        private void FixedPositionItem(AbilityItem abilityItem)
        {
            var clipData = abilityItem.GetComponent<AbilityItemCollisionExecuteComponent>().ExecuteClipData;
            abilityItem.TransformComponent.position = inputPoint;
            abilityItem.AddComponent<AbilityItemLifeTimeComponent, long>((long)(clipData.Duration * 1000));
        }

        private void FixedDirectionItem(AbilityItem abilityItem)
        {
            var clipData = abilityItem.GetComponent<AbilityItemCollisionExecuteComponent>().ExecuteClipData;
            abilityItem.TransformComponent.position = Owner.TransformComponent.position;
            abilityItem.TransformComponent.rotation = Owner.TransformComponent.rotation;
            abilityItem.AddComponent<AbilityItemLifeTimeComponent, long>((long)(clipData.Duration * 1000));
        }

    }
}
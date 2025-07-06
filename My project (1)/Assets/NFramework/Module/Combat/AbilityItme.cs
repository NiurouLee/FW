using NFramework.Core.ILiveing;
using NFramework.Module.EntityModule;
using UnityEngine;

namespace NFramework.Module.Combat
{
    public class AbilityItem : Entity, IAwakeSystem<IAbilityExecution, ExecuteClipData>
    {
        public IAbilityExecution AbilityExecution;
        public Entity ability;
        public EffectApplyType effectApplyType;

        public TransformComponent TransformComponent => GetComponent<TransformComponent>();
        public AABBConponent AABBComponent => GetComponent<AABBComponent>();

        public override void Awake<IAbilityExecution, ExecuteClipData>(IAbilityExecution abilityExecution, ExecuteClipData clipData)
        {
            var @event = new SyncCrateAbilityItem(this.Id);
            Framework.Instance.GetModule<EventD>().d.Fire(ref @event);
            AddComponent<TranformComponent>();
            AddComponent<AbilityItemCollisionExecuteComponent, ExecuteClipData>(clipData);
            AABB aabb = new AABB(new Vector2(-1, -1), new Vector2(1, 1));
            AddComponent<AABBComponent, AABB>(aabb);





        }
    }

}

using NFramework.Core.ILiveing;
using UnityEngine;
namespace NFramework.Module.Combat
{
    public class AbilityEffectDecoratosComponent : Entity, IAwake
    {
        public Effect Effect => GetParent<AbilityEffect>().effect;
        public override void Awake()
        {
            if (Effect.DecoratorList != null)
            {
                foreach (var item in Effect.DecoratorList)
                {
                    if (item is DamageReduceWithTargetCountDecorator)
                    {
                        Parent.AddComponent<AbilityEffectDamageReduceWithTargetCountComponent>();
                    }
                }
            }
        }
    }
}


using NFramework.Core.ILiveing;
using NFramework.Module.EntityModule;
using UnityEngine;
namespace NFramework.Module.Combat
{
    public class AbilityEffectDamageReduceWithTargetCountComponent : Entity, IAwakeSystem
    {
        public DamageEffect DamageEffect => (DamageEffect)GetParent<AbilityEffect>().effect;
        public float ReducePercent;
        public float minPercent;

        public void Awake()
        {
            foreach (var item in DamageEffect.DecoratorList)
            {
                if (item is DamageErdureWithTargetCountDecorator decorator)
                {
                    ReducePercent = decorator.ReducePercent / 100;
                    minPercent = decorator / 100;
                }
            }
        }
        public float GetDamageValue(int targetCounter)
        {
            return Mathf.Max(minPercent, 1 - ReducePercent * targetCounter);
        }

    }

}
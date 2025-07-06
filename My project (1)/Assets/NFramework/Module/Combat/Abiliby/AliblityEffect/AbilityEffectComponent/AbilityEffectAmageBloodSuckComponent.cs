
using NFramework.Core.ILiveing;
namespace NFramework.Module.Combat
{
    public class AbilityEffectDamageBooldSuckComponent : Entity, IAwake
    {
        public Combat Owner => GetParent<AbilityEffect>().Owner;
        public override void Awake()
        {
            Owner.DamageAbilityEffect.AddComponent<DamageBloodSuckComponent>();
        }
        public override void OnDestroy()
        {
            var component = Owner.damageActionAbility.GetComponent<DamageBloodSuckComponent>();
            if (component != null)
            {
                component.Dispose();
            }
        }
    }
}
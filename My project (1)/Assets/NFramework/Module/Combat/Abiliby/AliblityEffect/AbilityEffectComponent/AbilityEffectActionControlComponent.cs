using NFramework.Core.ILiveing;
namespace NFramework.Module.Combat
{
    public class AbilityEffectActionControlComponent : Entity, IAwake
    {
        public ActionControEffect ActionControEffect => (ActionControEffect)GetParent<AbilityEffect>().effect;
        public Combat Owner => GetParent<AbilityEffect>().Owner;
        public StatusAbility OwnerAbility => (statusAbility)GetParent<AbilityEffect>().OwnerAbility;

        public void Awake()
        {
            Owner.OnStatuesChanged(OwnerAbility);
        }

        public override private void OnDestroy()
        {
            Owner.OnStatuesChanged(OwnerAbility);
        }
    }
}
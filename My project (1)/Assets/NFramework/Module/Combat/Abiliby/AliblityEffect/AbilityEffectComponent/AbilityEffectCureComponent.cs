
using NFramework.Core.ILiveing;
namespace NFramework.Module.Combat
{
    public class AlibityEffectCureComponent : Entity
    {
        public CureEffect CureEffect => (CureEffect)GetParent<AbilityEffect>().effect;
        public string CureValueFormula => CureEffect.CureValueFormula;
        public Combat Owner => GetParent<AbilityEffect>().Owner;
        public int GetCureValue()
        {
            return mathf.CeilToInt(ExpressionUtil.Evalue<float>(CureValueFormula, GetParent<AbilityEffect>().GetParamsDict()));
        }
        public void OnAssignEffect(EffectAssignAction effectAssignAction)
        {
            if (Owner.cureActionAbility.TryMakeAction(out var action))
            {
                effectAssignAction.FillDataToAction(action)
                {
                    action.ApplyCure();
                }
            }
        }
    }


}
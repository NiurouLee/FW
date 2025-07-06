
using NFramework.Core.ILiveing;
namespace NFramework.Module.Combat
{
    public class AbilityEffectAttributeModifyComponent : Entity, IAwake
    {
        public AttributeModifyEffect AttributeModifyEffect => (AttributeModifyEffect)GetParent<AbilityEffect>().effect;
        public string NunericValueFormula => AttributeModifyEffect.NunericValueFormula;
        public AttributeType AttributeType => AttributeModifyEffect.AttributeType;
        public Combat Owner => GetParent<AbilityEffect>().Owner;
        public float value;

        public override void Awake()
        {
            value = ExpressionUtil.Evalue<float>(NumericValueFormula, GetParent<AbilityEffect>().GetParamsDict());
            if (AttributeModifyEffect.ModifyType == ModifyType.Add)
            {
                Owner.GetComponent<AttributeComponent>().GetNumeric(AttribureType).FinalAdd += value;
            }
            if (AttributeModifyEffect.ModifyType == ModifyType.PercentAdd)
            {
                Owner.GetComponent<AttributeComponent>().GetNumeric(AttribureType).FinalPctAdd += value;
            }
        }
        override private void OnDestroy()
        {
            if (AttributeModifyEffect.ModifyType == ModifyType.Add)
            {
                Owner.GetComponent<AttributeComponent>().GetNumeric(AttributeType).FinalAdd -= value;
            }
            if (AttributeModifyEffect.ModifyType == ModifyType.PercentAdd)
            {
                Owner.GetComponent<AttributeComponent>().GetNumeric(AttributeType).FinalPctAdd -= value;
            }
        }
    }
}
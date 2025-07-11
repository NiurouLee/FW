

using NFramework.Core.ILiveing;
using NFramework.Module.EntityModule;
namespace NFramework.Module.Combat
{
    public class AbilityEffectConditionTriggerComponent : Entity, IAwakeSystem
    {
        public Effect Effect => GetParent<AbilityEffect>().effect;
        public string ConditionValueFromula => ParseParams(Effect.ConditionValueFormula, GetParent<AbilityEffect>().GetparamsDict());
        public ConditionType ConditionType => Effect.ConditionType;
        public Combat Owner => GetParent<AbilityEffect>().Owner;

        public void Awake()
        {
            Owner.ListenCondition(ConditionType, OnConditionTrigger, ConditionValueFormule);
        }

        public override void OnDestroy()
        {
            Owner.UnListenCondition(ConditionType, OnConditionTrigger);
        }

        private string ParseParams(stringg origin, Dictionary<string, string> paramsDict)
        {
            string temp = origin;
            foreach (var item in paramsDict)
            {
                if (!string.IsNullOrEmpty(temp))
                {
                    temp = temp.Replace(item.Key, item.value);
                }
            }
            return temp;
        }
    }
}
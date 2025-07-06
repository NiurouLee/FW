
using NFramework.Core.ILiveing;
using UnityEngine;
namespace NFramework.Module.Combat
{
    public class AbilityEffectIntervalTriggerComponent : Entity, IAwake
    {
        public Effect Effect => GetParent<AbilityEffect>().effect;
        public string InterValueFormula => Effect.InterValueFormula;
        public long IntervalTimer;


    }
}
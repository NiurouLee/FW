using System;
using System.Security.Cryptography;
using Sirenix.OdinInspector;
using UnityEngine;

namespace NFramework.Module.Combat
{

    public enum EffectTriggerType
    {
        [LabelText("无")]
        None = 0,
        [LabelText("瞬发")]
        Instant = 1,
        [LabelText("条件")]
        Condition = 2,
        [LabelText("行动点触发")]
        Action = 3,
        [LabelText("间隔")]
        Interval = 4,
        [LabelText("行动点且满足条件")]
        ActionCondition = 5,
    }

    public enum ConditionType
    {
        [LabelText("自定义条件")]
        CustomCondition = 0,

        [LabelText("血量低于")]
        WhenHPLower = 1,

        [LabelText("血量百分比低于")]
        WhenHPPctLower = 2,

        [LabelText("在时间内未受到伤害")]
        WhenInTimeNoDamage = 3
    }


    [AttributeUsage(AttributeTargets.Class, Inherited = false, AllowMultiple = false)]
    public class EffectAttribute : System.Attribute
    {
        private readonly string _effectType;
        private readonly int _order;
        public EffectAttribute(string effectType, int order)
        {
            _effectType = effectType;
            _order = order;
        }
        public string EffectType => _effectType;
        public int Order => _order;
    }

    [Serializable]
    public abstract class Effect
    {
        private const string EffectTypeNameDefine = "(添加效果修饰)";
        [HideInInspector]
        public bool IsSkillEffect;
        [HideInInspector]
        public bool IsExecutionEffect;
        [HideInInspector]
        public bool IsItemEffect;
        [HideInInspector]
        public virtual string Label => "Effect";
        [ToggleGroup("Enabled", "$Label")]
        public bool Enabled;

        [HorizontalGroup("Enabled/Hor")]
        [ToggleGroup("Enabled"), HideIf("HideEffectTriggerType", true), HideLabel]
        public EffectTriggerType EffectTriggerType;

        [HorizontalGroup("Enabled/Hor")]
        [ToggleGroup("Enabled"), HideIf("IsSkillEffect", true), ShowIf("EffectTriggerType", EffectTriggerType.Condition), HideLabel]
        public ConditionType ConditionType;

        public ActionPointType ActionPointType;



    }
}
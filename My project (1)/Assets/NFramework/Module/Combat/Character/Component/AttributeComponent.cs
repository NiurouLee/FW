using System.Collections.Generic;
using Entitas;
using NFramework.Core.ILiveing;
using Sirenix.OdinInspector;

namespace NFramework.Module.Combat
{
    [LabelText("属性类型")]
    public enum AttributeType
    {
        [LabelText("(空)")]
        None = 0,

        [LabelText("生命值")]
        HealthPoint = 1000,
        [LabelText("生命值上限")]
        HealthPointMax = 1001,
        [LabelText("攻击力")]
        Attack = 1002,
        [LabelText("护甲值")]
        Defense = 1003,
        [LabelText("法术强度")]
        AbilityPower = 1004,
        [LabelText("魔法抗性")]
        SpellResistance = 1005,
        [LabelText("吸血")]
        SuckBlood = 1006,
        [LabelText("暴击概率")]
        CriticalProbability = 1007,
        [LabelText("移动速度")]
        MoveSpeed = 1008,
        [LabelText("攻击速度")]
        AttackSpeed = 1009,
        [LabelText("护盾值")]
        ShieldValue = 1010,
        [LabelText("造成伤害")]
        CauseDamage = 1011,
    }

    public class AttributeComponent : Entity, IAwakeSystem
    {
        private readonly Dictionary<AttributeType, FloatNumeric> _attributeDict = new Dictionary<AttributeType, FloatNumeric>();
        public FloatNumeric MoveSpeed => _attributeDict[AttributeType.MoveSpeed];//移动速度
        public FloatNumeric HealthPoint => _attributeDict[AttributeType.HealthPoint];//当前生命值
        public FloatNumeric HealthPointMax => _attributeDict[AttributeType.HealthPointMax];//生命值上限
        public FloatNumeric Attack => _attributeDict[AttributeType.Attack];//攻击力
        public FloatNumeric Defense => _attributeDict[AttributeType.Defense];//防御力
        public FloatNumeric AbilityPower => _attributeDict[AttributeType.AbilityPower];//法术强度
        public FloatNumeric SpellResistance => _attributeDict[AttributeType.SpellResistance];//魔法抗性
        public FloatNumeric CriticalProbability => _attributeDict[AttributeType.CriticalProbability];//暴击概率
        public FloatNumeric CauseDamage => _attributeDict[AttributeType.CauseDamage];//暴击概率


        public void Awake()
        {
        }
    }
}
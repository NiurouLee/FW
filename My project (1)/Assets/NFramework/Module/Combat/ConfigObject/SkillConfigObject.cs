
using System.IO;
using Sirenix.OdinInspector;
using UnityEngine;

namespace NFramework.Module.Combat
{
    public enum SkillSpellType
    {
        [LabelText("主动技能")]
        Initiative,

        [LabelText("被动技能")]
        passive,
    }

    public enum SkillAffectTargetType
    {
        [LabelText("自身")]
        self = 0,

        [LabelText("己方")]
        SelfTeam = 1,

        [LabelText("敌方")]
        EnemyTeam = 2,
    }

    [CreateAssetMenu(fileName = "技能配置", menuName = "技能|状态/技能配置")]
    public class SkillConfigObject : SerializedScriptableObject
    {

    }


}
using UnityEngine;

namespace NFramework.Module.Combat
{
    [CreateAssetMenu(fileName = "ExecutionConfigObject", menuName = "技能|状态/Execution")]
    public class ExecutionConfigObject : ScriptableObject
    {
        public int id;
        public ExecutionTargetInputType TargetInputType;

        

    }
}
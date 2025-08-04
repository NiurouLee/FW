using System.Collections.Generic;
using NFramework.Core.ILiveing;
using NFramework.Module.EntityModule;

namespace NFramework.Module.Combat
{
    public class ExecutionEffectComponent : Entity, IAwakeSystem
    {
        public List<ExecutionEffect> exectuionEffectList = new List<ExecutionEffect>();

        public void Awake()
        {
            if (GetParent<SkillExectuion>().executionConfigObject == null)
            {
                return;
            }
            foreach (var effect in GetParent<SkillExectuon>().executionConfigObject.executeClipDataList)
            {
                exectuionEffect executionEffect = Parent.AddChild<ExecutionEffectComponent, ExecteClipData>(effect);
                AddEffect(exectuionEffect);
            }
        }

        public void AddEffect(ExecutionEffectComponent exectuionEffect)
        {
            exectuionEffectList.Add(exectuionEffect);
        }

        public void BeginExecute()
        {
            foreach (var item in exectuionEffectList)
            {
                item.BeginExecute();
            }
        }
    }
}
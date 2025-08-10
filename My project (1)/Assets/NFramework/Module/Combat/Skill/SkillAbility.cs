using System.Collections.Generic;
using NFramework.Core.ILiveing;
using NFramework.Module.EntityModule;
using NFramework.Module.Res;

namespace NFramework.Module.Combat
{
    public class SkillAbility : Entity, IAbility, IAwakeSystem<SkillConfigObject>
    {
        public bool Spelling { get; set; }
        public Combat Owner => GetParent<Combat>();
        public SkillConfigObject SkillConfigObject;
        public ExecutionConfigObject ExecutionConfigObject;
        private List<StatusAbility> m_StatusList = new List<StatusAbility>();
        public void Awake(SkillConfigObject a)
        {
            SkillConfigObject = a;
            AddComponent<AbilityEffectComponent, List<Effect>>(SkillConfigObject.EffectList);
            ExecutionConfigObject = Framework.I.G<ResM>().Load<ExecutionConfigObject>(string.Empty);
        }

        public void ActivateAbility()
        {
            Enable = true;

            if (SkillConfigObject.EnableChildStatus)
            {
                foreach (var item in SkillConfigObject.StatusList)
                {
                    var status = Owner.AttachStatus(item.StatusConfigObject.Id);
                    status.Creator = Owner;
                    status.isChildStatus = true;
                    status.childStatusData = item;
                    status.SetParams(item.ParamsDict);
                    status.ActivateAbility();
                    m_StatusList.Add(status);
                }
            }
        }


        public void EndAbility()
        {

            Enable = false;
            if (SkillConfigObject.EnableChildStatus)
            {
                foreach (var item in m_StatusList)
                {
                    item.EndAbility();
                }
                m_StatusList.Clear();
            }
            Dispose();
        }

        public Entity CreateExecution()
        {
            var execution = Owner.AddChild<SkillExecution, SkillAbility>(this);
            execution.executionConfigObject = ExecutionConfigObject;
            execution.LoadExecutionEffect();
            return execution;
        }
    }


}
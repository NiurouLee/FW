using System.Collections.Generic;
using NFramework.Core.ILiveing;
using NFramework.Module.EntityModule;
using UnityEngine;

namespace NFramework.Module.Combat
{
    public class SkillAbility : Entity, IAbility, IAwakeSystem<SkillConfigObject>
    {
        public bool Spelling { get; set; }
        public Combat Owner => GetParent<Combat>();

        public SkillConfigObject SkillConfigObject;
        public ExecutionConfigObject ExecutionConfigObject;
        public bool Spelling;
        private List<StatusAbility> m_StatusList = new List<StatusAbility>();


        public void Awake(SkillConfigObject a)
        {
            SkillConfigObject = a;
            AddComponent<AbilityEffectComponent, List<Effect>>(SkillConfigObject.EffectList);
            ExecutionConfigObject = Framework.Instance.GetModule<ResModule>().LoadRes<ExecutionConfigObject>(string.Empty);
        }

        public void ActivateAbility()
        {
            Enable = true;

            if (SkillConfigObject.EnbaleChildStatus)
            {
                foreach (var item in SkillConfigObject.StatusList)
                {
                    var status = Owner.AttachStatus(item.statusConfigObject.Id);
                    status.Creator = Owner;
                    status.IsChildStatus = true;
                    status.ChildStatusData = item;
                    status.SetParams(item.paramsDict);
                    status.ActivateAbility();
                    m_StatusList.Add(status);
                }
            }
        }


        public void EndAbility()
        {

            Enable = false;
            if (SkillConfigObject.EnbaleChildStatus)
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
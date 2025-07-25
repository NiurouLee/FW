using System;
using System.Collections.Generic;
using Sirenix.OdinInspector;


namespace NFramework.Module.Combat
{
    [Effect("施加状态效果", 30)]
    [Serializable]
    public class AddStatusEffect : Effect
    {
        public override string Label
        {
            get
            {
                if (this.StatusConfigObject != null)
                {
                    return $"施加[{this.StatusConfigObject.Name}] 状态效果";
                }
                return "施加状态效果";
            }
        }


        [ToggleGroup("Enable")]
        [LabelText("状态配置")]
        public StatusConfigObject StatusConfigObject;

        [ToggleGroup("Enable"), LabelText("持续时间"), SuffixLabel("毫秒", true)]
        public uint Duration;

        [HideReferenceObjectPicker]
        [ToggleGroup("Enable")]
        [LabelText("参数列表")]
        public Dictionary<string, string> ParamsDict = new Dictionary<string, string>();
    }
}
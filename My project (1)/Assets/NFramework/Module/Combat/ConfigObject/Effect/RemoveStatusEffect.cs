using NFramework.Module.EntityModule;
using Unity.VisualScripting;

namespace NFramework.Module.Combat
{
    public class RemoveStatusEffect : Effect
    {
        public override string Label
        {
            get
            {
                if (this.statusConfigObject != null)
                {
                    return $"移除{statusConfigObject.Name}";
                }
                return "移除状态";
            }

        }

        public StatusConfigObject statusConfigObject;


    }
}
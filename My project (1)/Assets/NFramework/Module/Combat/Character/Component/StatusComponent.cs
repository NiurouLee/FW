using System.Collections.Generic;
using NFramework.Module.EntityModule;
using NFramework.Module.Res;

namespace NFramework.Module.Combat
{
    public class StatusComponent : Entity
    {
        public Combat Combat => GetParent<Combat>();
        public List<StatusAbility> statusList = new List<StatusAbility>();

        public Dictionary<int, List<StatusAbility>> statusDict = new Dictionary<int, List<StatusAbility>>();

        public StatusAbility AddStatus(int StatusId)
        {
            StatusConfigObject statusConfigObject = Framework.Instance.GetModule<ResModule>().Load<StatusConfigObject>(string.Empty);
            if (statusConfigObject == null)
            {
                return null;
            }

            var status = Combat.AttachAbility<StatusAbility>(statusConfigObject);
            if (!statusDict.ContainsKey(status.statusConfigObject.Id))
            {
                statusDict.Add(status.statusConfigObject.Id, new List<StatusAbility>());
            }
        }
    }
}
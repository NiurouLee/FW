using System.Collections.Generic;
using NFramework.Core.Collections;
using NFramework.Module.EntityModule;
using NFramework.Module.Res;

namespace NFramework.Module.Combat
{
    public class StatusComponent : Entity
    {
        public Combat Combat => GetParent<Combat>();
        public List<StatusAbility> statusList = new List<StatusAbility>();

        public UnOrderMultiMapVector<int, StatusAbility> statusDict = new UnOrderMultiMapVector<int, StatusAbility>();

        public StatusAbility AddStatus(int StatusId)
        {
            StatusConfigObject statusConfigObject = Framework.Instance.GetModule<ResModule>().Load<StatusConfigObject>(string.Empty);
            if (statusConfigObject == null)
            {
                return null;
            }

            var status = Combat.AttachAbility<StatusAbility>(statusConfigObject);
            if (!statusDict.ContainsKey(status.StatusConfigObject.Id))
            {
                statusDict.Add(status.StatusConfigObject.Id, new List<StatusAbility>());

            }
            statusDict[status.StatusConfigObject.Id].Add(status);
            statusList.Add(status);
            return status;
        }

        public StatusAbility GetStatus(int statusID, int index = 0)
        {
            if (HasStatus(statusID))
            {
                return statusDict[statusID][index];
            }
            return null;
        }

        public void OnStatusRemove(StatusAbility inStatusAbility)
        {
            statusDict[inStatusAbility.StatusConfigObject.Id].Remove(inStatusAbility);
            statusList.Remove(inStatusAbility);
        }
        private bool HasStatus(int statusID)
        {
            return statusDict.ContainsKey(statusID);
        }
    }
}
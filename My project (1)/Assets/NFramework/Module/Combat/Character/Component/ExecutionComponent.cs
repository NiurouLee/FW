
using System;
using System.Collections.Generic;
using NFramework.Module.EntityModule;
using NFramework.Module.Res;

namespace NFramework.Module.Combat
{
    public class ExecutionComponent : Entity
    {
        public Combat Combat => GetParent<Combat>();
        public Dictionary<int, ExecutionConfigObject> executionDict = new Dictionary<int, ExecutionConfigObject>();

        public ExecutionConfigObject AttachExectuion(int executionID)
        {
            if (GetExecution(executionID) != null)
            {
                return GetExecution(executionID);
            }
            ExecutionConfigObject executionConfigObject = Framework.I.G<ResM>().Load<ExecutionConfigObject>(string.Empty);
            if (executionConfigObject == null)
            {
                return null;
            }

            if (!executionDict.ContainsKey(executionConfigObject.id))
            {
                executionDict.Add(executionConfigObject.id, executionConfigObject);
            }
            return executionConfigObject;
        }

        public ExecutionConfigObject GetExecution(int executionID)
        {
            if (executionDict.ContainsKey(executionID))
            {
                return executionDict[executionID];
            }
            return null;
        }
    }
}
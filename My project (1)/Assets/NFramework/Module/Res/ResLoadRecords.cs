using NFramework.Core.Collections;
using Proto.Promises;
using UnityEngine;

namespace NFramework.Module.Res
{
    public class ResLoadRecords : BaseRecords<ResHandler>, IResLoader
    {
        public void Free<T>(T inObj) where T : Object
        {
            throw new System.NotImplementedException();
        }

        public T Load<T>(string inAssetID) where T : Object
        {
            throw new System.NotImplementedException();
        }

        public Promise<T> LoadAsync<T>(string inAssetID) where T : Object
        {
            throw new System.NotImplementedException();
        }

        public Promise<T> LoadAsyncAndInstantiate<T>(string inAssetID) where T : Object
        {
            throw new System.NotImplementedException();
        }
    }
}

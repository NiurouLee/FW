using System.Collections.Generic;
using UnityEngine;

public class ResourceManager
{
    public static ResourceManager Instance { get; private set; }

    public Dictionary<string, string> AssetID2PathDic = new Dictionary<string, string>();

    public T Load<T>(string inAssetID) where T : Object
    {
        if (this.AssetID2PathDic.TryGetValue(inAssetID, out var path))
        {
            return Resources.Load(path) as T;
        }
        return null;
    }

}


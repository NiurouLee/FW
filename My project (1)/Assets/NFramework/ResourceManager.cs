using System;
using System.Collections.Generic;
using UnityEngine;

public class ResourceManager
{
    public static ResourceManager Instance { get; private set; } = new();

    public Dictionary<string, string> AssetID2PathDic = new Dictionary<string, string>();

    public void AwakeAssetID2PathMap(List<Tuple<string, string>> inCfgList)
    {
        this.AssetID2PathDic = new Dictionary<string, string>();
        foreach (var item in inCfgList)
        {
            this.AssetID2PathDic.Add(item.Item1, item.Item2);
        }
    }

    public T Load<T>(string inAssetID) where T : UnityEngine.Object
    {
        if (this.AssetID2PathDic.TryGetValue(inAssetID, out var path))
        {
            return Resources.Load(path) as T;
        }
        return null;
    }

}


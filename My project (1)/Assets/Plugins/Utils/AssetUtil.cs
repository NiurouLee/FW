using Ez.Assets;
using System.Collections.Generic;
using UnityEngine;

namespace client
{
    public sealed class AssetUtil
    {
        private static Dictionary<string, string> mapPath;

        public static EzAdapter adapter { get; private set; }

        public static void Init(string path)
        {
            if (adapter == null)
            {
                adapter = new EzAdapter();
                AssetAdapter.InitAdapter(adapter);
            }
            else
            {
                Debug.LogError("has inited.....");
            }

            var lines = Ez.Core.FileSystem.VFileSystem.ReadAllLines(path, System.Text.Encoding.UTF8);
            mapPath = new Dictionary<string, string>(lines.Length);

            foreach (var line in lines)
            {
                var values = line.Split(';');
                if (values.Length >= 2)
                {
                    var strId = values[0];
                    mapPath.Add(strId, values[1]);
                }
            }

            adapter.Init(mapPath);
        }
        /// <summary>
        /// 判断资源是否存在
        /// </summary>
        /// <param name="key"></param>
        /// <returns></returns>
        public static bool HasKey(string key)
        {
            return mapPath.ContainsKey(key);
        }

        public static void Final()
        {
            mapPath.Clear();
            mapPath = null;

            adapter.Final();
            adapter = null;
        }
    }
}
using System;
using System.Collections;
using System.Collections.Generic;
using System.Globalization;
using Game.Asset;
using Game.Conf.Fight;
using Luban;
using UnityEngine;

namespace Game.Conf
{
    public class ConfManager
    {
        private readonly Dictionary<Type, IDictionary> m_MapConfs = new();
        private readonly Dictionary<Type, IList> m_ListConfs = new();
        private readonly Dictionary<Type, BeanBase> m_BeanConfs = new();

        //生成单例代码
        private static ConfManager m_Instance;
        public static ConfManager Instance
        {
            get
            {
                if (m_Instance == null)
                {
                    m_Instance = new ConfManager();
                }

                return m_Instance;
            }
        }
        public static void DestroyInstance()
        {
            if (m_Instance != null)
            {
                m_Instance.DoRelease();
                m_Instance = null;
            }
        }
        private delegate Luban.BeanBase ConvertCfg(int id);
        Dictionary<Type, ConvertCfg> m_ConvertDic = new Dictionary<Type, ConvertCfg>();
        Dictionary<Type, Dictionary<int,Luban.BeanBase>> m_ConvertDicCatch = new Dictionary<Type, Dictionary<int,Luban.BeanBase>>();

        public ConfManager()
        {
            
            m_ConvertDic.Add(typeof(BossNpcCfg), BossNpcCfg.ConvertBossNpcCfg);
            m_ConvertDic.Add(typeof(NormalNpcCfg), NormalNpcCfg.ConvertBossNpcCfg);
            m_ConvertDic.Add(typeof(NormalNpcGroupCfg), NormalNpcGroupCfg.ConvertBossNpcCfg);
            m_ConvertDic.Add(typeof(PropertyGroupCfg), PropertyGroupCfg.ConvertBossNpcCfg);
        }

        public void DoRelease()
        {
            m_ConvertDic.Clear();
            m_ConvertDicCatch.Clear();
        }
        /// <summary>
        /// 预加载配置
        /// </summary>
        public void prepare()
        {
            GetDictionary<int, WeaponCfg>();
            GetDictionary<int, PropertyGroupCfg>();
            GetDictionary<int, PropertyCfg>();
        }

        public IReadOnlyDictionary<K, V> GetDictionary<K, V>() where V : BeanBase
        {
            if (!m_MapConfs.TryGetValue(typeof(V), out var conf))
            {
                if (!ConfDefine.Conf2MapFunc.TryGetValue(typeof(V), out var func))
                {
                    Debug.LogError($"[Conf] Cannot Find {typeof(V)} Func");
                    return null;
                }

                var path = $"Conf/{func.Name}.bytes";
                var asset = AssetManager.Instance.Load(path)?.DiskAsset as TextAsset;
                if (asset == null)
                {
                    return null;
                }

                try
                {
                    conf = func.MapFunc(new ByteBuf(asset.bytes));
                }
                catch (Exception e)
                {
                    Debug.LogException(e);
                    return null;
                }

                AssetManager.Instance.Unload(path);
                if (conf is not Dictionary<K, V>)
                {
                    Debug.LogError($"[Conf] Type Error {typeof(V)}");
                    return null;
                }

                m_MapConfs.Add(typeof(V), conf);
            }

            return conf as IReadOnlyDictionary<K, V>;
        }
  
 

        /// <summary>
        ///  获取配置
        /// </summary>
        /// <param name="id"></param>
        /// <typeparam name="T"></typeparam>
        /// <returns></returns>
        public T ContainsConvert<T>(int id) where T : BeanBase
        {
            Type cfgT = typeof(T);
            if(m_ConvertDicCatch.ContainsKey(cfgT))
            {
                if(m_ConvertDicCatch[cfgT].ContainsKey(id))
                {
                    return m_ConvertDicCatch[cfgT][id] as T;
                }
            }
            if (m_ConvertDic.ContainsKey(cfgT))
            {
                try
                {
                    var item = m_ConvertDic[cfgT](id) as T;
                    if (item != null)
                    {
                        if (!m_ConvertDicCatch.ContainsKey(cfgT))
                        {
                            m_ConvertDicCatch.Add(cfgT, new Dictionary<int, Luban.BeanBase>());
                        }
                        m_ConvertDicCatch[cfgT].Add(id, item);
                        return item;
                    }
                }
                catch (Exception e)
                {
                    Debug.LogError(" GetById Error "+cfgT.ToString() + e.Message);
                    return null;
                }
            }

            return null;
        }
        public T GetById<T>(int id, bool logError = false) where T : BeanBase
        {
            var ConvertCfg = ContainsConvert<T>(id);
            if (ConvertCfg!=null)
            {
                return ConvertCfg;
            }
 
            var dictionary = GetDictionary<int, T>();
            if (dictionary == null)
            {
                return null;
            }

            if (!dictionary.TryGetValue(id, out var value))
            {
                if (logError)
                {
                    Debug.LogError($"[Conf] Cannot Find {typeof(T)} With {id}");
                }

                return null;
            }

            return value;
        }

        public T GetByKey<K, T>(K key, bool logError = true) where T : BeanBase
        {
            var dictionary = GetDictionary<K, T>();
            if (dictionary == null)
            {
                return null;
            }

            if (!dictionary.TryGetValue(key, out var value))
            {
                if (logError)
                {
                    Debug.LogError($"[Conf] Cannot Find {typeof(T)} With {key}");
                }

                return null;
            }

            return value;
        }

        public IReadOnlyList<T> GetList<T>() where T : BeanBase
        {
            if (!m_ListConfs.TryGetValue(typeof(T), out var conf))
            {
                if (!ConfDefine.Conf2ListFunc.TryGetValue(typeof(T), out var func))
                {
                    Debug.LogError($"[Conf] Cannot Find {typeof(T)} Func");
                    return null;
                }

                var path = $"Conf/{func.Name}.bytes";
                var asset = AssetManager.Instance.Load(path)?.DiskAsset as TextAsset;
                if (asset == null)
                {
                    return null;
                }

                try
                {
                    conf = func.ListFunc(new ByteBuf(asset.bytes));
                }
                catch (Exception e)
                {
                    Debug.LogException(e);
                    return null;
                }

                AssetManager.Instance.Unload(path);
                if (conf is not List<T>)
                {
                    Debug.LogError($"[Conf] Type Error {typeof(T)}");
                    return null;
                }

                m_ListConfs.Add(typeof(T), conf);
            }

            return conf as IReadOnlyList<T>;
        }

        public T GetByIndex<T>(int index) where T : BeanBase
        {
            var list = GetList<T>();
            if (list == null)
            {
                return null;
            }

            if (index < 0 || index >= list.Count)
            {
                Debug.LogError($"[Conf] Cannot Find {typeof(T)} With {index}");
                return null;
            }

            return list[index];
        }

        public T GetBean<T>() where T : BeanBase
        {
            if (!m_BeanConfs.TryGetValue(typeof(T), out var conf))
            {
                if (!ConfDefine.Conf2BeanFunc.TryGetValue(typeof(T), out var func))
                {
                    Debug.LogError($"[Conf] Cannot Find {typeof(T)} Func");
                    return null;
                }

                var path = $"Conf/{func.Name}.bytes";
                var asset = AssetManager.Instance.Load(path)?.DiskAsset as TextAsset;
                if (asset == null)
                {
                    return null;
                }

                try
                {
                    conf = func.BeanFunc(new ByteBuf(asset.bytes));
                }
                catch (Exception e)
                {
                    Debug.LogException(e);
                    return null;
                }

                AssetManager.Instance.Unload(path);
                if (conf is not T)
                {
                    Debug.LogError($"[Conf] Type Error {typeof(T)}");
                    return null;
                }

                m_BeanConfs.Add(typeof(T), conf);
            }

            return conf as T;
        }

    }
}
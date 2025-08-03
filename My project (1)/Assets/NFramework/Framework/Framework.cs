using System;
using System.Collections.Generic;

namespace NFramework
{
    public class Framework
    {
        public static Framework I => Instance;
        public static Framework Instance { get; private set; }

        /// <summary>
        /// 按类型存储
        /// </summary>
        public Dictionary<Type, IFrameWorkModule> m_modulesDict;
        /// <summary>
        /// 按顺序轮询
        /// </summary>
        public List<IFrameWorkModule> m_modulesList;

        public void Awake()
        {
            Instance = this;
        }
        public T G<T>() where T : IFrameWorkModule
        {
            return GetModule<T>();
        }

        public T GetModule<T>() where T : IFrameWorkModule
        {
            if (m_modulesDict.TryGetValue(typeof(T), out var module))
            {
                return (T)module;
            }
            return null;
        }


        public void AddModel<T>() where T : IFrameWorkModule, new()
        {
            var type = typeof(T);
            if (m_modulesDict.ContainsKey(type))
            {
                // Framework.Instance.GetModule<Log>()?.Err($"Framework::AddModel 重复添加模块 {type.Name}");
                return;
            }

            var module = new T();
            module.Awake();
            m_modulesDict[typeof(T)] = module;
            m_modulesList.Add(module);
        }

        public void OpenAll()
        {
            for (int i = 0; i < m_modulesList.Count; i++)
            {
                m_modulesList[i].Open();
            }
        }

        public void Update(float elapseSeconds, float realElapseSeconds)
        {
            for (int i = 0; i < m_modulesList.Count; i++)
            {
                m_modulesList[i].Update(elapseSeconds, realElapseSeconds);
            }
        }

        public void CloseAll()
        {
            for (int i = 0; i < m_modulesList.Count; i++)
            {
                m_modulesList[i].Close();
            }
        }

        public void DestroyAll()
        {
            for (int i = 0; i < m_modulesList.Count; i++)
            {
                m_modulesList[i].Destroy();
            }
            m_modulesDict.Clear();
            m_modulesList.Clear();
        }

    }

}
using NFramework.Core;

namespace NFramework
{
    public class Framework
    {
        public static Framework Instance { get; private set; }

        public static I=>Instance;

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
        public void AddModel<T>() where T : IFrameWorkModule, new()
        {
            var type = typeof(T);
            if (m_modulesDict.ContainsKey(type))
            {
                Log.Err($"Framework::AddModel 重复添加模块 {type.Name}");
                return;
            }

            var module = new T();
            module.Awake();
            m_modulesDict[typeof(T)] = module;
            m_modulesList.Add(module);
        }




    }

}
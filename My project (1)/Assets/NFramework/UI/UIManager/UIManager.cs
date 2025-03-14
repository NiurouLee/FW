using System;
using System.Reflection;
using System.Collections.Generic;
using Proto.Promises;

namespace NFramework.UI
{
    public partial class UIManager
    {
        public static UIManager Instance { get; private set; }
      
        public ViewConfigServices ConfigServices { get; private set; }

        public void Awake()
        {
            this.ConfigServices = new ViewConfigServices();
        }

        public Promise<T> Open<T>()
        {
            var result = Promise<T>.NewDeferred();
            return result.Promise;
        }


        public ViewConfig GetViewConfig<T>() where T : View
        {
            var type = typeof(T);
            if (this.type2ConfigNameDic.TryGetValue(type, out var configName))
            {
                return this.GetViewConfig(configName);
            }
            return null;
        }


        public ViewConfig GetViewConfig(string inName)
        {
            return this.ConfigServices.GetViewConfig(inName);
        }




        public void AwakeRoot()
        {

        }


        public T CreateView<T>() where T : View, new()
        {
            return new T();
        }

        // private Dictionary<string, ViewConfig> ;
        // private Dictionary<>
        // public ViewConfig GetConfig<T>() where T : View
        // {
        //     
        // }
    }
}
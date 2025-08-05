using System;
using System.Collections.Generic;
using Proto.Promises;

namespace NFramework.Module.UI
{
    public partial class UIM : IFrameWorkModule
    {
        public ViewConfigServices ConfigServices { get; private set; }

        public void AwakeTypeCfg(List<Tuple<Type, string, ViewConfig>> inCfgList)
        {
            this.ConfigServices = new ViewConfigServices();
            foreach (var item in inCfgList)
            {
                this.ConfigServices.AddViewConfig(item.Item1, item.Item2, item.Item3);
            }
        }

        public Promise<T> Open<T>()
        {
            var result = Promise<T>.NewDeferred();
            return result.Promise;
        }


        public ViewConfig GetViewConfig<T>() where T : View
        {
            return this.ConfigServices.GetViewConfig<T>();
        }

        public ViewConfig GetViewConfig(string inName)
        {
            return this.ConfigServices.GetViewConfig(inName);
        }


        public T CreateView<T>() where T : View, new()
        {
            return new T();
        }

        public View CreateView(ViewConfig inViewConfig)
        {
            var type = this.ConfigServices.GetViewType(inViewConfig.ID);
            if (type == null)
            {
                throw new Exception($"ViewConfig {inViewConfig.ID} not found");
            }
            return Activator.CreateInstance(type) as View;
        }

    }
}
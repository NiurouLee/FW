using System;
using Google.FlatBuffers;
using NFramework.Module.Config.DataPipeline;
using NFramework.Module.LogModule;

namespace NFramework.Module.ConfigModule
{
    public class ConfigM : IFrameWorkModule
    {
        private ConfigDataLoader _dataLoader;
        private IConfigDataProvider _dataProvider;

        public void Initialize()
        {
            _dataLoader = ConfigDataLoader.Instance;
            
#if WECHAT_MINIGAME
            _dataProvider = new WeChatConfigDataProvider();
#else
            _dataProvider = new SQLiteConfigDataProvider();
#endif
            _dataLoader.Initialize(_dataProvider);
        }

        public T GetCfg<T>(int id) where T : class, IFlatbufferObject, new()
        {
            try
            {
                string configType = typeof(T).Name;
                return _dataLoader.LoadConfig<T>(configType, id.ToString());
            }
            catch (Exception ex)
            {
                Framework.Instance.GetModule<LoggerM>()?.Err($"ConfigM::GetCfg - Error loading {typeof(T).Name} with id {id}: {ex.Message}");
                return null;
            }
        }

        public void Dispose()
        {
            _dataLoader?.Dispose();
        }
    }
}
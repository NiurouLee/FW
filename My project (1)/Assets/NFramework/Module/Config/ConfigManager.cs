
using System.Diagnostics;
using Google.FlatBuffers;
using NFramework.Module.Log;

namespace NFramework.Module.Config
{
    public class Config : IFrameWorkModule
    {
        public StackTrace m_markStack;

        public void MarkCfgObject(ref IFlatbufferObject inCfgObject)
        {
            if (m_markStack != null)
            {
                Framework.Instance.GetModule<LoggerModule>()?.Err("ConfigManager::MarkCfgObject 重复标记");
                return;
            }
            m_markStack = new StackTrace(true);
            //标记一下正在使用的表对象
        }

        public void UnMarkCfgObject(ref IFlatbufferObject inCfgObject)
        {
            m_markStack = null;
            //取消标记
        }


    }
}

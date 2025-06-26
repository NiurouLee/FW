
using System.Diagnostics;
using Google.FlatBuffers;

namespace NFramework.Cfg
{
    public class ConfigManager
    {


        public StackTrace m_markStack;

        public void MarkCfgObject(ref IFlatbufferObject inCfgObject)
        {
            if (m_markStack != null)
            {
                Log.Err("ConfigManager::MarkCfgObject 重复标记");
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

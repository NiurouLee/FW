using NFramework.Module.LogModule;

namespace NFramework.Module.UIModule
{
    public class UIObject
    {
        public FM GetFM<FM>() where FM : IFrameWorkModule
        {
            return Framework.I.G<FM>();
        }

        public void Log(string inMessage)
        {
            GetFM<LoggerM>().Log(inMessage);
        }

        public void Error(string inMessage)
        {
            GetFM<LoggerM>().Error(inMessage);
        }

        public void Warn(string inMessage)
        {
            GetFM<LoggerM>().Warn(inMessage);
        }

    }
}
using NFramework.Module.LogModule;

namespace NFramework.Module.UIModule
{
    public class UIObject
    {
        public FM GetFM<FM>() where FM : IFrameWorkModule
        {
            return Framework.I.G<FM>();
        }

        public Log? Log
        {
            get
            {
                return GetFM<LoggerM>().Log;
            }
        }
        public Error? Error
        {
            get
            {
                return GetFM<LoggerM>().Error;
            }
        }

        public Warning? Warning
        {
            get
            {
                return GetFM<LoggerM>().Warning;
            }
        }

    }
}
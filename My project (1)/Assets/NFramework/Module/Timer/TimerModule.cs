using System;

namespace NFramework.Module.TimerModule
{
    public class TimerModule : IFrameWorkModule
    {

        public long NewOnceTimer(float time, Action action)
        {
            return 0;
        }

        public void RemoveTimer(long timer)
        {
        }

        public void Update(float deltaTime)
        {
        }
    }
}

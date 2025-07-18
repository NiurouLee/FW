using System;

namespace NFramework.Module.TimerModule
{
    /// <summary>
    /// https://www.zhihu.com/question/52968810/answer/1929456142423163724
    /// </summary>
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

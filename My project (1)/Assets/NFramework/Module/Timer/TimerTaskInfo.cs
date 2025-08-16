using NFramework.Core.ObjectPool;

namespace NFramework.Module.TimerModule
{
    public class TaskTimerInfo : IFreeToPool
    {
        public long TaskID { get; set; }
        public uint WheelIndex { get; set; }
        public int WheelSlotIndex;

        public void FreeToPool()
        {
            this.TaskID = -1;
            this.WheelIndex = uint.MaxValue;
            this.WheelSlotIndex = -1;
        }
    }
}
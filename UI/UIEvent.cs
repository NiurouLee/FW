namespace Game
{
    /// <summary>
    /// 通用框架层UI事件
    /// </summary>
    public class UIEvent
    {
        /// <summary>
        /// 通用普通飞行特效事件
        /// </summary>
        public const string FlyParamEvent = nameof(FlyParamEvent);

        /// <summary>
        /// 通用特殊飞行特效事件
        /// </summary>
        public const string FlyParamSpecialEvent = nameof(FlyParamSpecialEvent);

        /// <summary>
        /// 清理UI相关的飞行特效事件
        /// </summary>
        public const string FlyParamClearEvent = nameof(FlyParamClearEvent);
    }
}

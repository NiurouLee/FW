namespace Game
{
    [System.Flags]
    public enum EGraphicQuality : int
    {
        None = 0,
        Standard = 1 << 0,
        Medium = 1 << 1,
        High = 1 << 2,
        Ultra = 1 << 3,
    }
    /// <summary>
    /// 由于Base也要用品质所以做个桥接
    /// </summary>
    public static class Qualty
    {

        static EGraphicQuality m_Quality = EGraphicQuality.Standard;
        public static void SetQuality(EGraphicQuality level)
        {
            m_Quality = level;
        }
        public static EGraphicQuality GetQuality()
        {
            return m_Quality;
        }
    }
}
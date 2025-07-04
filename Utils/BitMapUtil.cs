namespace client
{
    public sealed class BitMapUtil
    {
        public static void Set(ref uint value, int bit)
        {
            value |= (1u << bit);
        }

        public static bool Get(uint value, int bit)
        {
            return (value & (1u << bit)) != 0;
        }

        public static void Reset(ref uint value, int bit)
        {
            value &= ~(1u << bit);
        }

        public static void Set(ref ulong value, int bit)
        {
            value |= (1u << bit);
        }

        public static bool Get(ulong value, int bit)
        {
            return (value & (1u << bit)) != 0;
        }

        public static void Reset(ref ulong value, int bit)
        {
            value &= ~(1u << bit);
        }
    }
}

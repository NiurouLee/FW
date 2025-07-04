using System;

namespace Game
{
    public class ArrayUtil
    {
        // 获取数组的子数组
        public static T[] GetSubArray<T>(T[] sourceArray, int startIndex, int endIndex)
        {
            if (startIndex < 0 || endIndex >= sourceArray.Length || startIndex > endIndex)
            {
                throw new ArgumentException("无效的索引范围");
            }

            int subArrayLength = endIndex - startIndex + 1;

            T[] subArray = new T[subArrayLength];

            // 使用 Array.Copy 复制数组的特定区间
            Array.Copy(sourceArray, startIndex, subArray, 0, subArrayLength);

            return subArray;
        }
    }
}

using System;

namespace NFramework.Core.Collections
{
    [Serializable]
    public struct BitField128 : IEquatable<BitField128>
    {
        public static int MinBitCount = 0;
        public static int MidBitCount = 64;
        public static int MaxBitCount = 128;
        private ulong _low;
        private ulong _high;

        #region 构造函数
        public BitField128(ulong low = 0, ulong high = 0)
        {
            _low = low;
            _high = high;
        }

        public BitField128(ulong lowBits, ulong highBits)
        {
            _low = lowBits;
            _high = highBits;
        }

        #endregion

        #region 属性

        /// <summary>
        /// 获取或设置低64位值
        /// </summary>
        public ulong Low
        {
            get => _low;
            set => _low = value;
        }

        /// <summary>
        /// 获取或设置高64位值
        /// </summary>
        public ulong High
        {
            get => _high;
            set => _high = value;
        }

        #endregion

        #region 位操作方法

        /// <summary>
        /// 获取指定位置的位状态
        /// </summary>
        /// <param name="position">位置 (0-127)</param>
        /// <returns>位状态</returns>
        public bool GetBit(int position)
        {
            if (position < MinBitCount || position >= MaxBitCount)
                throw new ArgumentOutOfRangeException(nameof(position), "Position must be between 0 and 127");

            if (position < MidBitCount)
                return (_low & (1UL << position)) != 0;
            else
                return (_high & (1UL << (position - MidBitCount))) != 0;
        }

        /// <summary>
        /// 设置指定位置的位状态
        /// </summary>
        /// <param name="position">位置 (0-127)</param>
        /// <param name="value">要设置的状态</param>
        public void SetBit(int position, bool value)
        {
            if (position < MinBitCount || position >= MaxBitCount)
                throw new ArgumentOutOfRangeException(nameof(position), "Position must be between 0 and 127");

            if (position < MidBitCount)
            {
                if (value)
                    _low |= (1UL << position);
                else
                    _low &= ~(1UL << position);
            }
            else
            {
                int highPos = position - MidBitCount;
                if (value)
                    _high |= (1UL << highPos);
                else
                    _high &= ~(1UL << highPos);
            }
        }

        /// <summary>
        /// 判断
        /// </summary>
        public bool Has(int bitId)
        {
            if (bitId < MinBitCount || bitId >= MaxBitCount)
                throw new ArgumentOutOfRangeException(nameof(bitId));

            return GetBit(bitId);
        }

        /// <summary>
        /// 标记
        /// </summary>
        public void Learn(int bitId)
        {
            if (bitId < MinBitCount || bitId >= MaxBitCount)
                throw new ArgumentOutOfRangeException(nameof(bitId));

            SetBit(bitId, true);
        }

        /// <summary>
        /// 清除
        /// </summary>
        public void Forget(int bitId)
        {
            if (bitId < MinBitCount || bitId >= MaxBitCount)
                throw new ArgumentOutOfRangeException(nameof(bitId));

            SetBit(bitId, false);
        }

        /// <summary>
        /// 清除所有低位（0-63位）
        /// </summary>
        public void ClearLowBits()
        {
            _low = 0;
        }

        /// <summary>
        /// 清除所有高位（64-127位）
        /// </summary>
        public void ClearHighBits()
        {
            _high = 0;
        }

        /// <summary>
        /// 清除所有位
        /// </summary>
        public void Clear()
        {
            _low = 0;
            _high = 0;
        }

        #endregion

        #region 批量操作

        /// <summary>
        /// 获取指定范围
        /// </summary>
        public ulong GetRange(int startBit, int endBit)
        {
            if (startBit < MinBitCount || endBit >= MaxBitCount || startBit > endBit)
                throw new ArgumentException("Invalid range");

            // 简化实现：只返回低64位的结果
            if (endBit < MidBitCount)
            {
                int length = endBit - startBit + 1;
                ulong mask = ((1UL << length) - 1) << startBit;
                return (_low & mask) >> startBit;
            }
            else if (startBit >= MidBitCount)
            {
                int length = endBit - startBit + 1;
                int highStart = startBit - MidBitCount;
                ulong mask = ((1UL << length) - 1) << highStart;
                return (_high & mask) >> highStart;
            }
            else
            {
                // 跨边界的情况，需要特殊处理
                throw new ArgumentException("Range cannot span across low and high parts");
            }
        }

        /// <summary>
        /// 设置指定范围
        /// </summary>
        public void SetRange(int startBit, int endBit, ulong value)
        {
            if (startBit < MinBitCount || endBit >= MaxBitCount || startBit > endBit)
                throw new ArgumentException("Invalid range");

            if (endBit < MidBitCount)
            {
                int length = endBit - startBit + 1;
                ulong mask = ((1UL << length) - 1) << startBit;
                _low = (_low & ~mask) | ((value << startBit) & mask);
            }
            else if (startBit >= MidBitCount)
            {
                int length = endBit - startBit + 1;
                int highStart = startBit - MidBitCount;
                ulong mask = ((1UL << length) - 1) << highStart;
                _high = (_high & ~mask) | ((value << highStart) & mask);
            }
            else
            {
                throw new ArgumentException("Range cannot span across low and high parts");
            }
        }

        #endregion

        #region 运算符重载

        public static bool operator ==(BitField128 left, BitField128 right)
            => left._low == right._low && left._high == right._high;

        public static bool operator !=(BitField128 left, BitField128 right)
            => left._low != right._low || left._high != right._high;

        public override int GetHashCode()
        {
            unchecked
            {
                return (_low.GetHashCode() * 397) ^ _high.GetHashCode();
            }
        }

        public override string ToString()
            => $"Low: 0x{Low:X16}, High: 0x{High:X16}";

        public bool Equals(BitField128 other)
        {
            return _low == other._low && _high == other._high;
        }

        public override bool Equals(object obj)
        {
            return obj is BitField128 other && Equals(other);
        }

        #endregion
    }
}


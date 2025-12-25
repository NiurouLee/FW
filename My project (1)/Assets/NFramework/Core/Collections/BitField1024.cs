using System;

namespace NFramework.Core.Collections
{
    [Serializable]
    public struct BitField1024 : IEquatable<BitField1024>
    {
        public static int MinBitCount = 0;
        public static int MaxBitCount = 1024;
        private const int BitsPerUlong = 64;
        private const int UlongCount = 16;
        private ulong _value0;
        private ulong _value1;
        private ulong _value2;
        private ulong _value3;
        private ulong _value4;
        private ulong _value5;
        private ulong _value6;
        private ulong _value7;
        private ulong _value8;
        private ulong _value9;
        private ulong _value10;
        private ulong _value11;
        private ulong _value12;
        private ulong _value13;
        private ulong _value14;
        private ulong _value15;

        #region 构造函数
        public BitField1024()
        {
            _value0 = 0;
            _value1 = 0;
            _value2 = 0;
            _value3 = 0;
            _value4 = 0;
            _value5 = 0;
            _value6 = 0;
            _value7 = 0;
            _value8 = 0;
            _value9 = 0;
            _value10 = 0;
            _value11 = 0;
            _value12 = 0;
            _value13 = 0;
            _value14 = 0;
            _value15 = 0;
        }

        #endregion

        #region 私有辅助方法

        private ref ulong GetUlongRef(int position)
        {
            int index = position / BitsPerUlong;
            switch (index)
            {
                case 0: return ref _value0;
                case 1: return ref _value1;
                case 2: return ref _value2;
                case 3: return ref _value3;
                case 4: return ref _value4;
                case 5: return ref _value5;
                case 6: return ref _value6;
                case 7: return ref _value7;
                case 8: return ref _value8;
                case 9: return ref _value9;
                case 10: return ref _value10;
                case 11: return ref _value11;
                case 12: return ref _value12;
                case 13: return ref _value13;
                case 14: return ref _value14;
                case 15: return ref _value15;
                default: throw new ArgumentOutOfRangeException();
            }
        }

        private ulong GetUlong(int position)
        {
            int index = position / BitsPerUlong;
            switch (index)
            {
                case 0: return _value0;
                case 1: return _value1;
                case 2: return _value2;
                case 3: return _value3;
                case 4: return _value4;
                case 5: return _value5;
                case 6: return _value6;
                case 7: return _value7;
                case 8: return _value8;
                case 9: return _value9;
                case 10: return _value10;
                case 11: return _value11;
                case 12: return _value12;
                case 13: return _value13;
                case 14: return _value14;
                case 15: return _value15;
                default: throw new ArgumentOutOfRangeException();
            }
        }

        #endregion

        #region 位操作方法

        /// <summary>
        /// 获取指定位置的位状态
        /// </summary>
        /// <param name="position">位置 (0-1023)</param>
        /// <returns>位状态</returns>
        public bool GetBit(int position)
        {
            if (position < MinBitCount || position >= MaxBitCount)
                throw new ArgumentOutOfRangeException(nameof(position), "Position must be between 0 and 1023");

            int ulongIndex = position / BitsPerUlong;
            int bitIndex = position % BitsPerUlong;
            ulong value = GetUlong(ulongIndex);
            return (value & (1UL << bitIndex)) != 0;
        }

        /// <summary>
        /// 设置指定位置的位状态
        /// </summary>
        /// <param name="position">位置 (0-1023)</param>
        /// <param name="value">要设置的状态</param>
        public void SetBit(int position, bool value)
        {
            if (position < MinBitCount || position >= MaxBitCount)
                throw new ArgumentOutOfRangeException(nameof(position), "Position must be between 0 and 1023");

            int ulongIndex = position / BitsPerUlong;
            int bitIndex = position % BitsPerUlong;
            ref ulong ulongRef = ref GetUlongRef(ulongIndex);

            if (value)
                ulongRef |= (1UL << bitIndex);
            else
                ulongRef &= ~(1UL << bitIndex);
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
        /// 清除所有位
        /// </summary>
        public void Clear()
        {
            _value0 = 0;
            _value1 = 0;
            _value2 = 0;
            _value3 = 0;
            _value4 = 0;
            _value5 = 0;
            _value6 = 0;
            _value7 = 0;
            _value8 = 0;
            _value9 = 0;
            _value10 = 0;
            _value11 = 0;
            _value12 = 0;
            _value13 = 0;
            _value14 = 0;
            _value15 = 0;
        }

        #endregion

        #region 运算符重载

        public static bool operator ==(BitField1024 left, BitField1024 right)
            => left._value0 == right._value0 && 
               left._value1 == right._value1 && 
               left._value2 == right._value2 && 
               left._value3 == right._value3 &&
               left._value4 == right._value4 && 
               left._value5 == right._value5 && 
               left._value6 == right._value6 && 
               left._value7 == right._value7 &&
               left._value8 == right._value8 && 
               left._value9 == right._value9 && 
               left._value10 == right._value10 && 
               left._value11 == right._value11 &&
               left._value12 == right._value12 && 
               left._value13 == right._value13 && 
               left._value14 == right._value14 && 
               left._value15 == right._value15;

        public static bool operator !=(BitField1024 left, BitField1024 right)
            => !(left == right);

        public override int GetHashCode()
        {
            unchecked
            {
                int hash = _value0.GetHashCode();
                hash = (hash * 397) ^ _value1.GetHashCode();
                hash = (hash * 397) ^ _value2.GetHashCode();
                hash = (hash * 397) ^ _value3.GetHashCode();
                hash = (hash * 397) ^ _value4.GetHashCode();
                hash = (hash * 397) ^ _value5.GetHashCode();
                hash = (hash * 397) ^ _value6.GetHashCode();
                hash = (hash * 397) ^ _value7.GetHashCode();
                hash = (hash * 397) ^ _value8.GetHashCode();
                hash = (hash * 397) ^ _value9.GetHashCode();
                hash = (hash * 397) ^ _value10.GetHashCode();
                hash = (hash * 397) ^ _value11.GetHashCode();
                hash = (hash * 397) ^ _value12.GetHashCode();
                hash = (hash * 397) ^ _value13.GetHashCode();
                hash = (hash * 397) ^ _value14.GetHashCode();
                hash = (hash * 397) ^ _value15.GetHashCode();
                return hash;
            }
        }

        public override string ToString()
            => $"BitField1024: 0x{_value15:X16}{_value14:X16}{_value13:X16}{_value12:X16}{_value11:X16}{_value10:X16}{_value9:X16}{_value8:X16}{_value7:X16}{_value6:X16}{_value5:X16}{_value4:X16}{_value3:X16}{_value2:X16}{_value1:X16}{_value0:X16}";

        public bool Equals(BitField1024 other)
        {
            return _value0 == other._value0 && 
                   _value1 == other._value1 && 
                   _value2 == other._value2 && 
                   _value3 == other._value3 &&
                   _value4 == other._value4 && 
                   _value5 == other._value5 && 
                   _value6 == other._value6 && 
                   _value7 == other._value7 &&
                   _value8 == other._value8 && 
                   _value9 == other._value9 && 
                   _value10 == other._value10 && 
                   _value11 == other._value11 &&
                   _value12 == other._value12 && 
                   _value13 == other._value13 && 
                   _value14 == other._value14 && 
                   _value15 == other._value15;
        }

        public override bool Equals(object obj)
        {
            return obj is BitField1024 other && Equals(other);
        }

        #endregion
    }
}


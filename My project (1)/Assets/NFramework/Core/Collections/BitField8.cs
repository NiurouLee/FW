using System;

namespace NFramework.Core.Collections
{
    public struct BitField8
    {
        private byte _value;

        public BitField8(byte value = 0)
        {
            _value = value;
        }

        public bool GetBit(int position)
        {
            if (position < 0 || position >= 8)
                throw new ArgumentOutOfRangeException(nameof(position), "Position must be between 0 and 7");

            return (_value & (1 << position)) != 0;
        }

        public void SetBit(int position, bool value)
        {
            if (position < 0 || position >= 8)
                throw new ArgumentOutOfRangeException(nameof(position), "Position must be between 0 and 7");

            if (value)
                _value |= (byte)(1 << position);
            else
                _value &= (byte)~(1 << position);
        }

        public byte Value => _value;

    }
}


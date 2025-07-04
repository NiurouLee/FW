using System;
using System.Collections.Generic;

namespace client
{
    public class SlidingBuffer<T>
    {
        private readonly List<T> _buffer;
        private readonly int _capacity;

        public SlidingBuffer(int capacity)
        {
            if (capacity <= 0)
                throw new ArgumentException("Capacity must be greater than 0");

            _capacity = capacity;
            _buffer = new List<T>(_capacity);
        }

        public void Add(T item)
        {
            if (_buffer.Count >= _capacity)
            {
                // 删除最早添加的元素
                _buffer.RemoveAt(0);
            }
            // 添加新元素到末尾
            _buffer.Add(item);
        }

        public T this[int index]
        {
            get
            {
                if (index >= _buffer.Count || index < 0)
                {
                    return default(T);
                }

                return _buffer[index];
            }
        }

        public void Clear()
        {
            _buffer.Clear();
        }

        public int Count
        {
            get { return _buffer.Count; }
        }

        public int Capacity
        {
            get { return _capacity; }
        }
    }
}
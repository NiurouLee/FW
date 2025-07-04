using System.Collections.Generic;

namespace NFramework.Core.Collections
{
    public interface IRecords
    {
        public void Awake();
        public void Destroy();
    }

    public interface IRecords<T> : IRecords
    {
        public HashSet<T> Records { get; set; }
    }


    /// <summary>
    /// 只记录
    /// </summary>
    /// <typeparam name="T"></typeparam>
    public abstract class BaseRecords<T> : IRecords<T>
    {
        public HashSet<T> Records { get; set; }

        public void Awake()
        {
            if (this.Records == null)
            {
                this.Records = HashSetPool.Alloc<T>();
            }

            this.OnAwake();
        }

        protected virtual void OnAwake()
        {
        }


        public bool TryAdd(T inT)
        {
            if (this.Records.Contains(inT))
            {
                return false;
            }

            this.Records.Add(inT);
            return true;
        }

        public bool TryRemove(T inT)
        {
            if (this.Records.Contains(inT))
            {
                this.Records.Remove(inT);
                return true;
            }

            return false;
        }

        protected virtual void OnDestroy()
        {
        }

        public void Destroy()
        {
            this.OnDestroy();
            if (this.Records != null)
            {
                this.Records.Clear();
                HashSetPool.Free(this.Records);
                this.Records = null;
            }
        }
    }
}
using System.Collections.Generic;

public interface IRecords
{
    public void Awake();
    public void Destroy();
}

public interface IRecords<T> : IRecords where T : class
{
    public HashSet<T> records { get; set; }
}


/// <summary>
/// 只记录
/// </summary>
/// <typeparam name="T"></typeparam>
public abstract class BaseRecords<T> : IRecords<T> where T : class
{
    public HashSet<T> records { get; set; }

    public void Awake()
    {
        if (this.records == null)
        {
            this.records = HashSetPool.Alloc<T>();
        }

        this.OnAwake();
    }

    protected virtual void OnAwake()
    {
    }


    public bool TryAdd(T inT)
    {
        if (this.records.Contains(inT))
        {
            return false;
        }

        this.records.Add(inT);
        return true;
    }

    public bool TryRemove(T inT)
    {
        if (this.records.Contains(inT))
        {
            this.records.Remove(inT);
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
        if (this.records != null)
        {
            this.records.Clear();
            HashSetPool.Free(this.records);
            this.records = null;
        }
    }
}
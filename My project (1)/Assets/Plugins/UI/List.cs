using System;
using System.Collections;
using System.Collections.Generic;

public static class ListPool
{
    private static Dictionary<Type, IList> _cache = new Dictionary<Type, IList>();
    private static HashSet<int> _hash = new HashSet<int>();

    public static List<T> Alloc<T>()
    {
        var type = typeof(T);
        if (_cache.TryGetValue(type, out var list) && list.Count > 0)
        {
            var result = list[^1];
            list.RemoveAt(list.Count);
            var hash = result.GetHashCode();
            _hash.Remove(hash);
            var result1 = result as List<T>;
            return result1;
        }

        return new List<T>();
    }

    public static bool Free<T>(List<T> inList)
    {
        var hash = inList.GetHashCode();
        if (_hash.Contains(hash))
        {
            return false;
        }

        inList.Clear();
        var c = inList.Capacity;
        if (c >= 16)
        {
            inList.TrimExcess();
        }

        var type = typeof(T);
        if (_cache.TryGetValue(type, out var list))
        {
            list.Add(inList);
        }

        list = new List<T>();
        _cache.Add(type, list);
        list.Add(inList);
        return true;
    }
}


public static class ListEx
{
    public static void Dispose<T>(this List<T> inList)
    {
        ListPool.Free(inList);
    }
}


public struct StructList<T> : IDisposable, IList<T>
{
    private List<T> _list;

    public StructList(T item1)
    {
        _list =ListPool.Alloc<T>();
        _list.Add(item1);
    }

    public StructList(T item1, T item2)
    {
        _list = ListPool.Alloc<T>();
        _list.Add(item1);
        _list.Add(item2);
    }

    public void Dispose()
    {
        _list.Dispose();
    }

    public IEnumerator<T> GetEnumerator()
    {
        return _list.GetEnumerator();
    }

    IEnumerator IEnumerable.GetEnumerator()
    {
        return _list.GetEnumerator();
    }

    public void Add(T item)
    {
        _list.Add(item);
    }

    public void Clear()
    {
        _list.Clear();
    }

    public bool Contains(T item)
    {
        return _list.Contains(item);
    }

    public void CopyTo(T[] array, int arrayIndex)
    {
        _list.CopyTo(array, arrayIndex);
    }

    public bool Remove(T item)
    {
        return _list.Remove(item);
    }

    public int Count => _list.Count;
    public bool IsReadOnly => ((IList)_list).IsReadOnly;

    public int IndexOf(T item)
    {
        return _list.IndexOf(item);
    }

    public void Insert(int index, T item)
    {
        _list.Insert(index, item);
    }

    public void RemoveAt(int index)
    {
        _list.RemoveAt(index);
    }

    public T this[int index]
    {
        get => _list[index];
        set => _list[index] = value;
    }
}
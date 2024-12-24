using System;
using System.Collections.Generic;


public partial class View
{
    protected delegate bool UI2ParentEvent<T>(ref T view2ParentEvent);

    private Dictionary<Type, System.Delegate> _delegates;

    private Dictionary<Type, System.Delegate> Delegates
    {
        get
        {
            if (_delegates == null)
            {
                _delegates = new Dictionary<Type, Delegate>();
            }

            return _delegates;
        }
    }


    protected bool RegisterSubEvent<T>(UI2ParentEvent<T> inHandle) where T : IView2ParentEvent
    {
        return _RegisterSubEvent(inHandle);
    }

    protected void PopEvent2Parent<T>(ref T inEvent) where T : IView2ParentEvent
    {
        _PopEvent2Parent(inEvent);
    }

    private bool _RegisterSubEvent<T>(UI2ParentEvent<T> inHandle) where T : IView2ParentEvent
    {
        var eventType = typeof(T);
        if (Delegates.TryGetValue(eventType, out var @delegate))
        {
            return false;
        }
        else
        {
            Delegates.Add(eventType, inHandle);
            return true;
        }
    }

    private void _PopEvent2Parent<T>(T inEvent) where T : IView2ParentEvent
    {
        if (Parent == null || Parent == this)
        {
            return;
        }
        else
        {
            Parent._OnChildPopEvent(inEvent);
        }
    }

    private void _OnChildPopEvent<T>(T inEvent) where T : IView2ParentEvent
    {
        if (this._delegates == null)
        {
            this.Parent._PopEvent2Parent(inEvent);
        }
        else
        {
            var eventType = typeof(T);
            if (this.Delegates.TryGetValue(eventType, out var @delegate) &&
                @delegate is UI2ParentEvent<T> func)
            {
                if (func.Invoke(ref inEvent))
                {
                    Parent._PopEvent2Parent(inEvent);
                }
            }
        }
    }
}
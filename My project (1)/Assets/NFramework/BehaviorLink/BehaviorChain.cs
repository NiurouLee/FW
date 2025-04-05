using System;
using System.Collections.Generic;

public class BehaviorChain
{
    /// <summary>
    /// 0  init 1 runing 2 success 3 fail
    /// </summary>
    private byte state = 0;
    public BehaviorChain Parent => parent;
    private BehaviorChain parent;
    private int index = 0;
    public List<BehaviorChain> list = new List<BehaviorChain>();
    public void Append<T>() where T : BehaviorChain, new()
    {
        var behaviorChain = new T();
        behaviorChain.parent = this;
        behaviorChain.Awake();
        list.Add(behaviorChain);
    }

    protected virtual void Awake()
    {
    }

    public void AddChild(BehaviorChain behaviorChain)
    {
        list.Add(behaviorChain);
    }

    protected void Success()
    {
        if (state != 1)
        {
            return;
        }

        if (parent != null)
        {
            parent.OnChildSuccess(this);
        }
        else
        {
            this.OnSuccess();
        }
    }

    private void OnSuccess()
    {
    }

    private void OnChildSuccess(BehaviorChain behaviorChain)
    {
        if (index == list.Count - 1)
        {
            this.Success();
        }
        else
        {
            index++;
            list[index].Execute();
        }
    }

    public virtual void Execute()
    {
        if (this.list.Count == 0)
        {
            this.Success();
        }
        else
        {
            this.list[index].Execute();
        }
    }

    public void Fail()
    {
        if (state != 1)
        {
            return;
        }
        if (parent != null)
        {
            parent.OnChildFail(this);
        }
        else
        {
            this.OnFail();
        }
    }

    private void OnFail()
    {
    }

    protected virtual void OnChildFail(BehaviorChain behaviorChain)
    {

    }
}


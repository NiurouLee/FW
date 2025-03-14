using System;
using NFramework.Core;
using NFramework.Test.EventTestEx;
using UnityEngine;

namespace NFramework.Event
{
    public abstract class BaseRegister : IEquatable<BaseRegister>, IFreeToPool
    {
        public System.Type EventType { get; set; }
        public System.Delegate CallBack { get; set; }
        public EventSchedule EventSchedule { get; set; }
        public abstract void UnRegister();

        public virtual bool Equals(BaseRegister other)
        {
            return EventType == other.EventType && CallBack == other.CallBack;
        }

        internal void Invoke<T>(T e) where T : IEvent
        {
            var type = typeof(T);
            if (CallBack is RefAction<T> action)
            {
                action(ref e);
            }
        }

        public virtual void FreeToPool()
        {
            this.EventSchedule = null;
            this.CallBack = null;
            this.EventType = null;
            ObjectPool.Free(this);
        }
    }

    public class NormalRegister : BaseRegister
    {
        public override void UnRegister()
        {
            var inRegister = ObjectPool.Alloc<NormalRegister>();
            inRegister.EventType = this.EventType;
            inRegister.CallBack = this.CallBack;
            inRegister.EventSchedule = this.EventSchedule;
            this.EventSchedule.UnSubscribe(inRegister);
        }
    }

    public class ConditionRegister : BaseRegister, IEquatable<ConditionRegister>
    {
        public System.Delegate Condition { get; set; }

        public bool Equals(ConditionRegister other)
        {
            if (other == null)
                return false;
            return base.Equals(other) && this.Condition == other.Condition;
        }

        public override int GetHashCode()
        {
            return (Condition != null ? Condition.GetHashCode() : 0);
        }

        public override void UnRegister()
        {
            var inRegister = ObjectPool.Alloc<ConditionRegister>();
            inRegister.EventType = this.EventType;
            inRegister.CallBack = this.CallBack;
            inRegister.EventSchedule = this.EventSchedule;
            inRegister.Condition = Condition;
            this.EventSchedule.UnSubscribe(inRegister);
        }

        public override void FreeToPool()
        {
            this.Condition = default;
            base.FreeToPool();
        }
    }

    public class ChannelRegister : BaseRegister, IEquatable<ChannelRegister>
    {
        public string Channel { get; set; }

        public bool Equals(ChannelRegister other)
        {
            if (other == null)
                return false;
            return base.Equals(other) && this.Channel == other.Channel;
        }

        public override bool Equals(object obj)
        {
            if (obj is null) return false;
            if (ReferenceEquals(this, obj)) return true;
            if (obj.GetType() != GetType()) return false;
            return Equals((ChannelRegister)obj);
        }

        public override int GetHashCode()
        {
            return (Channel != null ? Channel.GetHashCode() : 0);
        }

        public override void UnRegister()
        {
            var inRegister = ObjectPool.Alloc<ChannelRegister>();
            inRegister.EventType = this.EventType;
            inRegister.CallBack = this.CallBack;
            inRegister.EventSchedule = this.EventSchedule;
            inRegister.Channel = this.Channel;
            this.EventSchedule.UnSubscribe(inRegister);
        }

        public override void FreeToPool()
        {
            this.Channel = default;
            base.FreeToPool();
        }
    }
}
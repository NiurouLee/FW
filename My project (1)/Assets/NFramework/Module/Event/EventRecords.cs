using Nframework.Module.ObjectPoolModule;
using NFramework.Core.Collections;
using NFramework.Core.ObjectPool;

namespace NFramework.Module.EventModule
{
    public class EventRecords : BaseRecords<BaseRegister>, IEventRegister, IFreeToPool
    {
        private IEventRegister EventSchedule { get; set; }
        public void SetSchedule(IEventRegister inEventSchedule)
        {
            EventSchedule = inEventSchedule;
        }

        public BaseRegister Subscribe<T>(RefAction<T> callback) where T : IEvent
        {
            var register = this.EventSchedule.Subscribe<T>(callback);
            this.TryAdd(register);
            return register;
        }

        public BaseRegister Subscribe<T>(RefAction<T> callback, RefFunc<T> condition) where T : IEvent
        {
            var register = this.EventSchedule.Subscribe<T>(callback, condition);
            this.TryAdd(register);
            return register;
        }

        public BaseRegister Subscribe<T>(RefAction<T> callback, string channel) where T : IEvent
        {
            var register = this.EventSchedule.Subscribe<T>(callback, channel);
            this.TryAdd(register);
            return register;
        }

        public void UnSubscribe<T>(RefAction<T> callback) where T : IEvent
        {
            var register = GetFrameworkModule<ObjectPoolM>().Alloc<NormalRegister>();
            register.EventType = typeof(T);
            register.CallBack = callback;
            register.EventSchedule = this.EventSchedule;
            this.EventSchedule.UnSubscribe(register);
            this.TryRemove(register);
        }

        public void UnSubscribe<T>(RefAction<T> callback, RefFunc<T> condition) where T : IEvent
        {
            var register = GetFrameworkModule<ObjectPoolM>().Alloc<ConditionRegister>();
            register.EventType = typeof(T);
            register.CallBack = callback;
            register.Condition = condition;
            register.EventSchedule = this.EventSchedule;
            this.EventSchedule.UnSubscribe(register);
            this.TryRemove(register);
        }

        public void UnSubscribe<T>(RefAction<T> callback, string channel) where T : IEvent
        {
            var register = GetFrameworkModule<ObjectPoolM>().Alloc<ChannelRegister>();
            register.EventType = typeof(T);
            register.CallBack = callback;
            register.Channel = channel;
            register.EventSchedule = this.EventSchedule;
            this.EventSchedule.UnSubscribe(register);
            this.TryRemove(register);
        }

        public void UnSubscribe(BaseRegister inRegister)
        {
            this.EventSchedule.UnSubscribe(inRegister);
            this.TryRemove(inRegister);
        }

        public bool Check<T>(RefAction<T> callback) where T : IEvent
        {
            return this.EventSchedule.Check<T>(callback);
        }

        public bool Check<T>(RefAction<T> callback, RefFunc<T> condition) where T : IEvent
        {
            return this.EventSchedule.Check<T>(callback, condition);
        }

        public bool Check<T>(RefAction<T> callback, string channel) where T : IEvent
        {
            return this.EventSchedule.Check<T>(callback, channel);
        }

        protected override void OnDestroy()
        {
            foreach (var register in this.Records)
            {
                this.EventSchedule.UnSubscribe(register);
            }
            this.EventSchedule = null;
        }

        public void FreeToPool()
        {
        }
    }
}
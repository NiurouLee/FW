namespace NFramework.Event
{
    public class EventRecords : BaseRecords<BaseRegister>, IEventSchedule
    {
        private IEventSchedule EventSchedule { get; set; }

        public void SetSchedule(IEventSchedule inEventSchedule)
        {
            EventSchedule = inEventSchedule;
        }

        public BaseRegister Subscribe<T>(RefAction<T> callback) where T : IEvent
        {
            var register = EventSchedule.Subscribe<T>(callback);
            this.TryAdd(register);
            return register;
        }

        public BaseRegister Subscribe<T>(RefAction<T> callback, RefFunc<T> condition) where T : IEvent
        {
            throw new System.NotImplementedException();
        }

        public BaseRegister Subscribe<T>(RefAction<T> callback, string channel) where T : IEvent
        {
            throw new System.NotImplementedException();
        }

        public void UnSubscribe<T>(RefAction<T> callback) where T : IEvent
        {
            throw new System.NotImplementedException();
        }

        public void UnSubscribe<T>(RefAction<T> callback, RefFunc<T> condition) where T : IEvent
        {
            throw new System.NotImplementedException();
        }

        public void UnSubscribe<T>(RefAction<T> callback, string channel) where T : IEvent
        {
            throw new System.NotImplementedException();
        }

        public void UnSubscribe(BaseRegister inRegister)
        {
            throw new System.NotImplementedException();
        }

        public bool Check<T>(RefAction<T> callback) where T : IEvent
        {
            throw new System.NotImplementedException();
        }

        public bool Check<T>(RefAction<T> callback, RefFunc<T> condition) where T : IEvent
        {
            throw new System.NotImplementedException();
        }

        public bool Check<T>(RefAction<T> callback, string channel) where T : IEvent
        {
            throw new System.NotImplementedException();
        }
    }
}
using System;

namespace NFramework.Module.EntityModule
{
    public class EntityPoolModule : IFrameWorkModule
    {

        public T Fetch<T>() where T : Entity, new()
        {
            return new T();
        }

        public Entity Fetch(Type type)
        {
            return Activator.CreateInstance(type) as Entity;
        }

        public void Recycle(Entity entity)
        {
        }
    }
}
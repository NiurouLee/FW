using System;
using System.Collections.Generic;
using NFramework.Core.Collections;
using NFramework.Core.ILiveing;
using NFramework.Module.LogModule;
using NFramework.Module.IDGeneratorModule;


namespace NFramework.Module.EntityModule
{
    [Flags]
    public enum EntityStatus : byte
    {
        None = 0,
        IsFromPool = 1,
        IsRegister = 1 << 1,
        IsComponent = 1 << 2,
        IsCreated = 1 << 3,
        IsNew = 1 << 4,
    }

    public partial class Entity : IDisposable
    {
#if ENABLE_VIEW && UNITY_EDITOR
        private UnityEngine.GameObject viewGO;

        private static UnityEngine.GameObject viewRoot;


        // 每次被重新使用的时候都会赋予新的实例id
        [ShowInInspector]
#endif
        public long Id { get; protected set; }

        protected Entity()
        {
        }

        private EntityStatus status = EntityStatus.None;

        private bool IsFromPool
        {
            get => (this.status & EntityStatus.IsFromPool) == EntityStatus.IsFromPool;
            set
            {
                if (value)
                {
                    this.status |= EntityStatus.IsFromPool;
                }
                else
                {
                    this.status &= ~EntityStatus.IsFromPool;
                }
            }
        }

        protected bool IsRegister
        {
            get => (this.status & EntityStatus.IsRegister) == EntityStatus.IsRegister;
            set
            {
                if (this.IsRegister == value)
                {
                    return;
                }

                if (value)
                {
                    this.status |= EntityStatus.IsRegister;
                }
                else
                {
                    this.status &= ~EntityStatus.IsRegister;
                }


                if (!value)
                {
                    // if (this is not World)
                    //     EntityRoot.Ins.Remove(this.Id);
                }
                else
                {
                    // if (this is not RootEntity)
                    // {
                    //     EntityRoot.Ins.Add(this);
                    // }

                    Framework.Instance.GetModule<EntitySystemM>().RegisterSystem(this);
                }

#if ENABLE_VIEW && UNITY_EDITOR
                if (value)
                {
                    this.viewGO = new UnityEngine.GameObject(this.ViewName);
                    this.viewGO.AddComponent<ComponentView>().Component = this;
                    if (viewRoot == null)
                    {
                        viewRoot = new GameObject("EntityViewRoot");
                        UnityEngine.Object.DontDestroyOnLoad(viewRoot);
                    }

                    this.viewGO.transform.SetParent(this.Parent == null
                        ? viewRoot.transform
                        : this.Parent.viewGO.transform);
                }
                else
                {
                    UnityEngine.Object.Destroy(this.viewGO);
                }
#endif
            }
        }

        protected virtual string ViewName
        {
            get { return this.GetType().Name; }
        }

        private bool IsComponent
        {
            get => (this.status & EntityStatus.IsComponent) == EntityStatus.IsComponent;
            set
            {
                if (value)
                {
                    this.status |= EntityStatus.IsComponent;
                }
                else
                {
                    this.status &= ~EntityStatus.IsComponent;
                }
            }
        }

        protected bool IsCreated
        {
            get => (this.status & EntityStatus.IsCreated) == EntityStatus.IsCreated;
            set
            {
                if (value)
                {
                    this.status |= EntityStatus.IsCreated;
                }
                else
                {
                    this.status &= ~EntityStatus.IsCreated;
                }
            }
        }

        protected bool IsNew
        {
            get => (this.status & EntityStatus.IsNew) == EntityStatus.IsNew;
            set
            {
                if (value)
                {
                    this.status |= EntityStatus.IsNew;
                }
                else
                {
                    this.status &= ~EntityStatus.IsNew;
                }
            }
        }

        public bool IsDisposed => this.Id == 0;

        protected Entity parent;

        // 可以改变parent，但是不能设置为null
        public Entity Parent
        {
            get => this.parent;
            private set
            {
                if (this.parent != null) // 之前有parent
                {
                    // parent相同，不设置
                    if (this.parent == value)
                    {
                        Framework.Instance.GetModule<LoggerM>()?.Err($"重复设置了Parent: {this.GetType().Name} parent: {this.parent.GetType().Name}");
                        return;
                    }

                    this.parent.RemoveFromChildren(this);
                }

                this.parent = value;
                this.IsComponent = false;
                if (parent != null)
                {
                    this.parent.AddToChildren(this);
                }

                this.IsRegister = true;
            }
        }

        // 该方法只能在AddComponent中调用，其他人不允许调用


        private Entity ComponentParent
        {
            set
            {
                if (value == null)
                {
                    throw new Exception($"cant set parent null: {this.GetType().Name}");
                }

                if (value == this)
                {
                    throw new Exception($"cant set parent self: {this.GetType().Name}");
                }

                if (this.parent != null) // 之前有parent
                {
                    // parent相同，不设置
                    if (this.parent == value)
                    {
                        Framework.Instance.GetModule<LoggerM>().Err($"重复设置了Parent: {this.GetType().Name} parent: {this.parent.GetType().Name}");
                        return;
                    }

                    this.Parent.RemoveFromComponents(this);
                }

                this.Parent = value;
                this.IsComponent = true;
                this.Parent.AddToComponents(this);
            }
        }

        public T GetParent<T>() where T : Entity
        {
            return this.Parent as T;
        }

        public T GetRoot<T>() where T : Entity
        {
            if (this.Parent == null)
            {
                return this as T;
            }
            return this.Parent.GetRoot<T>();
        }

        private Dictionary<long, Entity> children;

        public Dictionary<long, Entity> Children
        {
            get { return this.children ??= DictionaryPool.Alloc<long, Entity>(); }
        }

        private void AddToChildren(Entity entity)
        {
            this.Children.Add(entity.Id, entity);
        }

        private void RemoveFromChildren(Entity entity)
        {
            if (this.children == null)
            {
                return;
            }

            this.children.Remove(entity.Id);

            if (this.children.Count == 0)
            {
                DictionaryPool.Free(this.children);
                this.children = null;
            }
        }

        private Dictionary<Type, Entity> components;

        public Dictionary<Type, Entity> Components
        {
            get { return this.components ??= DictionaryPool.Alloc<Type, Entity>(); }
        }

        private bool _enable = true;

        public bool Enable
        {
            get => _enable;
            set
            {
                _enable = value;
                if (value)
                    OnEnable();
                else
                    OnDisable();
            }
        }

        public void SetEnable(bool enable)
        {
            Enable = enable;
        }

        protected virtual void OnEnable()
        {
        }


        protected virtual void OnDisable()
        {
        }

        public void Dispose()
        {
            if (this.IsDisposed)
            {
                return;
            }

            this.IsRegister = false;
            this.Id = 0;

            // 清理Component
            if (this.components != null)
            {
                foreach (KeyValuePair<Type, Entity> kv in this.components)
                {
                    kv.Value.Dispose();
                }

                this.components.Clear();
                DictionaryPool.Free(this.components);
                this.components = null;
            }

            // 清理Children
            if (this.children != null)
            {
                foreach (Entity child in this.children.Values)
                {
                    child.Dispose();
                }

                this.children.Clear();
                DictionaryPool.Free(this.children);
                this.children = null;
            }

            // 触发Destroy事件
            if (this is IDestroySystem)
            {
                Framework.Instance.GetModule<EntitySystemM>().Destroy(this);
            }


            if (this.parent != null && !this.parent.IsDisposed)
            {
                if (this.IsComponent)
                {
                    this.parent.RemoveComponent(this);
                }
                else
                {
                    this.parent.RemoveFromChildren(this);
                }
            }

            this.parent = null;

            Dispose();

            if (this.IsFromPool)
            {
                // ObjectPool.Ins.Recycle(this);
            }

            status = EntityStatus.None;
        }

        private void AddToComponents(Entity component)
        {
            this.Components.Add(component.GetType(), component);
        }

        private void RemoveFromComponents(Entity component)
        {
            if (this.components == null)
            {
                return;
            }

            this.components.Remove(component.GetType());

            if (this.components.Count == 0)
            {
                // ObjectPool.Ins.Recycle(this.components);
                this.components = null;
            }
        }

        public K GetChild<K>(long id) where K : Entity
        {
            if (this.children == null)
            {
                return null;
            }

            this.children.TryGetValue(id, out Entity child);
            return child as K;
        }

        public void RemoveChild(long id)
        {
            if (this.children == null)
            {
                return;
            }

            if (!this.children.TryGetValue(id, out Entity child))
            {
                return;
            }

            this.children.Remove(id);
            child.Dispose();
        }

        public void RemoveComponent<K>() where K : Entity
        {
            if (this.IsDisposed)
            {
                return;
            }

            if (this.components == null)
            {
                return;
            }

            Type type = typeof(K);
            Entity c = this.GetComponent(type);
            if (c == null)
            {
                return;
            }

            this.RemoveFromComponents(c);
            c.Dispose();
        }

        public void RemoveComponent(Entity component)
        {
            if (this.IsDisposed)
            {
                return;
            }

            if (this.components == null)
            {
                return;
            }

            Entity c = this.GetComponent(component.GetType());
            if (c == null)
            {
                return;
            }

            if (c.Id != component.Id)
            {
                return;
            }

            this.RemoveFromComponents(c);
            c.Dispose();
        }

        public void RemoveComponent(Type type)
        {
            if (this.IsDisposed)
            {
                return;
            }

            Entity c = this.GetComponent(type);
            if (c == null)
            {
                return;
            }

            RemoveFromComponents(c);
            c.Dispose();
        }

        public K GetComponent<K>()
        {
            if (this.components == null)
            {
                return default;
            }
            var type = typeof(K);
            Entity component = null;
            foreach (var items in components)
            {
                if (type.IsAssignableFrom(items.Key))
                {
                    component = items.Value;
                    break;
                }
            }

            if (component == null) return default;
            return (K)(object)component;
        }

        public List<K> GetComponents<K>()
        {
            if (this.components == null)
            {
                return null;
            }

            List<K> result = ListPool.Alloc<K>();
            foreach (var items in components)
            {
                if (typeof(K).IsAssignableFrom(items.Key))
                {
                    result.Add((K)(object)items.Value);
                }
            }

            return result;
        }

        public Entity GetComponent(Type type)
        {
            if (this.components == null)
            {
                return null;
            }

            Entity component;
            if (!this.components.TryGetValue(type, out component))
            {
                return null;
            }

            return component;
        }

        public static Entity Create(System.Type type, bool isFromPool = false)
        {
            Entity component;
            if (isFromPool)
            {
                component = Framework.Instance.GetModule<EntityPoolM>().Fetch(type) as Entity;
            }
            else
            {
                component = Activator.CreateInstance(type) as Entity;
            }

            component.IsFromPool = isFromPool;
            component.IsCreated = true;
            component.IsNew = true;
            component.Id = Framework.Instance.GetModule<IDGeneratorM>().GenerateInstanceId();
            return component;
        }

        public static Entity Create<T>(bool isFromPool = false) where T : Entity, new()
        {
            Entity component;
            if (isFromPool)
            {
                component = Framework.Instance.GetModule<EntityPoolM>().Fetch<T>();
            }
            else
            {
                component = new T();
            }

            component.IsFromPool = isFromPool;
            component.IsCreated = true;
            component.IsNew = true;
            component.Id = Framework.Instance.GetModule<IDGeneratorM>().GenerateInstanceId();
            return component;
        }


        public Entity AddComponent(Entity component)
        {
            Type type = component.GetType();
            if (this.components != null && this.components.ContainsKey(type))
            {
                throw new Exception($"entity already has component: {type.FullName}");
            }

            component.ComponentParent = this;
            return component;
        }

        public Entity AddComponent(Type type, bool isFromPool = false)
        {
            if (this.components != null && this.components.ContainsKey(type))
            {
                throw new Exception($"entity already has component: {type.FullName}");
            }

            Entity component = Create(type, isFromPool);
            component.ComponentParent = this;
            Framework.Instance.GetModule<EntitySystemM>().Awake(component);
            Framework.Instance.GetModule<EntitySystemM>().Start(component);
            return component;
        }

        public K AddComponent<K>(bool isFromPool = false) where K : Entity, new()
        {
            Type type = typeof(K);
            if (this.components != null && this.components.ContainsKey(type))
            {
                throw new Exception($"entity already has component: {type.FullName}");
            }

            Entity component = Create(type, isFromPool);
            component.ComponentParent = this;
            Framework.Instance.GetModule<EntitySystemM>().Awake(component);
            Framework.Instance.GetModule<EntitySystemM>().Start(component);
            return component as K;
        }

        public K AddComponent<K, P1>(P1 p1, bool isFromPool = false) where K : Entity, IAwakeSystem<P1>, new()
        {
            Type type = typeof(K);
            if (this.components != null && this.components.ContainsKey(type))
            {
                throw new Exception($"entity already has component: {type.FullName}");
            }

            Entity component = Create(type, isFromPool);
            component.ComponentParent = this;
            Framework.Instance.GetModule<EntitySystemM>().Awake(component, p1);
            Framework.Instance.GetModule<EntitySystemM>().Start(component);
            return component as K;
        }

        public K AddComponent<K, P1, P2>(P1 p1, P2 p2, bool isFromPool = false)
            where K : Entity, IAwakeSystem<P1, P2>, new()
        {
            Type type = typeof(K);
            if (this.components != null && this.components.ContainsKey(type))
            {
                throw new Exception($"entity already has component: {type.FullName}");
            }

            Entity component = Create(type, isFromPool);
            component.ComponentParent = this;
            Framework.Instance.GetModule<EntitySystemM>().Awake(component, p1, p2);
            Framework.Instance.GetModule<EntitySystemM>().Start(component);
            return component as K;
        }

        public K AddComponent<K, P1, P2, P3>(P1 p1, P2 p2, P3 p3, bool isFromPool = false)
            where K : Entity, IAwakeSystem<P1, P2, P3>, new()
        {
            Type type = typeof(K);
            if (this.components != null && this.components.ContainsKey(type))
            {
                throw new Exception($"entity already has component: {type.FullName}");
            }

            Entity component = Create(type, isFromPool);
            component.ComponentParent = this;
            Framework.Instance.GetModule<EntitySystemM>().Awake(component, p1, p2, p3);
            Framework.Instance.GetModule<EntitySystemM>().Start(component);
            return component as K;
        }

        public K AddComponent<K, P1, P2, P3, P4>(P1 p1, P2 p2, P3 p3, P4 p4, bool isFromPool = false)
            where K : Entity, IAwakeSystem<P1, P2, P3, P4>, new()
        {
            Type type = typeof(K);
            if (this.components != null && this.components.ContainsKey(type))
            {
                throw new Exception($"entity already has component: {type.FullName}");
            }

            Entity component = Create(type, isFromPool);
            component.ComponentParent = this;
            Framework.Instance.GetModule<EntitySystemM>().Awake(component, p1, p2, p3, p4);
            Framework.Instance.GetModule<EntitySystemM>().Start(component);
            return component as K;
        }


        public Entity AddChild(Type entityType, bool isFromPool = false)
        {
            Entity child = Create(entityType, isFromPool);
            child.Id = Framework.Instance.GetModule<IDGeneratorM>().GenerateId();
            child.Parent = this;

            Framework.Instance.GetModule<EntitySystemM>().Awake(child);
            Framework.Instance.GetModule<EntitySystemM>().Start(child);
            return child;
        }

        public Entity AddChild<P>(Type entityType, P p, bool isFromPool = false)
        {
            Entity child = Create(entityType, isFromPool);
            child.Id = Framework.Instance.GetModule<IDGeneratorM>().GenerateId();
            child.Parent = this;

            Framework.Instance.GetModule<EntitySystemM>().Awake(child, p);
            Framework.Instance.GetModule<EntitySystemM>().Start(child);
            return child;
        }

        public Entity AddChild<P1, P2>(Type entityType, P1 p1, P2 p2, bool isFromPool = false)
        {
            Entity child = Create(entityType, isFromPool);
            child.Id = Framework.Instance.GetModule<IDGeneratorM>().GenerateId();
            child.Parent = this;

            Framework.Instance.GetModule<EntitySystemM>().Awake(child, p1, p2);
            Framework.Instance.GetModule<EntitySystemM>().Start(child);
            return child;
        }

        public T AddChild<T, A>(T inT, A inA) where T : Entity, IAwakeSystem<A>
        {
            inT.Id = Framework.Instance.GetModule<IDGeneratorM>().GenerateId();
            inT.Parent = this;
            Framework.Instance.GetModule<EntitySystemM>().Awake(inT, inA);
            Framework.Instance.GetModule<EntitySystemM>().Start(inT);
            return inT;
        }

        public T AddChild<T>(bool isFromPool = false) where T : Entity
        {
            Type type = typeof(T);
            T component = (T)Entity.Create(type, isFromPool);
            component.Id = Framework.Instance.GetModule<IDGeneratorM>().GenerateId();
            component.Parent = this;

            Framework.Instance.GetModule<EntitySystemM>().Awake(component);
            Framework.Instance.GetModule<EntitySystemM>().Start(component);
            return component;
        }

        public T AddChild<T, A>(A a, bool isFromPool = false) where T : Entity, IAwakeSystem<A>
        {
            Type type = typeof(T);
            T component = (T)Entity.Create(type, isFromPool);
            component.Id = Framework.Instance.GetModule<IDGeneratorM>().GenerateId();
            component.Parent = this;

            Framework.Instance.GetModule<EntitySystemM>().Awake(component, a);
            Framework.Instance.GetModule<EntitySystemM>().Start(component);
            return component;
        }

        public T AddChild<T, A, B>(A a, B b, bool isFromPool = false) where T : Entity, IAwakeSystem<A, B>
        {
            Type type = typeof(T);
            T component = (T)Entity.Create(type, isFromPool);
            component.Id = Framework.Instance.GetModule<IDGeneratorM>().GenerateId();
            component.Parent = this;

            Framework.Instance.GetModule<EntitySystemM>().Awake(component, a, b);
            Framework.Instance.GetModule<EntitySystemM>().Start(component);
            return component;
        }

        public T AddChild<T, A, B, C>(A a, B b, C c, bool isFromPool = false) where T : Entity, IAwakeSystem<A, B, C>
        {
            Type type = typeof(T);
            T component = (T)Entity.Create(type, isFromPool);
            component.Id = Framework.Instance.GetModule<IDGeneratorM>().GenerateId();
            component.Parent = this;

            Framework.Instance.GetModule<EntitySystemM>().Awake(component, a, b, c);
            Framework.Instance.GetModule<EntitySystemM>().Start(component);
            return component;
        }

        public T AddChild<T, A, B, C, D>(A a, B b, C c, D d, bool isFromPool = false)
            where T : Entity, IAwakeSystem<A, B, C, D>
        {
            Type type = typeof(T);
            T component = (T)Entity.Create(type, isFromPool);
            component.Id = Framework.Instance.GetModule<IDGeneratorM>().GenerateId();
            component.Parent = this;

            Framework.Instance.GetModule<EntitySystemM>().Awake(component, a, b, c, d);
            Framework.Instance.GetModule<EntitySystemM>().Start(component);
            return component;
        }

        public T AddChildWithId<T>(long id, bool isFromPool = false) where T : Entity, new()
        {
            Type type = typeof(T);
            T component = Entity.Create(type, isFromPool) as T;
            component.Parent = this;
            Framework.Instance.GetModule<EntitySystemM>().Awake(component);
            Framework.Instance.GetModule<EntitySystemM>().Start(component);
            return component;
        }

        public T AddChildWithId<T, A>(long id, A a, bool isFromPool = false) where T : Entity, IAwakeSystem<A>
        {
            Type type = typeof(T);
            T component = (T)Entity.Create(type, isFromPool);
            component.Parent = this;

            Framework.Instance.GetModule<EntitySystemM>().Awake(component, a);
            Framework.Instance.GetModule<EntitySystemM>().Start(component);
            return component;
        }

        public T AddChildWithId<T, A, B>(long id, A a, B b, bool isFromPool = false)
            where T : Entity, IAwakeSystem<A, B>
        {
            Type type = typeof(T);
            T component = (T)Entity.Create(type, isFromPool);
            component.Parent = this;

            Framework.Instance.GetModule<EntitySystemM>().Awake(component, a, b);
            Framework.Instance.GetModule<EntitySystemM>().Start(component);
            return component;
        }

        public T AddChildWithId<T, A, B, C>(long id, A a, B b, C c, bool isFromPool = false)
            where T : Entity, IAwakeSystem<A, B, C>
        {
            Type type = typeof(T);
            T component = (T)Entity.Create(type, isFromPool);
            component.Parent = this;

            Framework.Instance.GetModule<EntitySystemM>().Awake(component, a, b, c);
            Framework.Instance.GetModule<EntitySystemM>().Start(component);
            return component;
        }
    }
}
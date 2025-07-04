namespace NFramework.Core.ILiveing
{
    public interface IAwakeSystem : ISystemType
    {
        void Awake();
    }

    public interface IAwakeSystem<A> : ISystemType
    {
        IAwakeSystem<A> Awake(A a);
    }

    public interface IAwakeSystem<A, B> : ISystemType
    {
        IAwakeSystem<A, B> Awake(A a, B b);
    }

    public interface IAwakeSystem<A, B, C> : ISystemType
    {
        IAwakeSystem<A, B, C> Awake(A a, B b, C c);
    }

    public interface IAwakeSystem<A, B, C, D> : ISystemType
    {
        IAwakeSystem<A, B, C, D> Awake(A a, B b, C c, D d);
    }

    public interface IAwakeSystem<A, B, C, D, E> : ISystemType
    {
        IAwakeSystem<A, B, C, D, E> Awake(A a, B b, C c, D d, E e);
    }

    public interface IAwakeSystem<A, B, C, D, E, F> : ISystemType
    {
        IAwakeSystem<A, B, C, D, E, F> Awake(A a, B b, C c, D d, E e, F f);
    }

    public interface IAwakeSystem<A, B, C, D, E, F, G> : ISystemType
    {
        IAwakeSystem<A, B, C, D, E, F, G> Awake(A a, B b, C c, D d, E e, F f, G g);
    }

    public interface IAwakeSystem<A, B, C, D, E, F, G, H> : ISystemType
    {
        IAwakeSystem<A, B, C, D, E, F, G, H> Awake(A a, B b, C c, D d, E e, F f, G g, H h);
    }

    public interface IAwakeSystem<A, B, C, D, E, F, G, H, I> : ISystemType
    {
        IAwakeSystem<A, B, C, D, E, F, G, H, I> Awake(A a, B b, C c, D d, E e, F f, G g, H h, I i);
    }

    public interface IAwakeSystem<A, B, C, D, E, F, G, H, I, J> : ISystemType
    {
        IAwakeSystem<A, B, C, D, E, F, G, H, I, J> Awake(A a, B b, C c, D d, E e, F f, G g, H h, I i, J j);
    }

    public interface IAwakeSystem<A, B, C, D, E, F, G, H, I, J, K> : ISystemType
    {
        IAwakeSystem<A, B, C, D, E, F, G, H, I, J, K> Awake(A a, B b, C c, D d, E e, F f, G g, H h, I i, J j, K k);
    }

    public interface IAwakeSystem<A, B, C, D, E, F, G, H, I, J, K, L> : ISystemType
    {
        IAwakeSystem<A, B, C, D, E, F, G, H, I, J, K, L> Awake(A a, B b, C c, D d, E e, F f, G g, H h, I i, J j, K k, L l);
    }

}
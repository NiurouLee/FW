using NFramework.Module.EntityModule;

namespace NFramework.Module.Combat
{
    public class AABBComponent : Entity, IAwakeSystem<ABBB>
    {

        public AABB aabb;
        public void Awake()
        {

        }
    }
}
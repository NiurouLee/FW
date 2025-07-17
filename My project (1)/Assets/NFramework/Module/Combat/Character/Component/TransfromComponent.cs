using UnityEngine;
using NFramework.Module.EntityModule;
using NFramework.Core.ILiveing;
namespace NFramework.Module.Combat
{
    public class TransformComponent : Entity, IAwakeSystem
    {
        private Vector3 _position;
        private Quaternion _rotation;
        private Vector3 _localScale;

        public Vector3 Position
        {
            get { return _position; }
            set
            {
                _position = value;
                SyncTransform();
            }
        }

        public Quaternion Rotation
        {
            get
            {
                return _rotation;
            }
            set
            {
                _rotation = value;
                SyncTransform();
            }
        }

        public Vector3 LocalScale
        {
            get
            {
                return _localScale;
            }
            set
            {
                _localScale = value;
                SyncTransform();
            }
        }


        public void Awake()
        {
            Position = Vector3.zero;
            Rotation = Quaternion.identity;
            LocalScale = Vector3.one;
        }


        public void TransLate(Vector3 translation)
        {
            Position += translation;
        }

        public void Move(float angle, float speed)
        {
            var quaternion = Quaternion.Euler(0, 0, -angle);
            var normalDistance = (quaternion * Vector3.up).normalized;
            if (angle < 0)
            {
                Rotation = Quaternion.Euler(0, 180, 0);
            }
            else
            {
                Rotation = Quaternion.Euler(0, 0, 0);
            }
        }

        public void MoveToTarget(TransformComponent target)
        {
            Vector3 normalDistance = (target.Position - Position).normalized;
            if (normalDistance.x < 0)
            {
                Rotation = Quaternion.Euler(0, 180, 0);
            }
            else
            {
                Rotation = Quaternion.Euler(0, 0, 0);
            }
            GetParent<Combat>().OrcaComponent.Set2DTarget(target);
        }
        public void SyncTransform()
        {
            Framework.Instance.GetModule<EventD>().D.Fire(ref new SyncTranform(GetParent<Combat>().id, _position, _rotation, _localScale));

        }



    }
}
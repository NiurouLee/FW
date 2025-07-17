using NFramework.Core.ILiveing;
using NFramework.Module.EntityModule;
using Org.BouncyCastle.Asn1;
using RVO;
using System;
using UnityEngine;
using Random = System.Random;
using Vector2 = UnityEngine.Vector2;

namespace NFramework.Module.Combat
{
    public class OrcaComponent : Entity, IFixedUpdateSystem, IAwakeSystem, IDestroySystem
    {
        public Random Random;
        public RVO.Vector2 target;
        public Agent agent;
        public int Id => agent.id_;

        public AttributeComponent AttributeComponent;

        public void FixedUpdate(float deltaTime)
        {
        }

        public void Awake()
        {
            Random = new Random();
        }

        public void Destroy()
        {
            RemoveAgent();
        }

        public Agent AddAgent(Vector2 pos)
        {
            RVO.Vector2 vector = new RVO.Vector2(pos.x, pos.y);
            agent = Simulator.Instance.addAgent(vector);
            agent.maxSpeed_ = AttributeComponent.MoveSpeed.Value;
            agent.radius_ = 1;
            return agent;
        }

        public Agent AddAgent3D(Vector3 pos)
        {
            
        }
    }




}

using Entitas;
using NFramework.Core.ILiveing;
using RVO;
using System;
using UnityEngine;
using Random = System.Random;
using Vector2 = UnityEngine.Vector2;

namespace NFramework.Module.Combat
{
    public class OrcaComponent : Entity, IFixedUpdateSystem
    {
        public Random Random;
        public RVO.Vector2 target;
        public Agent Agent;
        public int Id => Agent.id_;

        public AttributeComponent AttributeComponent;

        public void FixedUpdate(float deltaTime)
        {
        }
    }

}

using NFramework.Module.Event;
using NFramework.Module.EntityModule;
using UnityEngine.UIElements;
using Sirenix.Utilities;
using NFramework.Core.ILiveing;

namespace NFramework.Module.Combat
{
    public class FloatNumeric : Entity, IAwakeSystem<NumericEntity, AttributeType>
    {
        public NumericEntity m_NumericEntity;
        private int m_Type;
        public float BaseValue
        {
            get
            {
                return m_NumericEntity.GetFloat(m_Type * 10 + 1);
            }
            set
            {
                m_NumericEntity.Ste(m_Type * 10 + 1, value);
                Framework.Instance.GetModule<EventD>().D.Fire(new SyncModifyAttribute(Parent.Id, m_Type, 1, value));
            }
        }

        public float Add
        {
            get
            {
                return m_NumericEntity.GetFloat(m_Type * 10 + 2);

            }
            set
            {
                m_NumericEntity.set(m_Type * 10 + 2, value);
                Framework.Instance.GetModule<EventD>().D.Fire(new SyncModifyAttribute(Parent.Id, m_Type, 2, value));
            }
        }

        public float PctAdd
        {
            get
            {
                return m_NumericEntity.GetFloat(m_Type * 10 + 3);
            }
            set
            {
                m_NumericEntity.set(m_Type * 10 + 3, value);
                Framework.Instance.GetModule<EventD>().D.Fire(new SyncModifyAttribute(Parent.Id, m_Type, 3, value));
            }
        }

        public float FinalAdd
        {
            get
            {
                return m_NumericEntity.GetFloat(m_Type * 10 + 4);
            }
            set
            {
                m_NumericEntity.set(m_Type * 10 + 4, value);
                Framework.Instance.GetModule<EventD>().D.Fire(new SyncModifyAttribute(Parent.Id, m_Type, 4, value));
            }
        }

        public float FinalPctAdd
        {
            get
            {
                return m_NumericEntity.GetFloat(m_Type * 10 + 5);
            }
            set
            {
                m_NumericEntity.set(m_Type * 10 + 5, value);
                Framework.Instance.GetModule<EventD>().D.Fire(new SyncModifyAttribute(Parent.Id, m_Type, 5, value));
            }
        }

        public float Value => m_NumericEntity.GetFloat(m_Type);

        public void Awake(NumericEntity a, AttributeType b)
        {
            m_NumericEntity = a;
            m_Type = (int)(AttributeType)b;
        }
    }

}
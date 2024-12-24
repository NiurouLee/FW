using UnityEngine;
using UnityEngine.Animations;

namespace Game
{
    public class UnityConstraintUtil
    {
        public static RotationConstraint Rotation(GameObject gobj, Transform source)
        {
            return Constraint<RotationConstraint>(gobj, source);
        }

        public static PositionConstraint Position(GameObject gobj, Transform source)
        {
            return Constraint<PositionConstraint>(gobj, source);
        }

        public static ParentConstraint Parent(GameObject gobj, Transform source)
        {
            return Constraint<ParentConstraint>(gobj, source);
        }

        private static T Constraint<T>(GameObject gobj, Transform source) where T : Behaviour, IConstraint
        {
            if (gobj == null)
                return default(T);

            T constraint = gobj.GetComponent<T>();
            if (constraint == null)
                constraint = gobj.AddComponent<T>();
            else
                ClearConstraint(constraint);

            var src = new ConstraintSource();
            src.sourceTransform = source;
            src.weight = 1f;

            constraint.AddSource(src);
            constraint.constraintActive = true;
            return constraint;
        }

        public static void ClearConstraint(IConstraint constraint)
        {
            if (constraint == null)
            {
                return;
            }

            int flag = 10;
            while (constraint.sourceCount > 0 && flag > 0)
            {
                flag--;
                constraint.RemoveSource(0);
            }
        }
    }
}

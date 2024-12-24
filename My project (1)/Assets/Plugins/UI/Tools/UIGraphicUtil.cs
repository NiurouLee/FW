using UnityEngine;
using UnityEngine.UI;

namespace Ez.UI
{
    public class UIGraphicUtil
    {
        public static void SetMaterial(Component trans, Material mat)
        {
            if (trans == null)
                return;

            var graphic = trans.GetComponent<Graphic>();
            if (graphic != null)
            {
                graphic.material = mat;
            }
        }

        public static void RemoveMaterial(Component trans)
        {
            SetMaterial(trans, null);
        }

        public static void SetMaterialRecursive(Component transform, Material mat)
        {
            var comps = transform.GetComponentsInChildren<Graphic>(true);
            foreach (var comp in comps)
            {
                comp.material = mat;
            }
        }

        public static void RemoveMaterialRecursive(Component transform)
        {
            SetMaterialRecursive(transform, null);
        }
    }
}
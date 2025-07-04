using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

namespace NFramework.Module.UI.ScrollView
{
    public class SliderComplexItemList : MonoBehaviour
    {
        public List<SliderComplexItem> mItemList;

        public void Init()
        {
            foreach (SliderComplexItem item in mItemList)
            {
                item.Init();
            }
        }
    }   
}

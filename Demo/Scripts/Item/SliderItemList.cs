using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

namespace NFramework.Module.UI.ScrollView
{
    public class SliderItemList : MonoBehaviour
    {
        public List<SliderItem> mItemList;

        public void Init()
        {
            foreach (SliderItem item in mItemList)
            {
                item.Init();
            }
        }
    }   
}
